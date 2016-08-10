#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
my @Tests = (   {
                    'name' => 'C simple',
                    'args' => '../tests/inputs/C-Ansi.c',
                    'ref'  => '../tests/outputs/C-Ansi.c.yaml',
                },
                {
                    'name' => 'Assembly 1',
                    'ref'  => '../tests/outputs/Assembler-Intel.asm.yaml',
                    'args' => '../tests/inputs/Assembler-Intel.asm',
                },
                {
                    'name' => 'Assembly 2',
                    'ref'  => '../tests/outputs/Assembly-sysv.S.yaml',
                    'args' => '../tests/inputs/Assembly-sysv.S',
                },
                {
                    'name' => 'Antlr',
                    'ref'  => '../tests/outputs/ExprParser.g.yaml',
                    'args' => '../tests/inputs/ExprParser.g',
                },
                
                {
                    'name' => 'Blade',
                    'ref'  => '../tests/outputs/master.blade.php.yaml',
                    'args' => '../tests/inputs/master.blade.php',
                },
                {
                    'name' => 'Brainfuck',
                    'ref'  => '../tests/outputs/hello.bf.yaml',
                    'args' => '../tests/inputs/hello.bf',
                },
                {
                    'name' => 'C# 2',
                    'ref'  => '../tests/outputs/wokka.cs.yaml',
                    'args' => '../tests/inputs/wokka.cs',
                },
                {
                    'name' => 'C/C++ header',
                    'ref'  => '../tests/outputs/locale_facets.h.yaml',
                    'args' => '../tests/inputs/locale_facets.h',
                },
                {
                    'name' => 'Clean',
                    'ref'  => '../tests/outputs/iclean.icl.yaml',
                    'args' => '../tests/inputs/iclean.icl',
                },
                {
                    'name' => 'COBOL',
                    'ref'  => '../tests/outputs/conditions.CBL.yaml',
                    'args' => '../tests/inputs/conditions.CBL',
                },
                {
                    'name' => 'COBOL 2',
                    'ref'  => '../tests/outputs/wokka.cbl.yaml',
                    'args' => '../tests/inputs/wokka.cbl',
                },
                {
                    'name' => 'COBOL 3',
                    'ref'  => '../tests/outputs/Cobol.cbl.yaml',
                    'args' => '../tests/inputs/Cobol.cbl',
                },
                {
                    'name' => 'ColdFusion',
                    'ref'  => '../tests/outputs/ColdFusion.cfm.yaml',
                    'args' => '../tests/inputs/ColdFusion.cfm',
                },
                {
                    'name' => 'C#',
                    'ref'  => '../tests/outputs/C#.cs.yaml',
                    'args' => '../tests/inputs/C#.cs',
                },
                {
                    'name' => 'C++',
                    'ref'  => '../tests/outputs/C++-MFC.cc.yaml',
                    'args' => '../tests/inputs/C++-MFC.cc',
                },
                {
                    'name' => 'C simple',
                    'ref'  => '../tests/outputs/C-Ansi.c.yaml',
                    'args' => '../tests/inputs/C-Ansi.c',
                },
                {
                    'name' => 'dir 1',
                    'ref'  => '../tests/outputs/foo_bar.yaml',
                    'args' => '../tests/inputs/foo_bar',
                },
                {
                    'name' => 'dir 2',
                    'ref'  => '../tests/outputs/dd.yaml',
                    'args' => '../tests/inputs/dd',
                },
                {
                    'name' => 'dir 3',
                    'ref'  => '../tests/outputs/aa.yaml',
                    'args' => '../tests/inputs/aa',
                },
                {
                    'name' => 'DOS batch',
                    'ref'  => '../tests/outputs/MSDOS.bat.yaml',
                    'args' => '../tests/inputs/MSDOS.bat',
                },
                {
                    'name' => 'ECPP',
                    'ref'  => '../tests/outputs/comp.ecpp.yaml',
                    'args' => '../tests/inputs/comp.ecpp',
                },
                {
                    'name' => 'Focus',
                    'ref'  => '../tests/outputs/FOCUS.focexec.yaml',
                    'args' => '../tests/inputs/FOCUS.focexec',
                },
                {
                    'name' => 'Fortran 77',
                    'ref'  => '../tests/outputs/Fortran77.f.yaml',
                    'args' => '../tests/inputs/Fortran77.f',
                },
                {
                    'name' => 'Fortran 77 2',
                    'ref'  => '../tests/outputs/hello.f.yaml',
                    'args' => '../tests/inputs/hello.f',
                },
                {
                    'name' => 'Fortran 90',
                    'ref'  => '../tests/outputs/Fortran90.f90.yaml',
                    'args' => '../tests/inputs/Fortran90.f90',
                },
                {
                    'name' => 'Fortran 90 2',
                    'ref'  => '../tests/outputs/hello.f90.yaml',
                    'args' => '../tests/inputs/hello.f90',
                },
                {
                    'name' => 'Freemarker Template',
                    'ref'  => '../tests/outputs/FreemarkerTemplate.ftl.yaml',
                    'args' => '../tests/inputs/FreemarkerTemplate.ftl',
                },
                {
                    'name' => 'F#',
                    'ref'  => '../tests/outputs/fsharp.fs.yaml',
                    'args' => '../tests/inputs/fsharp.fs',
                },
                {
                    'name' => 'Glade',
                    'ref'  => '../tests/outputs/glade-search-popover.ui.yaml',
                    'args' => '../tests/inputs/glade-search-popover.ui',
                },
                {
                    'name' => 'GLSL',
                    'ref'  => '../tests/outputs/blur.glsl.yaml',
                    'args' => '../tests/inputs/blur.glsl',
                },
                {
                    'name' => 'HAML',
                    'ref'  => '../tests/outputs/just_stuff.haml.yaml',
                    'args' => '../tests/inputs/just_stuff.haml',
                },
                {
                    'name' => 'Haskell',
                    'ref'  => '../tests/outputs/test2.lhs.yaml',
                    'args' => '../tests/inputs/test2.lhs',
                },
                {
                    'name' => 'Haskell 2',
                    'ref'  => '../tests/outputs/test1.lhs.yaml',
                    'args' => '../tests/inputs/test1.lhs',
                },
                {
                    'name' => 'Haskell 3',
                    'ref'  => '../tests/outputs/Haskell.hs.yaml',
                    'args' => '../tests/inputs/Haskell.hs',
                },
                {
                    'name' => 'Haskell 4',
                    'ref'  => '../tests/outputs/test.hs.yaml',
                    'args' => '../tests/inputs/test.hs',
                },
                {
                    'name' => 'Haxe',
                    'ref'  => '../tests/outputs/Sys.hx.yaml',
                    'args' => '../tests/inputs/Sys.hx',
                },
                {
                    'name' => 'IDL',
                    'ref'  => '../tests/outputs/IDL.idl.yaml',
                    'args' => '../tests/inputs/IDL.idl',
                },
                {
                    'name' => 'INI',
                    'ref'  => '../tests/outputs/wpedia.ini.yaml',
                    'args' => '../tests/inputs/wpedia.ini',
                },
                {
                    'name' => 'Java',
                    'ref'  => '../tests/outputs/Java.java.yaml',
                    'args' => '../tests/inputs/Java.java',
                },
                {
                    'name' => 'JSON',
                    'ref'  => '../tests/outputs/glossary.json.yaml',
                    'args' => '../tests/inputs/glossary.json',
                },
                {
                    'name' => 'Julia',
                    'ref'  => '../tests/outputs/julia.jl.yaml',
                    'args' => '../tests/inputs/julia.jl',
                },
                {
                    'name' => 'Kotlin',
                    'ref'  => '../tests/outputs/hello.kt.yaml',
                    'args' => '../tests/inputs/hello.kt',
                },
                {
                    'name' => 'LFE',
                    'ref'  => '../tests/outputs/ping_pong.lfe.yaml',
                    'args' => '../tests/inputs/ping_pong.lfe',
                },
                {
                    'name' => 'Lisp',
                    'ref'  => '../tests/outputs/sharpsign.cl.yaml',
                    'args' => '../tests/inputs/sharpsign.cl',
                },
                {
                    'name' => 'Logtalk',
                    'ref'  => '../tests/outputs/logtalk.lgt.yaml',
                    'args' => '../tests/inputs/logtalk.lgt',
                },
                {
                    'name' => 'Lua',
                    'ref'  => '../tests/outputs/hello.lua.yaml',
                    'args' => '../tests/inputs/hello.lua',
                },
                {
                    'name' => 'Makefile',
                    'ref'  => '../tests/outputs/Makefile.yaml',
                    'args' => '../tests/inputs/Makefile',
                },
                {
                    'name' => 'Makefile 2',
                    'ref'  => '../tests/outputs/mfile.mk.yaml',
                    'args' => '../tests/inputs/mfile.mk',
                },
                {
                    'name' => 'Mathematica',
                    'ref'  => '../tests/outputs/Mathematica_1.m.yaml',
                    'args' => '../tests/inputs/Mathematica_1.m',
                },
                {
                    'name' => 'Mathematica 2',
                    'ref'  => '../tests/outputs/Mathematica_2.wlt.yaml',
                    'args' => '../tests/inputs/Mathematica_2.wlt',
                },
                {
                    'name' => 'MATLAB',
                    'ref'  => '../tests/outputs/Octave.m.yaml',
                    'args' => '../tests/inputs/Octave.m',
                },
                {
                    'name' => 'MATLAB 2',
                    'ref'  => '../tests/outputs/Lanczos.m.yaml',
                    'args' => '../tests/inputs/Lanczos.m',
                },
                {
                    'name' => 'Mumps',
                    'ref'  => '../tests/outputs/Mumps.mps.yaml',
                    'args' => '../tests/inputs/Mumps.mps',
                },
                {
                    'name' => 'Mustache',
                    'ref'  => '../tests/outputs/x.mustache.yaml',
                    'args' => '../tests/inputs/x.mustache',
                },
                {
                    'name' => 'Mustache 2',
                    'ref'  => '../tests/outputs/includes_demo.mustache.yaml',
                    'args' => '../tests/inputs/includes_demo.mustache',
                },
                {
                    'name' => 'MXML',
                    'ref'  => '../tests/outputs/drupal.mxml.yaml',
                    'args' => '../tests/inputs/drupal.mxml',
                },
                {
                    'name' => 'Nim',
                    'ref'  => '../tests/outputs/statcsv.nim.yaml',
                    'args' => '../tests/inputs/statcsv.nim',
                },
                {
                    'name' => 'Objective C',
                    'ref'  => '../tests/outputs/qsort_demo.m.yaml',
                    'args' => '../tests/inputs/qsort_demo.m',
                },
                {
                    'name' => 'Pascal',
                    'ref'  => '../tests/outputs/Pascal.pas.yaml',
                    'args' => '../tests/inputs/Pascal.pas',
                },
                {
                    'name' => 'Pascal 2',
                    'ref'  => '../tests/outputs/Pascal.pp.yaml',
                    'args' => '../tests/inputs/Pascal.pp',
                },
                {
                    'name' => 'Pascal 3',
                    'ref'  => '../tests/outputs/hello1.pas.yaml',
                    'args' => '../tests/inputs/hello1.pas',
                },
                {
                    'name' => 'Pascal 4',
                    'ref'  => '../tests/outputs/hello.pas.yaml',
                    'args' => '../tests/inputs/hello.pas',
                },
                {
                    'name' => 'PHP',
                    'ref'  => '../tests/outputs/test1.inc.yaml',
                    'args' => '../tests/inputs/test1.inc',
                },
                {
                    'name' => 'PHP 2',
                    'ref'  => '../tests/outputs/test1.php.yaml',
                    'args' => '../tests/inputs/test1.php',
                },
                {
                    'name' => 'Pig Latin',
                    'ref'  => '../tests/outputs/script1-hadoop.pig.yaml',
                    'args' => '../tests/inputs/script1-hadoop.pig',
                },
                {
                    'name' => 'PO File',   
                    'ref'  => '../tests/outputs/en_AU.po.yaml',
                    'args' => '../tests/inputs/en_AU.po',
                },
                {
                    'name' => 'PL/I',
                    'ref'  => '../tests/outputs/hello.pl1.yaml',
                    'args' => '../tests/inputs/hello.pl1',
                },
                {
                    'name' => 'Puppet',
                    'ref'  => '../tests/outputs/modules1-ntp1.pp.yaml',
                    'args' => '../tests/inputs/modules1-ntp1.pp',
                },
                {
                    'name' => 'Qt Linguist',
                    'ref'  => '../tests/outputs/i18n_de.ts.yaml',
                    'args' => '../tests/inputs/i18n_de.ts',
                },
                {
                    'name' => 'R_2',
                    'ref'  => '../tests/outputs/acpclust.R.yaml',
                    'args' => '../tests/inputs/acpclust.R',
                },
                {
                    'name' => 'Racket',
                    'ref'  => '../tests/outputs/md5.rkt.yaml',
                    'args' => '../tests/inputs/md5.rkt',
                },
                {
                    'name' => 'Razor',
                    'ref'  => '../tests/outputs/razor.cshtml.yaml',
                    'args' => '../tests/inputs/razor.cshtml',
                },
                {
                    'name' => 'RobotFramework',
                    'ref'  => '../tests/outputs/robotframework.tsv.yaml',
                    'args' => '../tests/inputs/robotframework.tsv',
                },
                {
                    'name' => 'R',
                    'ref'  => '../tests/outputs/sample.R.yaml',
                    'args' => '../tests/inputs/sample.R',
                },
                {
                    'name' => 'R',
                    'ref'  => '../tests/outputs/utilities.R.yaml',
                    'args' => '../tests/inputs/utilities.R',
                },
                {
                    'name' => 'Ruby',
                    'ref'  => '../tests/outputs/messages.rb.yaml',
                    'args' => '../tests/inputs/messages.rb',
                },
                {
                    'name' => 'SASS',
                    'ref'  => '../tests/outputs/style.scss.yaml',
                    'args' => '../tests/inputs/style.scss',
                },
                {
                    'name' => 'Slim',
                    'ref'  => '../tests/outputs/Slim.html.slim.yaml',
                    'args' => '../tests/inputs/Slim.html.slim',
                },
                {
                    'name' => 'Swift',
                    'ref'  => '../tests/outputs/tour.swift.yaml',
                    'args' => '../tests/inputs/tour.swift',
                },
                {
                    'name' => 'Tcl/Tk',
                    'ref'  => '../tests/outputs/Tk.yaml',
                    'args' => '../tests/inputs/Tk',
                },
                {
                    'name' => 'TeX',
                    'ref'  => '../tests/outputs/LaTeX.tex.yaml',
                    'args' => '../tests/inputs/LaTeX.tex',
                },
                {
                    'name' => 'TTCN',
                    'ref'  => '../tests/outputs/clusterConf.ttcn.yaml',
                    'args' => '../tests/inputs/clusterConf.ttcn',
                },
                {
                    'name' => 'TypeScript 2',
                    'ref'  => '../tests/outputs/warship.ts.yaml',
                    'args' => '../tests/inputs/warship.ts',
                },
                {
                    'name' => 'TypeScript',
                    'ref'  => '../tests/outputs/TypeScript.ts.yaml',
                    'args' => '../tests/inputs/TypeScript.ts',
                },
                {
                    'name' => 'VB.Net',
                    'ref'  => '../tests/outputs/VisualBasic.Net.vba.yaml',
                    'args' => '../tests/inputs/VisualBasic.Net.vba',
                },
                {
                    'name' => 'Verilog',
                    'ref'  => '../tests/outputs/verilog.sv.yaml',
                    'args' => '../tests/inputs/verilog.sv',
                },
                {
                    'name' => 'Vuejs Component',
                    'ref'  => '../tests/outputs/ItemView.vue.yaml',
                    'args' => '../tests/inputs/ItemView.vue',
                },
                {
                    'name' => 'Windows Message',
                    'ref'  => '../tests/outputs/ZosMsg.mc.yaml',
                    'args' => '../tests/inputs/ZosMsg.mc',
                },
                {
                    'name' => 'Windows Message 2',
                    'ref'  => '../tests/outputs/Sample.mc.yaml',
                    'args' => '../tests/inputs/Sample.mc',
                },
                {
                    'name' => 'Windows Module',
                    'ref'  => '../tests/outputs/ZosNp.def.yaml',
                    'args' => '../tests/inputs/ZosNp.def',
                },
                {
                    'name' => 'Windows Resource',
                    'ref'  => '../tests/outputs/ZosNet.rc.yaml',
                    'args' => '../tests/inputs/ZosNet.rc',
                },
                {
                    'name' => 'xBase',
                    'ref'  => '../tests/outputs/harbour_xbase.prg.yaml',
                    'args' => '../tests/inputs/harbour_xbase.prg',
                },
                {
                    'name' => 'XML',
                    'ref'  => '../tests/outputs/XML.xml.yaml',
                    'args' => '../tests/inputs/XML.xml',
                },
                {
                    'name' => 'XQuery',
                    'ref'  => '../tests/outputs/pop_by_country.xq.yaml',
                    'args' => '../tests/inputs/pop_by_country.xq',
                },
                {
                    'name' => 'XSLT',
                    'ref'  => '../tests/outputs/XSL-FO.xsl.yaml',
                    'args' => '../tests/inputs/XSL-FO.xsl',
                },
                {
                    'name' => 'XSLT 2',
                    'ref'  => '../tests/outputs/XSLT.xslt.yaml',
                    'args' => '../tests/inputs/XSLT.xslt',
                },
            );

my $Verbose = 0;

my $results = 'results.yaml';
my $Run = "../cloc --quiet --yaml --out $results ";
foreach my $t (@Tests) {
    print  $Run . $t->{'args'} if $Verbose;
    system($Run . $t->{'args'});
    ok(-e $results, $t->{'name'} . " created output");
    my %ref  = load_yaml($t->{'ref'});
    my %this = load_yaml($results);
    is_deeply(\%ref, \%this, $t->{'name'} . " results match");
}
done_testing();

sub load_yaml {
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
        if (/^(\w+)\s*:\s*$/) {
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
}
