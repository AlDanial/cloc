use rayon::prelude::*;
use std::collections::{HashMap, HashSet};
use std::fs;
use std::ops::Deref;
use std::path::{Path, PathBuf};
use xxhash_rust::xxh3::xxh3_64;

pub const MMAP_THRESHOLD: u64 = 64 * 1024;

#[derive(Debug)]
pub enum FileData {
    Mmap(memmap2::Mmap),
    Buffer(Vec<u8>),
}

impl std::ops::Deref for FileData {
    type Target = [u8];

    #[inline]
    fn deref(&self) -> &[u8] {
        match self {
            FileData::Mmap(mmap) => mmap,
            FileData::Buffer(buf) => buf,
        }
    }
}

impl AsRef<[u8]> for FileData {
    #[inline]
    fn as_ref(&self) -> &[u8] {
        self.deref()
    }
}

pub fn read_file(path: &Path) -> std::io::Result<FileData> {
    let file = fs::File::open(path)?;
    let meta = file.metadata()?;
    let size = meta.len();

    if size == 0 {
        return Ok(FileData::Buffer(Vec::new()));
    }

    if size > MMAP_THRESHOLD {
        if let Ok(mmap) = unsafe { memmap2::Mmap::map(&file) } {
            return Ok(FileData::Mmap(mmap));
        }
    }

    let mut buf = Vec::with_capacity(size as usize);
    let mut reader = std::io::BufReader::new(file);
    std::io::Read::read_to_end(&mut reader, &mut buf)?;
    Ok(FileData::Buffer(buf))
}

pub fn hash_file(path: &Path) -> std::io::Result<u64> {
    let meta = fs::metadata(path)?;
    hash_file_with_size(path, meta.len())
}

pub fn hash_file_with_size(path: &Path, size: u64) -> std::io::Result<u64> {
    if size == 0 {
        return Ok(xxh3_64(b""));
    }
    let data = read_file(path)?;
    Ok(xxh3_64(&data))
}

pub fn deduplicate(files: Vec<PathBuf>) -> Vec<PathBuf> {
    if files.is_empty() {
        return Vec::new();
    }

    let file_sizes: Vec<(PathBuf, u64)> = files
        .into_par_iter()
        .filter_map(|path| match fs::metadata(&path) {
            Ok(meta) if meta.is_file() => Some((path, meta.len())),
            _ => None,
        })
        .collect();

    let mut size_buckets: HashMap<u64, Vec<PathBuf>> = HashMap::new();
    for (path, size) in file_sizes {
        size_buckets.entry(size).or_default().push(path);
    }

    let mut unique_files = Vec::new();
    let mut non_zero_collisions: Vec<(PathBuf, u64)> = Vec::new();

    for (size, mut paths) in size_buckets {
        if paths.len() == 1 {
            unique_files.push(paths.pop().unwrap());
        } else {
            paths.sort();
            if size == 0 {
                if let Some(first) = paths.into_iter().next() {
                    unique_files.push(first);
                }
            } else {
                for path in paths {
                    non_zero_collisions.push((path, size));
                }
            }
        }
    }

    if !non_zero_collisions.is_empty() {
        let hashed: Vec<(PathBuf, u64, Option<u64>)> = non_zero_collisions
            .into_par_iter()
            .map(|(path, size)| {
                let hash = hash_file_with_size(&path, size).ok();
                (path, size, hash)
            })
            .collect();

        let mut seen: HashSet<(u64, u64)> = HashSet::new();
        for (path, size, maybe_hash) in hashed {
            if let Some(hash) = maybe_hash {
                if seen.insert((size, hash)) {
                    unique_files.push(path);
                }
            }
        }
    }

    unique_files.sort();
    unique_files
}

