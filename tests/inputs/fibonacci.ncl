# https://raw.githubusercontent.com/tweag/nickel/master/examples/fibonacci/fibonacci.ncl
# test = 'pass'

# This is the naive, exponential version of fibonacci: don't call it on a big
# value!
let rec fibonacci = fun n =>
  if n == 0 then
    0
  else if n == 1 then
    1
  else
    fibonacci (n - 1) + fibonacci (n - 2)
in
fibonacci 10
