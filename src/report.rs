use crate::{Counts, FileCount, Report};
use serde_json::{Map, Value, json};
use std::collections::BTreeMap;

const CLOC_URL: &str = "github.com/AlDanial/cloc";
const CLOC_VERSION: &str = "2.10";

pub fn format_number(n: u64) -> String {
    let s = n.to_string();
    let bytes = s.as_bytes();
    let len = bytes.len();
    if len <= 3 {
        return s;
    }
    let mut result = String::with_capacity(len + len / 3);
    for (i, &b) in bytes.iter().enumerate() {
        if i > 0 && (len - i) % 3 == 0 {
            result.push(',');
        }
        result.push(b as char);
    }
    result
}

fn csv_escape(s: &str) -> String {
    if s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r') {
        format!("\"{}\"", s.replace('"', "\"\""))
    } else {
        s.to_string()
    }
}

pub fn aggregate(rows: Vec<FileCount>, by_file: bool) -> Report {
    let mut files = 0u64;
    let mut blank = 0u64;
    let mut comment = 0u64;
    let mut code = 0u64;
    let mut languages: BTreeMap<String, Counts> = BTreeMap::new();

    for row in &rows {
        let f_count = if row.counts.files > 0 {
            row.counts.files
        } else {
            1
        };
        files += f_count;
        blank += row.counts.blank;
        comment += row.counts.comment;
        code += row.counts.code;

        let entry = languages.entry(row.language.clone()).or_default();
        entry.files += f_count;
        entry.blank += row.counts.blank;
        entry.comment += row.counts.comment;
        entry.code += row.counts.code;
    }

    let by_file_vec = if by_file {
        let mut sorted = rows;
        sorted.sort_by(|a, b| {
            b.counts
                .code
                .cmp(&a.counts.code)
                .then_with(|| a.path.cmp(&b.path))
        });
        sorted
    } else {
        Vec::new()
    };

    Report {
        files,
        blank,
        comment,
        code,
        languages,
        by_file: by_file_vec,
    }
}

