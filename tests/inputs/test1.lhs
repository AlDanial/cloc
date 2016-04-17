\documentstyle{article}

\begin{document}

\section{Introduction}

This is a trivial program that prints the first 20
factorials.  It should have 2 lines of code.

\begin{code}
main :: IO ()
main =  print [ (n, product [1..n]) | n <- [1..20]]
\end{code}

\end{document}
