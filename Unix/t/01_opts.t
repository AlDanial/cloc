#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
use File::Copy "cp";
use Cwd;
#use YAML qw(LoadFile);
my @Tests = (

                {
                    'name' => '--exclude-dir 1 (baseline for github issue #82)',
                    'args' => '--exclude-dir cc ../tests/inputs/dd',
                    'ref'  => '../tests/outputs/exclude_dir_1.yaml',
                },
                {
                    'name' => '--exclude-dir 2 (github issue #82)',
                    'cd'   => '../tests/inputs/dd',
                    'args' => '--exclude-dir cc *',
                    'ref'  => '../tests/outputs/exclude_dir_1.yaml',
                },
                {
                    'name' => '--not-match-d',
                    'cd'   => '../tests/inputs/dd',
                    'args' => '--not-match-d cc *',
                    'ref'  => '../tests/outputs/exclude_dir_1.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T1)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file issues/114',
                    'ref'  => '../tests/outputs/issues/114/T1.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T2)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --not-match-d bar issues/114',
                    'ref'  => '../tests/outputs/issues/114/T2.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T3)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --not-match-d bee issues/114',
                    'ref'  => '../tests/outputs/issues/114/T3.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T4)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --not-match-d bar/bee issues/114',
                    'ref'  => '../tests/outputs/issues/114/T4.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T5)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --fullpath --not-match-d   bar issues/114',
                    'ref'  => '../tests/outputs/issues/114/T5.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T6)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --fullpath --not-match-d ./bar issues/114',
                    'ref'  => '../tests/outputs/issues/114/T6.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T7)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --fullpath --not-match-d bar/bee issues/114',
                    'ref'  => '../tests/outputs/issues/114/T7.yaml',
                },
              # {
              #     'name' => 'git submodule handling (github issue #131 T1)',
              #     'cd'   => '../tests/inputs',
              #     'args' => 'issues/131',
              #     'ref'  => '../tests/outputs/issues/131/T1.yaml',
              # },
              # {
              #     'name' => 'git submodule handling (github issue #131 T2)',
              #     'cd'   => '../tests/inputs',
              #     'args' => '--vcs git issues/131',
              #     'ref'  => '../tests/outputs/issues/131/T2.yaml',
              # },
                {
                    'name' => 'all files (github issue #132 T1)',
                    'cd'   => '../tests/inputs',
                    'args' => 'issues/132',
                    'ref'  => '../tests/outputs/issues/132/T1.yaml',
                },
                {
                    'name' => '--vcs git issues/132 (github issue #132 T2)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git issues/132',
                    'ref'  => '../tests/outputs/issues/132/T2.yaml',
                },
                {
                    'name' => '--vcs-git --exclude-dir ignore_dir (github issue #132 T3)',
                    'cd'   => '../tests/inputs/issues/132',
                    'args' => '--vcs git --exclude-dir ignore_dir .',
                    'ref'  => '../tests/outputs/issues/132/T3.yaml',
                },
                {
                    'name' => '--vcs git --fullpath --not-match-d issues/132/ignore_dir (github issue #132 T4)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git --fullpath --not-match-d issues/132/ignore_dir issues/132',
                    'ref'  => '../tests/outputs/issues/132/T4.yaml',
                },
                {
                    'name' => '--vcs git --match-f C-Ansi (github issue #132 T5)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git --match-f C-Ansi issues/132',
                    'ref'  => '../tests/outputs/issues/132/T5.yaml',
                },
                {
                    'name' => '--vcs git --match-f "\.c$" (github issue #132 T6)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git --match-f "\.c$" issues/132',
                    'ref'  => '../tests/outputs/issues/132/T6.yaml',
                },
                {
                    'name' => '--vcs "find X" (github issue #147)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs "find foo_bar"',
                    'ref'  => '../tests/outputs/issues/147/T1.yaml',
                },
                {
                    'name' => '--read-lang-def w/remove_between_general (github issue #166)',
                    'cd'   => '../tests/inputs/issues/166',
                    'args' => '--read-lang-def X fake.thy',
                    'ref'  => '../tests/outputs/issues/166/fake.thy.yaml',
                },
                {
                    'name' => '--read-lang-def w/triple_extension',
                    'cd'   => '../tests/inputs',
                    'args' => '--read-lang-def triple_lang_def.txt custom.triple.extension.js',
                    'ref'  => '../tests/outputs/custom.triple.extension.js.yaml',
                },
                {
                    'name' => 'Forth balanced parentheses #1 (github issue #183)',
                    'cd'   => '../tests/inputs/issues/183',
                    'args' => 'file.fth',
                    'ref'  => '../tests/outputs/issues/183/file.fth.yaml',
                },
                {
                    'name' => 'Forth balanced parentheses #2 (github issue #183)',
                    'cd'   => '../tests/inputs/issues/183',
                    'args' => 'eval1957.SACunidir.fr',
                    'ref'  => '../tests/outputs/issues/183/eval1957.SACunidir.fr.yaml',
                },
                {
                    'name' => 'diff identical files (github issue #280)',
                    'cd'   => '../tests/inputs/issues/280',
                    'args' => '--diff L R',
                    'ref'  => '../tests/outputs/issues/280/280.yaml',
                },
                {
                    'name' => 'diff identical files by file (github issue #280)',
                    'cd'   => '../tests/inputs/issues/280',
                    'args' => '--by-file --diff L R',
                    'ref'  => '../tests/outputs/issues/280/280_by_file.yaml',
                },

                {
                    'name' => '--follow-links, --not-match-d, --fullpath  1/6 (github issue #286)',
                    'cd'   => '../tests/inputs/issues/286',
                    'args' => '               --not-match-d ignore_subdir                    project',
                    'ref'  => '../tests/outputs/issues/286/1.yaml',
                },

                {
                    'name' => '--follow-links, --not-match-d, --fullpath  2/6 (github issue #286)',
                    'cd'   => '../tests/inputs/issues/286',
                    'args' => '--follow-links --not-match-d ignore_subdir                    project',

                    'ref'  => '../tests/outputs/issues/286/2.yaml',
                },

                {
                    'name' => '--follow-links, --not-match-d, --fullpath  3/6 (github issue #286)',
                    'cd'   => '../tests/inputs/issues/286',
                    'args' => '               --not-match-d ignore_subdir --fullpath         project',

                    'ref'  => '../tests/outputs/issues/286/3.yaml',
                },

                {
                    'name' => '--follow-links, --not-match-d, --fullpath  4/6 (github issue #286)',
                    'cd'   => '../tests/inputs/issues/286',
                    'args' => '--follow-links --not-match-d ignore_subdir --fullpath         project',
                    'ref'  => '../tests/outputs/issues/286/4.yaml',
                },

                {
                    'name' => '--follow-links, --not-match-d, --fullpath  5/6 (github issue #286)',
                    'cd'   => '../tests/inputs/issues/286',
                    'args' => '               --not-match-d project/ignore_subdir --fullpath project',
                    'ref'  => '../tests/outputs/issues/286/5.yaml',
                },

                {
                    'name' => '--follow-links, --not-match-d, --fullpath  6/6 (github issue #286)',
                    'cd'   => '../tests/inputs/issues/286',
                    'args' => '--follow-links --not-match-d project/ignore_subdir --fullpath project',
                    'ref'  => '../tests/outputs/issues/286/6.yaml',
                },

                {
                    'name' => '--include-ext m,lua (github issue #296)',
                    'cd'   => '../tests/inputs/issues/296',
                    'args' => '--include-ext m,lua .',
                    'ref'  => '../tests/outputs/issues/296/results.yaml',
                },

                {
                    'name' => '--strip-str-comments (github issue #245)',
                    'cd'   => '../tests/inputs/issues/245',
                    'args' => '--strip-str-comments .',
                    'ref'  => '../tests/outputs/issues/245/CRS.scala.yaml',
                },

                {
                    'name' => 'YAML --by-file output with unusual filename (github issue #312)',
                    'cd'   => '../tests/inputs/issues/312',
                    'args' => '--by-file .',
                    'ref'  => '../tests/outputs/issues/312/results.yaml',
                },

                {
                    'name' => 'custom Smarty definition (github issue #327)',
                    'cd'   => '../tests/inputs/issues/327',
                    'args' => '--force-lang-def=lang.config example.smarty2',
                    'ref'  => '../tests/outputs/issues/327/results.yaml',
                },

                {
                    'name' => 'UTF-8 output file encoding',
                    'cd'   => '../tests/inputs/issues/318',
                    'args' => '--by-file --file-encoding utf8 R*.cs',
                    'ref'  => '../tests/inputs/issues/318/Rcs.yaml',  # results in input dir
                },

                {
                    'name' => 'distinguish TeX from VB (github issue #341)',
                    'cd'   => '../tests/inputs/issues/341',
                    'args' => '.',
                    'ref'  => '../tests/outputs/issues/341/results.yaml',
                },

                {
                    'name' => '--strip-str-comments (github issue #350)',
                    'cd'   => '../tests/inputs/issues/350',
                    'args' => '--strip-str-comments .',
                    'ref'  => '../tests/outputs/issues/350/fs.go.yaml',
                },

                {
                    'name' => 'Java comments in strings, issue #365',
                    'cd'   => '../tests/inputs/issues/365',
                    'args' => 'RSpecTests.java',
                    'ref'  => '../tests/outputs/issues/365/results.yaml',
                },

                {
                    'name' => 'Arduino IDE 0xA0 characters',
                    'cd'   => '../tests/inputs/issues/370',
                    'args' => 'arduino_issue_370.ino',
                    'ref'  => '../tests/outputs/issues/370/results.yaml',
                },

                {
                    'name' => 'Python docstrings --docstring-as-code',
                    'cd'   => '../tests/inputs/issues/375',
                    'args' => '--docstring-as-code docstring.py',
                    'ref'  => '../tests/outputs/issues/375/results.yaml',
                },

                {
                    'name' => 'Perl v. Prolog',
                    'cd'   => '../tests/inputs/issues/380',
                    'args' => 'wrapper.pl',
                    'ref'  => '../tests/outputs/issues/380/wrapper.pl.yaml',
                },

                {
                    'name' => 'Java comments and continuation lines issue 381',
                    'cd'   => '../tests/inputs/issues/381',
                    'args' => 'issue381.java',
                    'ref'  => '../tests/outputs/issues/381/issue381.java.yaml',
                },

                {
                    'name' => 'C comments w/ backslashed quote in strings issue 381',
                    'cd'   => '../tests/inputs/issues/381',
                    'args' => '--strip-str-comments issue381.c',
                    'ref'  => '../tests/outputs/issues/381/issue381.c.yaml',
                },

                {
                    'name' => '--exclude-content issue 396',
                    'cd'   => '../tests/inputs',
                    'args' => '--exclude-content Lambda acpclust.R sample.R utilities.R',
                    'ref'  => '../tests/outputs/issues/396/excl.yaml',
                },

                {
                    'name' => '--exclude-content w/--diff issue 396',
                    'cd'   => '../tests/inputs/issues/280',
                    'args' => '--exclude-content Copyright --diff L R',
                    'ref'  => '../tests/outputs/issues/396/excl_diff.yaml',
                },

                {
                    'name' => 'Python with /* in strings issue 405',
                    'cd'   => '../tests/inputs/issues/405',
                    'args' => 'globs.py',
                    'ref'  => '../tests/outputs/issues/405/globs.py.yaml',
                },

                {
                    'name' => '--exclude-dir and --follow-link, #407 1/3',
                    'cd'   => '../tests/inputs/issues/407',
                    'args' => '--follow-link --exclude-dir Test count_dir',
                    'ref'  => '../tests/outputs/issues/407/results1.yaml',
                },

                {
                    'name' => '--exclude-dir and --follow-link, #407 2/3',
                    'cd'   => '../tests/inputs/issues/407',
                    'args' => '--exclude-dir Test level2',
                    'ref'  => '../tests/outputs/issues/407/results2.yaml',
                },

                {
                    'name' => '--exclude-dir and --follow-link, #407 3/3',
                    'cd'   => '../tests/inputs/issues/407',
                    'args' => '--follow-link --exclude-dir Test level2',
                    'ref'  => '../tests/outputs/issues/407/results3.yaml',
                },

                {
                    'name' => 'doubly counted she-bang line, #408',
                    'cd'   => '../tests/inputs/issues/408',
                    'args' => 'badly_named_ruby.pl',
                    'ref'  => '../tests/outputs/issues/408/badly_named_ruby.yaml',
                },

                {
                    'name' => 'case insensitive file ext, #420',
                    'cd'   => '../tests/inputs/issues/420',
                    'args' => '--ignore-case-ext .',
                    'ref'  => '../tests/outputs/issues/420/results.yaml',
                },

                {
                    'name' => 'diff with --exclude-list-file, #433',
                    'cd'   => '../tests/inputs/issues/433',
                    'args' => '--exclude-list-file excl.txt --by-file --follow-links --diff L R
                    ',
                    'ref'  => '../tests/outputs/issues/433/results.yaml',
                },
                {
                    'name' => 'JavaScript comment in string, #454',
                    'cd'   => '../tests/inputs/issues/454',
                    'args' => '--strip-str-comments createServer.js',
                    'ref'  => '../tests/outputs/issues/454/createServer.js.yaml',
                },
                {
                    'name' => 'XML with no extension, #456',
                    'cd'   => '../tests/inputs/issues/456',
                    'args' => 'XML_no_ext',
                    'ref'  => '../tests/outputs/issues/456/XML_no_ext.yaml',
                },
                {
                    'name' => 'XML with unusual extension, #456',
                    'cd'   => '../tests/inputs/issues/456',
                    'args' => 'XML_weird_ext.profile',
                    'ref'  => '../tests/outputs/issues/456/XML_weird_ext.profile.yaml',
                },
                {
                    'name' => 'ignore Algorithm::Diff::sdiff() failures, #463',
                    'cd'   => '../tests/inputs/issues/463',
                    'args' => '--diff left.C right.C',
                    'ref'  => '../tests/outputs/issues/463/diff.yaml',
                },
                {
                    'name' => 'diff list input format 1, #455',
                    'cd'   => '../',
                    'args' => '--diff-list-file tests/inputs/issues/455/list.txt',
                    'ref'  => '../tests/outputs/issues/455/list.yaml',
                },
                {
                    'name' => 'diff list input format 2, #455',
                    'cd'   => '../',
                    'args' => '--diff-list-file tests/inputs/issues/455/list_align.txt',
                    'ref'  => '../tests/outputs/issues/455/list_align.yaml',
                },
                {
                    'name' => 'replace_regex with null, #472',
                    'cd'   => '../tests/inputs/issues/472',
                    'args' => '--force-lang-def lua_def.txt not_really.lua',
                    'ref'  => '../tests/outputs/issues/472/not_really.lua.yaml',
                },
                {
                    'name' => '--exclude-lang --diff 1/3, #476',
                    'cd'   => '../tests/inputs/issues/476',
                    'args' => '--diff A B',
                    'ref'  => '../tests/outputs/issues/476/all.yaml',
                },
                {
                    'name' => '--exclude-lang --diff 2/3, #476',
                    'cd'   => '../tests/inputs/issues/476',
                    'args' => "--exclude-lang 'Fortran 90' --diff A B",
                    'ref'  => '../tests/outputs/issues/476/no_fortran.yaml',
                },
                {
                    'name' => '--exclude-lang --diff 3/3, #476',
                    'cd'   => '../tests/inputs/issues/476',
                    'args' => "--exclude-lang C++ --diff A B",
                    'ref'  => '../tests/outputs/issues/476/no_cpp.yaml',
                },
                # Next test, 482, requires an empty directory B.  Git
                # does not like this so create it at runtime.
                {
                    'name' => '--include-lang --diff, #482',
                    'cd'   => '../tests/inputs/issues/482',
                    'args' => '--include-lang C --diff A B',
                    'ref'  => '../tests/outputs/issues/482/results.yaml',
                },

                {
                    'name' => '--unicode #494',
                    'cd'   => '../tests/inputs/issues/494',
                    'args' => '--unicode --by-file P*.sql',
                    'ref'  => '../tests/outputs/issues/494/results.yaml',
                },

                {
                    'name' => '--diff-list-file #513',
                    'cd'   => '../tests/inputs/issues/513',
                    'args' => '--diff-list-file diff_list.txt',
                    'ref'  => '../tests/outputs/issues/513/results.yaml',
                },

                {
                    'name' => '--list-file BOM #502',
                    'cd'   => '../tests/inputs/issues/502',
                    'args' => '--list-file FileCounter20200715140433.txt',
                    'ref'  => '../tests/outputs/issues/502/results.yaml',
                },

                {
                    'name' => 'Julia with docstring as comment #520 1/2',
                    'cd'   => '../tests/inputs/issues/520',
                    'args' => 'julia_docstr.jl',
                    'ref'  => '../tests/outputs/issues/520/doc_as_comment.yaml',
                },

                {
                    'name' => 'Julia with docstring as comment #520 2/2',
                    'cd'   => '../tests/inputs/issues/520',
                    'args' => '--docstring-as-code julia_docstr.jl',
                    'ref'  => '../tests/outputs/issues/520/doc_as_code.yaml',
                },

                {
                    'name' => 'diff alignment on Windows #521 1/2',
                    'cd'   => '../tests/inputs/issues/521',
                    'args' => '--diff "Test 188" ../521/Test188New',
                    'ref'  => '../tests/outputs/issues/521/uniq.yaml',
                },

                {
                    'name' => 'diff alignment on Windows #521 2/2',
                    'cd'   => '../tests/inputs/issues/521',
                    'args' => '--skip-uniqueness --diff "Test 188" ../521/Test188New',
                    'ref'  => '../tests/outputs/issues/521/skip_uniq.yaml',
                },

                {
                    'name' => '--summary-cutoff (f:1) #528 1/3',
                    'cd'   => '../tests/inputs/issues/528',
                    'args' => '--summary-cutoff f:1 .',
                    'ref'  => '../tests/outputs/issues/528/cutoff_files_1.yaml',
                },

                {
                    'name' => '--summary-cutoff (c:10) #528 2/3',
                    'cd'   => '../tests/inputs/issues/528',
                    'args' => '--summary-cutoff c:10 .',
                    'ref'  => '../tests/outputs/issues/528/cutoff_code_10.yaml',
                },

                {
                    'name' => '--summary-cutoff (c:50%) #528 3/3',
                    'cd'   => '../tests/inputs/issues/528',
                    'args' => '--summary-cutoff c:50% .',
                    'ref'  => '../tests/outputs/issues/528/cutoff_code_50pct.yaml',
                },

                {
                    'name' => '--skip-leading 2 #530 1/4',
                    'cd'   => '../tests/inputs/issues/530',
                    'args' => '--skip-leading 2 .',
                    'ref'  => '../tests/outputs/issues/530/case_1.yaml',
                },

                {
                    'name' => '--skip-leading 100 #530 2/4',
                    'cd'   => '../tests/inputs/issues/530',
                    'args' => '--skip-leading 100 .',
                    'ref'  => '../tests/outputs/issues/530/case_2.yaml',
                },

                {
                    'name' => '--skip-leading 2,c,h #530 3/4',
                    'cd'   => '../tests/inputs/issues/530',
                    'args' => '--skip-leading 2,c,h .',
                    'ref'  => '../tests/outputs/issues/530/case_3.yaml',
                },

                {
                    'name' => '--skip-leading 2,C,H #530 4/4',
                    'cd'   => '../tests/inputs/issues/530',
                    'args' => '--skip-leading 2,C,H .',
                    'ref'  => '../tests/outputs/issues/530/case_4.yaml',
                },

                {
                    'name' => '--force-lang-def #537 1/2',
                    'cd'   => '../tests/inputs/issues/537',
                    'args' => '--force-lang-def my_define.txt sourceCounter.vsql',
                    'ref'  => '../tests/outputs/issues/537/results_force.yaml',
                },

                {
                    'name' => '--read-lang-def #537 2/2',
                    'cd'   => '../tests/inputs/issues/537',
                    'args' => '--read-lang-def my_define.txt sourceCounter.vsql',
                    'ref'  => '../tests/outputs/issues/537/results_read.yaml',
                },

                {
                    'name' => 'Elm empty comment, #538',
                    'cd'   => '../tests/inputs/issues/538',
                    'args' => 'add.elm',
                    'ref'  => '../tests/outputs/issues/538/add.elm.yaml',
                },

                {
                    'name' => 'Elm nested block comments, #539',
                    'cd'   => '../tests/inputs/issues/539',
                    'args' => 'nested_comments.elm',
                    'ref'  => '../tests/outputs/issues/539/nested_comments.elm.yaml',
                },

                {
                    'name' => 'preserve upper/lowercase filenames on Windows, #540',
                    'cd'   => '../tests/inputs/issues/540',
                    'args' => '--windows --by-file Hello.f',
                    'ref'  => '../tests/outputs/issues/540/Hello.f.yaml',
                },

                {
                    'name' => 'accept all file extensions in user-provided language definitions, #542',
                    'cd'   => '../tests/inputs/issues/542',
                    'args' => '--read-lang-def txt_lang_def.txtt txt_lang_def.txtt',
                    'ref'  => '../tests/outputs/issues/542/results.yaml',
                },

                {
                    'name' => 'small unicode files, #580',
                    'cd'   => '../tests/inputs/issues/580',
                    'args' => '--unicode encodingtest.cs',
                    'ref'  => '../tests/outputs/issues/580/encodingtest.cs.yaml',
                },

                {
                    'name' => 'identify autogenerated C#, #579',
                    'cd'   => '../tests/inputs/issues/579',
                    'args' => 'csharp-autogen.cs',
                    'ref'  => '../tests/outputs/issues/579/csharp-autogen.cs.yaml',
                },

                {
                    'name' => 'config file from list file directory, #577',
                    'cd'   => '../tests/inputs/issues/577',
                    'args' => '--diff-list-file diff_list_file.txt',
                    'ref'  => '../tests/outputs/issues/577/diff_list.yaml',
                },

                {
                    'name' => '--force-lang-def without XML definition, #596',
                    'cd'   => '../tests/inputs/issues/596',
                    'args' => '--force-lang-def def.txt .',
                    'ref'  => '../tests/outputs/issues/596/results.yaml',
                },

                {
                    'name' => '--csv-delimiter="#", #597',
                    'cd'   => '../tests/inputs/issues/597',
                    'args' => '--csv-delimiter="#" .',
                    'ref'  => '../tests/outputs/issues/597/results.yaml',
                },

                {
                    'name' => '--unicode (uninitialized value), #606',
                    'cd'   => '../tests/inputs/issues/606',
                    'args' => '--unicode in',
                    'ref'  => '../tests/outputs/issues/606/results.yaml',
                },

                {
                    'name' => 'CMakeLists.txt on Windows (lowercase file), #611',
                    'cd'   => '../tests/inputs/issues/611',
                    'args' => '.',
                    'ref'  => '../tests/outputs/issues/611/cmakelists.txt.yaml',
                },

                {
                    'name' => 'SCSS separate from Sass, #613',
                    'cd'   => '../tests/inputs/issues/613',
                    'args' => '.',
                    'ref'  => '../tests/outputs/issues/613/nav.scss.yaml',
                },

                {
                    'name' => 'sequence of Assembly filters, #619',
                    'cd'   => '../tests/inputs/issues/619',
                    'args' => '.',
                    'ref'  => '../tests/outputs/issues/619/RA.s.yaml',
                },

                {
                    'name' => 'GraphQL descriptions, #628',
                    'cd'   => '../tests/inputs/issues/628',
                    'args' => '.',
                    'ref'  => '../tests/outputs/issues/628/results.yaml',
                },

                {
                    'name' => 'diff with dir of excluded extensions, #625',
                    'cd'   => '../tests/inputs/issues/625',
                    'args' => '--diff old new',
                    'ref'  => '../tests/outputs/issues/625/results.yaml',
                },

                {
                    'name' => 'case insensitive --include-lang, #637',
                    'cd'   => '../tests/inputs/issues/637',
                    'args' => '--include-lang python,perl --follow-links A B',
                    'ref'  => '../tests/outputs/issues/637/straight_incl_lang.yaml',
                },

                {
                    'name' => 'case insensitive --include-lang --diff, #637',
                    'cd'   => '../tests/inputs/issues/637',
                    'args' => '--include-lang python,perl --follow-links --diff A B',
                    'ref'  => '../tests/outputs/issues/637/diff_incl_lang.yaml',
                },

                {
                    'name' => 'empty Unicode file w/only BOM, #644',
                    'cd'   => '../tests/inputs/issues/644',
                    'args' => 'UInt8.cs',
                    'ref'  => '../tests/outputs/issues/644/results.yaml',
                },

                {
                    'name' => '--no-recurse, #657',
                    'cd'   => '../tests/inputs/issues/657',
                    'args' => '--no-recurse .',
                    'ref'  => '../tests/outputs/issues/657/results.yaml',
                },

                {
                    'name' => '--csv-delimiter="|", #670',
                    'cd'   => '../tests/inputs/issues/670',
                    'args' => '--csv-delimiter="|" .',
                    'ref'  => '../tests/outputs/issues/670/results.yaml',
                },

                {
                    'name' => '--diff-list-files, #692',
                    'cd'   => '../tests/inputs/issues/692',
                    'args' => '--diff-list-files A.txt B.txt',
                    'ref'  => '../tests/outputs/issues/692/results.yaml',
                },

                {
                    'name' => 'comments in OCaml strings, #701',
                    'cd'   => '../tests/inputs/issues/701',
                    'args' => '--strip-str-comments demo.ml',
                    'ref'  => '../tests/outputs/issues/701/results.yaml',
                },

                {
                    'name' => '--only-count-files, #708',
                    'cd'   => '../tests/inputs/dd',
                    'args' => '--only-count-files .',
                    'ref'  => '../tests/outputs/issues/708/results.yaml',
                },

                {
                    'name' => '--diff-list-file w/unknown lang, #710',
                    'cd'   => '../tests/inputs/issues/710',
                    'args' => '--diff-list-file test_files.list',
                    'ref'  => '../tests/outputs/issues/710/results.yaml',
                },

            );

