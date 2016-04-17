
This is an extract of a larger literate Haskell file for testing
SLOCCount.  It should have 21 lines of code.

This dumps the tree in dot format, which is very handy for visualizing
the trees.

> dotTree name t = "digraph " ++ filter dotChars name ++ " { " ++ (dotTree' t 0) ++ " }"

> dotTree' Empty _ = ""
> dotTree' t i | is_leaf t = "n"++(show i)++" [label=\""++(show $ x_span t)++
>                            "\",shape=box]; "
>              | otherwise = "n"++(show i)++" [label=\""++(show $ x_span t)++"\"]; " ++
>			     "n"++(show i)++" -> n"++(show (2*i+1))++"; "++
>                            "n"++(show i)++" -> n"++(show (2*i+2))++"; "++
>                            dotTree' (left t) (2*i+1) ++
>                            dotTree' (right t) (2*i+2)
>   where is_leaf Node { left = Empty, right = Empty } = True
>         is_leaf _ = False
> {- this is a comment

foo bar baz

>    that
>    spans literate blocks -}

> dotChars '.' = False
> dotChars '/' = False
> dotChars _ = True

These functions fill in the monotonically increasing index values for
the lines in the finite map.  They also do appropriate things to combine
the world values.

> idxList [] n = []
> idxList (x:xs) n = (x {idx=n}):(idxList xs (n+1))

> idxFM' fm (x,k) = addToFM (delFromFM fm k) k (y {idx=toInteger x})
>	where y = case lookupFM fm k of
>                   Just foo -> foo
>                   Nothing  -> error $ "No such key: " ++ show k

> idxFM fm = foldl idxFM' fm (zip [1..sizeFM fm] $ keysFM fm)

