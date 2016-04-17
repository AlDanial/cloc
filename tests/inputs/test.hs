
-- This literate program prompts the user for a number
-- and prints the factorial of that number:

{- This is a comment. -}
{- This is a comment,
   too -}

{-# this is a pragma, COUNT IT -}

 main :: IO ()
 main = do putStr "Enter a number: "
           l <- readLine
           putStr "n!= "
           print (fact (read l))
 fact :: Integer -> Integer
 fact 0 = 1
 fact n = n * fact (n-1)

