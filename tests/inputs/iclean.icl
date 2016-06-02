// https://github.com/camilstaps/iClean/raw/master/iclean.icl
/**
 * Interactive Clean
 *
 * Clean program to easily compile and run one-line Clean expressions
 *
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Camil Staps <info@camilstaps.nl>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module iclean

import StdEnv
import ReadLine

// SETTINGS
temp_path :== "/tmp/"
temp_module :== "iclean"
readline_history :== ".iclean_history"
// END SETTINGS

temp_file :== temp_path +++ temp_module +++ ".icl"

Start :: *World -> *World
Start w
# w = setReadLineName "iClean" w
# w = usingHistory w
# w = checkedWorldFunc readHistory "Couldn't read history file\n" readline_history w
# w = loop w
# w = checkedWorldFunc writeHistory "Couldn't write history file\n" readline_history w
= w
where
    loop :: !*World -> *World
    loop w
    # (s,w) = readLine "λ. " False w
    | isNothing s = print "\n" w
    # s = fromJust s
    | s == "" = loop (print "Use Ctrl-D to exit\n" w)
    # w = addHistory s w
    # w = writemodule s w
    # (r,w) = compile temp_path temp_module w
    | r <> 0 = loop w
    # w = run (temp_path +++ temp_module) w
    = loop w

checkedWorldFunc :: (a *World -> (Bool, *World)) !String !a !*World -> *World
checkedWorldFunc f err s w
# (ok, w) = f s w
| not ok = print err w
| otherwise = w

print :: String *World -> *World
print s w
# (io,w) = stdio w
# io = fwrites s io
# (ok,w) = fclose io w
| not ok = abort "Couldn't close stdio\n"
| otherwise = w

writemodule :: String *World -> *World
writemodule s w
# (ok,f,w) = fopen temp_file FWriteText w
| not ok = abort ("Couldn't open " +++ temp_file +++ " for writing.\n")
# f = fwrites ("module " +++ temp_module +++ "\n") f
# f = fwrites "import StdEnv\n" f
# f = fwrites ("Start = " +++ s +++ "\n") f
# (ok,w) = fclose f w
| not ok = abort ("Couldn't close " +++ temp_file +++ "\n")
| otherwise = w

compile :: !String !String !*World -> *(!Int,*World)
compile _ _ _ = code {
    ccall compile "SS:p:p"
}

run :: !String *World -> *World
run _ _ = code {
    ccall run "S:V:p"
}

