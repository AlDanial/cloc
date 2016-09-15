/*
https://raw.githubusercontent.com/Microsoft/TypeScriptSamples/master/greeter/greeter.ts
renamed to greeter.tsx to test .tsx association
*/
class Greeter {
    constructor(public greeting: string) { }
    greet() {
        return "<h1>" + this.greeting + "</h1>";
    }
};

var greeter = new Greeter("Hello, world!");
    
// document.body.innerHTML = greeter.greet();
