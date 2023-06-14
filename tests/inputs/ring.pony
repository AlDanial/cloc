/*
 * https://github.com/ponylang/ponyc/raw/908402b60f083d66d3b59a1879efb6adee5ca3cc/examples/ring/main.pony
 */

"""
A ring is a group of processes connected to each other using
unidirectional links through which messages can pass from process to
process in a cyclic manner.

The logic of this program is as follows:
* Each process in a ring is represented by the actor `Ring`
* `Main` creates Ring by instantiating `Ring` actors based on the
  arguments passed and links them with each other by setting the next
  actor as the previous ones number and at the end linking the last actor
  to the first one thereby closing the links and completing the ring
* Once the ring is complete messages can be passed by calling the `pass`
  behaviour on the current `Ring` to its neighbour.
* The program prints the id of the last `Ring` to receive a message

For example if you run this program with the following options `--size 3`
and `--pass 2`. It will create a ring that looks like this:


        *  *              *  *
     *        *        *        *
    *     1    *_ _ _ *     2    *
    *          *      *          *
     *        *        *        *
        *  *              *  *
          \                 /
           \               /
            \             /
             \    *  *   /
               *        *
              *     3    *
              *          *
               *        *
                  *  *

and print 3 as the id of the last Ring actor that received the
message.
"""

use "collections"

actor Ring
  let _id: U32
  let _env: Env
  var _next: (Ring | None)

  new create(id: U32, env: Env, neighbor: (Ring | None) = None) =>
    _id = id
    _env = env
    _next = neighbor

  be set(neighbor: Ring) =>
    _next = neighbor

  be pass(i: USize) =>
    if i > 0 then
      match _next
      | let n: Ring =>
        n.pass(i - 1)
      end
    else
      _env.out.print(_id.string())
    end

actor Main
  var _ring_size: U32 = 3
  var _ring_count: U32 = 1
  var _pass: USize = 10

  var _env: Env

  new create(env: Env) =>
    _env = env

    try
      parse_args()?
      setup_ring()
    else
      usage()
    end

  fun ref parse_args() ? =>
    var i: USize = 1

    while i < _env.args.size() do
      // Every option has an argument.
      var option = _env.args(i)?
      var value = _env.args(i + 1)?
      i = i + 2

      match option
      | "--size" =>
        _ring_size = value.u32()?
      | "--count" =>
        _ring_count = value.u32()?
      | "--pass" =>
        _pass = value.usize()?
      else
        error
      end
    end

  fun setup_ring() =>
    for j in Range[U32](0, _ring_count) do
      let first = Ring(1, _env)
      var next = first

      for k in Range[U32](0, _ring_size - 1) do
        let current = Ring(_ring_size - k, _env, next)
        next = current
      end

      first.set(next)

      if _pass > 0 then
        first.pass(_pass)
      end
    end

  fun usage() =>
    _env.out.print(
      """
      rings OPTIONS
        --size N number of actors in each ring
        --count N number of rings
        --pass N number of messages to pass around each ring
      """
      )