pub fn generate_text(report: &Report, elapsed_secs: f64) -> String {
    let mut out = String::new();
    let total_lines = report.blank + report.comment + report.code;
    let files_per_sec = if elapsed_secs > 0.0 {
        report.files as f64 / elapsed_secs
    } else {
        0.0
    };
    let lines_per_sec = if elapsed_secs > 0.0 {
        total_lines as f64 / elapsed_secs
    } else {
        0.0
    };

    if !report.by_file.is_empty() {
        let mut max_path_len = "File".len();
        let mut max_blank_len = "blank".len();
        let mut max_comment_len = "comment".len();
        let mut max_code_len = "code".len();

        for fc in &report.by_file {
            max_path_len = max_path_len.max(fc.path.len());
            max_blank_len = max_blank_len.max(format_number(fc.counts.blank).len());
            max_comment_len = max_comment_len.max(format_number(fc.counts.comment).len());
            max_code_len = max_code_len.max(format_number(fc.counts.code).len());
        }
        max_blank_len = max_blank_len.max(format_number(report.blank).len());
        max_comment_len = max_comment_len.max(format_number(report.comment).len());
        max_code_len = max_code_len.max(format_number(report.code).len());

        let path_width = (max_path_len + 1).max(34);
        let blank_width = (max_blank_len + 2).max(15);
        let comment_width = (max_comment_len + 2).max(15);
        let code_width = (max_code_len + 2).max(15);

        let total_width = path_width + blank_width + comment_width + code_width;
        let sep = "-".repeat(total_width);

        out.push_str(&sep);
        out.push('\n');
        out.push_str(&format!(
            "{:<pw$}{:>bw$}{:>cw$}{:>cdw$}\n",
            "File",
            "blank",
            "comment",
            "code",
            pw = path_width,
            bw = blank_width,
            cw = comment_width,
            cdw = code_width,
        ));
        out.push_str(&sep);
        out.push('\n');

        for fc in &report.by_file {
            out.push_str(&format!(
                "{:<pw$}{:>bw$}{:>cw$}{:>cdw$}\n",
                fc.path,
                format_number(fc.counts.blank),
                format_number(fc.counts.comment),
                format_number(fc.counts.code),
                pw = path_width,
                bw = blank_width,
                cw = comment_width,
                cdw = code_width,
            ));
        }

        out.push_str(&sep);
        out.push('\n');
        out.push_str(&format!(
            "{:<pw$}{:>bw$}{:>cw$}{:>cdw$}\n",
            "SUM:",
            format_number(report.blank),
            format_number(report.comment),
            format_number(report.code),
            pw = path_width,
            bw = blank_width,
            cw = comment_width,
            cdw = code_width,
        ));
        out.push_str(&sep);
        out.push('\n');
    } else {
        let mut max_lang_len = "Language".len();
        let mut max_files_len = "files".len();
        let mut max_blank_len = "blank".len();
        let mut max_comment_len = "comment".len();
        let mut max_code_len = "code".len();

        for (lang, counts) in &report.languages {
            max_lang_len = max_lang_len.max(lang.len());
            max_files_len = max_files_len.max(format_number(counts.files).len());
            max_blank_len = max_blank_len.max(format_number(counts.blank).len());
            max_comment_len = max_comment_len.max(format_number(counts.comment).len());
            max_code_len = max_code_len.max(format_number(counts.code).len());
        }
        max_files_len = max_files_len.max(format_number(report.files).len());
        max_blank_len = max_blank_len.max(format_number(report.blank).len());
        max_comment_len = max_comment_len.max(format_number(report.comment).len());
        max_code_len = max_code_len.max(format_number(report.code).len());

        let lang_width = (max_lang_len + 1).max(29);
        let files_width = (max_files_len + 1).max(5);
        let blank_width = (max_blank_len + 2).max(15);
        let comment_width = (max_comment_len + 2).max(15);
        let code_width = (max_code_len + 2).max(15);

        let total_width = lang_width + files_width + blank_width + comment_width + code_width;
        let sep = "-".repeat(total_width);

        out.push_str(&sep);
        out.push('\n');
        out.push_str(&format!(
            "{:<lw$}{:>fw$}{:>bw$}{:>cw$}{:>cdw$}\n",
            "Language",
            "files",
            "blank",
            "comment",
            "code",
            lw = lang_width,
            fw = files_width,
            bw = blank_width,
            cw = comment_width,
            cdw = code_width,
        ));
        out.push_str(&sep);
        out.push('\n');

        let mut sorted_langs: Vec<(&String, &Counts)> = report.languages.iter().collect();
        sorted_langs.sort_by(|a, b| b.1.code.cmp(&a.1.code).then_with(|| a.0.cmp(b.0)));

        for (lang, counts) in sorted_langs {
            out.push_str(&format!(
                "{:<lw$}{:>fw$}{:>bw$}{:>cw$}{:>cdw$}\n",
                lang,
                format_number(counts.files),
                format_number(counts.blank),
                format_number(counts.comment),
                format_number(counts.code),
                lw = lang_width,
                fw = files_width,
                bw = blank_width,
                cw = comment_width,
                cdw = code_width,
            ));
        }

        out.push_str(&sep);
        out.push('\n');
        out.push_str(&format!(
            "{:<lw$}{:>fw$}{:>bw$}{:>cw$}{:>cdw$}\n",
            "SUM:",
            format_number(report.files),
            format_number(report.blank),
            format_number(report.comment),
            format_number(report.code),
            lw = lang_width,
            fw = files_width,
            bw = blank_width,
            cw = comment_width,
            cdw = code_width,
        ));
        out.push_str(&sep);
        out.push('\n');
    }

    out.push_str(&format!(
        "{} files, {} lines in {:.2}s ({:.1} files/s, {:.1} lines/s)\n",
        format_number(report.files),
        format_number(total_lines),
        elapsed_secs,
        files_per_sec,
        lines_per_sec,
    ));

    out
}

pub fn print_text(report: &Report, elapsed_secs: f64) {
    print!("{}", generate_text(report, elapsed_secs));
}

fn build_cloc_json_map(report: &Report, elapsed_secs: f64) -> Map<String, Value> {
    let mut map = Map::new();
    let total_lines = report.blank + report.comment + report.code;
    let files_per_sec = if elapsed_secs > 0.0 {
        report.files as f64 / elapsed_secs
    } else {
        0.0
    };
    let lines_per_sec = if elapsed_secs > 0.0 {
        total_lines as f64 / elapsed_secs
    } else {
        0.0
    };

    map.insert(
        "header".to_string(),
        json!({
            "cloc_url": CLOC_URL,
            "cloc_version": CLOC_VERSION,
            "elapsed_seconds": elapsed_secs,
            "n_files": report.files,
            "n_lines": total_lines,
            "files_per_second": files_per_sec,
            "lines_per_second": lines_per_sec,
        }),
    );

    if !report.by_file.is_empty() {
        for fc in &report.by_file {
            map.insert(
                fc.path.clone(),
                json!({
                    "blank": fc.counts.blank,
                    "comment": fc.counts.comment,
                    "code": fc.counts.code,
                    "language": fc.language,
                }),
            );
        }
    } else {
        for (lang, counts) in &report.languages {
            map.insert(
                lang.clone(),
                json!({
                    "nFiles": counts.files,
                    "blank": counts.blank,
                    "comment": counts.comment,
                    "code": counts.code,
                }),
            );
        }
    }

    map.insert(
        "SUM".to_string(),
        json!({
            "blank": report.blank,
            "comment": report.comment,
            "code": report.code,
            "nFiles": report.files,
        }),
    );

    map
}

