-- https://github.com/ziman/lightyear/raw/master/Lightyear/Combinators.idr
-- --------------------------------------------------------- [ Combinators.idr ]
-- Module      : Lightyear.Combinators
-- Description : Generic Combinators
--
-- This code is distributed under the BSD 2-clause license.
-- See the file LICENSE in the root directory for its full text.
-- --------------------------------------------------------------------- [ EOH ]
module Lightyear.Combinators

import Data.Vect

import Lightyear.Core

%access export

-- --------------------------------------------------------------- [ Operators ]
infixr 3 :::
private
(:::) : a -> List a -> List a
(:::) x xs = x :: xs

infixr 3 ::.
private
(::.) : a -> Vect n a -> Vect (S n) a
(::.) x xs = x :: xs

-- -------------------------------------------------- [ Any Token and No Token ]

||| Parse a single arbitrary token. Returns the parsed token.
|||
||| This parser will fail if and only if the input stream is empty.
anyToken : (Monad m, Stream tok str) => ParserT str m tok
anyToken = satisfy (const True) <?> "any token"

||| Parse the end of input.
|||
||| This parser will succeed if and only if the input stream is empty.
eof : (Monad m, Stream tok str) => ParserT str m ()
eof = requireFailure anyToken <?> "end of input"

-- ---------------------------------------------------- [ Multiple Expressions ]

||| Run some parser as many times as possible, collecting a list of
||| successes.
many : Monad m => ParserT str m a -> ParserT str m (List a)
many p = (pure (:::) <*> p <*>| many p) <|> pure List.Nil

||| Run the specified parser precisely `n` times, returning a vector
||| of successes.
ntimes : Monad m => (n : Nat)
                 -> ParserT str m a
                 -> ParserT str m (Vect n a)
ntimes    Z  p = pure Vect.Nil
ntimes (S n) p = [| p ::. ntimes n p |]

||| Like `many`, but the parser must succeed at least once
some : Monad m => ParserT str m a -> ParserT str m (List a)
some p = [| p ::: many p |]

-- --------------------------------------------------- [ Separated Expressions ]

||| Parse repeated instances of at least one `p`, separated by `s`,
||| returning a list of successes.
|||
||| @ p the parser for items
||| @ s the parser for separators
sepBy1 : Monad m => (p : ParserT str m a)
                 -> (s : ParserT str m b)
                 -> ParserT str m (List a)
sepBy1 p s = [| p ::: many (s *> p) |]

||| Parse zero or more `p`s, separated by `s`s, returning a list of
||| successes.
|||
||| @ p the parser for items
||| @ s the parser for separators
sepBy : Monad m => (p : ParserT str m a)
                -> (s : ParserT str m b)
                -> ParserT str m (List a)
sepBy p s = (p `sepBy1` s) <|> pure List.Nil

||| Parse precisely `n` `p`s, separated by `s`s, returning a vect of
||| successes.
|||
||| @ n how many to parse
||| @ p the parser for items
||| @ s the parser for separators
sepByN : Monad m => (n : Nat)
                 -> (p : ParserT str m a)
                 -> (s : ParserT str m b)
                 -> ParserT str m (Vect n a)
sepByN    Z  p s = pure Vect.Nil
sepByN (S n) p s = [| p ::. ntimes n (s *> p) |]

||| Parse one or more `p`s, separated by `op`s. Return a value that is
||| the left associative application of the functions returned by `op`.
|||
||| @ p  the parser
||| @ op the parser for operators
chainl1 : Monad m => (p : ParserT str m a)
                  -> (op: ParserT str m (a -> a -> a))
                  -> ParserT str m a
chainl1 p op = p >>= rest
  where rest a1 = (do f <- op
                      a2 <- p
                      rest (f a1 a2)) <|> pure a1

