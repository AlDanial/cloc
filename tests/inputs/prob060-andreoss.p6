use v6;

# https://github.com/Raku/examples/raw/master/categories/euler/prob060-andreoss.pl

=begin pod

=TITLE Prime pair sets 

=AUTHOR Andrei Osipov

The primes 3, 7, 109, and 673, are quite remarkable. By taking any two
primes and concatenating them in any order the result will always be
prime. For example, taking 7 and 109, both 7109 and 1097 are
prime. The sum of these four primes, 792, represents the lowest sum
for a set of four primes with this property.

Find the lowest sum for a set of five primes for which any two primes
concatenate to produce another prime.

=end   pod

subset Prime of Int where *.is-prime;


sub infix:«R»($a, $b) {
    +( $a ~ $b ) & +( $b ~ $a ) ~~ Prime 
}

multi are-remarkable()          { True }
multi are-remarkable($a)        { True }
multi are-remarkable($a, *@xs)  {
    $a R @xs.all
}

sub get-remarkable(  :@primes   is copy
                   , *@sequence
                  ) {
    gather while my $x = @primes.shift {
        if are-remarkable $x, @sequence {
            take(|@sequence , $x) if @sequence;
            take $_
                for get-remarkable
                     :@primes
                    , @sequence, $x
        }
    }
}

sub MAIN(  Int  :$limit   = 10_000
         , Bool :$verbose = False
         , Int  :$size    = 5
        ) {
    
    my @primes = grep Prime , 1 .. $limit;
    
    for get-remarkable :@primes -> @r {
        
        say @r.perl if $verbose ;

        if @r == $size {
            $verbose
                ?? say "The sequence is @r[], the sum is {[+] @r}"
                !! say [+] @r
            and last
        }
    }
    
    say "Done in {now - BEGIN now}." if $verbose;
}