pub fn generate_json(report: &Report, elapsed_secs: f64) -> String {
    let map = build_cloc_json_map(report, elapsed_secs);
    serde_json::to_string_pretty(&map).unwrap_or_default()
}

pub fn print_json(report: &Report) {
    print_json_timed(report, 0.0);
}

pub fn print_json_timed(report: &Report, elapsed_secs: f64) {
    println!("{}", generate_json(report, elapsed_secs));
}

pub fn generate_yaml(report: &Report, elapsed_secs: f64) -> String {
    let map = build_cloc_json_map(report, elapsed_secs);
    let yaml = serde_yaml::to_string(&map).unwrap_or_default();
    let mut out = String::from("---\n# github.com/AlDanial/cloc\n");
    if let Some(rest) = yaml.strip_prefix("---\n") {
        out.push_str(rest);
    } else {
        out.push_str(&yaml);
    }
    out
}

pub fn print_yaml(report: &Report) {
    print_yaml_timed(report, 0.0);
}

pub fn print_yaml_timed(report: &Report, elapsed_secs: f64) {
    print!("{}", generate_yaml(report, elapsed_secs));
}

pub fn generate_csv(report: &Report, _elapsed_secs: f64) -> String {
    let mut out = String::new();

    if !report.by_file.is_empty() {
        out.push_str("language,filename,blank,comment,code\n");
        for fc in &report.by_file {
            out.push_str(&format!(
                "{},{},{},{},{}\n",
                csv_escape(&fc.language),
                csv_escape(&fc.path),
                fc.counts.blank,
                fc.counts.comment,
                fc.counts.code,
            ));
        }
        out.push_str(&format!(
            "SUM,,{},{},{}\n",
            report.blank, report.comment, report.code,
        ));
    } else {
        out.push_str("files,language,blank,comment,code\n");
        let mut sorted_langs: Vec<(&String, &Counts)> = report.languages.iter().collect();
        sorted_langs.sort_by(|a, b| b.1.code.cmp(&a.1.code).then_with(|| a.0.cmp(b.0)));

        for (lang, counts) in sorted_langs {
            out.push_str(&format!(
                "{},{},{},{},{}\n",
                counts.files,
                csv_escape(lang),
                counts.blank,
                counts.comment,
                counts.code,
            ));
        }
        out.push_str(&format!(
            "{},SUM,{},{},{}\n",
            report.files, report.blank, report.comment, report.code,
        ));
    }

    out
}

pub fn print_csv(report: &Report) {
    print_csv_timed(report, 0.0);
}

pub fn print_csv_timed(report: &Report, elapsed_secs: f64) {
    print!("{}", generate_csv(report, elapsed_secs));
}

