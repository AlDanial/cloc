use serde::Serialize;
use std::collections::BTreeMap;

pub mod args;
pub mod classifier;
pub mod counter;
pub mod dedup;
pub mod report;
pub mod walker;

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize)]
pub struct Counts {
    pub files: u64,
    pub blank: u64,
    pub comment: u64,
    pub code: u64,
}

impl Counts {
    #[inline(always)]
    pub fn add(&mut self, other: &Self) {
        self.files += other.files;
        self.blank += other.blank;
        self.comment += other.comment;
        self.code += other.code;
    }

    #[inline(always)]
    pub fn total_lines(&self) -> u64 {
        self.blank + self.comment + self.code
    }
}

#[derive(Clone, Debug, Serialize)]
pub struct FileCount {
    pub path: String,
    pub language: String,
    #[serde(flatten)]
    pub counts: Counts,
}

#[derive(Clone, Debug, Serialize)]
pub struct Report {
    pub files: u64,
    pub blank: u64,
    pub comment: u64,
    pub code: u64,
    pub languages: BTreeMap<String, Counts>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub by_file: Vec<FileCount>,
}
