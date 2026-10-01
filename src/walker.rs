use rayon::prelude::*;
use std::collections::HashSet;
use std::path::{Path, PathBuf};

pub const BINARY_CHECK_SIZE: usize = 8192;

#[derive(Debug, Clone)]
pub struct WalkOptions<'a> {
    pub paths: &'a [PathBuf],
    pub no_recursion: bool,
    pub excluded_dirs: &'a HashSet<String>,
    pub included_exts: Option<&'a HashSet<String>>,
    pub excluded_exts: Option<&'a HashSet<String>>,
    pub skip_hidden: bool,
}

impl<'a> Default for WalkOptions<'a> {
    fn default() -> Self {
        static EMPTY_DIRS: std::sync::LazyLock<HashSet<String>> =
            std::sync::LazyLock::new(HashSet::new);
        Self {
            paths: &[],
            no_recursion: false,
            excluded_dirs: &EMPTY_DIRS,
            included_exts: None,
            excluded_exts: None,
            skip_hidden: true,
        }
    }
}

pub fn is_binary(path: &Path) -> std::io::Result<bool> {
    let mut file = std::fs::File::open(path)?;
    let mut buf = [0u8; BINARY_CHECK_SIZE];
    let n = std::io::Read::read(&mut file, &mut buf)?;
    Ok(is_binary_bytes(&buf[..n]))
}

#[inline(always)]
pub fn is_binary_bytes(buf: &[u8]) -> bool {
    memchr::memchr(0, buf).is_some()
}

pub fn is_dir_excluded(entry: &ignore::DirEntry, excluded_dirs: &HashSet<String>) -> bool {
    if excluded_dirs.is_empty() {
        return false;
    }

    if let Some(name) = entry.file_name().to_str() {
        if excluded_dirs.contains(name) {
            return true;
        }
    }

    let path = entry.path();
    let path_str = path.to_string_lossy();
    for ex in excluded_dirs {
        if ex.contains('/') || ex.contains('\\') {
            let norm_ex = ex.replace('\\', "/");
            let norm_path = path_str.replace('\\', "/");
            if norm_path.ends_with(&norm_ex)
                || norm_path.contains(&format!("/{}/", norm_ex))
                || norm_path == norm_ex
            {
                return true;
            }
        }
    }

    false
}

fn matches_ext_set(path: &Path, set: &HashSet<String>) -> bool {
    if let Some(ext) = path.extension().and_then(|s| s.to_str()) {
        let ext_lower = ext.to_ascii_lowercase();
        let with_dot = format!(".{}", ext);
        let with_dot_lower = format!(".{}", ext_lower);
        set.contains(ext)
            || set.contains(&ext_lower)
            || set.contains(&with_dot)
            || set.contains(&with_dot_lower)
    } else {
        set.contains("") || set.contains("(no extension)")
    }
}

#[inline]
pub fn is_ext_allowed(
    path: &Path,
    included_exts: Option<&HashSet<String>>,
    excluded_exts: Option<&HashSet<String>>,
) -> bool {
    if let Some(excluded) = excluded_exts {
        if matches_ext_set(path, excluded) {
            return false;
        }
    }
    if let Some(included) = included_exts {
        if !matches_ext_set(path, included) {
            return false;
        }
    }
    true
}

pub fn discover(
    paths: &[PathBuf],
    no_recursion: bool,
    excluded_dirs: &HashSet<String>,
    included_exts: Option<&HashSet<String>>,
    excluded_exts: Option<&HashSet<String>>,
) -> anyhow::Result<Vec<PathBuf>> {
    let options = WalkOptions {
        paths,
        no_recursion,
        excluded_dirs,
        included_exts,
        excluded_exts,
        skip_hidden: true,
    };
    discover_with_options(&options)
}

