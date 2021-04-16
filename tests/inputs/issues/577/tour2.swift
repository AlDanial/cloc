// https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/GuidedTour.html#//apple_ref/doc/uid/TP40014097-CH2-XID_1

//    let implicitInteger = 70
//    let implicitDouble = 70.0
//    let explicitDouble: Double = 70
//
//
//
//    let label = "The width is "
//    let width = 94
//    let widthLabel = label + String(width)



    var shoppingList = ["catfish", "water", "tulips", "blue paint"]
    shoppingList[1] = "bottle of water"
    var occupations = [
          // "Malcolm": "Captain",
    "Kaylee": "Mechanic",
    ]
        /* occupations["Jayne"] = "Public Relations" */



    let individualScores = [75, 43, 103, 87, 12]
    var teamScore = 0
    for score in individualScores {
    if score > 50 {
    teamScore += 3
    } else {
    teamScore += 1
    }
    }
    teamScore



    var optionalString: String? = "Hello"
    optionalString == nil
    var optionalName: String? = "John Appleseed"
    var greeting = "Hello!"
    if let name = optionalName {
    greeting = "Hello, \(name)"
    }



    let vegetable = "red pepper"
    switch vegetable {
    case "celery":
    let vegetableComment = "Add some raisins and make ants on a log."
    case "cucumber", "watercress":
    let vegetableComment = "That would make a good tea sandwich."
    case let x where x.hasSuffix("pepper"):
    let vegetableComment = "Is it a spicy \(x)?"
    default:
    let vegetableComment = "Everything tastes good in soup."
    }



    let interestingNumbers = [
    "Prime": [2, 3, 5, 7, 11, 13],
    "Fibonacci": [1, 1, 2, 3, 5, 8],
    "Square": [1, 4, 9, 16, 25],
    ]
    var largest = 0
    for (kind, numbers) in interestingNumbers {
    for number in numbers {
    if number > largest {
    largest = number
    }
    }
    }
    largest



    func hasAnyMatches(list: Int[], condition: Int -> Bool) -> Bool {
    for item in list {
    if condition(item) {
    return true
    }
    }
    return false
    }
    func lessThanTen(number: Int) -> Bool {
    return number < 10
    }
    var numbers = [20, 19, 7, 12]
    hasAnyMatches(numbers, lessThanTen) /*
Functions are actually a special case of closures. You can write a closure without a name by surrounding code with braces ({}). Use in to separate the arguments and return type from the body. */

    numbers.map({
    (number: Int) -> Int in
    let result = 3 * number
    return result
    })