pub fn deduplicate_slice(files: &[PathBuf]) -> Vec<PathBuf> {
    deduplicate(files.to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;

    fn create_temp_file(dir: &Path, name: &str, content: &[u8]) -> PathBuf {
        let path = dir.join(name);
        let mut f = fs::File::create(&path).unwrap();
        f.write_all(content).unwrap();
        path
    }

    #[test]
    fn test_deduplicate_empty() {
        let result = deduplicate(vec![]);
        assert!(result.is_empty());
    }

    #[test]
    fn test_deduplicate_single_file() {
        let temp_dir = std::env::temp_dir().join("dedup_test_single");
        let _ = fs::create_dir_all(&temp_dir);
        let f1 = create_temp_file(&temp_dir, "file1.txt", b"hello world");
        let result = deduplicate(vec![f1.clone()]);
        assert_eq!(result, vec![f1]);
        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_deduplicate_unique_sizes_no_hash() {
        let temp_dir = std::env::temp_dir().join("dedup_test_unique_sizes");
        let _ = fs::create_dir_all(&temp_dir);
        let f1 = create_temp_file(&temp_dir, "file1.txt", b"a");
        let f2 = create_temp_file(&temp_dir, "file2.txt", b"bb");
        let f3 = create_temp_file(&temp_dir, "file3.txt", b"ccc");

        let mut expected = vec![f1.clone(), f2.clone(), f3.clone()];
        expected.sort();

        let result = deduplicate(vec![f1, f2, f3]);
        assert_eq!(result, expected);
        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_deduplicate_colliding_size_different_content() {
        let temp_dir = std::env::temp_dir().join("dedup_test_colliding_diff");
        let _ = fs::create_dir_all(&temp_dir);
        let f1 = create_temp_file(&temp_dir, "file1.txt", b"hello");
        let f2 = create_temp_file(&temp_dir, "file2.txt", b"world");

        let mut expected = vec![f1.clone(), f2.clone()];
        expected.sort();

        let result = deduplicate(vec![f1, f2]);
        assert_eq!(result.len(), 2);
        assert_eq!(result, expected);
        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_deduplicate_colliding_size_identical_content() {
        let temp_dir = std::env::temp_dir().join("dedup_test_colliding_same");
        let _ = fs::create_dir_all(&temp_dir);
        let f1 = create_temp_file(&temp_dir, "file1.txt", b"same content here!");
        let f2 = create_temp_file(&temp_dir, "file2.txt", b"same content here!");
        let f3 = create_temp_file(&temp_dir, "file3.txt", b"same content here!");

        let result = deduplicate(vec![f3, f1.clone(), f2]);
        assert_eq!(result.len(), 1);
        assert_eq!(result[0], f1);
        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_deduplicate_empty_files() {
        let temp_dir = std::env::temp_dir().join("dedup_test_empty_files");
        let _ = fs::create_dir_all(&temp_dir);
        let f1 = create_temp_file(&temp_dir, "empty1.txt", b"");
        let f2 = create_temp_file(&temp_dir, "empty2.txt", b"");

        let result = deduplicate(vec![f2, f1.clone()]);
        assert_eq!(result.len(), 1);
        assert_eq!(result[0], f1);
        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_deduplicate_large_files_mmap() {
        let temp_dir = std::env::temp_dir().join("dedup_test_large_files");
        let _ = fs::create_dir_all(&temp_dir);
        let large_content = vec![b'x'; 70 * 1024];
        let f1 = create_temp_file(&temp_dir, "large1.bin", &large_content);
        let f2 = create_temp_file(&temp_dir, "large2.bin", &large_content);

        let mut diff_content = large_content.clone();
        diff_content[70 * 1024 - 1] = b'y';
        let f3 = create_temp_file(&temp_dir, "large3.bin", &diff_content);

        let result = deduplicate(vec![f1.clone(), f2, f3.clone()]);
        assert_eq!(result.len(), 2);
        let mut expected = vec![f1, f3];
        expected.sort();
        assert_eq!(result, expected);
        let _ = fs::remove_dir_all(&temp_dir);
    }
}
