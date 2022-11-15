#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
use Cwd;
my @Tests = (
                {
                    'name' => 'Agda',
                    'ref'  => '../tests/outputs/Lookup.agda.yaml',
                    'args' => '../tests/inputs/Lookup.agda',
                },
                {
                    'name' => 'Apex Class',
                    'ref'  => '../tests/outputs/RemoteSiteHelperTest.cls.yaml',
                    'args' => '../tests/inputs/RemoteSiteHelperTest.cls',
                },
                {
                    'name' => 'APL',
                    'ref'  => '../tests/outputs/rand.apl.yaml',
                    'args' => '../tests/inputs/rand.apl',
                },
                {
                    'name' => 'AsciiDoc',
                    'ref'  => '../tests/outputs/asciidoctor.adoc.yaml',
                    'args' => '../tests/inputs/asciidoctor.adoc',
                },
                {
                    'name' => 'ASP.NET 1',
                    'ref'  => '../tests/outputs/page_layout.aspx.yaml',
                    'args' => '../tests/inputs/page_layout.aspx',
                },
                {
                    'name' => 'ASP.NET 2',
                    'ref'  => '../tests/outputs/server_side.aspx.yaml',
                    'args' => '../tests/inputs/server_side.aspx',
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
                    'name' => 'Assembly 3',
                    'ref'  => '../tests/outputs/zos_assembly.s.yaml',
                    'args' => '../tests/inputs/zos_assembly.s',
                },
                {
                    'name' => 'ANTLR Grammar 1',
                    'ref'  => '../tests/outputs/ExprParser.g.yaml',
                    'args' => '../tests/inputs/ExprParser.g',
                },
                {
                    'name' => 'ANTLR Grammar 2',
                    'ref'  => '../tests/outputs/C.g4.yaml',
                    'args' => '../tests/inputs/C.g4',
                },
                {
                    'name' => 'Bazel',
                    'ref'  => '../tests/outputs/BUILD.yaml',
                    'args' => '../tests/inputs/BUILD',
                },
                {
                    'name' => 'BizTalk Orchestration',
                    'ref'  => '../tests/outputs/ProcessPO.odx.yaml',
                    'args' => '../tests/inputs/ProcessPO.odx',
                },
                {
                    'name' => 'BizTalk Pipeline',
                    'ref'  => '../tests/outputs/XmlToJSONSendPipeline.btp.yaml',
                    'args' => '--unicode ../tests/inputs/XmlToJSONSendPipeline.btp',
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
                    'name' => 'BrightScript',
                    'ref'  => '../tests/outputs/roku.brs.yaml',
                    'args' => '../tests/inputs/roku.brs',
                },
                {
                    'name' => 'C simple',
                    'args' => '../tests/inputs/C-Ansi.c',
                    'ref'  => '../tests/outputs/C-Ansi.c.yaml',
                },
                {
                    'name' => 'C# 1',
                    'ref'  => '../tests/outputs/C#.cs.yaml',
                    'args' => '../tests/inputs/C#.cs',
                },
                {
                    'name' => 'C# 2',
                    'ref'  => '../tests/outputs/wokka.cs.yaml',
                    'args' => '../tests/inputs/wokka.cs',
                },
                {
                    'name' => 'C# 3',
                    'ref'  => '../tests/outputs/assembly.cs.yaml',
                    'args' => '../tests/inputs/assembly.cs',
                },
                {
                    'name' => 'C# Designer',
                    'ref'  => '../tests/outputs/csharp-designer.designer.cs.yaml',
                    'args' => '../tests/inputs/csharp-designer.designer.cs',
                },
                {
                    'name' => 'C/C++ header',
                    'ref'  => '../tests/outputs/locale_facets.h.yaml',
                    'args' => '../tests/inputs/locale_facets.h',
                },
                {
                    'name' => 'Cairo',
                    'ref'  => '../tests/outputs/ERC20.cairo.yaml',
                    'args' => '../tests/inputs/ERC20.cairo',
                },
                {
                    'name' => 'Cake Build Script',
                    'ref'  => '../tests/outputs/build.cake.yaml',
                    'args' => '../tests/inputs/build.cake',
                },
                {
                    'name' => 'Circom',
                    'ref'  => '../tests/outputs/eddsa.circom.yaml',
                    'args' => '../tests/inputs/eddsa.circom',
                },
                {
                    'name' => 'Chapel',
                    'ref'  => '../tests/outputs/Chapel.chpl.yaml',
                    'args' => '../tests/inputs/Chapel.chpl',
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
                    'name' => 'Containerfile',
                    'ref'  => '../tests/outputs/Containerfile.yaml',
                    'args' => '../tests/inputs/Containerfile',
                },
                {
                    'name' => 'C++',
                    'ref'  => '../tests/outputs/C++-MFC.cc.yaml',
                    'args' => '../tests/inputs/C++-MFC.cc',
                },
                {
                    'name' => 'C++ Uppercase extension',
                    'ref'  => '../tests/outputs/C++-uppercase.CPP.yaml',
                    'args' => '../tests/inputs/C++-uppercase.CPP',
                },
                {
                    'name' => 'Carbon',
                    'ref'  => '../tests/outputs/variable_length.carbon.yaml',
                    'args' => '../tests/inputs/variable_length.carbon',
                },
                {
                    'name' => 'C simple',
                    'ref'  => '../tests/outputs/C-Ansi.c.yaml',
                    'args' => '../tests/inputs/C-Ansi.c',
                },
                {
                    'name' => 'CSV',
                    'ref'  => '../tests/outputs/cloc_counts.csv.yaml',
                    'args' => '../tests/inputs/cloc_counts.csv',
                },
                {
                    'name' => 'Cucumber',
                    'ref'  => '../tests/outputs/cucumber.feature.yaml',
                    'args' => '../tests/inputs/cucumber.feature',
                },
                {
                    'name' => 'DenizenScript',
                    'ref'  => '../tests/outputs/double_doors.dsc.yaml',
                    'args' => '../tests/inputs/double_doors.dsc',
                },
                {
                    'name' => 'Derw',
                    'ref'  => '../tests/outputs/complex_union.derw.yaml',
                    'args' => '../tests/inputs/complex_union.derw',
                },
                {
                    'name' => 'dhall',
                    'ref'  => '../tests/outputs/Prelude.dhall.yaml',
                    'args' => '../tests/inputs/Prelude.dhall',
                },
                {
                    'name' => 'DIET',
                    'ref'  => '../tests/outputs/layout.dt.yaml',
                    'args' => '../tests/inputs/layout.dt',
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
                    'name' => 'Dockerfile',
                    'ref'  => '../tests/outputs/Dockerfile.yaml',
                    'args' => '../tests/inputs/Dockerfile',
                },
                {
                    'name' => 'DOS batch',
                    'ref'  => '../tests/outputs/MSDOS.bat.yaml',
                    'args' => '../tests/inputs/MSDOS.bat',
                },
                {
                    'name' => 'Drools',
                    'ref'  => '../tests/outputs/drools.drl.yaml',
                    'args' => '../tests/inputs/drools.drl',
                },
                {
                    'name' => 'ECPP',
                    'ref'  => '../tests/outputs/comp.ecpp.yaml',
                    'args' => '../tests/inputs/comp.ecpp',
                },
                {
                    'name' => 'EJS',
                    'ref'  => '../tests/outputs/sample.ejs.yaml',
                    'args' => '../tests/inputs/sample.ejs',
                },
                {
                    'name' => 'Elixir',
                    'ref'  => '../tests/outputs/elixir.ex.yaml',
                    'args' => '../tests/inputs/elixir.ex',
                },
                {
                    'name' => 'Embedded Crystal',
                    'ref'  => '../tests/outputs/capture.ecr.yaml',
                    'args' => '../tests/inputs/capture.ecr',
                },
                {
                    'name' => 'Fennel',    
                    'ref'  => '../tests/outputs/generate.fnl.yaml',
                    'args' => '../tests/inputs/generate.fnl',
                },
                {
                    'name' => 'Finite State Language',
                    'ref'  => '../tests/outputs/traffic_light.fsl.yaml',
                    'args' => '../tests/inputs/traffic_light.fsl',
                },
                {
                    'name' => 'Fish Shell',
                    'ref'  => '../tests/outputs/git_helpers.fish.yaml',
                    'args' => '../tests/inputs/git_helpers.fish',
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
                    'name' => 'Futhark',
                    'ref'  => '../tests/outputs/futhark.fut.yaml',
                    'args' => '../tests/inputs/futhark.fut',
                },
                {
                    'name' => 'FXML',
                    'ref'  => '../tests/outputs/vbox.fxml.yaml',
                    'args' => '../tests/inputs/vbox.fxml',
                },
                {
                    'name' => 'F#',
                    'ref'  => '../tests/outputs/fsharp.fs.yaml',
                    'args' => '../tests/inputs/fsharp.fs',
                },
                {
                    'name' => 'F# Script',
                    'ref'  => '../tests/outputs/fsharp_script.fsx.yaml',
                    'args' => '../tests/inputs/fsharp_script.fsx',
                },
                {
                    'name' => 'Flatbuffers',
                    'ref'  => '../tests/outputs/flatbuffers.fbs.yaml',
                    'args' => '../tests/inputs/flatbuffers.fbs',
                },
                {
                    'name' => 'Gencat NLS',
                    'ref'  => '../tests/outputs/Gencat-NLS.msg.yaml',
                    'args' => '../tests/inputs/Gencat-NLS.msg',
                },
                {
                    'name' => 'Glade',
                    'ref'  => '../tests/outputs/glade-search-popover.ui.yaml',
                    'args' => '../tests/inputs/glade-search-popover.ui',
                },
                {
                    'name' => 'Gleam',
                    'ref'  => '../tests/outputs/string.gleam.yaml',
                    'args' => '../tests/inputs/string.gleam',
                },
                {
                    'name' => 'GLSL',
                    'ref'  => '../tests/outputs/blur.glsl.yaml',
                    'args' => '../tests/inputs/blur.glsl',
                },
                {
                    'name' => 'Go',
                    'ref'  => '../tests/outputs/hello_app.go-1.yaml',
                    'args' => '../tests/inputs/hello_app*.go',
                },
                {
                    'name' => 'Go --no-autogen',
                    'ref'  => '../tests/outputs/hello_app.go-2.yaml',
                    'args' => '--no-autogen ../tests/inputs/hello_app*.go',
                },
                {
                    'name' => 'Godot Scene',
                    'ref'  => '../tests/outputs/GamePanel.tscn.yaml',
                    'args' => '../tests/inputs/GamePanel.tscn',
                },
                {
                    'name' => 'Godot Shaders',
                    'ref'  => '../tests/outputs/example_2d.gdshader.yaml',
                    'args' => '../tests/inputs/example_2d.gdshader',
                },
                {
                    'name' => 'Godot Resource',
                    'ref'  => '../tests/outputs/door.tres.yaml',
                    'args' => '../tests/inputs/door.tres',
                },
                {
                    'name' => 'Groovy',
                    # issue #139; avoid
                    # Complex regular subexpression recursion limit (32766) exceeded
                    'ref'  => '../tests/outputs/regex_limit.gradle.yaml',
                    'args' => '../tests/inputs/regex_limit.gradle',
                },
                {
                    'name' => 'GraphQL',
                    'ref'  => '../tests/outputs/graphql.gql.yaml',
                    'args' => '../tests/inputs/graphql.gql',
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
                    'name' => 'HCL',
                    'ref'  => '../tests/outputs/nomad_job.hcl.yaml',
                    'args' => '../tests/inputs/nomad_job.hcl',
                },
                {
                    'name' => 'HolyC',
                    'ref'  => '../tests/outputs/Once.HC.yaml',
                    'args' => '../tests/inputs/Once.HC',
                },
                {
                    'name' => 'Hoon',
                    'ref'  => '../tests/outputs/arvo.hoon.yaml',
                    'args' => '../tests/inputs/arvo.hoon',
                },
                {
                    'name' => 'HTML EEx',
                    'ref'  => '../tests/outputs/html_heex_example.heex.yaml',
                    'args' => '../tests/inputs/html_heex_example.heex',
                },
                {
                    'name' => 'IDL 1',
                    'ref'  => '../tests/outputs/IDL.idl.yaml',
                    'args' => '../tests/inputs/IDL.idl',
                },
                {
                    'name' => 'IDL 2',
                    'ref'  => '../tests/outputs/streamlines.pro.yaml',
                    'args' => '../tests/inputs/streamlines.pro',
                },
                {
                    'name' => 'Idris',
                    'ref'  => '../tests/outputs/Combinators.idr.yaml',
                    'args' => '../tests/inputs/Combinators.idr',
                },
                {
                    'name' => 'Idris (block comments)',
                    'ref'  => '../tests/outputs/idris_block_comments.idr.yaml',
                    'args' => '../tests/inputs/idris_block_comments.idr',
                },
                {
                    'name' => 'Igor Pro',
                    'ref'  => '../tests/outputs/igorpro.ipf.yaml',
                    'args' => '../tests/inputs/igorpro.ipf',
                },
                {
                    'name' => 'Jinja Templates',
                    'ref'  => '../tests/outputs/child_template.jinja2.yaml',
                    'args' => '../tests/inputs/child_template.jinja2',
                },
                {
                    'name' => 'Jupyter Notebook',
                    'ref'  => '../tests/outputs/Trapezoid_Rule.ipynb.yaml',
                    'args' => '../tests/inputs/Trapezoid_Rule.ipynb',
                },
                {
                    'name' => 'Juniper Junos',
                    'ref'  => '../tests/outputs/config.junos.yaml',
                    'args' => '../tests/inputs/config.junos',
                },
                {
                    'name' => 'Imba',
                    'ref'  => '../tests/outputs/class.imba.yaml',
                    'args' => '../tests/inputs/class.imba',
                },
                {
                    'name' => 'INI',
                    'ref'  => '../tests/outputs/wpedia.ini.yaml',
                    'args' => '../tests/inputs/wpedia.ini',
                },
                {
                    'name' => 'IPL',
                    'ref'  => '../tests/outputs/insertJournalEntry.ipl.yaml',
                    'args' => '../tests/inputs/insertJournalEntry.ipl',
                },
                {
                    'name' => 'Java',
                    'ref'  => '../tests/outputs/Java.java.yaml',
                    'args' => '../tests/inputs/Java.java',
                },
                {
                    'name' => 'JCL',
                    'ref'  => '../tests/outputs/offline.jcl.yaml',
                    'args' => '../tests/inputs/offline.jcl',
                },
                {
                    'name' => 'JSON',
                    'ref'  => '../tests/outputs/glossary.json.yaml',
                    'args' => '../tests/inputs/glossary.json',
                },
                {
                    'name' => 'JSON5',
                    'ref'  => '../tests/outputs/glossary.json5.yaml',
                    'args' => '../tests/inputs/glossary.json5',
                },
                {
                    'name' => 'Julia',
                    'ref'  => '../tests/outputs/julia.jl.yaml',
                    'args' => '../tests/inputs/julia.jl',
                },
                {
                    'name' => 'kvlang',
                    'ref'  => '../tests/outputs/kvlang.kv.yaml',
                    'args' => '../tests/inputs/kvlang.kv',
                },
                {
                    'name' => 'Kotlin',
                    'ref'  => '../tests/outputs/hello.kt.yaml',
                    'args' => '../tests/inputs/hello.kt',
                },
                {
                    'name' => 'Lean',
                    'ref'  => '../tests/outputs/dlist.lean.yaml',
                    'args' => '../tests/inputs/dlist.lean',
                },
                {
                    'name' => 'Lem',
                    'ref'  => '../tests/outputs/machineDefFreshIds.lem.yaml',
                    'args' => '../tests/inputs/machineDefFreshIds.lem',
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
                    'name' => 'Literate Idris',
                    'ref'  => '../tests/outputs/Hello.lidr.yaml',
                    'args' => '../tests/inputs/Hello.lidr',
                },
                {
                    'name' => 'LLVM IR',
                    'ref'  => '../tests/outputs/DIEnumerator-10.0.ll.yaml',
                    'args' => '../tests/inputs/DIEnumerator-10.0.ll',
                },
                {
                    'name' => 'Logos 1',
                    'ref'  => '../tests/outputs/logos.x.yaml',
                    'args' => '../tests/inputs/logos.x',
                },
                {
                    'name' => 'Logos 2',
                    'ref'  => '../tests/outputs/logos.xm.yaml',
                    'args' => '../tests/inputs/logos.xm',
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
                    'name' => 'Lua nested comments',
                    'ref'  => '../tests/outputs/nested.lua.yaml',
                    'args' => '../tests/inputs/nested.lua',
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
                    'name' => 'Mako',
                    'ref'  => '../tests/outputs/Mako.mako.yaml',
                    'args' => '../tests/inputs/Mako.mako',
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
                    'name' => 'MATLAB 3',
                    'ref'  => '../tests/outputs/matlab_line_colors.m.yaml',
                    'args' => '../tests/inputs/matlab_line_colors.m',
                },
                {
                    'name' => 'Meson',
                    'ref'  => '../tests/outputs/meson.build.yaml',
                    'args' => '../tests/inputs/meson.build',
                },
                {
                    'name' => 'Metal',
                    'ref'  => '../tests/outputs/RenderTest.metal.yaml',
                    'args' => '../tests/inputs/RenderTest.metal',
                },
                {
                    'name' => 'Mojo',
                    'ref'  => '../tests/outputs/Mojo.mojom.yaml',
                    'args' => '../tests/inputs/Mojo.mojom',
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
                    'name' => 'Nix',
                    'ref'  => '../tests/outputs/darwin-configuration.nix.yaml',
                    'args' => '../tests/inputs/darwin-configuration.nix',
                },
                {
                    'name' => 'Nunjucks',
                    'ref'  => '../tests/outputs/child_template.njk.yaml',
                    'args' => '../tests/inputs/child_template.njk',
                },
                {
                    'name' => 'Objective-C',
                    'ref'  => '../tests/outputs/qsort_demo.m.yaml',
                    'args' => '../tests/inputs/qsort_demo.m',
                },
                {
                    'name' => 'Odin',
                    'ref'  => '../tests/outputs/demo.odin.yaml',
                    'args' => '../tests/inputs/demo.odin',
                },
                {
                    'name' => 'OpenSCAD',
                    'ref'  => '../tests/outputs/Rounds.scad.yaml',
                    'args' => '../tests/inputs/Rounds.scad',
                },
                {
                    'name' => 'Oracle PL/SQL',
                    'ref'  => '../tests/outputs/bubs_tak_ard.prc.yaml',
                    'args' => '../tests/inputs/bubs_tak_ard.prc',
                },
                {
                    'name' => 'P4',
                    'ref'  => '../tests/outputs/basic.p4.yaml',
                    'args' => '../tests/inputs/basic.p4',
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
                    'name' => 'PEG',
                    'ref'  => '../tests/outputs/sdp_parser.peg.yaml',
                    'args' => '../tests/inputs/sdp_parser.peg',
                },
                {
                    'name' => 'pegjs',
                    'ref'  => '../tests/outputs/sdp_parser.pegjs.yaml',
                    'args' => '../tests/inputs/sdp_parser.pegjs',
                },
                {
                    'name' => 'peggy',
                    'ref'  => '../tests/outputs/sdp_parser.peggy.yaml',
                    'args' => '../tests/inputs/sdp_parser.peggy',
                },
                {
                    'name' => 'tspeg 1',
                    'ref'  => '../tests/outputs/sdp_parser.tspeg.yaml',
                    'args' => '../tests/inputs/sdp_parser.tspeg',
                },
                {
                    'name' => 'tspeg 2',
                    'ref'  => '../tests/outputs/sdp_parser.jspeg.yaml',
                    'args' => '../tests/inputs/sdp_parser.jspeg',
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
                    'name' => 'PL/I',
                    'ref'  => '../tests/outputs/hello.pl1.yaml',
                    'args' => '../tests/inputs/hello.pl1',
                },
                {
                    'name' => 'PL/M',
                    'ref'  => '../tests/outputs/find.plm.yaml',
                    'args' => '../tests/inputs/find.plm',
                },
                {
                    'name' => 'PlantUML',
                    'ref'  => '../tests/outputs/plantuml.puml.yaml',
                    'args' => '../tests/inputs/plantuml.puml',
                },
                {
                    'name' => 'PO File',
                    'ref'  => '../tests/outputs/en_AU.po.yaml',
                    'args' => '../tests/inputs/en_AU.po',
                },
                {
                    'name' => 'ProGuard',
                    'ref'  => '../tests/outputs/proguard-project-app.pro.yaml',
                    'args' => '../tests/inputs/proguard-project-app.pro',
                },
                {
                    'name' => 'Prolog',
                    'ref'  => '../tests/outputs/birds.pro.yaml',
                    'args' => '../tests/inputs/birds.pro',
                },
                {
                    'name' => 'Properties',
                    'ref'  => '../tests/outputs/wiki.properties.yaml',
                    'args' => '../tests/inputs/wiki.properties',
                },
                {
                    'name' => 'Puppet class',
                    'ref'  => '../tests/outputs/modules1-ntp1.pp.yaml',
                    'args' => '../tests/inputs/modules1-ntp1.pp',
                },
                {
                    'name' => 'Puppet function without arguments',
                    'ref'  => '../tests/outputs/modules1-func1.pp.yaml',
                    'args' => '../tests/inputs/modules1-func1.pp',
                },
                {
                    'name' => 'Puppet function with arguments',
                    'ref'  => '../tests/outputs/modules1-func2.pp.yaml',
                    'args' => '../tests/inputs/modules1-func2.pp',
                },
                {
                    'name' => 'Puppet typealias',
                    'ref'  => '../tests/outputs/modules1-typealias.pp.yaml',
                    'args' => '../tests/inputs/modules1-typealias.pp',
                },
                {
                    'name' => 'Python',
                    'ref'  => '../tests/outputs/hi.py.yaml',
                    'args' => '../tests/inputs/hi.py',
                },
                {
                    'name' => 'Python wheel file',
                    'ref'  => '../tests/outputs/test-1.0-py2.py3-none-win32.whl.yaml',
                    'args' => '../tests/inputs/test-1.0-py2.py3-none-win32.whl',
                },
                {
                    'name' => 'Qt Linguist',
                    'ref'  => '../tests/outputs/i18n_de.ts.yaml',
                    'args' => '../tests/inputs/i18n_de.ts',
                },
                {
                    'name' => 'R 1',
                    'ref'  => '../tests/outputs/sample.R.yaml',
                    'args' => '../tests/inputs/sample.R',
                },
                {
                    'name' => 'R 2',
                    'ref'  => '../tests/outputs/utilities.R.yaml',
                    'args' => '../tests/inputs/utilities.R',
                },
                {
                    'name' => 'R 3',
                    'ref'  => '../tests/outputs/acpclust.R.yaml',
                    'args' => '../tests/inputs/acpclust.R',
                },
                {
                    'name' => 'Racket',
                    'ref'  => '../tests/outputs/md5.rkt.yaml',
                    'args' => '../tests/inputs/md5.rkt',
                },
                {
                    'name' => 'Ring',
                    'ref'  => '../tests/outputs/tictactoe3d.ring.yaml',
                    'args' => '../tests/inputs/tictactoe3d.ring',
                },
                {
                    'name' => 'Raku',
                    'ref'  => '../tests/outputs/prob060-andreoss.p6.yaml',
                    'args' => '../tests/inputs/prob060-andreoss.p6',
                },
                {
                    'name' => 'RAML',
                    'ref'  => '../tests/outputs/helloworld.raml.yaml',
                    'args' => '../tests/inputs/helloworld.raml',
                },
                {
                    'name' => 'Razor',
                    'ref'  => '../tests/outputs/razor.cshtml.yaml',
                    'args' => '../tests/inputs/razor.cshtml',
                },
                {
                    'name' => 'ReasonML',
                    'ref'  => '../tests/outputs/LogMain.re.yaml',
                    'args' => '../tests/inputs/LogMain.re',
                },
                {
                    'name' => 'ReScript',
                    'ref'  => '../tests/outputs/RedBlackTree.res.yaml',
                    'args' => '../tests/inputs/RedBlackTree.res',
                },
                {
                    'name' => 'reStructuredText',
                    'ref'  => '../tests/outputs/reStructuredText.rst.yaml',
                    'args' => '../tests/inputs/reStructuredText.rst',
                },
                {
                    'name' => 'RobotFramework',
                    'ref'  => '../tests/outputs/robotframework.robot.yaml',
                    'args' => '../tests/inputs/robotframework.robot',
                },
                {
                    'name' => 'Rmd',
                    'ref'  => '../tests/outputs/test.Rmd.yaml',
                    'args' => '../tests/inputs/test.Rmd',
                },
                {
                    'name' => 'Ruby',
                    'ref'  => '../tests/outputs/messages.rb.yaml',
                    'args' => '../tests/inputs/messages.rb',
                },
                {
                    'name' => 'SCSS',
                    'ref'  => '../tests/outputs/style.scss.yaml',
                    'args' => '../tests/inputs/style.scss',
                },
                {
                    'name' => 'SaltStack',
                    'ref'  => '../tests/outputs/certificates.sls.yaml',
                    'args' => '../tests/inputs/certificates.sls',
                },
                {
                    'name' => 'Scheme',
                    'ref'  => '../tests/outputs/scheme.sls.yaml',
                    'args' => '../tests/inputs/scheme.sls',
                },
                {
                    'name' => 'Starlark',
                    'ref'  => '../tests/outputs/build.bzl.yaml',
                    'args' => '../tests/inputs/build.bzl',
                },
                {
                    'name' => 'Slim',
                    'ref'  => '../tests/outputs/Slim.html.slim.yaml',
                    'args' => '../tests/inputs/Slim.html.slim',
                },
                {
                    'name' => 'Smalltalk 1',
                    'ref'  => '../tests/outputs/chat.st.yaml',
                    'args' => '../tests/inputs/chat.st',
                },
                {
                    'name' => 'Smalltalk 2',
                    'ref'  => '../tests/outputs/captcha.cs.yaml',
                    'args' => '../tests/inputs/captcha.cs',
                },
                {
                    'name' => 'Smarty',
                    'ref'  => '../tests/outputs/guestbook.tpl.yaml',
                    'args' => '../tests/inputs/guestbook.tpl',
                },
                {
                    'name' => 'SparForte',
                    'ref'  => '../tests/outputs/hello.sp.yaml',
                    'args' => '../tests/inputs/hello.sp',
                },
                {
                    'name' => 'Solidity',
                    'ref'  => '../tests/outputs/solidity.sol.yaml',
                    'args' => '../tests/inputs/solidity.sol',
                },
                {
                    'name' => 'Specman e 1',
                    'ref'  => '../tests/outputs/specman_e.e.yaml',
                    'args' => '../tests/inputs/specman_e.e',
                },
                {
                    'name' => 'Specman e 2',
                    'ref'  => '../tests/outputs/specman_e2.e.yaml',
                    'args' => '../tests/inputs/specman_e2.e',
                },
                {
                    'name' => 'Squirrel',
                    'ref'  => '../tests/outputs/squirrel_table.nut.yaml',
                    'args' => '../tests/inputs/squirrel_table.nut',
                },
                {
                    'name' => 'Stata',
                    'ref'  => '../tests/outputs/stata.do.yaml',
                    'args' => '../tests/inputs/stata.do',
                },
                {
                    'name' => 'SugarSS',
                    'ref'  => '../tests/outputs/rules.sss.yaml',
                    'args' => '../tests/inputs/rules.sss',
                },
                {
                    'name' => 'Svelte',
                    'ref'  => '../tests/outputs/reactive.svelte.yaml',
                    'args' => '../tests/inputs/reactive.svelte',
                },
                {
                    'name' => 'SVG',
                    'ref'  => '../tests/outputs/SVG_logo.svg.yaml',
                    'args' => '../tests/inputs/SVG_logo.svg',
                },
                {
                    'name' => 'Swift',
                    'ref'  => '../tests/outputs/tour.swift.yaml',
                    'args' => '../tests/inputs/tour.swift',
                },
                {
                    'name' => 'SWIG',
                    'ref'  => '../tests/outputs/swig_example.i.yaml',
                    'args' => '../tests/inputs/swig_example.i',
                },
                {
                    'name' => 'TableGen',
                    'ref'  => '../tests/outputs/TableGen-ARM.yaml',
                    'args' => '../tests/inputs/TableGen-ARM.td',
                },
                {
                    'name' => 'Tcl/Tk',
                    'ref'  => '../tests/outputs/Tk.yaml',
                    'args' => '../tests/inputs/Tk',
                },
                {
                    'name' => 'TEAL',
                    'ref'  => '../tests/outputs/htlc.teal.yaml',
                    'args' => '../tests/inputs/htlc.teal',
                },
                {
                    'name' => 'TeX',
                    'ref'  => '../tests/outputs/LaTeX.tex.yaml',
                    'args' => '../tests/inputs/LaTeX.tex',
                },
                {
                    'name' => 'Text',
                    'ref'  => '../tests/outputs/plain_text.txt.yaml',
                    'args' => '../tests/inputs/plain_text.txt',
                },
                {
                    'name' => 'Thrift',
                    'ref'  => '../tests/outputs/DocTest.thrift.yaml',
                    'args' => '../tests/inputs/DocTest.thrift',
                },
                {
                    'name' => 'TOML',
                    'ref'  => '../tests/outputs/toml_example.toml.yaml',
                    'args' => '../tests/inputs/toml_example.toml',
                },
                {
                    'name' => 'TNSDL',
                    'ref'  => '../tests/outputs/tnsdl.sdl.yaml',
                    'args' => '../tests/inputs/tnsdl.sdl',
                },
                {
                    'name' => 'TTCN',
                    'ref'  => '../tests/outputs/clusterConf.ttcn.yaml',
                    'args' => '../tests/inputs/clusterConf.ttcn',
                },
                {
                    'name' => 'TypeScript',
                    'ref'  => '../tests/outputs/TypeScript.ts.yaml',
                    'args' => '../tests/inputs/TypeScript.ts',
                },
                {
                    'name' => 'TypeScript 2',
                    'ref'  => '../tests/outputs/TypeScript_2.ts.yaml',
                    'args' => '../tests/inputs/TypeScript_2.ts',
                },
                {
                    'name' => 'TypeScript 3',
                    'ref'  => '../tests/outputs/warship.ts.yaml',
                    'args' => '../tests/inputs/warship.ts',
                },
                {
                    'name' => 'TypeScript 4',
                    'ref'  => '../tests/outputs/greeter.tsx.yaml',
                    'args' => '../tests/inputs/greeter.tsx',
                },
                {
                    'name' => 'Umka',
                    'ref'  => '../tests/outputs/fractal.um.yaml',
                    'args' => '../tests/inputs/fractal.um',
                },
                {
                    'name' => 'Vala',
                    'ref'  => '../tests/outputs/gnureadline.vala.yaml',
                    'args' => '../tests/inputs/gnureadline.vala',
                },
                {
                    'name' => 'VB.Net',
                    'ref'  => '../tests/outputs/VisualBasic.Net.vba.yaml',
                    'args' => '../tests/inputs/VisualBasic.Net.vba',
                },
                {
                    'name' => 'Velocity Template Language',
                    'ref'  => '../tests/outputs/vtl.vm.yaml',
                    'args' => '../tests/inputs/vtl.vm',
                },
                {
                    'name' => 'Verilog',
                    'ref'  => '../tests/outputs/verilog.sv.yaml',
                    'args' => '../tests/inputs/verilog.sv',
                },
                {
                    'name' => 'Visual Basic',
                    'ref'  => '../tests/outputs/JetCar.cls.yaml',
                    'args' => '../tests/inputs/JetCar.cls',
                },
                {
                    'name' => 'Visual Studio Module',
                    'ref'  => '../tests/outputs/BasicPlane.Figures-Rectangle.ixx.yaml',
                    'args' => '../tests/inputs/BasicPlane.Figures-Rectangle.ixx',
                },
                {
                    'name' => 'Visual Studio Solution',
                    'ref'  => '../tests/outputs/vs_solution.sln.yaml',
                    'args' => '../tests/inputs/vs_solution.sln',
                },
                {
                    'name' => 'Vuejs Component',
                    'ref'  => '../tests/outputs/ItemView.vue.yaml',
                    'args' => '../tests/inputs/ItemView.vue',
                },
                {
                    'name' => 'WebAssembly',
                    'ref'  => '../tests/outputs/type.wast.yaml',
                    'args' => '../tests/inputs/type.wast',
                },
                {
                    'name' => 'Web Services Description',
                    'ref'  => '../tests/outputs/webservice.wsdl.yaml',
                    'args' => '../tests/inputs/webservice.wsdl',
                },
                {
                    'name' => 'WGSL',
                    'ref'  => '../tests/outputs/updateSprites.wgsl.yaml',
                    'args' => '../tests/inputs/updateSprites.wgsl',
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
                    'name' => 'WXML',
                    'ref'  => '../tests/outputs/pages.wxml.yaml',
                    'args' => '../tests/inputs/pages.wxml',
                },
                {
                    'name' => 'WXSS',
                    'ref'  => '../tests/outputs/pages.wxss.yaml',
                    'args' => '../tests/inputs/pages.wxss',
                },
                {
                    'name' => 'xBase',
                    'ref'  => '../tests/outputs/harbour_xbase.prg.yaml',
                    'args' => '../tests/inputs/harbour_xbase.prg',
                },
                {
                    'name' => 'X++',
                    'ref'  => '../tests/outputs/X++.xpo.yaml',
                    'args' => '../tests/inputs/X++.xpo',
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
                {
                    'name' => 'Xtend',
                    'ref'  => '../tests/outputs/Xtend.xtend.yaml',
                    'args' => '../tests/inputs/Xtend.xtend',
                },
                {
                    'name' => 'Zig',
                    'ref'  => '../tests/outputs/zir_sema.zig.yaml',
                    'args' => '../tests/inputs/zir_sema.zig',
                },
            );

my $Verbose = 0;

my $results  = 'results.yaml';
my $work_dir = getcwd;
my $cloc     = "$work_dir/../cloc";   # all-purpose version
#my $cloc     = "$work_dir/cloc";      # Unix-tuned version
my $Run = "$cloc --quiet --yaml --out $results ";
foreach my $t (@Tests) {
    print  $Run . $t->{'args'} if $Verbose;
    system($Run . $t->{'args'});
    ok(-e $results, $t->{'name'} . " created output");
    my %ref  = load_yaml($t->{'ref'});
    my %this = load_yaml($results);
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
        $K =~ s/'//g;
        $result{$section}{$K} = $V;
    }
    close IN;
    return %result
} # 1}}}
