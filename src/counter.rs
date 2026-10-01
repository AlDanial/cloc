use crate::Counts;
use memchr::{memchr, memchr2};

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct CommentSyntax {
    pub line_comments: &'static [&'static str],
    pub block_comments: &'static [(&'static str, &'static str)],
    pub nested_comments: bool,
}

impl CommentSyntax {
    pub const fn new(
        line_comments: &'static [&'static str],
        block_comments: &'static [(&'static str, &'static str)],
    ) -> Self {
        Self {
            line_comments,
            block_comments,
            nested_comments: false,
        }
    }

    pub const fn with_nested(
        line_comments: &'static [&'static str],
        block_comments: &'static [(&'static str, &'static str)],
    ) -> Self {
        Self {
            line_comments,
            block_comments,
            nested_comments: true,
        }
    }

    pub const C: Self = Self {
        line_comments: &["//"],
        block_comments: &[("/*", "*/")],
        nested_comments: false,
    };

    pub const RUST: Self = Self {
        line_comments: &["//"],
        block_comments: &[("/*", "*/")],
        nested_comments: true,
    };

    pub const PYTHON: Self = Self {
        line_comments: &["#"],
        block_comments: &[("\"\"\"", "\"\"\""), ("'''", "'''")],
        nested_comments: false,
    };

    pub const SHELL: Self = Self {
        line_comments: &["#"],
        block_comments: &[],
        nested_comments: false,
    };

    pub const HTML: Self = Self {
        line_comments: &[],
        block_comments: &[("<!--", "-->")],
        nested_comments: false,
    };

    pub const SQL: Self = Self {
        line_comments: &["--"],
        block_comments: &[("/*", "*/")],
        nested_comments: false,
    };

    pub const HASKELL: Self = Self {
        line_comments: &["--"],
        block_comments: &[("{-", "-}")],
        nested_comments: true,
    };

    pub const LUA: Self = Self {
        line_comments: &["--"],
        block_comments: &[("--[[", "]]")],
        nested_comments: false,
    };

    pub const PLAIN: Self = Self {
        line_comments: &[],
        block_comments: &[],
        nested_comments: false,
    };
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum QuoteState {
    None,
    DoubleQuote,
    Backtick,
    TripleDoubleQuote,
    TripleSingleQuote,
    RawString(u8),
}

#[inline(always)]
fn is_blank(line: &[u8]) -> bool {
    line.iter().all(|&b| matches!(b, b' ' | b'\t' | b'\r'))
}

