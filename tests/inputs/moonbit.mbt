///|
///without spaces
/// 返回一个新数组，其中元素被反转。
///
/// # 示例
///
/// ```
/// reverse([1,2,3,4]) |> println()
/// ```
fn reverse[T](xs : Array[T]) -> Array[T] {
  Array::rev(xs)
}

test {
  assert_eq!(reverse([1,2,3,4]), [4, 3, 2, 1]) // pass
  assert_eq!(reverse([1,2,3,4]), [4, 3, 2, 1]) //pass
  let _ = "https://github.com"
}

fn main {
  let greeting =
    #|
    #|     (\(\
    #|     ( -.-)
    #|     o_(")(")
    #|     __  __     ____         __  ___                  ____  _ __
    #|    / / / /__  / / /___     /  |/  /___  ____  ____  / __ )(_) /_
    #|   / /_/ / _ \/ / / __ \   / /|_/ / __ \/ __ \/ __ \/ __  / / __/
    #|  / __  /  __/ / / /_/ /  / /  / / /_/ / /_/ / / / / /_/ / / /_
    #| /_/ /_/\___/_/_/\____/  /_/  /_/\____/\____/_/ /_/_____/_/\__/
    #|
  println(greeting)

    // Define two array of Int.
  let arr1 : Array[Int] = [1, 2, 3, 4, 5]

  // Let compiler infer the type.
  let arr2 = [6, 7, 8, 9, 10]

  // Get the length of the array.
  println(arr1.length())

  // Access the element of the array.
  println(arr1[1]) 

  // We change the elements inside the array. 
  // The binding of arr1 is immutable, it still points to the same array.
  // The internal mutability of the array is defined by the standard library and 
  // is not affected by the binding.
  arr1.push(6) 
  arr1[1] = 10
  println("push and change element:")
  println(arr1)
}
