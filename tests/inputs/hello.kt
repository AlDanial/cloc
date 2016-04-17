/* http://confluence.jetbrains.com/display/Kotlin/Hello%2C+world! 
*/
fun main(args : Array<String>) { 
  val language = if (args.size == 0) "EN" else args[0] 
  println(when (language) { 
    "EN" -> "Hello!" 
    "ES" -> "¡Hola!" 
    // will this render?
    "RU" -> "Привет!"  
    else -> "Sorry, I can't greet you in $language yet" 
  }) 
}