pub fn count_lines(data: &[u8], syntax: CommentSyntax) -> Counts {
    let mut counts = Counts {
        files: if data.is_empty() { 0 } else { 1 },
        blank: 0,
        comment: 0,
        code: 0,
    };

    if data.is_empty() {
        return counts;
    }

    if syntax.line_comments.is_empty() && syntax.block_comments.is_empty() {
        let mut cursor = 0;
        let len = data.len();
        while cursor < len {
            let (line, next_cursor) = match memchr(b'\n', &data[cursor..]) {
                Some(pos) => {
                    let end = cursor + pos;
                    (&data[cursor..end], end + 1)
                }
                None => (&data[cursor..], len),
            };
            cursor = next_cursor;

            let line = if let Some(&b'\r') = line.last() {
                &line[..line.len() - 1]
            } else {
                line
            };

            if is_blank(line) {
                counts.blank += 1;
            } else {
                counts.code += 1;
            }
        }
        return counts;
    }

    let mut cursor = 0;
    let len = data.len();
    let mut block_depth: usize = 0;
    let mut active_block_start: &[u8] = b"";
    let mut active_block_end: &[u8] = b"";
    let mut quote_state = QuoteState::None;

    while cursor < len {
        let (line, next_cursor) = match memchr(b'\n', &data[cursor..]) {
            Some(pos) => {
                let end = cursor + pos;
                (&data[cursor..end], end + 1)
            }
            None => (&data[cursor..], len),
        };
        cursor = next_cursor;

        let line = if let Some(&b'\r') = line.last() {
            &line[..line.len() - 1]
        } else {
            line
        };

        if is_blank(line) {
            counts.blank += 1;
            continue;
        }

        let mut has_code = false;
        let mut has_comment = false;
        let mut i = 0;
        let line_len = line.len();

        while i < line_len {
            if quote_state != QuoteState::None {
                has_code = true;
                match quote_state {
                    QuoteState::DoubleQuote => {
                        while i < line_len {
                            match memchr2(b'\\', b'"', &line[i..]) {
                                Some(pos) => {
                                    let p = i + pos;
                                    if line[p] == b'\\' {
                                        i = p + 2;
                                    } else {
                                        quote_state = QuoteState::None;
                                        i = p + 1;
                                        break;
                                    }
                                }
                                None => {
                                    i = line_len;
                                    break;
                                }
                            }
                        }
                    }
                    QuoteState::Backtick => {
                        while i < line_len {
                            match memchr2(b'\\', b'`', &line[i..]) {
                                Some(pos) => {
                                    let p = i + pos;
                                    if line[p] == b'\\' {
                                        i = p + 2;
                                    } else {
                                        quote_state = QuoteState::None;
                                        i = p + 1;
                                        break;
                                    }
                                }
                                None => {
                                    i = line_len;
                                    break;
                                }
                            }
                        }
                    }
                    QuoteState::TripleDoubleQuote => {
                        while i < line_len {
                            match memchr(b'"', &line[i..]) {
                                Some(pos) => {
                                    let p = i + pos;
                                    if line[p..].starts_with(b"\"\"\"") {
                                        quote_state = QuoteState::None;
                                        i = p + 3;
                                        break;
                                    } else {
                                        i = p + 1;
                                    }
                                }
                                None => {
                                    i = line_len;
                                    break;
                                }
                            }
                        }
                    }
                    QuoteState::TripleSingleQuote => {
                        while i < line_len {
                            match memchr(b'\'', &line[i..]) {
                                Some(pos) => {
                                    let p = i + pos;
                                    if line[p..].starts_with(b"'''") {
                                        quote_state = QuoteState::None;
                                        i = p + 3;
                                        break;
                                    } else {
                                        i = p + 1;
                                    }
                                }
                                None => {
                                    i = line_len;
                                    break;
                                }
                            }
                        }
                    }
                    QuoteState::RawString(hashes) => {
                        while i < line_len {
                            match memchr(b'"', &line[i..]) {
                                Some(pos) => {
                                    let p = i + pos;
                                    let needed = 1 + hashes as usize;
                                    if line[p..].len() >= needed
                                        && line[p + 1..p + needed].iter().all(|&b| b == b'#')
                                    {
                                        quote_state = QuoteState::None;
                                        i = p + needed;
                                        break;
                                    } else {
                                        i = p + 1;
                                    }
                                }
                                None => {
                                    i = line_len;
                                    break;
                                }
                            }
                        }
                    }
                    QuoteState::None => unreachable!(),
                }
                continue;
            }

            if block_depth > 0 {
                has_comment = true;
                if syntax.nested_comments {
                    let start_b = active_block_start[0];
                    let end_b = active_block_end[0];
                    while i < line_len {
                        let cand = if start_b == end_b {
                            memchr(start_b, &line[i..])
                        } else {
                            memchr2(start_b, end_b, &line[i..])
                        };
                        match cand {
                            Some(pos) => {
                                let p = i + pos;
                                if line[p..].starts_with(active_block_start) {
                                    block_depth += 1;
                                    i = p + active_block_start.len();
                                } else if line[p..].starts_with(active_block_end) {
                                    block_depth -= 1;
                                    i = p + active_block_end.len();
                                    if block_depth == 0 {
                                        break;
                                    }
                                } else {
                                    i = p + 1;
                                }
                            }
                            None => {
                                i = line_len;
                                break;
                            }
                        }
                    }
                } else {
                    let end_b = active_block_end[0];
                    while i < line_len {
                        match memchr(end_b, &line[i..]) {
                            Some(pos) => {
                                let p = i + pos;
                                if line[p..].starts_with(active_block_end) {
                                    block_depth = 0;
                                    i = p + active_block_end.len();
                                    break;
                                } else {
                                    i = p + 1;
                                }
                            }
                            None => {
                                i = line_len;
                                break;
                            }
                        }
                    }
                }
                continue;
            }

            let b = line[i];

            if matches!(b, b' ' | b'\t' | b'\r') {
                i += 1;
                continue;
            }

            let mut matched_block = false;
            for &(start, end) in syntax.block_comments {
                let start_bytes = start.as_bytes();
                if line[i..].starts_with(start_bytes) {
                    has_comment = true;
                    active_block_start = start_bytes;
                    active_block_end = end.as_bytes();
                    block_depth = 1;
                    i += start_bytes.len();
                    matched_block = true;
                    break;
                }
            }
            if matched_block {
                continue;
            }

            let mut matched_line_comment = false;
            for &marker in syntax.line_comments {
                let marker_bytes = marker.as_bytes();
                if line[i..].starts_with(marker_bytes) {
                    has_comment = true;
                    i = line_len;
                    matched_line_comment = true;
                    break;
                }
            }
            if matched_line_comment {
                break;
            }

            if b == b'r' || (matches!(b, b'b' | b'c') && i + 1 < line_len && line[i + 1] == b'r') {
                let r_pos = if b == b'r' { i } else { i + 1 };
                let mut h = r_pos + 1;
                while h < line_len && line[h] == b'#' {
                    h += 1;
                }
                if h < line_len && line[h] == b'"' {
                    has_code = true;
                    let hashes = (h - (r_pos + 1)) as u8;
                    i = h + 1;
                    quote_state = QuoteState::RawString(hashes);
                    continue;
                }
            }

            if line[i..].starts_with(b"\"\"\"") {
                has_code = true;
                i += 3;
                quote_state = QuoteState::TripleDoubleQuote;
                continue;
            }
            if line[i..].starts_with(b"'''") {
                has_code = true;
                i += 3;
                quote_state = QuoteState::TripleSingleQuote;
                continue;
            }

            if b == b'"' {
                has_code = true;
                i += 1;
                quote_state = QuoteState::DoubleQuote;
                continue;
            }

            if b == b'`' {
                has_code = true;
                i += 1;
                quote_state = QuoteState::Backtick;
                continue;
            }

            if b == b'\'' {
                has_code = true;
                let mut j = i + 1;
                let mut closed = false;
                while j < line_len {
                    if line[j] == b'\\' {
                        j += 2;
                    } else if line[j] == b'\'' {
                        closed = true;
                        j += 1;
                        break;
                    } else {
                        j += 1;
                    }
                }
                if closed {
                    i = j;
                } else {
                    i += 1;
                }
                continue;
            }

            has_code = true;
            i += 1;
        }

        if has_code {
            counts.code += 1;
        } else if has_comment {
            counts.comment += 1;
        }
    }

    counts
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_empty_input() {
        let counts = count_lines(b"", CommentSyntax::C);
        assert_eq!(counts.files, 0);
        assert_eq!(counts.code, 0);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.blank, 0);
        assert_eq!(counts.total_lines(), 0);
    }

    #[test]
    fn test_pure_blank_lines() {
        let input = b"\n\n   \n\t\t\n\r\n  \r\n";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.blank, 6);
        assert_eq!(counts.code, 0);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.files, 1);
    }

    #[test]
    fn test_pure_comment_lines_inline() {
        let input = b"// line comment 1\n   // line comment 2 with leading spaces\n// line 3";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.comment, 3);
        assert_eq!(counts.code, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_pure_comment_lines_block() {
        let input =
            b"/* single line block comment */\n   /* with leading spaces */\n/* c1 */ /* c2 */";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.comment, 3);
        assert_eq!(counts.code, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_mixed_code_and_comment_lines() {
        let input = b"int x = 5; // inline comment\n/* inline */ int y = 10;\nint z = 15; /* comment */\n/* c1 */ int a = 1; /* c2 */\n";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.code, 4);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_multiline_block_comments() {
        let input = b"/*\n * Line 2 of comment\n * Line 3 of comment\n */\n";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.comment, 4);
        assert_eq!(counts.code, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_multiline_block_comment_with_blank_line() {
        let input = b"/*\n * Comment line\n   \n */\n";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.comment, 3);
        assert_eq!(counts.blank, 1);
        assert_eq!(counts.code, 0);
    }

    #[test]
    fn test_multiline_block_comment_with_code_on_ends() {
        let input = b"int x = 1; /* start of block\n * middle of block\n */ int y = 2;\n";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.code, 2);
        assert_eq!(counts.comment, 1);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_comments_inside_quotes() {
        let input = b"let s = \" \";\nlet t = \"// not comment\";\nlet u = '/* not comment */';\n";
        let counts = count_lines(input, CommentSyntax::RUST);
        assert_eq!(counts.code, 3);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_escapes_inside_quotes() {
        let input = b"let s = \"hello \\\" /* not comment */ \\\" world\";\nlet t = \"hello \\\\\"; // real comment\n";
        let counts = count_lines(input, CommentSyntax::RUST);
        assert_eq!(counts.code, 2);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_multiline_double_quote_string() {
        let input = b"let s = \"hello\n \nworld\";\n";
        let counts = count_lines(input, CommentSyntax::RUST);
        assert_eq!(counts.code, 3);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_rust_raw_strings() {
        let input = b"let s = r#\" \"#;\nlet m = r##\"\n/* not comment */\n\"##;\n";
        let counts = count_lines(input, CommentSyntax::RUST);
        assert_eq!(counts.code, 4);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_rust_lifetimes_and_comments() {
        let input = b"fn foo<'a>(x: &'a str) -> &'a str { // comment\n    x\n}\n";
        let counts = count_lines(input, CommentSyntax::RUST);
        assert_eq!(counts.code, 3);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_nested_block_comments() {
        let input = b"/*\n  /* nested comment */\n*/\n";
        let counts_nested = count_lines(input, CommentSyntax::RUST);
        assert_eq!(counts_nested.comment, 3);
        assert_eq!(counts_nested.code, 0);

        let counts_non_nested = count_lines(input, CommentSyntax::C);
        assert_eq!(counts_non_nested.comment, 2);
        assert_eq!(counts_non_nested.code, 1);
    }

    #[test]
    fn test_python_syntax() {
        let input = b"# comment line 1\nx = 1 # inline comment\n\n\"\"\"\nDocstring line 1\nDocstring line 2\n\"\"\"\n";
        let counts = count_lines(input, CommentSyntax::PYTHON);
        assert_eq!(counts.code, 1);
        assert_eq!(counts.comment, 5);
        assert_eq!(counts.blank, 1);
    }

    #[test]
    fn test_html_syntax() {
        let input = b"<!-- comment 1 -->\n<div><!-- inline --></div>\n<!--\nmultiline\n-->\n";
        let counts = count_lines(input, CommentSyntax::HTML);
        assert_eq!(counts.code, 1);
        assert_eq!(counts.comment, 4);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_sql_syntax() {
        let input = b"-- SQL comment\nSELECT * FROM users; -- get all users\n/* Block comment */\n";
        let counts = count_lines(input, CommentSyntax::SQL);
        assert_eq!(counts.code, 1);
        assert_eq!(counts.comment, 2);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_lua_syntax_prefix() {
        let input = b"--[[ block start\nmiddle\n]]\n-- line comment\nlocal x = 1\n";
        let counts = count_lines(input, CommentSyntax::LUA);
        assert_eq!(counts.code, 1);
        assert_eq!(counts.comment, 4);
        assert_eq!(counts.blank, 0);
    }

    #[test]
    fn test_plain_text() {
        let input = b"Hello world\n// Not a comment here\n/* Still not a comment */\n\nFinal line";
        let counts = count_lines(input, CommentSyntax::PLAIN);
        assert_eq!(counts.code, 4);
        assert_eq!(counts.comment, 0);
        assert_eq!(counts.blank, 1);
    }

    #[test]
    fn test_no_trailing_newline() {
        let input = b"let x = 1;\n// comment";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.code, 1);
        assert_eq!(counts.comment, 1);
        assert_eq!(counts.blank, 0);
        assert_eq!(counts.total_lines(), 2);
    }

    #[test]
    fn test_crlf_endings() {
        let input = b"let x = 1;\r\n// comment\r\n\r\nlet y = 2;\r\n";
        let counts = count_lines(input, CommentSyntax::C);
        assert_eq!(counts.code, 2);
        assert_eq!(counts.comment, 1);
        assert_eq!(counts.blank, 1);
        assert_eq!(counts.total_lines(), 4);
    }

    #[test]
    fn test_conversion_from_classifier_syntax() {
        let input = b"// c-style\nlet x = 1;\n";
        let counts = count_lines(input, crate::classifier::CommentSyntax::Slash.into());
        assert_eq!(counts.code, 1);
        assert_eq!(counts.comment, 1);
    }
}
