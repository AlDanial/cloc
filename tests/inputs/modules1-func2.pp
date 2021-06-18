# this is a Puppet function with args
# /root/examples/modules1-func2.pp
function ntp::my_func ($arg1, $arg2) {
  return("${arg1} and ${arg2}")
}
