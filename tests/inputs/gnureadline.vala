// https://wiki.gnome.org/Projects/Vala/InputSamples?highlight=%28%5CbVala%2FExamples%5Cb%29
void main () {
    while (true) {
        var name = Readline.readline ("Please enter your name: ");
        if (name != null && name != "") {
/*
            stdout.printf ("Hello, %s\n", name);
            Readline.History.add (name);
*/
        } else {
            break;
        }
    }
}