||| Parse zero or more `p`s, separated by `op`s. Return a value that is
||| the left associative application of the functions returned by `op`.
||| Return `a` when there are zero occurences of `p`.
|||
||| @ p  the parser
||| @ op the parser for operators
chainl : Monad m => (p : ParserT str m a)
                 -> (op : ParserT str m (a -> a -> a))
                 -> a
                 -> ParserT str m a
chainl p op a = (p `chainl1` op) <|> pure a

||| Parse one or more `p`s, separated by `op`s. Return a value that is
||| the right associative application of the functions returned by `op`.
|||
||| @ p  the parser
||| @ op the parser for operators
chainr1 : Monad m => (p : ParserT str m a)
                  -> (op: ParserT str m (a -> a -> a))
                  -> ParserT str m a
chainr1 p op = p >>= rest
  where rest a1 = (do f <- op
                      a2 <- p >>= rest
                      rest (f a1 a2)) <|> pure a1

||| Parse zero or more `p`s, separated by `op`s. Return a value that is
||| the right associative application of the functions returned by `op`.
||| Return `a` when there are zero occurences of `p`.
|||
||| @ p  the parser
||| @ op the parser for operators
chainr : Monad m => (p : ParserT str m a)
                 -> (op : ParserT str m (a -> a -> a))
                 -> a
                 -> ParserT str m a
chainr p op a = (p `chainr1` op) <|> pure a

||| Alternate between matches of `p` and `s`, starting with `p`,
||| returning a list of successes from both.
alternating : Monad m => (p : ParserT str m a)
                      -> (s : ParserT str m a)
                      -> ParserT str m (List a)
alternating p s = (pure (:::) <*> p <*>| alternating s p) <|> pure List.Nil

||| Throw away the result from a parser
skip : Monad m => ParserT str m a -> ParserT str m ()
skip = map (const ())

||| Attempt to parse `p`. If it succeeds, then return the value. If it
||| fails, continue parsing.
opt : Monad m => (p : ParserT str m a) -> ParserT str m (Maybe a)
opt p = map Just p <|> pure Nothing

||| Parse open, then p, then close. Returns the result of `p`.
|||
||| @open The opening parser.
||| @close The closing parser.
||| @p The parser for the middle part.
between : Monad m => (open : ParserT str m a)
                  -> (close : ParserT str m a)
                  -> (p : ParserT str m b)
                  -> ParserT str m b
between open close p = open *> p <* close

-- The following names are inspired by the cut operator from Prolog

-- ---------------------------------------------------- [ Monad-like Operators ]

infixr 5 >!=
||| Committing bind
(>!=) : Monad m => ParserT str m a
                -> (a -> ParserT str m b)
                -> ParserT str m b
x >!= f = x >>= commitTo . f

infixr 5 >!
||| Committing sequencing
(>!) : Monad m => ParserT str m a
               -> ParserT str m b
               -> ParserT str m b
x >! y = x >>= \_ => commitTo y

-- ---------------------------------------------- [ Applicative-like Operators ]

infixl 2 <*!>
||| Committing application
(<*!>) : Monad m => ParserT str m (a -> b)
                 -> ParserT str m a
                 -> ParserT str m b
f <*!> x = f <*> commitTo x

infixl 2 <*!
(<*!) : Monad m => ParserT str m a
                -> ParserT str m b
                -> ParserT str m a
x <*! y = x <* commitTo y

infixl 2 *!>
(*!>) : Monad m => ParserT str m a
                -> ParserT str m b
                -> ParserT str m b
x *!> y = x *> commitTo y

-- ---------------------------------------------------------- [ Lazy Operators ]

infixl 2 <*|
(<*|) : Monad m => ParserT str m a
                -> Lazy (ParserT str m b)
                -> ParserT str m a
x <*| y = pure const <*> x <*>| y

infixl 2 *>|
(*>|) : Monad m => ParserT str m a
                -> Lazy (ParserT str m b)
                -> ParserT str m b
x *>| y = pure (const id) <*> x <*>| y
-- ---------------------------------------------------------------------- [ EF ]
