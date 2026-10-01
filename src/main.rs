use clap::Parser;
use rayon::prelude::*;
use rscloc::FileCount;
use rscloc::args::Args;
use rscloc::report;
use std::collections::HashSet;
use std::time::Instant;

fn main() -> anyhow::Result<()> {
    let args = Args::parse();

    if let Some(jobs) = args.jobs {
        let _ = rayon::ThreadPoolBuilder::new()
            .num_threads(jobs)
            .build_global();
    }

    let start = Instant::now();

    let excluded_dirs: HashSet<String> = args
        .excluded_dirs()
        .into_iter()
        .map(|s| s.to_string())
        .collect();

    let included_exts: Option<HashSet<String>> = args
        .included_extensions()
        .map(|exts| exts.into_iter().collect());

    let excluded_exts: Option<HashSet<String>> = args
        .excluded_extensions()
        .map(|exts| exts.into_iter().collect());

    let files = rscloc::walker::discover(
        &args.paths,
        args.no_recursion,
        &excluded_dirs,
        included_exts.as_ref(),
        excluded_exts.as_ref(),
    )?;

    let files = if args.no_dedup {
        files
    } else {
        rscloc::dedup::deduplicate(files)
    };

    let file_counts: Vec<FileCount> = files
        .into_par_iter()
        .filter_map(|path| {
            let data = rscloc::dedup::read_file(&path).ok()?;
            let (language, syntax) = rscloc::classifier::classify(&path, &data);
            if language == "(unknown)" || language == "Unknown" {
                return None;
            }
            let counts = rscloc::counter::count_lines(&data, syntax.into());
            Some(FileCount {
                path: path.to_string_lossy().into_owned(),
                language: language.to_string(),
                counts,
            })
        })
        .collect();

    let elapsed = start.elapsed().as_secs_f64();
    let rep = report::aggregate(file_counts, args.by_file);
    report::print_report(&rep, args.format, elapsed);

    Ok(())
}