# Special cases:

# Create test input for issue #132 which needs data not in the git repo.
# Silently fail if file/dir already exists.
mkdir "../tests/inputs/issues/132/ignore_git";
cp    "../tests/inputs/hi.py", "../tests/inputs/issues/132/ignore_git/";

# Issues #540, #544 regarding case preservation on file systems
# that are case insensitive:  git issues a warning about the
# link hello.f -> Hello.f.  Per https://github.com/mitchblank,
# remove it from git and make it at runtime.
my $work_dir = getcwd;
chdir( "../tests/inputs/issues/540/" );
symlink("Hello.f", "hello.f");
chdir( $work_dir );

my $missing_dir = "../tests/inputs/issues/482/B";
if (!-d $missing_dir) {
    mkdir $missing_dir;
}

my $Verbose = 0;

my $results = 'results.yaml';
my $cloc     = "$work_dir/../cloc";   # all-purpose version
#my $cloc     = "$work_dir/cloc";      # Unix-tuned version
my $Run = "$cloc --quiet --yaml --out $results ";
foreach my $t (@Tests) {
    chdir($t->{'cd'}) if defined $t->{'cd'};
    print "Run  dir= ", cwd(), "\n" if $Verbose;
    print  $Run . $t->{'args'} if $Verbose;
    system($Run . $t->{'args'});
    ok(-e $results, $t->{'name'} . " created output");
    my %this = load_yaml($results);
    unlink $results unless $Verbose;
    chdir($work_dir) if defined $t->{'cd'};
    print "Load dir= ", cwd(), "\n" if $Verbose;
    my %ref  = load_yaml($t->{'ref'});

#   my $REF = LoadFile($t->{'ref'});  # using official YAML module
#   is_deeply($REF , \%this, $t->{'name'} . " results match");

#   use Data::Dumper;
#   print Dumper(\%ref);
#   print Dumper(\%this);

    is_deeply(\%ref, \%this, $t->{'name'} . " results match");
}
done_testing();

sub load_yaml { # {{{1
    my ($file, ) = @_;
    my %result = ();
    if (!-r $file) {
        warn "File not found: $file\n";
        return %result;
    }
    open IN, $file or return %result;
    my $section = undef;
    while (<IN>) {
        next if /^\s*#/ or /^--/;
        if (/^\s*'?(.*?)'?\s*:\s*$/) {
            $section = $1;
            next;
        }
        next unless defined $section;
        next if $section eq 'header';
        chomp;
        s/\s+//g;
        my ($K, $V) = split(':');
        $result{$section}{$K} = $V;
    }
    close IN;
    return %result
} # 1}}}
