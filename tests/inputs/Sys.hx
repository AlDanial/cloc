/*
 https://raw.githubusercontent.com/HaxeFoundation/haxe/development/std/Sys.hx
 * Copyright (C)2005-2016 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
/**
	This class gives you access to many base functionalities of system platforms. Looks in `sys` sub packages for more system APIs.
**/
@:require(sys)
extern class Sys {

	/**
		Print any value on the standard output.
	**/
	static function print( v : Dynamic ) : Void;

	/**
		Print any value on the standard output, followed by a newline.
	**/
	static function println( v : Dynamic ) : Void;

	/**
		Returns all the arguments that were passed by the commandline.
	**/
	static function args() : Array<String>;

	/**
		Returns the value of the given environment variable.
	**/
	static function getEnv( s : String ) : String;

	/**
		Set the value of the given environment variable.
	**/
	static function putEnv( s : String, v : String ) : Void;

	/**
		Returns the whole environement variables.
	**/
	static function environment() : Map<String,String>;

	/**
		Suspend the current execution for the given time (in seconds).
	**/
	static function sleep( seconds : Float ) : Void;

	/**
		Change the current time locale, which will affect `DateTools.format` date formating.
		Returns true if the locale was successfully changed
	**/
	static function setTimeLocale( loc : String ) : Bool;

	/**
		Get the current working directory (usually the one in which the program was started)
	**/
	static function getCwd() : String;

	/**
		Change the current working directory.
	**/
	static function setCwd( s : String ) : Void;

	/**
		Returns the name of the system you are running on. For instance :
			"Windows", "Linux", "BSD" and "Mac" depending on your desktop OS.
	**/
	static function systemName() : String;

	/**
		Run the given command. The command output will be printed on the same output as the current process.
		The current process will block until the command terminates and it will return the command result (0 if there was no error).

		Command arguments can be passed in two ways: 1. using `args`, 2. appending to `cmd` and leaving `args` as `null`.

		 1. When using `args` to pass command arguments, each argument will be automatically quoted, and shell meta-characters will be escaped if needed.
		`cmd` should be an executable name that can be located in the `PATH` environment variable, or a path to an executable.

		 2. When `args` is not given or is `null`, command arguments can be appended to `cmd`. No automatic quoting/escaping will be performed. `cmd` should be formatted exactly as it would be when typed at the command line.
		It can run executables, as well as shell commands that are not executables (e.g. on Windows: `dir`, `cd`, `echo` etc).

		Read the `sys.io.Process` api for a more complete way to start background processes.
	**/
	static function command( cmd : String, ?args : Array<String> ) : Int;

	/**
		Exit the current process with the given error code.
	**/
	static function exit( code : Int ) : Void;

	/**
		Gives the most precise timestamp value (in seconds).
	**/
	static function time() : Float;

	/**
		Gives the most precise timestamp value (in seconds) but only account for the actual time spent running on the CPU for the current thread/process.
	**/
	static function cpuTime() : Float;

	/**
		Returns the path to the current executable that we are running.
	**/
	@:deprecated("Use programPath instead") static function executablePath() : String;

	/**
		Returns the absolute path to the current program file that we are running.
		Concretely, for an executable binary, it returns the path to the binary.
		For a script (e.g. a PHP file), it returns the path to the script.
	**/
	static function programPath() : String;

	/**
		Read a single input character from the standard input (without blocking) and returns it. Setting `echo` to true will also display it on the output.
	**/
	static function getChar( echo : Bool ) : Int;

	/**
		Returns the process standard input, from which you can read what user enters. Usually it will block until the user send a full input line. See `getChar` for an alternative.
	**/
	static function stdin() : haxe.io.Input;

	/**
		Returns the process standard output on which you can write.
	**/
	static function stdout() : haxe.io.Output;

	/**
		Returns the process standard error on which you can write.
	**/
	static function stderr() : haxe.io.Output;

}
