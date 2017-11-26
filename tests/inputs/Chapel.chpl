// "Production-grade" hello world
// From https://github.com/chapel-lang/chapel/blob/release/1.16/test/release/examples/hello2-module.chpl

/* This program is conceptually very similar to :ref:`hello.chpl
   <primers-hello>`, but it uses a more structured programming style,
   explicitly defining a module, a configuration constant, and a
   main() procedure.
 */

//
// The following statement declares a module named 'Hello'.  If a
// source file contains no module declarations, the filename minus its
// ``.chpl`` extension serves as the module name for the code it
// contains.  Thus, 'hello' would be the automatic module name for the
// previous :ref:`hello.chpl <primers-hello>` example.
//
module Hello {

//
// This next statement declares a `configuration constant` named
// `message`.  The type is inferred to be a string since the
// initializing expression is a string literal.  Users may override
// the default values of configuration constants and variables on the
// executable's command-line.  For example, we could change the
// default message for a given run using the command line: ``./hello
// --message="hiya!"``.
//
  config const message = "Hello, world!";


// Any top-level code in a module is executed as part of the module's
// initialization when the program begins executing.  Thus, in the
// previous one-line :ref:`hello.chpl <primers-hello>`, the presence
// of a `writeln()` at the file scope formed the implicit `hello`
// module's initialization and would be executed at program startup.
// Since there was no explicit `main()` function or any other
// top-level code, that's all that the program would do.


//
// In this program, we define an entry point for the program by
// defining a procedure named `main()`.  This will be invoked after
// this module and all the modules it uses are initialized.
//
  proc main() {
    writeln(message);
  }
}
