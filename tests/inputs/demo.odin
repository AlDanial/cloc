// portion of https://github.com/odin-lang/Odin/raw/master/examples/demo/demo.odin
package main

import "core:fmt"
import "core:mem"
import "core:os"


/*
	The Odin programming language is fast, concise, readable, pragmatic and open sourced.
	It is designed with the intent of replacing C with the following goals:
	 * simplicity
	 * high performance
	 * built for modern systems
	 * joy of programming

*/

the_basics :: proc() {
	fmt.println("\n# the basics");

	{ // The Basics
		fmt.println("Hellope");

		// Lexical elements and literals
		// A comment

		my_integer_variable: int; // A comment for documentaton

		// Multi-line comments begin with /* and end with */. Multi-line comments can
		// also be nested (unlike in C):
		/*
			You can have any text or code here and
			have it be commented.
		*/

		// Note: `:=` is two tokens, `:` and `=`. The following are equivalent,
		/*
			i: int = 123;
			i:     = 123;
			i := 123;
		*/

		_ = my_integer_variable;
		_ = x;
	}
}

control_flow :: proc() {
	fmt.println("\n# control flow");
	{ // Control flow
		// For loop
		// Odin has only one loop statement, the `for` loop

		// Basic for loop
		for i := 0; i < 10; i += 1 {
			fmt.println(i);
		}

		// NOTE: Unlike other languages like C, there are no parentheses `( )` surrounding the three components.
		// Braces `{ }` or a `do` are always required>
		for i := 0; i < 10; i += 1 { }
		for i := 0; i < 10; i += 1 do fmt.print();

		// The initial and post statements are optional
		i := 0;
		for ; i < 10; {
			i += 1;
		}

		// You can defer an entire block too:
		{
			bar :: proc() {}

			defer {
				fmt.println("1");
				fmt.println("2");
			}

			cond := false;
			defer if cond {
				bar();
			}
		}

		// Defer statements are executed in the reverse order that they were declared:
		{
			defer fmt.println("1");
			defer fmt.println("2");
			defer fmt.println("3");
		}
		// Will print 3, 2, and then 1.

		if false {
			f, err := os.open("my_file.txt");
			if err != 0 {
				// handle error
			}
			defer os.close(f);
			// rest of code
		}
	}

	{ // When statement
		/*
			The when statement is almost identical to the if statement but with some differences:

			* Each condition must be a constant expression as a when
			  statement is evaluated at compile time.
			* The statements within a branch do not create a new scope
			* The compiler checks the semantics and code only for statements
			  that belong to the first condition that is true
			* An initial statement is not allowed in a when statement
			* when statements are allowed at file scope
		*/

		// Example
		when ODIN_ARCH == "386" {
			fmt.println("32 bit");
		} else when ODIN_ARCH == "amd64" {
			fmt.println("64 bit");
		} else {
			fmt.println("Unsupported architecture");
		}
		// The when statement is very useful for writing platform specific code.
		// This is akin to the #if construct in C’s preprocessor however, in Odin,
		// it is type checked.
	}

	{ // Branch statements
		cond, cond1, cond2 := false, false, false;
		one_step :: proc() { fmt.println("one_step"); }
		beyond :: proc() { fmt.println("beyond"); }

		// Break statement
		for cond {
			switch {
			case:
				if cond {
					break; // break out of the `switch` statement
				}
			}

			break; // break out of the `for` statement
		}

		loop: for cond1 {
			for cond2 {
				break loop; // leaves both loops
			}
		}

		// Continue statement
		for cond {
			if cond2 {
				continue;
			}
			fmt.println("Hellope");
		}

		// Fallthrough statement

		// Odin’s switch is like one in C or C++, except that Odin only runs the selected
		// case. This means that a break statement is not needed at the end of each case.
		// Another important difference is that the case values need not be integers nor
		// constants.

		// fallthrough can be used to explicitly fall through into the next case block:

		switch i := 0; i {
		case 0:
			one_step();
			fallthrough;
		case 1:
			beyond();
		}
	}
}
