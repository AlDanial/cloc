// from http://www.roesler-ac.de/wolfram/hello.htm
// Hello World in Java

// 2016-12-02:  additional code by https://github.com/filippucher1
// to test /* within quoted string github issue #140

@Controller
@RequestMapping( "/path/*" )
public class ControllerClass {
/** 
* javadoc
* style
*/

/* block comment 1 - on one line */

/* 
  block comment 2
*/

/* 
* block comment 3
*/

import java.io.*;
class HelloWorld {
  static public void main( String args[] ) {
    System.out.println( "Hello World!" );
  }
}
