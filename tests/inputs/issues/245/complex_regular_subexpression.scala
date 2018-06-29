portion of finagle-base-http/src/test/scala/com/twitter/finagle/http/codec/HttpDtabTest.scala
from finagle-finagle-17.11.0.tar.gz used to trigger 
Complex regular subexpression recursion limit (32766) exceeded

package com.twitter.finagle.http.codec

import com.google.common.io.BaseEncoding
import com.twitter.finagle.http.{Message, Method, Request, Version}
import com.twitter.finagle.{Dentry, Dtab, Failure, NameTree}
import java.nio.charset.Charset
import org.scalatest.FunSuite
import org.scalatest.junit.AssertionsForJUnit

class HttpDtabTest extends FunSuite with AssertionsForJUnit {
  val okDests = Vector("/$/inet/10.0.0.1/9000", "/foo/bar", "/")
  val okPrefixes = Vector("/foo", "/", "/foo/*/bar")
  val okDentries = for {
    prefix <- okPrefixes
    dest <- okDests
  } yield Dentry(Dentry.Prefix.read(prefix), NameTree.read(dest))

  val Utf8 = Charset.forName("UTF-8")
  val Base64 = BaseEncoding.base64()
  private def b64Encode(v: String): String =
    Base64.encode(v.getBytes(Utf8))

  val okDtabs =
    Dtab.empty +: (okDentries.permutations map (ds => Dtab(ds))).toIndexedSeq

  def newMsg(): Message = Request(Version.Http11, Method.Get, "/")

//  test("write(dtab, msg); read(msg) == dtab") {
//    for (dtab <- okDtabs) {
//      val m = newMsg()
//      HttpDtab.write(dtab, m)
//      val dtab1 = HttpDtab.read(m).get()
//      assert(Equiv[Dtab].equiv(dtab, dtab1))
//    }
//  }

}
