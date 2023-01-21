/*
http://the-witness.net/news/2018/03/testing-the-jai-compiler/
with init_thing commented out
*/
#import "Basic";

Thing :: struct {
    mem : *u8;
    value := 42;
    #constructor init_thing;
    #destructor free_thing;
}

// init_thing :: (using thing : *$T) {
//     mem = alloc(1000);
// }

free_thing :: (using thing: *$T) {
    free(mem);
    mem = null;
    print("Thing memory freed.\n");
}

main :: () {
    {
        our_thing : Thing; // Constructor fires off.
        print("%\n", our_thing);
    } // Destructor fires off.
}
