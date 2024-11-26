---- MODULE TLAExample ----
(* TLA+ example program. *)
(* Multi-line
   (* nested *)
   comment *)
\* Single-line comment

VARIABLES tlaIsCool

Init == tlaIsCool = TRUE

Next == tlaIsCool = TRUE /\ tlaIsCool' = TRUE
====
