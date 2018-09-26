/* LogMain.re */
/*
 * Example from http://2ality.com/2017/12/modules-reasonml.html
 */

let () = Log.make()
  |> Log.logStr(" /* Hello")  /* another comment */
  |> Log.logStr("everyone")
  |> Log.print;

/* Output:
Hello
everyone
*/