pub fn discover_with_options(options: &WalkOptions) -> anyhow::Result<Vec<PathBuf>> {
    if options.paths.is_empty() {
        return Ok(Vec::new());
    }

    let mut builder = ignore::WalkBuilder::new(&options.paths[0]);
    for path in &options.paths[1..] {
        builder.add(path);
    }

    builder.hidden(options.skip_hidden);

    if options.no_recursion {
        builder.max_depth(Some(1));
    } else {
        builder.max_depth(None);
    }

    if !options.excluded_dirs.is_empty() {
        let excluded_dirs = options.excluded_dirs.clone();
        builder.filter_entry(move |entry| {
            if entry.file_type().map_or(false, |ft| ft.is_dir()) {
                if is_dir_excluded(entry, &excluded_dirs) {
                    return false;
                }
            }
            true
        });
    }

    let walker = builder.build_parallel();
    let (tx, rx) = std::sync::mpsc::channel();

    walker.run(|| {
        let tx = tx.clone();
        Box::new(move |result| {
            if let Ok(entry) = result {
                if entry.file_type().map_or(false, |ft| ft.is_file()) {
                    let _ = tx.send(entry.into_path());
                }
            }
            ignore::WalkState::Continue
        })
    });
    drop(tx);

    let candidate_paths: Vec<PathBuf> = rx.into_iter().collect();

    let included_exts = options.included_exts;
    let excluded_exts = options.excluded_exts;

    let mut files: Vec<PathBuf> = candidate_paths
        .into_par_iter()
        .filter(|path| {
            if !is_ext_allowed(path, included_exts, excluded_exts) {
                return false;
            }
            match is_binary(path) {
                Ok(is_bin) => !is_bin,
                Err(_) => false,
            }
        })
        .collect();

    files.sort();
    Ok(files)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::io::Write;

    fn create_test_file(dir: &Path, rel_path: &str, content: &[u8]) -> PathBuf {
        let path = dir.join(rel_path);
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).unwrap();
        }
        let mut f = fs::File::create(&path).unwrap();
        f.write_all(content).unwrap();
        path
    }

    #[test]
    fn test_is_binary() {
        let temp_dir = std::env::temp_dir().join("walker_test_binary");
        let _ = fs::create_dir_all(&temp_dir);

        let text_path = create_test_file(&temp_dir, "test.txt", b"hello world\nline 2\n");
        assert!(!is_binary(&text_path).unwrap());

        let bin_path = create_test_file(&temp_dir, "test.bin", b"hello\0world");
        assert!(is_binary(&bin_path).unwrap());

        let empty_path = create_test_file(&temp_dir, "empty.txt", b"");
        assert!(!is_binary(&empty_path).unwrap());

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_discover_basic() {
        let temp_dir = std::env::temp_dir().join("walker_test_basic");
        let _ = fs::create_dir_all(&temp_dir);

        let f1 = create_test_file(&temp_dir, "a.rs", b"fn main() {}");
        let f2 = create_test_file(&temp_dir, "b.py", b"print(1)");
        let _bin = create_test_file(&temp_dir, "c.bin", b"\0\0\0binary");

        let empty_set = HashSet::new();
        let paths = vec![temp_dir.clone()];
        let found = discover(&paths, false, &empty_set, None, None).unwrap();

        assert_eq!(found, vec![f1, f2]);
        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_discover_excluded_dirs() {
        let temp_dir = std::env::temp_dir().join("walker_test_exclude_dir");
        let _ = fs::create_dir_all(&temp_dir);

        let f1 = create_test_file(&temp_dir, "src/main.rs", b"code");
        let _f2 = create_test_file(&temp_dir, "target/debug/build.rs", b"code");
        let _f3 = create_test_file(&temp_dir, "node_modules/lib/index.js", b"code");

        let mut excluded = HashSet::new();
        excluded.insert("target".to_string());
        excluded.insert("node_modules".to_string());

        let paths = vec![temp_dir.clone()];
        let found = discover(&paths, false, &excluded, None, None).unwrap();

        assert_eq!(found, vec![f1]);
        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_discover_no_recursion() {
        let temp_dir = std::env::temp_dir().join("walker_test_no_recursion");
        let _ = fs::create_dir_all(&temp_dir);

        let f1 = create_test_file(&temp_dir, "root.rs", b"code");
        let _f2 = create_test_file(&temp_dir, "nested/sub.rs", b"code");

        let empty_set = HashSet::new();
        let paths = vec![temp_dir.clone()];
        let found = discover(&paths, true, &empty_set, None, None).unwrap();

        assert_eq!(found, vec![f1]);
        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_discover_extension_filters() {
        let temp_dir = std::env::temp_dir().join("walker_test_exts");
        let _ = fs::create_dir_all(&temp_dir);

        let f_rs = create_test_file(&temp_dir, "code.rs", b"code");
        let f_py = create_test_file(&temp_dir, "code.py", b"code");
        let _f_js = create_test_file(&temp_dir, "code.js", b"code");

        let empty_set = HashSet::new();
        let mut included = HashSet::new();
        included.insert("rs".to_string());
        included.insert(".py".to_string());

        let paths = vec![temp_dir.clone()];
        let found = discover(&paths, false, &empty_set, Some(&included), None).unwrap();

        assert_eq!(found, vec![f_py, f_rs.clone()]);

        let mut excluded = HashSet::new();
        excluded.insert("py".to_string());

        let found_ex =
            discover(&paths, false, &empty_set, Some(&included), Some(&excluded)).unwrap();
        assert_eq!(found_ex, vec![f_rs]);

        let _ = fs::remove_dir_all(&temp_dir);
    }
}
