/*
https://github.com/Zxilly/playground-cj/blob/master/src/examples/functional.cj
*/
package playground

// 用给定的分隔符拆分字符串，支持多分隔符
import std.collection.*

// 常规实现
func split_normal(text: String, sep: String): ArrayList<String> {
    let indices = ArrayList<Int64>()
    var last = true
    for (i in 0..text.size) {
        let current = sep.indexOf(text[i]).isSome()
        if (last != current) {
            indices.add(i)
        }
        last = current
    }
    if (!last) {
        indices.add(text.size)
    }

    let result = ArrayList<String>()
    for (i in 0..indices.size : 2) {
        result.add(text[indices[i]..indices[i + 1]])
    }
    return result
}

// 函数式编程实现
func split(text: String, sep: String): ArrayList<String> {
    let indices = ArrayList<Int64>()
    text |> enumerate |>
        fold(false) {
        state, e =>
        let current = sep.indexOf(e[1]).isNone()
        if (state != current) {
            indices.add(e[0])
        }
        current
    } |> {
        valid: Bool => if (valid) {
            indices.add(text.size)
        }
    }

    let result = ArrayList<String>()
    for (i in 0..indices.size : 2) {
        result.add(text[indices[i]..indices[i + 1]])
    }
    return result
}

main() {
    let text = "123, 456 7&89, , 96^3, 567"
    let separator = "&^, "
    println(split_normal(text, separator))
    println(split(text, separator))
}
