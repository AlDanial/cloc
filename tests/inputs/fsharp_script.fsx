// https://blogs.msdn.microsoft.com/chrsmith/2008/09/12/scripting-in-f/
// Launches all .fs and .fsi files under the current folder in Notepad
open System

allFilesUnder Environment.CurrentDirectory
|> Seq.filter (function 
            | EndsWith ".fs" _
            | EndsWith ".fsi" _
                -> true
            | _ -> false)
|> Seq.iter (shellExecute "Notepad.exe")