pub fn print_report(report: &Report, format: crate::args::Format, elapsed_secs: f64) {
    match format {
        crate::args::Format::Text => print_text(report, elapsed_secs),
        crate::args::Format::Json => print_json_timed(report, elapsed_secs),
        crate::args::Format::Yaml => print_yaml_timed(report, elapsed_secs),
        crate::args::Format::Csv => print_csv_timed(report, elapsed_secs),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_file_counts() -> Vec<FileCount> {
        vec![
            FileCount {
                path: "src/lib.rs".to_string(),
                language: "Rust".to_string(),
                counts: Counts {
                    files: 1,
                    blank: 6,
                    comment: 0,
                    code: 45,
                },
            },
            FileCount {
                path: "src/main.rs".to_string(),
                language: "Rust".to_string(),
                counts: Counts {
                    files: 1,
                    blank: 0,
                    comment: 0,
                    code: 3,
                },
            },
            FileCount {
                path: "test.py".to_string(),
                language: "Python".to_string(),
                counts: Counts {
                    files: 1,
                    blank: 2,
                    comment: 1,
                    code: 10,
                },
            },
        ]
    }

    #[test]
    fn test_format_number() {
        assert_eq!(format_number(0), "0");
        assert_eq!(format_number(9), "9");
        assert_eq!(format_number(999), "999");
        assert_eq!(format_number(1000), "1,000");
        assert_eq!(format_number(12345), "12,345");
        assert_eq!(format_number(1000000), "1,000,000");
        assert_eq!(format_number(1234567890), "1,234,567,890");
    }

    #[test]
    fn test_aggregate_by_language() {
        let rows = sample_file_counts();
        let report = aggregate(rows, false);

        assert_eq!(report.files, 3);
        assert_eq!(report.blank, 8);
        assert_eq!(report.comment, 1);
        assert_eq!(report.code, 58);
        assert_eq!(report.languages.len(), 2);
        assert!(report.by_file.is_empty());

        let rust = &report.languages["Rust"];
        assert_eq!(rust.files, 2);
        assert_eq!(rust.blank, 6);
        assert_eq!(rust.comment, 0);
        assert_eq!(rust.code, 48);

        let py = &report.languages["Python"];
        assert_eq!(py.files, 1);
        assert_eq!(py.blank, 2);
        assert_eq!(py.comment, 1);
        assert_eq!(py.code, 10);
    }

    #[test]
    fn test_aggregate_by_file() {
        let rows = sample_file_counts();
        let report = aggregate(rows, true);

        assert_eq!(report.files, 3);
        assert_eq!(report.by_file.len(), 3);
        assert_eq!(report.by_file[0].path, "src/lib.rs");
        assert_eq!(report.by_file[1].path, "test.py");
        assert_eq!(report.by_file[2].path, "src/main.rs");
    }

    #[test]
    fn test_generate_text_table() {
        let rows = sample_file_counts();
        let report = aggregate(rows, false);
        let text = generate_text(&report, 0.05);

        assert!(text.contains("Language"));
        assert!(text.contains("files"));
        assert!(text.contains("blank"));
        assert!(text.contains("comment"));
        assert!(text.contains("code"));
        assert!(text.contains("Rust"));
        assert!(text.contains("Python"));
        assert!(text.contains("SUM:"));
        assert!(text.contains("3 files, 67 lines in 0.05s"));
    }

    #[test]
    fn test_generate_json() {
        let rows = sample_file_counts();
        let report = aggregate(rows, false);
        let json_str = generate_json(&report, 0.05);

        let val: serde_json::Value = serde_json::from_str(&json_str).unwrap();
        assert_eq!(val["header"]["n_files"], 3);
        assert_eq!(val["header"]["n_lines"], 67);
        assert_eq!(val["Rust"]["code"], 48);
        assert_eq!(val["Python"]["code"], 10);
        assert_eq!(val["SUM"]["code"], 58);
    }

    #[test]
    fn test_generate_yaml() {
        let rows = sample_file_counts();
        let report = aggregate(rows, false);
        let yaml_str = generate_yaml(&report, 0.05);

        assert!(yaml_str.starts_with("---\n# github.com/AlDanial/cloc\n"));
        let val: serde_yaml::Value = serde_yaml::from_str(&yaml_str).unwrap();
        assert_eq!(val["header"]["n_files"].as_u64().unwrap(), 3);
        assert_eq!(val["Rust"]["code"].as_u64().unwrap(), 48);
        assert_eq!(val["SUM"]["code"].as_u64().unwrap(), 58);
    }

    #[test]
    fn test_generate_csv() {
        let rows = sample_file_counts();
        let report = aggregate(rows, false);
        let csv_str = generate_csv(&report, 0.05);

        let lines: Vec<&str> = csv_str.lines().collect();
        assert_eq!(lines[0], "files,language,blank,comment,code");
        assert_eq!(lines[1], "2,Rust,6,0,48");
        assert_eq!(lines[2], "1,Python,2,1,10");
        assert_eq!(lines[3], "3,SUM,8,1,58");
    }

    #[test]
    fn test_generate_csv_by_file() {
        let rows = sample_file_counts();
        let report = aggregate(rows, true);
        let csv_str = generate_csv(&report, 0.05);

        let lines: Vec<&str> = csv_str.lines().collect();
        assert_eq!(lines[0], "language,filename,blank,comment,code");
        assert_eq!(lines[1], "Rust,src/lib.rs,6,0,45");
        assert_eq!(lines[2], "Python,test.py,2,1,10");
        assert_eq!(lines[3], "Rust,src/main.rs,0,0,3");
        assert_eq!(lines[4], "SUM,,8,1,58");
    }
}
