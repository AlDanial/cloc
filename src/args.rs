use clap::{Parser, ValueEnum};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, ValueEnum, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Format {
    #[default]
    Text,
    Json,
    Yaml,
    Csv,
}

impl std::fmt::Display for Format {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Format::Text => write!(f, "text"),
            Format::Json => write!(f, "json"),
            Format::Yaml => write!(f, "yaml"),
            Format::Csv => write!(f, "csv"),
        }
    }
}

#[derive(Parser, Debug, Clone)]
#[command(
    name = "rscloc",
    author = "Aditya Gupta (https://github.com/aditya-gupta-dev)",
    version = concat!(
        env!("CARGO_PKG_VERSION"),
        "\nCreator: Aditya Gupta (https://github.com/aditya-gupta-dev)\nRepository: https://github.com/aditya-gupta-dev/cloc-clone"
    ),
    about = "Count Lines of Code",
    long_about = "A high-performance line counter and statistics tool rewritten in Rust.\n\nCreator: Aditya Gupta\nGitHub:  https://github.com/aditya-gupta-dev"
)]
pub struct Args {
    #[arg(default_value = ".")]
    pub paths: Vec<PathBuf>,

    #[arg(short = 'j', long = "jobs")]
    pub jobs: Option<usize>,

    #[arg(long = "format", value_enum, default_value_t = Format::Text)]
    pub format: Format,

    #[arg(long = "by-file")]
    pub by_file: bool,

    #[arg(long = "no-recursion")]
    pub no_recursion: bool,

    #[arg(
        long = "exclude-dir",
        default_value = ".git,node_modules,target,vendor,.svn,.hg,cloc-map"
    )]
    pub exclude_dir: String,

    #[arg(long = "include-ext")]
    pub include_ext: Option<String>,

    #[arg(long = "exclude-ext")]
    pub exclude_ext: Option<String>,

    #[arg(long = "no-dedup")]
    pub no_dedup: bool,
}

impl Args {
    pub fn excluded_dirs(&self) -> Vec<&str> {
        self.exclude_dir
            .split(',')
            .map(|s| s.trim())
            .filter(|s| !s.is_empty())
            .collect()
    }

    pub fn included_extensions(&self) -> Option<Vec<String>> {
        self.include_ext.as_ref().map(|exts| {
            exts.split(',')
                .map(|s| s.trim().trim_start_matches('.').to_ascii_lowercase())
                .filter(|s| !s.is_empty())
                .collect()
        })
    }

    pub fn excluded_extensions(&self) -> Option<Vec<String>> {
        self.exclude_ext.as_ref().map(|exts| {
            exts.split(',')
                .map(|s| s.trim().trim_start_matches('.').to_ascii_lowercase())
                .filter(|s| !s.is_empty())
                .collect()
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_args() {
        let args = Args::parse_from(["rscloc"]);
        assert_eq!(args.paths, vec![PathBuf::from(".")]);
        assert_eq!(args.jobs, None);
        assert_eq!(args.format, Format::Text);
        assert!(!args.by_file);
        assert!(!args.no_recursion);
        assert!(!args.no_dedup);
        assert!(args.exclude_dir.contains(".git"));
        assert_eq!(args.include_ext, None);
        assert_eq!(args.exclude_ext, None);
    }

    #[test]
    fn test_custom_paths_and_flags() {
        let args = Args::parse_from([
            "rscloc",
            "src",
            "tests",
            "-j",
            "8",
            "--format",
            "json",
            "--by-file",
            "--no-recursion",
            "--no-dedup",
            "--include-ext",
            "rs,c,h",
            "--exclude-ext",
            "min.js",
            "--exclude-dir",
            "build,temp",
        ]);
        assert_eq!(
            args.paths,
            vec![PathBuf::from("src"), PathBuf::from("tests")]
        );
        assert_eq!(args.jobs, Some(8));
        assert_eq!(args.format, Format::Json);
        assert!(args.by_file);
        assert!(args.no_recursion);
        assert!(args.no_dedup);
        assert_eq!(args.excluded_dirs(), vec!["build", "temp"]);
        assert_eq!(
            args.included_extensions(),
            Some(vec!["rs".into(), "c".into(), "h".into()])
        );
        assert_eq!(args.excluded_extensions(), Some(vec!["min.js".into()]));
    }

    #[test]
    fn test_format_values() {
        let text_args = Args::parse_from(["rscloc", "--format", "text"]);
        assert_eq!(text_args.format, Format::Text);

        let json_args = Args::parse_from(["rscloc", "--format", "json"]);
        assert_eq!(json_args.format, Format::Json);

        let yaml_args = Args::parse_from(["rscloc", "--format", "yaml"]);
        assert_eq!(yaml_args.format, Format::Yaml);

        let csv_args = Args::parse_from(["rscloc", "--format", "csv"]);
        assert_eq!(csv_args.format, Format::Csv);
    }
}
