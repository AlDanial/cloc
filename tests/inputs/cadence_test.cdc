/* https://cadence-lang.org/docs/testing-framework
*/
// A `setup` function that always runs before the rest of the test cases.
// Can be used to initialize things that would be used across the test cases.
// e.g: initialling a blockchain backend, initializing a contract, etc.
access(all)
fun setup() {
}

// The `beforeEach` function runs before each test case. Can be used to perform
// some state cleanup before each test case, among other things.
access(all)
fun beforeEach() {
}

// The `afterEach` function runs after each test case.  Can be used to perform
// some state cleanup after each test case, among other things.
access(all)
fun afterEach() {
}

// Valid test functions start with the 'test' prefix.
access(all)
fun testSomething() {
}

access(all)
fun testAnotherThing() {
}

access(all)
fun testMoreThings() {
}

// Test functions cannot have any arguments or return values.
access(all)
fun testInvalidSignature(message: String): Bool {
}

// A `tearDown` function that always runs at the end of all test cases.
// e.g: Can be used to stop the blockchain back-end used for tests, etc. or any cleanup.
access(all)
fun tearDown() {
}

