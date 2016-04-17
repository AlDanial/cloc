(* http://en.wikipedia.org/wiki/F_Sharp_%28programming_language%29 
 *)
/// A very naive prime number detector
let isPrime (n:int) =
   let bound = int (sqrt (float n))
   seq {2 .. bound} |> Seq.forall (fun x -> n % x <> 0)
 
// We are using async workflows
let primeAsync n =
    async { return (n, isPrime n) }
 
/// Return primes between m and n using multiple threads
let primes m n =
    seq {m .. n}
        |> Seq.map primeAsync
        |> Async.Parallel
        |> Async.RunSynchronously
        |> Array.filter snd
        |> Array.map fst
 
// Run a test
primes 1000000 1002000
    |> Array.iter (printfn "%d")
