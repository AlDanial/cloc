// https://github.com/gleam-lang/stdlib/raw/main/src/gleam/string.gleam
//// Strings in Gleam are UTF-8 binaries. They can be written in your code a
//// text surrounded by `"double quotes"`.

import gleam/string_builder
import gleam/dynamic.{Dynamic}
import gleam/iterator
import gleam/list
import gleam/order
import gleam/result

pub type String =
  String

/// A UtfCodepoint is the integer representation of a valid UTF codepoint
pub type UtfCodepoint =
  UtfCodepoint

/// Determine if a string is empty.
///
/// ## Examples
///
///    > is_empty("")
///    True
///
///    > is_empty("the world")
///    False
///
pub fn is_empty(str: String) -> Bool {
  str == ""
}

/// Get the number of grapheme clusters in a given string.
///
/// This function has to iterate across the whole string to count the number of
/// graphemes, so it runs in linear time.
///
/// ## Examples
///
///    > length("Gleam")
///    5
///
///    > length("ß↑e̊")
///    3
///
///    > length("")
///    0
///
pub external fn length(String) -> Int =
  "string" "length"

///
/// Reverse a string.
///
/// This function has to iterate across the whole string so it runs in linear
/// time.
///
/// ## Examples
///
///    > reverse("stressed")
///    "desserts"
///
pub fn reverse(string: String) -> String {
  string
  |> string_builder.from_string
  |> string_builder.reverse
  |> string_builder.to_string
}
