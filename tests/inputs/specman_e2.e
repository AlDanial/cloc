<'
// All components should have their own package.
package foo_mon;

unit foo_mon_u {

    check() is also {
        if (CFG[ooo].foo_test_record_en) {
            // Following line has code segment delimiter sneakily hidden away
            // The usage model is "writing e code from an e module"
            writef(static, "        TEST_START \"chk\";\n    };\n};\n'>");
            this_is_not_a_comment();
            // Following line has code segment delimiter sneakily hidden away
            writef(static, "        TEST_DONE \"chk\";\n    };\n};\n<'");
        };
    };

};
'>
