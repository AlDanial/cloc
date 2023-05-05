// License: MPL-2.0
// (c) 2022 Alexey Yerin <yyp@disroot.org>
// (c) 2021 Andri Yngvason <andri@yngvason.is>
// (c) 2021-2022 Bor Grošelj Simić <bor.groseljsimic@telemach.net>
// (c) 2021 Byron Torres <b@torresjrjr.com>
// (c) 2021 Drew DeVault <sir@cmpwn.com>
// (c) 2021 Ember Sawady <ecs@d2evs.net>
use ascii;
use bufio;
use encoding::utf8;
use io;
// https://git.sr.ht/~sircmpwn/hare/tree/master/item/fmt/fmt.ha
use math;
use os;
use strconv;
use strings;
use types;

// Tagged union of the [[formattable]] types and [[modifiers]]. Used for
// functions which accept format strings.
export type field = (...formattable | *modifiers);

// Tagged union of all types which are formattable.
export type formattable = (...types::numeric | uintptr | str | rune | bool |
	nullable *void | void);

// Formats text for printing and writes it to [[os::stdout]].
export fn printf(fmt: str, args: field...) (io::error | size) =
	fprintf(os::stdout, fmt, args...);

// Formats text for printing and writes it to [[os::stdout]], followed by a line
// feed.
export fn printfln(fmt: str, args: field...) (io::error | size) =
	fprintfln(os::stdout, fmt, args...);
