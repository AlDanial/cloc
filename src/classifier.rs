use serde::Serialize;
use std::path::Path;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, Serialize)]
pub enum CommentSyntax {
    Slash,
    Hash,
    DashDash,
    Sql,
    Semicolon,
    Percent,
    Matlab,
    Fortran,
    Basic,
    Pascal,
    Haskell,
    OCaml,
    Html,
    Python,
    Ruby,
    Perl,
    Lua,
    Lisp,
    Clojure,
    PowerShell,
    VimScript,
    Batch,
    Cobol,
    None,
    Custom(&'static CommentDef),
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, Serialize)]
pub struct CommentDef {
    pub line_comments: &'static [&'static str],
    pub block_comments: &'static [(&'static str, &'static str)],
    pub string_delimiters: &'static [(&'static str, &'static str)],
    pub docstrings: &'static [(&'static str, &'static str)],
    pub nested_block_comments: bool,
    pub column_one_comments: &'static [u8],
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct CommentConfig {
    pub syntax: CommentSyntax,
    pub line_comments: &'static [&'static str],
    pub block_comments: &'static [(&'static str, &'static str)],
    pub string_delimiters: &'static [(&'static str, &'static str)],
    pub docstrings: &'static [(&'static str, &'static str)],
    pub nested_block_comments: bool,
    pub column_one_comments: &'static [u8],
}

impl CommentSyntax {
    #[inline]
    pub fn line_comments(&self) -> &'static [&'static str] {
        match self {
            Self::Slash => &["//"],
            Self::Hash | Self::Python | Self::Ruby | Self::Perl | Self::PowerShell => &["#"],
            Self::DashDash | Self::Lua | Self::Sql | Self::Haskell => &["--"],
            Self::Semicolon | Self::Lisp | Self::Clojure => &[";"],
            Self::Percent | Self::Matlab => &["%"],
            Self::Fortran => &["!"],
            Self::Basic => &["'", "REM", "rem"],
            Self::Pascal => &["//"],
            Self::VimScript => &["\""],
            Self::Batch => &["REM", "rem", "::"],
            Self::Custom(def) => def.line_comments,
            Self::OCaml | Self::Html | Self::Cobol | Self::None => &[],
        }
    }

    #[inline]
    pub fn block_comments(&self) -> &'static [(&'static str, &'static str)] {
        match self {
            Self::Slash | Self::Sql => &[("/*", "*/")],
            Self::Html => &[("<!--", "-->")],
            Self::Matlab => &[("%{", "%}")],
            Self::Pascal => &[("{", "}"), ("(*", "*)")],
            Self::Haskell => &[("{-", "-}")],
            Self::OCaml => &[("(*", "*)")],
            Self::Ruby => &[("=begin", "=end")],
            Self::Perl => &[("=pod", "=cut"), ("=head1", "=cut"), ("=head2", "=cut")],
            Self::Lua => &[("--[[", "]]")],
            Self::Lisp => &[("#|", "|#")],
            Self::PowerShell => &[("<#", "#>")],
            Self::Custom(def) => def.block_comments,
            _ => &[],
        }
    }

    #[inline]
    pub fn string_delimiters(&self) -> &'static [(&'static str, &'static str)] {
        match self {
            Self::Slash | Self::Hash | Self::Sql | Self::Basic | Self::Python | Self::Ruby | Self::Perl | Self::Lua | Self::PowerShell | Self::DashDash => {
                &[("\"", "\""), ("'", "'")]
            }
            Self::Custom(def) => def.string_delimiters,
            Self::None => &[],
            _ => &[("\"", "\"")],
        }
    }

    #[inline]
    pub fn docstrings(&self) -> &'static [(&'static str, &'static str)] {
        match self {
            Self::Python => &[("\"\"\"", "\"\"\""), ("'''", "'''")],
            Self::Custom(def) => def.docstrings,
            _ => &[],
        }
    }

    #[inline]
    pub fn allows_nested_block_comments(&self) -> bool {
        match self {
            Self::Haskell | Self::OCaml => true,
            Self::Custom(def) => def.nested_block_comments,
            _ => false,
        }
    }

    #[inline]
    pub fn column_one_comments(&self) -> &'static [u8] {
        match self {
            Self::Fortran => b"cCdD*!",
            Self::Cobol => b"*/",
            Self::Custom(def) => def.column_one_comments,
            _ => b"",
        }
    }

    #[inline]
    pub fn config(&self) -> CommentConfig {
        CommentConfig {
            syntax: *self,
            line_comments: self.line_comments(),
            block_comments: self.block_comments(),
            string_delimiters: self.string_delimiters(),
            docstrings: self.docstrings(),
            nested_block_comments: self.allows_nested_block_comments(),
            column_one_comments: self.column_one_comments(),
        }
    }
}

impl From<CommentSyntax> for crate::counter::CommentSyntax {
    fn from(s: CommentSyntax) -> Self {
        crate::counter::CommentSyntax {
            line_comments: s.line_comments(),
            block_comments: s.block_comments(),
            nested_comments: s.allows_nested_block_comments(),
        }
    }
}

static COMPOUND_EXTENSIONS: &[(&str, &str)] = &[
    ("app.config", "XML"),
    ("app.src", "Erlang"),
    ("blade.php", "Blade"),
    ("build.bazel", "Python"),
    ("build.xml", "Ant"),
    ("buildozer.spec", "INI"),
    ("cljs.hl", "Clojure"),
    ("cmake.in", "CMake"),
    ("cmakelists.txt", "CMake"),
    ("composer.lock", "JSON"),
    ("contents.lr", "Markdown"),
    ("data.sql", "SQL Data"),
    ("designer.cs", "C# Designer"),
    ("dll.config", "XML"),
    ("gemfile.lock", "Ruby"),
    ("glide.lock", "YAML"),
    ("gradle.kts", "Gradle"),
    ("haml.deface", "Haml"),
    ("hbm.xml", "Hibernate"),
    ("html.hl", "HTML"),
    ("lb.xml", "Liquibase"),
    ("makefile.pl", "Perl"),
    ("mcmod.info", "JSON"),
    ("meson.build", "Meson"),
    ("nim.cfg", "Nim"),
    ("nuget.config", "XML"),
    ("packages.config", "XML"),
    ("php_cs.dist", "PHP"),
    ("pom.xml", "Maven"),
    ("rebar.config", "Erlang"),
    ("rebar.config.lock", "Erlang"),
    ("rebar.lock", "Erlang"),
    ("rest.txt", "reStructuredText"),
    ("riemann.config", "Clojure"),
    ("rs.in", "Rust"),
    ("rst.txt", "reStructuredText"),
    ("settings.stylecop", "XML"),
    ("spc.sql", "SQL Stored Procedure"),
    ("spoc.sql", "SQL Stored Procedure"),
    ("sproc.sql", "SQL Stored Procedure"),
    ("tar.bz2", "(unknown)"),
    ("tar.gz", "(unknown)"),
    ("tar.xz", "(unknown)"),
    ("tar.z", "(unknown)"),
    ("tfstate.backup", "JSON"),
    ("udf.sql", "SQL Stored Procedure"),
    ("vue.html", "Vue"),
    ("web.config", "XML"),
    ("web.debug.config", "XML"),
    ("web.release.config", "XML"),
    ("xml.builder", "builder"),
    ("xml.dist", "XML"),
    ("yml.mysql", "YAML"),
];

static SIMPLE_EXTENSIONS: &[(&str, &str)] = &[
    ("4th", "Forth"),
    ("_coffee", "CoffeeScript"),
    ("_js", "JavaScript"),
    ("a51", "Assembly"),
    ("abap", "ABAP"),
    ("ac", "m4"),
    ("ack", "Perl"),
    ("ada", "Ada"),
    ("adb", "Ada"),
    ("adml", "XML"),
    ("admx", "XML"),
    ("ado", "Stata"),
    ("adoc", "AsciiDoc"),
    ("ads", "Ada"),
    ("adso", "ADSO/IDSM"),
    ("agda", "Agda"),
    ("ahk", "AutoHotkey"),
    ("ahkl", "AutoHotkey"),
    ("aj", "AspectJ"),
    ("al", "Perl/AL"),
    ("am", "make"),
    ("ample", "AMPLE"),
    ("ant", "XML"),
    ("apl", "APL"),
    ("apla", "APL"),
    ("aplc", "APL"),
    ("aplf", "APL"),
    ("apli", "APL"),
    ("apln", "APL"),
    ("aplo", "APL"),
    ("applescript", "AppleScript"),
    ("appraisals", "Ruby"),
    ("arcconfig", "JSON"),
    ("aria", "Aria"),
    ("art", "Arturo"),
    ("as", "ActionScript"),
    ("asa", "ASP"),
    ("asax", "ASP.NET"),
    ("asciidoc", "AsciiDoc"),
    ("ascx", "ASP.NET"),
    ("asd", "Lisp"),
    ("ashx", "ASP"),
    ("asm", "Assembly"),
    ("asmx", "ASP.NET"),
    ("asp", "ASP"),
    ("aspx", "ASP.NET"),
    ("astro", "Astro"),
    ("asy", "Asymptote"),
    ("auk", "awk"),
    ("aux", "TeX"),
    ("avsc", "JSON"),
    ("aw", "PHP"),
    ("awk", "awk"),
    ("axaml", "AXAML"),
    ("axd", "ASP"),
    ("axml", "XML"),
    ("b", "Brainfuck"),
    ("bas", "Visual Basic"),
    ("bash", "Bourne Again Shell"),
    ("bat", "DOS Batch"),
    ("bazel", "Starlark"),
    ("bb", "BitBake"),
    ("bbappend", "BitBake"),
    ("bbclass", "BitBake"),
    ("bbx", "TeX"),
    ("bdy", "Oracle PL/SQL"),
    ("bel", "Beluga"),
    ("berksfile", "Ruby"),
    ("bf", "Brainfuck"),
    ("bib", "TeX"),
    ("bicep", "Bicep"),
    ("bicepparam", "Bicep"),
    ("blade", "Blade"),
    ("blp", "Blueprint"),
    ("bod", "Oracle PL/SQL"),
    ("bones", "JavaScript"),
    ("boot", "Clojure"),
    ("bpmn", "Activiti Business Process"),
    ("brewfile", "Ruby"),
    ("brs", "BrightScript"),
    ("bst", "TeX"),
    ("btm", "DOS Batch"),
    ("btp", "BizTalk Pipeline"),
    ("btproj", "MSBuild script"),
    ("buck", "Python"),
    ("build", "NAnt script"),
    ("builder", "Ruby"),
    ("buildfile", "Ruby"),
    ("builds", "XML"),
    ("bzl", "Starlark"),
    ("c", "C"),
    ("c++", "C++"),
    ("c++m", "C++"),
    ("c3", "C3"),
    ("c3i", "C3"),
    ("c3t", "C3"),
    ("c5", "CoCoA 5"),
    ("cairo", "Cairo"),
    ("cake", "Cake Build Script"),
    ("cakefile", "CoffeeScript"),
    ("capfile", "Ruby"),
    ("carbon", "Carbon"),
    ("cats", "C"),
    ("cbl", "COBOL"),
    ("cbx", "TeX"),
    ("cc", "C++"),
    ("ccm", "C++"),
    ("ccp", "COBOL"),
    ("ccproj", "XML"),
    ("ccs", "CCS"),
    ("ccxml", "XML"),
    ("cdc", "Cadence"),
    ("cdf", "Mathematica"),
    ("cfc", "ColdFusion CFScript"),
    ("cfm", "ColdFusion"),
    ("cfml", "ColdFusion"),
    ("cg", "HLSL"),
    ("cg3", "Constraint Grammar"),
    ("cginc", "HLSL"),
    ("ch", "xBase Header"),
    ("chpl", "Chapel"),
    ("cii", "TNSDL"),
    ("cin", "TNSDL"),
    ("circom", "Circom"),
    ("civet", "Civet"),
    ("cj", "Clojure/Cangjie"),
    ("cjs", "JavaScript"),
    ("cjsx", "CoffeeScript"),
    ("cl", "Lisp/OpenCL"),
    ("cl2", "Clojure"),
    ("clang-format", "YAML"),
    ("clang-tidy", "YAML"),
    ("clar", "Clarity"),
    ("classpath", "XML"),
    ("clixml", "XML"),
    ("clj", "Clojure"),
    ("cljc", "ClojureC"),
    ("cljs", "ClojureScript"),
    ("cljscm", "Clojure"),
    ("cljx", "Clojure"),
    ("cls", "Visual Basic/TeX/Apex Class"),
    ("cmake", "CMake"),
    ("cmd", "DOS Batch"),
    ("cob", "COBOL"),
    ("cobol", "COBOL"),
    ("cocoa5", "CoCoA 5"),
    ("cocoa5server", "CoCoA 5"),
    ("code-workspace", "VSCode Workspace"),
    ("coffee", "CoffeeScript"),
    ("comp", "GLSL"),
    ("component", "Visualforce Component"),
    ("conf", "Unknown/BitBake"),
    ("containerfile", "Containerfile"),
    ("cpanfile", "Perl"),
    ("cpkg5", "CoCoA 5"),
    ("cpp", "C++"),
    ("cppm", "C++"),
    ("cproject", "XML"),
    ("cpy", "COBOL"),
    ("cql", "SQL"),
    ("cr", "Crystal"),
    ("cs", "C#/Smalltalk"),
    ("cscfg", "XML"),
    ("csdef", "XML"),
    ("csh", "C Shell"),
    ("cshtml", "Razor"),
    ("csl", "XML"),
    ("cson", "CSON"),
    ("csproj", "MSBuild script"),
    ("css", "CSS"),
    ("ct", "XML"),
    ("ctl", "Visual Basic"),
    ("ctp", "PHP"),
    ("cts", "TypeScript"),
    ("cu", "CUDA"),
    ("cuh", "CUDA"),
    ("cvt", "Civet"),
    ("cvtx", "Civet"),
    ("cxx", "C++"),
    ("cxxm", "C++"),
    ("d", "D/dtrace"),
    ("da", "DAL"),
    ("daml", "DAML"),
    ("dangerfile", "Ruby"),
    ("dart", "Dart"),
    ("dcl", "Clean"),
    ("def", "Windows Module Definition"),
    ("deliverfile", "Ruby"),
    ("depproj", "XML"),
    ("derw", "Derw"),
    ("dfm", "Delphi Form"),
    ("dfy", "Dafny"),
    ("dhall", "dhall"),
    ("diff", "diff"),
    ("dita", "DITA"),
    ("ditamap", "XML"),
    ("ditaval", "XML"),
    ("dlm", "IDL"),
    ("dmap", "NASTRAN DMAP"),
    ("do", "Stata"),
    ("dockerfile", "Dockerfile"),
    ("dofile", "AMPLE"),
    ("doh", "Stata"),
    ("dotsettings", "XML"),
    ("dpr", "Pascal"),
    ("drl", "Drools"),
    ("dsc", "DenizenScript"),
    ("dsr", "Visual Basic"),
    ("dt", "DIET"),
    ("dtd", "DTD"),
    ("dtx", "TeX"),
    ("dxl", "DOORS Extension Language"),
    ("dyalog", "APL"),
    ("dyapp", "APL"),
    ("e", "Specman e"),
    ("e4", "Forth"),
    ("ec", "C"),
    ("ecpp", "ECPP"),
    ("ecr", "Embedded Crystal"),
    ("editorconfig", "INI"),
    ("eex", "EEx"),
    ("ejs", "EJS"),
    ("el", "Lisp"),
    ("eliom", "OCaml"),
    ("eliomi", "OCaml"),
    ("elm", "Elm"),
    ("emakefile", "Erlang"),
    ("erb", "ERB"),
    ("erl", "Erlang"),
    ("es6", "JavaScript"),
    ("ets", "ArkTs"),
    ("ex", "Elixir"),
    ("exp", "Expect"),
    ("expr-dist", "R"),
    ("exs", "Elixir Script"),
    ("eye", "Ruby"),
    ("f", "Fortran 77/Forth"),
    ("f03", "Fortran 2003"),
    ("f08", "Fortran 2008"),
    ("f77", "Fortran 77"),
    ("f83", "Forth"),
    ("f90", "Fortran 90"),
    ("f95", "Fortran 95"),
    ("fastfile", "Ruby"),
    ("fb", "Forth"),
    ("fbs", "Flatbuffers"),
    ("feature", "Cucumber"),
    ("filters", "XML"),
    ("fish", "Fish Shell"),
    ("fmt", "Oracle Forms"),
    ("fnc", "Oracle PL/SQL"),
    ("fnl", "Fennel"),
    ("focexec", "Focus"),
    ("for", "Fortran 77/Forth"),
    ("forth", "Forth"),
    ("fp", "GLSL"),
    ("fpm", "Forth"),
    ("fr", "Forth"),
    ("frag", "GLSL"),
    ("frg", "GLSL"),
    ("frm", "Visual Basic"),
    ("frt", "Forth"),
    ("frx", "Visual Basic"),
    ("fsh", "GLSL"),
    ("fshader", "GLSL"),
    ("fsl", "Finite State Language"),
    ("fsproj", "XML"),
    ("ft", "Forth"),
    ("fth", "Forth"),
    ("ftl", "Freemarker Template"),
    ("ftn", "Fortran 77"),
    ("fun", "Standard ML"),
    ("fut", "Futhark"),
    ("fxh", "HLSL"),
    ("fxml", "FXML"),
    ("g", "ANTLR Grammar"),
    ("g4", "ANTLR Grammar"),
    ("gant", "Groovy"),
    ("gawk", "awk"),
    ("gclient", "Python"),
    ("gd", "GDScript"),
    ("gdshader", "Godot Shaders"),
    ("gemfile", "Ruby"),
    ("gemrc", "YAML"),
    ("gemspec", "Ruby"),
    ("geo", "GLSL"),
    ("geojson", "JSON"),
    ("geom", "GLSL"),
    ("gjs", "Glimmer JavaScript"),
    ("glade", "Glade"),
    ("gleam", "Gleam"),
    ("glsl", "GLSL"),
    ("glslv", "GLSL"),
    ("gltf", "JSON"),
    ("gmx", "XML"),
    ("gnumakefile", "make"),
    ("go", "Go"),
    ("god", "Ruby"),
    ("gql", "GraphQL"),
    ("gradle", "Gradle"),
    ("graphql", "GraphQL"),
    ("graphqls", "GraphQL"),
    ("groovy", "Groovy"),
    ("grt", "Groovy"),
    ("grxml", "XML"),
    ("gshader", "GLSL"),
    ("gsp", "Grails"),
    ("gtpl", "Groovy"),
    ("gts", "Glimmer TypeScript"),
    ("guardfile", "Ruby"),
    ("gvy", "Groovy"),
    ("gyp", "Python"),
    ("gypi", "Python"),
    ("h", "C/C++ Header"),
    ("h++", "C++"),
    ("ha", "Hare"),
    ("haml", "Haml"),
    ("handlebars", "Handlebars"),
    ("har", "JSON"),
    ("hb", "Harbour"),
    ("hbs", "Handlebars"),
    ("hc", "HolyC"),
    ("hcl", "HCL"),
    ("heex", "HTML EEx"),
    ("hh", "C/C++ Header"),
    ("hic", "Clojure"),
    ("hlean", "Lean"),
    ("hlsl", "HLSL"),
    ("hlsli", "HLSL"),
    ("hoon", "Hoon"),
    ("hpp", "C/C++ Header"),
    ("hrl", "Erlang"),
    ("hs", "Haskell"),
    ("hs-boot", "Haskell Boot"),
    ("hsc", "Haskell"),
    ("htm", "HTML"),
    ("html", "HTML"),
    ("htmlhintrc", "JSON"),
    ("hx", "Haxe"),
    ("hxsl", "Haxe"),
    ("hxx", "C/C++ Header"),
    ("i", "SWIG"),
    ("i3", "Modula3"),
    ("ice", "Slice"),
    ("iced", "CoffeeScript"),
    ("icl", "Clean"),
    ("idc", "C"),
    ("idl", "IDL"),
    ("idr", "Idris"),
    ("ig", "Modula3"),
    ("ihlp", "Stata"),
    ("il", "SKILL/.NET IL"),
    ("ils", "SKILL++"),
    ("imba", "Imba"),
    ("iml", "XML"),
    ("in1", "TNSDL"),
    ("in2", "TNSDL"),
    ("in3", "TNSDL"),
    ("in4", "TNSDL"),
    ("inc", "PHP/Pascal/Fortran/Pawn/BitBake/Assembly"),
    ("inf", "Windows INF/TNSDL"),
    ("ini", "INI"),
    ("inl", "C++"),
    ("ino", "Arduino Sketch"),
    ("ins", "TeX"),
    ("interface", "TNSDL"),
    ("ipf", "Igor Pro"),
    ("ipl", "IPL"),
    ("ipp", "C++"),
    ("ipynb", "Jupyter Notebook"),
    ("irbrc", "Ruby"),
    ("ism", "InstallShield"),
    ("itk", "Tcl/Tk"),
    ("iuml", "PlantUML"),
    ("ivy", "XML"),
    ("ixx", "C++"),
    ("j2", "Jinja Template"),
    ("jade", "Pug"),
    ("jai", "Jai"),
    ("jake", "JavaScript"),
    ("jakefile", "JavaScript"),
    ("janet", "Janet"),
    ("jarfile", "Ruby"),
    ("java", "Java"),
    ("jbuilder", "Ruby"),
    ("jcl", "JCL"),
    ("jelly", "XML"),
    ("jenkinsfile", "Groovy"),
    ("jinja", "Jinja Template"),
    ("jinja2", "Jinja Template"),
    ("jl", "Lisp/Julia"),
    ("jrxml", "Jasper Report XML/Template"),
    ("js", "JavaScript"),
    ("jsb", "JavaScript"),
    ("jscad", "JavaScript"),
    ("jsf", "JavaServer Faces"),
    ("jsfl", "JavaScript"),
    ("jsm", "JavaScript"),
    ("json", "JSON"),
    ("json-tmlanguage", "JSON"),
    ("json5", "JSON5"),
    ("jsonl", "JSON"),
    ("jsonnet", "Jsonnet"),
    ("jsp", "JSP"),
    ("jspeg", "tspeg"),
    ("jspf", "JSP"),
    ("jsproj", "XML"),
    ("jss", "JavaScript"),
    ("jssm", "Finite State Language"),
    ("jsx", "JSX"),
    ("junos", "Juniper Junos"),
    ("just", "Justfile"),
    ("kml", "XML"),
    ("kojo", "Scala"),
    ("ksc", "Kermit"),
    ("ksh", "Korn Shell"),
    ("kt", "Kotlin"),
    ("ktm", "Kotlin"),
    ("kts", "Kotlin"),
    ("kv", "kvlang"),
    ("l", "lex"),
    ("lagda", "Agda"),
    ("launch", "XML"),
    ("lbx", "TeX"),
    ("ld", "Linker Script"),
    ("lean", "Lean"),
    ("lektorproject", "INI"),
    ("lem", "Lem"),
    ("less", "LESS"),
    ("lex", "lex"),
    ("lfe", "LFE"),
    ("lgt", "Logtalk"),
    ("lhs", "Literate Haskell"),
    ("lhs-boot", "Haskell Boot"),
    ("lidr", "Literate Idris"),
    ("liquid", "liquid"),
    ("lisp", "Lisp"),
    ("lit", "PL/M"),
    ("ll", "LLVM IR"),
    ("lmi", "Python"),
    ("logtalk", "Logtalk"),
    ("lp", "AnsProlog"),
    ("lpr", "Pascal"),
    ("lsp", "Lisp"),
    ("ltx", "TeX"),
    ("lua", "Lua"),
    ("luau", "Luau"),
    ("m", "MATLAB/Mathematica/Objective-C/MUMPS/Mercury"),
    ("m3", "Modula3"),
    ("m4", "m4"),
    ("ma", "Mathematica"),
    ("magik", "Magik"),
    ("makefile", "make"),
    ("mako", "Mako"),
    ("mao", "Mako"),
    ("markdown", "Markdown"),
    ("master", "ASP.NET"),
    ("mat", "Unity-Prefab"),
    ("mata", "Stata"),
    ("matah", "Stata"),
    ("mathematica", "Mathematica"),
    ("mavenfile", "Ruby"),
    ("mawk", "awk"),
    ("mbt", "MoonBit"),
    ("mbti", "MoonBit"),
    ("mbtx", "MoonBit"),
    ("mbty", "MoonBit"),
    ("mc", "Windows Message File"),
    ("mcmeta", "JSON"),
    ("md", "Markdown"),
    ("mdown", "Markdown"),
    ("mdpolicy", "XML"),
    ("mdwn", "Markdown"),
    ("mdx", "Markdown"),
    ("met", "Teamcenter met"),
    ("metal", "Metal"),
    ("mg", "Modula3"),
    ("mipage", "APL"),
    ("mir", "YAML"),
    ("mjml", "XML"),
    ("mjs", "JavaScript"),
    ("mk", "make"),
    ("mkd", "Markdown"),
    ("mkdn", "Markdown"),
    ("mkdown", "Markdown"),
    ("mkii", "TeX"),
    ("mkiv", "TeX"),
    ("mkvi", "TeX"),
    ("ml", "OCaml"),
    ("ml4", "OCaml"),
    ("mli", "OCaml"),
    ("mll", "OCaml"),
    ("mly", "OCaml"),
    ("mm", "Objective-C++"),
    ("mo", "Modelica"),
    ("mojo", "Mojo"),
    ("mojom", "Mojom"),
    ("mps", "MUMPS"),
    ("msbuild", "MSBuild script"),
    ("msg", "Gencat NLS"),
    ("mspec", "Ruby"),
    ("mt", "Mathematica"),
    ("mth", "Teamcenter mth"),
    ("mts", "TypeScript"),
    ("mustache", "Mustache"),
    ("mxml", "MXML"),
    ("mysql", "SQL"),
    ("n", "Nemerle"),
    ("nasm", "Assembly"),
    ("natvis", "XML"),
    ("nawk", "awk"),
    ("nbp", "Mathematica"),
    ("ncl", "Nickel"),
    ("ndproj", "XML"),
    ("nf", "Nextflow"),
    ("nim", "Nim"),
    ("nimble", "Nim"),
    ("nimrod", "Nim"),
    ("nims", "Nim"),
    ("nix", "Nix"),
    ("njk", "Nunjucks"),
    ("njs", "JavaScript"),
    ("nlogo", "NetLogo"),
    ("nls", "NetLogo"),
    ("nomad", "HCL"),
    ("nproj", "XML"),
    ("nse", "Lua"),
    ("nu", "Nushell"),
    ("nuon", "Nushell Object Notation"),
    ("nuspec", "XML"),
    ("nut", "Squirrel"),
    ("odd", "XML"),
    ("odin", "Odin"),
    ("odx", "BizTalk Orchestration"),
    ("org", "Org Mode"),
    ("oscript", "LiveLink OScript"),
    ("osm", "XML"),
    ("p", "Prolog"),
    ("p4", "P4"),
    ("p6", "Raku/Prolog"),
    ("p8", "Lua"),
    ("pac", "JavaScript"),
    ("pad", "Ada"),
    ("page", "Visualforce Page"),
    ("pas", "Pascal"),
    ("pascal", "Pascal"),
    ("patch", "diff"),
    ("pawn", "Pawn"),
    ("pbt", "PowerBuilder"),
    ("pcc", "C++"),
    ("pcl", "Patran Command Language"),
    ("pd_lua", "Lua"),
    ("pde", "Processing"),
    ("peg", "PEG"),
    ("peggy", "peggy"),
    ("pegjs", "peg.js"),
    ("pek", "Pek"),
    ("perl", "Perl"),
    ("pest", "Pest"),
    ("pfo", "Fortran 77"),
    ("pgc", "C"),
    ("ph", "Perl"),
    ("phakefile", "PHP"),
    ("php", "PHP"),
    ("php3", "PHP"),
    ("php4", "PHP"),
    ("php5", "PHP"),
    ("php_cs", "PHP"),
    ("phps", "PHP"),
    ("phpt", "PHP"),
    ("phtml", "PHP"),
    ("pig", "Pig Latin"),
    ("pkgproj", "XML"),
    ("pkl", "Pkl"),
    ("pl", "Perl/Prolog"),
    ("pl1", "PL/I"),
    ("plantuml", "PlantUML"),
    ("plh", "Perl"),
    ("plist", "XML"),
    ("plm", "PL/M"),
    ("plx", "Perl"),
    ("pm", "Perl"),
    ("pm6", "Raku"),
    ("po", "PO File"),
    ("podfile", "Ruby"),
    ("podspec", "Ruby"),
    ("pom", "Maven"),
    ("pony", "Pony"),
    ("pp", "Pascal/Puppet"),
    ("pprx", "Rexx"),
    ("prc", "Oracle PL/SQL"),
    ("prefab", "Unity-Prefab"),
    ("prefs", "INI"),
    ("prg", "xBase"),
    ("prisma", "Prisma Schema"),
    ("pro", "IDL/Qt Project/Prolog/ProGuard"),
    ("proj", "XML"),
    ("project", "XML"),
    ("prolog", "Prolog"),
    ("properties", "Properties"),
    ("props", "XML"),
    ("proto", "Protocol Buffers"),
    ("prql", "PRQL"),
    ("prw", "xBase"),
    ("pryrc", "Ruby"),
    ("ps1", "PowerShell"),
    ("ps1xml", "XML"),
    ("psc1", "XML"),
    ("psd1", "PowerShell"),
    ("psgi", "Perl"),
    ("psm1", "PowerShell"),
    ("psql", "SQL"),
    ("pt", "XML"),
    ("pu", "PlantUML"),
    ("pug", "Pug"),
    ("puml", "PlantUML"),
    ("puppetfile", "Ruby"),
    ("purs", "PureScript"),
    ("pwn", "Pawn"),
    ("pxd", "Cython"),
    ("pxi", "Cython"),
    ("py", "Python"),
    ("py3", "Python"),
    ("pyde", "Python"),
    ("pyi", "Python"),
    ("pyj", "RapydScript"),
    ("pyp", "Python"),
    ("pyt", "Python"),
    ("pyw", "Python"),
    ("pyx", "Cython"),
    ("qbs", "QML"),
    ("ql", "CodeQL"),
    ("qll", "CodeQL"),
    ("qml", "QML"),
    ("qxs", "Quxlang"),
    ("r", "R"),
    ("rabl", "Ruby"),
    ("rake", "Ruby"),
    ("raku", "Raku"),
    ("rakumod", "Raku"),
    ("raml", "RAML"),
    ("razor", "Razor"),
    ("rb", "Ruby"),
    ("rbuild", "Ruby"),
    ("rbw", "Ruby"),
    ("rbx", "Ruby"),
    ("rbxs", "Lua"),
    ("rc", "Windows Resource File"),
    ("rc2", "Windows Resource File"),
    ("rd", "R"),
    ("rdf", "XML"),
    ("re", "ReasonML"),
    ("reek", "YAML"),
    ("rego", "Rego"),
    ("rei", "ReasonML"),
    ("res", "ReScript"),
    ("resi", "ReScript"),
    ("rest", "reStructuredText"),
    ("resx", "XML"),
    ("rex", "Oracle Reports"),
    ("rexfile", "Perl"),
    ("rexx", "Rexx"),
    ("rform", "Ring"),
    ("rh", "Ring"),
    ("rhai", "Rhai"),
    ("rhtml", "Ruby HTML"),
    ("ring", "Ring"),
    ("rkt", "Racket"),
    ("rktd", "Racket"),
    ("rktl", "Racket"),
    ("rlx", "Constraint Grammar"),
    ("rmd", "Rmd"),
    ("robot", "RobotFramework"),
    ("ronn", "Markdown"),
    ("rou", "TNSDL"),
    ("rprofile", "R"),
    ("rs", "Rust"),
    ("rss", "XML"),
    ("rst", "reStructuredText"),
    ("rsx", "R"),
    ("ru", "Ruby"),
    ("rules", "Snakemake"),
    ("rviz", "YAML"),
    ("rx", "Forth"),
    ("s", "Assembly"),
    ("sas", "SAS"),
    ("sass", "Sass"),
    ("sbl", "Softbridge Basic"),
    ("sbt", "Scala"),
    ("sc", "Scheme"),
    ("sca", "Visual Fox Pro"),
    ("scad", "OpenSCAD"),
    ("scala", "Scala"),
    ("sch", "Scheme"),
    ("scm", "Scheme"),
    ("sconscript", "Python"),
    ("sconstruct", "Python"),
    ("scp", "SQL Stored Procedure"),
    ("scrbl", "Racket"),
    ("scss", "SCSS"),
    ("scxml", "XML"),
    ("sdl", "TNSDL"),
    ("sdt", "TNSDL"),
    ("sed", "sed"),
    ("sema", "Sema"),
    ("ses", "Patran Command Language"),
    ("sfproj", "XML"),
    ("sh", "Bourne Shell"),
    ("shader", "HLSL"),
    ("shproj", "XML"),
    ("sig", "Standard ML"),
    ("sitemap", "ASP.NET"),
    ("sjs", "JavaScript"),
    ("slang", "Slang"),
    ("sld", "Scheme"),
    ("slim", "Slim"),
    ("slint", "Slint"),
    ("sln", "Visual Studio Solution"),
    ("sls", "Scheme/SaltStack"),
    ("smarty", "Smarty"),
    ("smk", "Snakemake"),
    ("sml", "Standard ML"),
    ("snakefile", "Python"),
    ("snapfile", "Ruby"),
    ("sol", "Solidity"),
    ("sp", "SparForte"),
    ("spc", "Oracle PL/SQL"),
    ("spd", "TNSDL"),
    ("sps", "Scheme"),
    ("sql", "SQL"),
    ("sra", "PowerBuilder"),
    ("srdf", "XML"),
    ("srf", "PowerBuilder"),
    ("srm", "PowerBuilder"),
    ("srs", "PowerBuilder"),
    ("sru", "PowerBuilder"),
    ("srw", "PowerBuilder"),
    ("ss", "Scheme"),
    ("ssc", "TNSDL"),
    ("ssjs", "JavaScript"),
    ("sss", "SugarSS"),
    ("sst", "TNSDL"),
    ("st", "Smalltalk"),
    ("startup", "AMPLE"),
    ("sthlp", "Stata"),
    ("storyboard", "XML"),
    ("sttheme", "XML"),
    ("sty", "TeX"),
    ("styl", "Stylus"),
    ("sublime-snippet", "XML"),
    ("sublime-syntax", "YAML"),
    ("surql", "SurrealQL"),
    ("sv", "Verilog-SystemVerilog"),
    ("svelte", "Svelte"),
    ("svg", "SVG"),
    ("svh", "Verilog-SystemVerilog"),
    ("swift", "Swift"),
    ("syntax", "YAML"),
    ("tab", "SQL"),
    ("tac", "Python"),
    ("targets", "XML"),
    ("tcc", "C++"),
    ("tcl", "Tcl/Tk"),
    ("tcsh", "C Shell"),
    ("td", "TableGen"),
    ("teal", "TEAL"),
    ("templ", "Templ"),
    ("tern-config", "JSON"),
    ("tern-project", "JSON"),
    ("tesc", "GLSL"),
    ("tese", "GLSL"),
    ("tex", "TeX"),
    ("text", "Text"),
    ("tf", "HCL"),
    ("tfstate", "JSON"),
    ("tfvars", "HCL"),
    ("thor", "Ruby"),
    ("thorfile", "Ruby"),
    ("thrift", "Thrift"),
    ("tk", "Tcl/Tk"),
    ("tla", "TLA+"),
    ("tld", "JSP Tag Library Definition"),
    ("tmcommand", "XML"),
    ("tml", "XML"),
    ("tmlanguage", "XML"),
    ("tmpreferences", "XML"),
    ("tmsnippet", "XML"),
    ("tmtheme", "XML"),
    ("toml", "TOML"),
    ("topojson", "JSON"),
    ("tpd", "TITAN Project File Information"),
    ("tpl", "Smarty"),
    ("tpp", "C++"),
    ("tres", "Godot Resource"),
    ("trg", "Oracle PL/SQL"),
    ("trigger", "Apex Trigger"),
    ("ts", "TypeScript/Qt Linguist"),
    ("tscn", "Godot Scene"),
    ("tspeg", "tspeg"),
    ("tss", "Titanium Style Sheet"),
    ("tsx", "TypeScript"),
    ("ttcn", "TTCN"),
    ("ttcn2", "TTCN"),
    ("ttcn3", "TTCN"),
    ("ttcnpp", "TTCN"),
    ("twig", "Twig"),
    ("txt", "Text"),
    ("typ", "Typst"),
    ("udf", "SQL"),
    ("ui", "XML-Qt-GTK/Glade"),
    ("um", "Umka"),
    ("urdf", "XML"),
    ("uss", "USS"),
    ("ux", "XML"),
    ("uxml", "UXML"),
    ("v", "Verilog-SystemVerilog/Coq"),
    ("vagrantfile", "Ruby"),
    ("vala", "Vala"),
    ("vapi", "Vala Header"),
    ("vb", "Visual Basic .NET"),
    ("vba", "VBA"),
    ("vbhtml", "Visual Basic .NET"),
    ("vbp", "Visual Basic"),
    ("vbproj", "Visual Basic .NET"),
    ("vbs", "VBScript"),
    ("vbw", "Visual Basic"),
    ("vcproj", "MSBuild script"),
    ("vcxproj", "XML"),
    ("vert", "GLSL"),
    ("vhd", "VHDL"),
    ("vhdl", "VHDL"),
    ("vhf", "VHDL"),
    ("vhi", "VHDL"),
    ("vho", "VHDL"),
    ("vhs", "VHDL"),
    ("vht", "VHDL"),
    ("vhw", "VHDL"),
    ("vim", "vim script"),
    ("viw", "SQL"),
    ("vm", "Velocity Template Language"),
    ("vrx", "GLSL"),
    ("vsh", "GLSL"),
    ("vshader", "GLSL"),
    ("vsixmanifest", "XML"),
    ("vssettings", "XML"),
    ("vstemplate", "XML"),
    ("vue", "Vuejs Component"),
    ("vxml", "XML"),
    ("vy", "Vyper"),
    ("wast", "WebAssembly"),
    ("wat", "WebAssembly"),
    ("watchmanconfig", "JSON"),
    ("watchr", "Ruby"),
    ("wdproj", "MSBuild script"),
    ("webapp", "JSON"),
    ("webinfo", "ASP.NET"),
    ("webmanifest", "JSON"),
    ("wgsl", "WGSL"),
    ("wixproj", "MSBuild script"),
    ("wl", "Mathematica"),
    ("wlt", "Mathematica"),
    ("wlua", "Lua"),
    ("workbook", "Markdown"),
    ("workspace", "Python"),
    ("wren", "Wren"),
    ("wsd", "PlantUML"),
    ("wsdl", "Web Services Description"),
    ("wsf", "XML"),
    ("wsgi", "Python"),
    ("wxi", "WiX include"),
    ("wxl", "WiX string localization"),
    ("wxml", "WXML"),
    ("wxs", "WiX source"),
    ("wxss", "WXSS"),
    ("x", "Logos"),
    ("x3d", "XML"),
    ("xacro", "XML"),
    ("xaml", "XAML"),
    ("xht", "HTML"),
    ("xhtml", "XHTML"),
    ("xib", "XML"),
    ("xlf", "XML"),
    ("xliff", "XML"),
    ("xm", "Logos"),
    ("xmi", "XMI"),
    ("xml", "XML"),
    ("xpo", "X++"),
    ("xproj", "XML"),
    ("xpy", "Python"),
    ("xq", "XQuery"),
    ("xql", "XQuery"),
    ("xqm", "XQuery"),
    ("xquery", "XQuery"),
    ("xqy", "XQuery"),
    ("xrl", "Erlang"),
    ("xsd", "XSD"),
    ("xsjs", "JavaScript"),
    ("xsjslib", "JavaScript"),
    ("xsl", "XSLT"),
    ("xslt", "XSLT"),
    ("xspec", "XML"),
    ("xtend", "Xtend"),
    ("xul", "XML"),
    ("y", "yacc"),
    ("yacc", "yacc"),
    ("yaml", "YAML"),
    ("yaml-tmlanguage", "YAML"),
    ("yang", "Yang"),
    ("yap", "Prolog"),
    ("yarn", "Yarn"),
    ("yml", "YAML"),
    ("yrl", "Erlang"),
    ("yyp", "JSON"),
    ("zcml", "XML"),
    ("zig", "Zig"),
    ("zsh", "zsh"),
    ("ʕ◔ϖ◔ʔ", "Go"),
    ("🔥", "Mojo"),
];

pub fn language_comment_syntax(lang: &str) -> CommentSyntax {
    match lang {
        "(unknown)" => CommentSyntax::None,
        "ABAP" => CommentSyntax::Cobol,
        "ADSO/IDSM" => CommentSyntax::Slash,
        "AMPLE" => CommentSyntax::Slash,
        "ANTLR Grammar" => CommentSyntax::Html,
        "APL" => CommentSyntax::Slash,
        "ASP" => CommentSyntax::Basic,
        "ASP.NET" => CommentSyntax::Slash,
        "AXAML" => CommentSyntax::Html,
        "ActionScript" => CommentSyntax::Slash,
        "Activiti Business Process" => CommentSyntax::Hash,
        "Ada" => CommentSyntax::DashDash,
        "Agda" => CommentSyntax::Haskell,
        "AnsProlog" => CommentSyntax::Percent,
        "Ant" => CommentSyntax::Html,
        "Ant/XML" => CommentSyntax::Html,
        "Apex Trigger" => CommentSyntax::Hash,
        "AppleScript" => CommentSyntax::DashDash,
        "Arduino Sketch" => CommentSyntax::Hash,
        "Aria" => CommentSyntax::Hash,
        "ArkTs" => CommentSyntax::Slash,
        "Arturo" => CommentSyntax::Hash,
        "AsciiDoc" => CommentSyntax::None,
        "AspectJ" => CommentSyntax::Slash,
        "Assembly" => CommentSyntax::Semicolon,
        "Astro" => CommentSyntax::Hash,
        "Asymptote" => CommentSyntax::Slash,
        "AutoHotkey" => CommentSyntax::Semicolon,
        "Bazel" => CommentSyntax::Hash,
        "Beluga" => CommentSyntax::Matlab,
        "Bicep" => CommentSyntax::Slash,
        "BitBake" => CommentSyntax::Hash,
        "BizTalk Orchestration" => CommentSyntax::Hash,
        "BizTalk Pipeline" => CommentSyntax::Html,
        "Blade" => CommentSyntax::Slash,
        "Blueprint" => CommentSyntax::Hash,
        "Bourne Again Shell" => CommentSyntax::Hash,
        "Bourne Shell" => CommentSyntax::Hash,
        "Brainfuck" => CommentSyntax::Hash,
        "BrightScript" => CommentSyntax::Hash,
        "C" => CommentSyntax::Slash,
        "C Shell" => CommentSyntax::Hash,
        "C# Designer" => CommentSyntax::Slash,
        "C# Generated" => CommentSyntax::Slash,
        "C++" => CommentSyntax::Slash,
        "C/C++ Header" => CommentSyntax::Slash,
        "C3" => CommentSyntax::Slash,
        "CCS" => CommentSyntax::Slash,
        "CMake" => CommentSyntax::Hash,
        "COBOL" => CommentSyntax::Cobol,
        "CSON" => CommentSyntax::Hash,
        "CUDA" => CommentSyntax::Slash,
        "Cadence" => CommentSyntax::Slash,
        "Cairo" => CommentSyntax::Hash,
        "Cake Build Script" => CommentSyntax::Hash,
        "Carbon" => CommentSyntax::Slash,
        "Chapel" => CommentSyntax::Slash,
        "Circom" => CommentSyntax::Hash,
        "Civet" => CommentSyntax::Slash,
        "Clarity" => CommentSyntax::Semicolon,
        "Clean" => CommentSyntax::Slash,
        "Clojure" => CommentSyntax::Semicolon,
        "Clojure/Cangjie" => CommentSyntax::Semicolon,
        "ClojureC" => CommentSyntax::Semicolon,
        "ClojureScript" => CommentSyntax::Semicolon,
        "CoCoA 5" => CommentSyntax::Slash,
        "CodeQL" => CommentSyntax::Slash,
        "CoffeeScript" => CommentSyntax::Hash,
        "ColdFusion" => CommentSyntax::Html,
        "ColdFusion CFScript" => CommentSyntax::Hash,
        "Constraint Grammar" => CommentSyntax::Hash,
        "Containerfile" => CommentSyntax::Hash,
        "Crystal" => CommentSyntax::Ruby,
        "Cucumber" => CommentSyntax::Hash,
        "Cython" => CommentSyntax::Python,
        "D" => CommentSyntax::Slash,
        "D/dtrace" => CommentSyntax::Hash,
        "DAL" => CommentSyntax::Slash,
        "DAML" => CommentSyntax::Haskell,
        "DIET" => CommentSyntax::Slash,
        "DITA" => CommentSyntax::Html,
        "DOORS Extension Language" => CommentSyntax::Hash,
        "DOS Batch" => CommentSyntax::Batch,
        "DTD" => CommentSyntax::Html,
        "Dafny" => CommentSyntax::Slash,
        "Dart" => CommentSyntax::Slash,
        "Delphi Form" => CommentSyntax::Pascal,
        "DenizenScript" => CommentSyntax::Hash,
        "Derw" => CommentSyntax::Hash,
        "Dockerfile" => CommentSyntax::Hash,
        "Drools" => CommentSyntax::Hash,
        "ECPP" => CommentSyntax::Slash,
        "EEx" => CommentSyntax::Slash,
        "EJS" => CommentSyntax::Html,
        "ERB" => CommentSyntax::Html,
        "Elixir" => CommentSyntax::Hash,
        "Elixir Script" => CommentSyntax::Hash,
        "Elm" => CommentSyntax::DashDash,
        "Embedded Crystal" => CommentSyntax::Hash,
        "Erlang" => CommentSyntax::Percent,
        "Expect" => CommentSyntax::Hash,
        "FXML" => CommentSyntax::Html,
        "Fennel" => CommentSyntax::Semicolon,
        "Finite State Language" => CommentSyntax::Semicolon,
        "Fish Shell" => CommentSyntax::Hash,
        "Flatbuffers" => CommentSyntax::Hash,
        "Focus" => CommentSyntax::Slash,
        "Forth" => CommentSyntax::Hash,
        "Fortran 2003" => CommentSyntax::Fortran,
        "Fortran 77" => CommentSyntax::Fortran,
        "Fortran 77/Forth" => CommentSyntax::Fortran,
        "Fortran 90" => CommentSyntax::Fortran,
        "Fortran 95" => CommentSyntax::Fortran,
        "Freemarker Template" => CommentSyntax::Html,
        "Futhark" => CommentSyntax::Hash,
        "GDScript" => CommentSyntax::Hash,
        "GLSL" => CommentSyntax::Slash,
        "Gencat NLS" => CommentSyntax::Slash,
        "Glade" => CommentSyntax::Html,
        "Gleam" => CommentSyntax::Slash,
        "Glimmer JavaScript" => CommentSyntax::Hash,
        "Glimmer TypeScript" => CommentSyntax::Hash,
        "Go" => CommentSyntax::Slash,
        "Godot Resource" => CommentSyntax::Hash,
        "Godot Scene" => CommentSyntax::Semicolon,
        "Godot Shaders" => CommentSyntax::Hash,
        "Gradle" => CommentSyntax::Hash,
        "Grails" => CommentSyntax::Hash,
        "GraphQL" => CommentSyntax::Hash,
        "Groovy" => CommentSyntax::Hash,
        "HCL" => CommentSyntax::Hash,
        "HLSL" => CommentSyntax::Slash,
        "HTML" => CommentSyntax::Html,
        "HTML EEx" => CommentSyntax::Html,
        "Haml" => CommentSyntax::Slash,
        "Handlebars" => CommentSyntax::Html,
        "Harbour" => CommentSyntax::Hash,
        "Hare" => CommentSyntax::Slash,
        "Haskell" => CommentSyntax::Haskell,
        "Haskell Boot" => CommentSyntax::Haskell,
        "Haxe" => CommentSyntax::Slash,
        "Hibernate" => CommentSyntax::Hash,
        "HolyC" => CommentSyntax::Slash,
        "Hoon" => CommentSyntax::Slash,
        "IDL" => CommentSyntax::Semicolon,
        "IDL/Qt Project/Prolog/ProGuard" => CommentSyntax::Percent,
        "INI" => CommentSyntax::Semicolon,
        "IPL" => CommentSyntax::Slash,
        "Idris" => CommentSyntax::Haskell,
        "Igor Pro" => CommentSyntax::Hash,
        "Imba" => CommentSyntax::Slash,
        "InstallShield" => CommentSyntax::Html,
        "JCL" => CommentSyntax::Slash,
        "JSON" => CommentSyntax::None,
        "JSON5" => CommentSyntax::None,
        "JSP" => CommentSyntax::Html,
        "JSP Tag Library Definition" => CommentSyntax::Semicolon,
        "JSX" => CommentSyntax::Slash,
        "Jai" => CommentSyntax::Slash,
        "Jam" => CommentSyntax::Hash,
        "Janet" => CommentSyntax::Hash,
        "Jasper Report XML/Template" => CommentSyntax::Html,
        "Java" => CommentSyntax::Slash,
        "JavaScript" => CommentSyntax::Slash,
        "JavaServer Faces" => CommentSyntax::Hash,
        "Jinja Template" => CommentSyntax::Html,
        "Jsonnet" => CommentSyntax::None,
        "Juniper Junos" => CommentSyntax::Hash,
        "Jupyter Notebook" => CommentSyntax::Python,
        "Justfile" => CommentSyntax::Hash,
        "Kermit" => CommentSyntax::Hash,
        "Korn Shell" => CommentSyntax::Hash,
        "Kotlin" => CommentSyntax::Slash,
        "LESS" => CommentSyntax::Slash,
        "LFE" => CommentSyntax::Semicolon,
        "LLVM IR" => CommentSyntax::Hash,
        "Lean" => CommentSyntax::Slash,
        "Lem" => CommentSyntax::Slash,
        "Linker Script" => CommentSyntax::Hash,
        "Liquibase" => CommentSyntax::Html,
        "Lisp" => CommentSyntax::Semicolon,
        "Lisp/Julia" => CommentSyntax::Semicolon,
        "Lisp/OpenCL" => CommentSyntax::Semicolon,
        "Literate Idris" => CommentSyntax::Haskell,
        "LiveLink OScript" => CommentSyntax::Hash,
        "Logos" => CommentSyntax::Hash,
        "Logtalk" => CommentSyntax::Percent,
        "Lua" => CommentSyntax::Lua,
        "Luau" => CommentSyntax::Lua,
        "MATLAB/Mathematica/Objective-C/MUMPS/Mercury" => CommentSyntax::Hash,
        "MSBuild script" => CommentSyntax::Hash,
        "MUMPS" => CommentSyntax::Semicolon,
        "MXML" => CommentSyntax::Html,
        "Magik" => CommentSyntax::Hash,
        "Mako" => CommentSyntax::Slash,
        "Markdown" => CommentSyntax::None,
        "Mathematica" => CommentSyntax::Slash,
        "Maven" => CommentSyntax::Html,
        "Maven/XML" => CommentSyntax::Html,
        "Meson" => CommentSyntax::Hash,
        "Metal" => CommentSyntax::Slash,
        "Modelica" => CommentSyntax::Slash,
        "Modula3" => CommentSyntax::Pascal,
        "Mojo" => CommentSyntax::Slash,
        "Mojom" => CommentSyntax::Slash,
        "MoonBit" => CommentSyntax::Slash,
        "Mustache" => CommentSyntax::Html,
        "NASTRAN DMAP" => CommentSyntax::Hash,
        "NAnt script" => CommentSyntax::Html,
        "Nemerle" => CommentSyntax::Hash,
        "NetLogo" => CommentSyntax::Semicolon,
        "Nextflow" => CommentSyntax::Slash,
        "Nickel" => CommentSyntax::Hash,
        "Nim" => CommentSyntax::Hash,
        "Nix" => CommentSyntax::Hash,
        "Nunjucks" => CommentSyntax::Slash,
        "Nushell" => CommentSyntax::Hash,
        "Nushell Object Notation" => CommentSyntax::Hash,
        "OCaml" => CommentSyntax::OCaml,
        "Objective-C" => CommentSyntax::Slash,
        "Objective-C++" => CommentSyntax::Slash,
        "Octave" => CommentSyntax::Matlab,
        "Odin" => CommentSyntax::Slash,
        "OpenSCAD" => CommentSyntax::Slash,
        "Oracle Forms" => CommentSyntax::Hash,
        "Oracle PL/SQL" => CommentSyntax::Sql,
        "Oracle Reports" => CommentSyntax::Hash,
        "Org Mode" => CommentSyntax::None,
        "P4" => CommentSyntax::Slash,
        "PEG" => CommentSyntax::Slash,
        "PHP" => CommentSyntax::Hash,
        "PHP/Pascal/Fortran/Pawn/BitBake/Assembly" => CommentSyntax::Fortran,
        "PL/I" => CommentSyntax::Slash,
        "PL/M" => CommentSyntax::Slash,
        "PO File" => CommentSyntax::Slash,
        "PRQL" => CommentSyntax::Hash,
        "Pascal" => CommentSyntax::Pascal,
        "Pascal/Pawn" => CommentSyntax::Pascal,
        "Pascal/Puppet" => CommentSyntax::Pascal,
        "Patran Command Language" => CommentSyntax::Hash,
        "Pawn" => CommentSyntax::Slash,
        "Pek" => CommentSyntax::Slash,
        "Perl" => CommentSyntax::Perl,
        "Perl/AL" => CommentSyntax::Perl,
        "Perl/Prolog" => CommentSyntax::Percent,
        "Pest" => CommentSyntax::Slash,
        "Pig Latin" => CommentSyntax::DashDash,
        "Pkl" => CommentSyntax::Slash,
        "PlantUML" => CommentSyntax::Html,
        "Pony" => CommentSyntax::Slash,
        "PowerBuilder" => CommentSyntax::Html,
        "PowerShell" => CommentSyntax::PowerShell,
        "Prisma Schema" => CommentSyntax::Hash,
        "Processing" => CommentSyntax::Slash,
        "Prolog" => CommentSyntax::Percent,
        "Properties" => CommentSyntax::Hash,
        "Protocol Buffers" => CommentSyntax::Slash,
        "Pug" => CommentSyntax::Slash,
        "PureScript" => CommentSyntax::Hash,
        "Python" => CommentSyntax::Python,
        "QML" => CommentSyntax::Slash,
        "Qt Linguist" => CommentSyntax::Html,
        "Quxlang" => CommentSyntax::Slash,
        "R" => CommentSyntax::Hash,
        "RAML" => CommentSyntax::Hash,
        "Racket" => CommentSyntax::Semicolon,
        "Raku" => CommentSyntax::Hash,
        "Raku/Prolog" => CommentSyntax::Percent,
        "RapydScript" => CommentSyntax::Hash,
        "Razor" => CommentSyntax::Hash,
        "ReScript" => CommentSyntax::Hash,
        "ReasonML" => CommentSyntax::Hash,
        "Rego" => CommentSyntax::Hash,
        "Rexx" => CommentSyntax::Hash,
        "Rhai" => CommentSyntax::Hash,
        "Ring" => CommentSyntax::Hash,
        "Rmd" => CommentSyntax::Hash,
        "RobotFramework" => CommentSyntax::Hash,
        "Ruby" => CommentSyntax::Ruby,
        "Ruby HTML" => CommentSyntax::Html,
        "Rust" => CommentSyntax::Slash,
        "SAS" => CommentSyntax::Slash,
        "SCSS" => CommentSyntax::Slash,
        "SKILL++" => CommentSyntax::Slash,
        "SKILL/.NET IL" => CommentSyntax::Slash,
        "SQL" => CommentSyntax::Sql,
        "SQL Data" => CommentSyntax::Sql,
        "SQL Stored Procedure" => CommentSyntax::Sql,
        "SVG" => CommentSyntax::Html,
        "SWIG" => CommentSyntax::Slash,
        "Sass" => CommentSyntax::Slash,
        "Scala" => CommentSyntax::Slash,
        "Scheme" => CommentSyntax::Semicolon,
        "Scheme/SaltStack" => CommentSyntax::Semicolon,
        "Sema" => CommentSyntax::Slash,
        "Slang" => CommentSyntax::Slash,
        "Slice" => CommentSyntax::Slash,
        "Slim" => CommentSyntax::Slash,
        "Slint" => CommentSyntax::Slash,
        "Smalltalk" => CommentSyntax::Slash,
        "Smarty" => CommentSyntax::Hash,
        "Snakemake" => CommentSyntax::Hash,
        "Softbridge Basic" => CommentSyntax::Basic,
        "Solidity" => CommentSyntax::Slash,
        "SparForte" => CommentSyntax::Hash,
        "Specman e" => CommentSyntax::Slash,
        "Squirrel" => CommentSyntax::Hash,
        "Standard ML" => CommentSyntax::OCaml,
        "Starlark" => CommentSyntax::Hash,
        "Stata" => CommentSyntax::Slash,
        "Stylus" => CommentSyntax::Slash,
        "SugarSS" => CommentSyntax::Hash,
        "SurrealQL" => CommentSyntax::Hash,
        "Svelte" => CommentSyntax::Slash,
        "Swift" => CommentSyntax::Slash,
        "TEAL" => CommentSyntax::Slash,
        "TITAN Project File Information" => CommentSyntax::Hash,
        "TLA+" => CommentSyntax::Slash,
        "TNSDL" => CommentSyntax::Slash,
        "TOML" => CommentSyntax::Hash,
        "TTCN" => CommentSyntax::Slash,
        "TableGen" => CommentSyntax::Slash,
        "Tcl/Tk" => CommentSyntax::Hash,
        "TeX" => CommentSyntax::Percent,
        "Teamcenter met" => CommentSyntax::Hash,
        "Teamcenter mth" => CommentSyntax::Hash,
        "Templ" => CommentSyntax::Slash,
        "Text" => CommentSyntax::Percent,
        "Thrift" => CommentSyntax::Hash,
        "Titanium Style Sheet" => CommentSyntax::Slash,
        "Twig" => CommentSyntax::Html,
        "TypeScript" => CommentSyntax::Slash,
        "TypeScript/Qt Linguist" => CommentSyntax::Html,
        "Typst" => CommentSyntax::Slash,
        "USS" => CommentSyntax::Slash,
        "UXML" => CommentSyntax::Html,
        "Umka" => CommentSyntax::Slash,
        "Unity-Prefab" => CommentSyntax::Hash,
        "Unknown" => CommentSyntax::None,
        "Unknown/BitBake" => CommentSyntax::Hash,
        "VBA" => CommentSyntax::Basic,
        "VBScript" => CommentSyntax::Basic,
        "VHDL" => CommentSyntax::DashDash,
        "VSCode Workspace" => CommentSyntax::Hash,
        "Vala" => CommentSyntax::Slash,
        "Vala Header" => CommentSyntax::Hash,
        "Velocity Template Language" => CommentSyntax::Html,
        "Verilog-SystemVerilog" => CommentSyntax::Hash,
        "Verilog-SystemVerilog/Coq" => CommentSyntax::OCaml,
        "Visual Basic" => CommentSyntax::Basic,
        "Visual Basic .NET" => CommentSyntax::Basic,
        "Visual Basic/TeX/Apex Class" => CommentSyntax::Basic,
        "Visual Fox Pro" => CommentSyntax::Hash,
        "Visual Studio Solution" => CommentSyntax::Hash,
        "Visualforce Component" => CommentSyntax::Hash,
        "Visualforce Page" => CommentSyntax::Hash,
        "Vue" => CommentSyntax::Html,
        "Vuejs Component" => CommentSyntax::Html,
        "Vyper" => CommentSyntax::Hash,
        "WGSL" => CommentSyntax::Slash,
        "WXML" => CommentSyntax::Html,
        "WXSS" => CommentSyntax::Slash,
        "Web Services Description" => CommentSyntax::Hash,
        "WebAssembly" => CommentSyntax::Semicolon,
        "WiX include" => CommentSyntax::Html,
        "WiX source" => CommentSyntax::Hash,
        "WiX string localization" => CommentSyntax::Hash,
        "Windows INF/TNSDL" => CommentSyntax::Slash,
        "Windows Message File" => CommentSyntax::Slash,
        "Windows Module Definition" => CommentSyntax::Semicolon,
        "Windows Resource File" => CommentSyntax::Hash,
        "Wren" => CommentSyntax::Hash,
        "X++" => CommentSyntax::Slash,
        "XAML" => CommentSyntax::Html,
        "XHTML" => CommentSyntax::Html,
        "XMI" => CommentSyntax::Html,
        "XML" => CommentSyntax::Html,
        "XML (Qt/GTK)" => CommentSyntax::Html,
        "XML-Qt-GTK/Glade" => CommentSyntax::Html,
        "XQuery" => CommentSyntax::Hash,
        "XSD" => CommentSyntax::Html,
        "XSLT" => CommentSyntax::Html,
        "Xtend" => CommentSyntax::Slash,
        "YAML" => CommentSyntax::Hash,
        "Yang" => CommentSyntax::Slash,
        "Yarn" => CommentSyntax::Hash,
        "Zig" => CommentSyntax::Slash,
        "awk" => CommentSyntax::Hash,
        "bc" => CommentSyntax::Hash,
        "builder" => CommentSyntax::Hash,
        "dhall" => CommentSyntax::Haskell,
        "diff" => CommentSyntax::None,
        "dtrace" => CommentSyntax::Hash,
        "kvlang" => CommentSyntax::Slash,
        "lex" => CommentSyntax::Slash,
        "liquid" => CommentSyntax::Slash,
        "m4" => CommentSyntax::Slash,
        "make" => CommentSyntax::Hash,
        "peg.js" => CommentSyntax::Slash,
        "peggy" => CommentSyntax::Slash,
        "reStructuredText" => CommentSyntax::Percent,
        "sed" => CommentSyntax::Hash,
        "tspeg" => CommentSyntax::Slash,
        "vim script" => CommentSyntax::VimScript,
        "xBase" => CommentSyntax::Slash,
        "xBase Header" => CommentSyntax::Hash,
        "yacc" => CommentSyntax::Slash,
        "zsh" => CommentSyntax::Hash,
        _ => {
            let l = lang.to_ascii_lowercase();
            if l.contains("sql") {
                CommentSyntax::Sql
            } else if l.contains("html") || l.contains("xml") {
                CommentSyntax::Html
            } else if l.contains("shell") || l.contains("sh") || l.contains("hash") {
                CommentSyntax::Hash
            } else if l.contains("basic") {
                CommentSyntax::Basic
            } else if l.contains("fortran") {
                CommentSyntax::Fortran
            } else {
                CommentSyntax::Slash
            }
        }
    }
}

#[inline]
pub fn match_exact_filename(filename: &str, data: &[u8]) -> Option<(&'static str, CommentSyntax)> {
    let lower_buf = filename.to_ascii_lowercase();
    let lower = lower_buf.as_str();

    match filename {
        "Makefile" | "makefile" | "Gnumakefile" | "gnumakefile" | "Kbuild" => {
            return Some(("make", CommentSyntax::Hash));
        }
        "BUILD" | "WORKSPACE" | "BUILD.bazel" | "WORKSPACE.bazel" => {
            return Some(("Bazel", CommentSyntax::Hash));
        }
        "CMakeLists.txt" | "cmakelists.txt" => {
            return Some(("CMake", CommentSyntax::Hash));
        }
        "Rakefile" | "rakefile" | "Gemfile" | "gemfile" | "Vagrantfile" | "Berksfile"
        | "Brewfile" | "Fastfile" | "Appfile" | "Podfile" | "Thorfile" | "Puppetfile"
        | "Capfile" | "Guardfile" | "Cheffile" => {
            return Some(("Ruby", CommentSyntax::Ruby));
        }
        "Jenkinsfile" | "jenkinsfile" => {
            return Some(("Groovy", CommentSyntax::Slash));
        }
        "Cargo.toml" | "Cargo.lock" | "poetry.lock" | "Pipfile" => {
            return Some(("TOML", CommentSyntax::Hash));
        }
        "meson.build" => {
            return Some(("Meson", CommentSyntax::Hash));
        }
        "Justfile" | "justfile" => {
            return Some(("Justfile", CommentSyntax::Hash));
        }
        "Snakefile" => {
            return Some(("Snakemake", CommentSyntax::Hash));
        }
        "Jamfile" | "jamfile" | "Jamrules" => {
            return Some(("Jam", CommentSyntax::Hash));
        }
        "wscript" => {
            return Some(("Python", CommentSyntax::Python));
        }
        "go.mod" | "go.sum" => {
            return Some(("Go", CommentSyntax::Slash));
        }
        "build.xml" => {
            let lang = disambiguate_build_xml(data);
            return Some((lang, CommentSyntax::Html));
        }
        "pom.xml" => {
            let lang = disambiguate_pom_xml(data);
            return Some((lang, CommentSyntax::Html));
        }
        _ => {}
    }

    if lower == "dockerfile"
        || lower.starts_with("dockerfile.")
        || lower.ends_with(".dockerfile")
    {
        return Some(("Dockerfile", CommentSyntax::Hash));
    }
    if lower == "containerfile"
        || lower.starts_with("containerfile.")
        || lower.ends_with(".containerfile")
    {
        return Some(("Containerfile", CommentSyntax::Hash));
    }

    None
}

#[inline]
pub fn is_not_code_filename(filename: &str) -> bool {
    if filename.ends_with('~') {
        return true;
    }
    let lower_buf = filename.to_ascii_lowercase();
    matches!(
        lower_buf.as_str(),
        "authors"
            | "bugs"
            | "changelog"
            | "changes"
            | "copying"
            | "description"
            | ".cvsignore"
            | "entries"
            | "faq"
            | "install"
            | "maintainers"
            | "readme"
            | "readme.md"
            | "readme.txt"
            | "licence"
            | "license"
            | "notice"
            | "todo"
            | ".gitignore"
            | ".gitattributes"
            | ".gitmodules"
    )
}

#[inline]
pub fn is_not_code_extension(ext: &str) -> bool {
    matches!(
        ext,
        "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
            | "a" | "o" | "so" | "dylib" | "dll" | "exe" | "class" | "pyc" | "pyo" | "elc"
            | "png" | "jpg" | "jpeg" | "gif" | "bmp" | "ico" | "tiff" | "webp" | "pdf" | "ps"
            | "zip" | "tar" | "gz" | "bz2" | "xz" | "7z" | "rar" | "whl" | "ear" | "war"
            | "mp3" | "wav" | "ogg" | "mp4" | "mkv" | "avi"
            | "bak" | "swp" | "swo" | "tag" | "gitattributes" | "gitignore" | "gitmodules"
    )
}

#[inline]
fn lines_iter(data: &[u8]) -> impl Iterator<Item = &[u8]> {
    data.split(|&b| b == b'\n').map(|l| {
        if l.ends_with(b"\r") {
            &l[..l.len() - 1]
        } else {
            l
        }
    })
}

#[inline]
fn trim_ascii(bytes: &[u8]) -> &[u8] {
    let mut start = 0;
    while start < bytes.len() && (bytes[start] == b' ' || bytes[start] == b'\t') {
        start += 1;
    }
    let mut end = bytes.len();
    while end > start && (bytes[end - 1] == b' ' || bytes[end - 1] == b'\t') {
        end -= 1;
    }
    &bytes[start..end]
}

pub fn disambiguate_m(data: &[u8]) -> &'static str {
    let mut matlab_points: i32 = 0;
    let mut mathematica_points: i32 = 0;
    let mut objective_c_points: i32 = 0;
    let mut mumps_points: i32 = 0;
    let mercury_points: i32 = 0;

    for (i, line) in lines_iter(data).enumerate() {
        let trimmed = trim_ascii(line);
        if trimmed.is_empty() {
            continue;
        }

        if trimmed.starts_with(b":- ") {
            return "Mercury";
        }

        if trimmed.starts_with(b"#import") || trimmed.starts_with(b"#include") {
            return "Objective-C";
        }
        if trimmed.starts_with(b"@interface")
            || trimmed.starts_with(b"@implementation")
            || trimmed.starts_with(b"@protocol")
            || trimmed.starts_with(b"@public")
            || trimmed.starts_with(b"@protected")
            || trimmed.starts_with(b"@private")
            || trimmed.starts_with(b"@end")
            || trimmed.starts_with(b"@property")
            || trimmed.starts_with(b"@synthesize")
        {
            return "Objective-C";
        }

        if i == 0 && !trimmed.is_empty() && trimmed[0].is_ascii_uppercase() {
            mumps_points += 1;
        }

        if trimmed.starts_with(b"/*") || trimmed.starts_with(b"//") {
            objective_c_points += 5;
            matlab_points -= 5;
        } else if trimmed.starts_with(b"[") {
            matlab_points += 5;
        } else if trimmed.starts_with(b";") {
            mumps_points += 1;
        } else if trimmed.starts_with(b"function") || trimmed.starts_with(b"%") {
            matlab_points += 1;
            objective_c_points -= 1;
        } else if trimmed.starts_with(b"BeginPackage") {
            mathematica_points += 5;
        } else if trimmed.starts_with(b"K ") || trimmed.starts_with(b"Kill ") {
            mumps_points += 5;
        }

        if line.windows(2).any(|w| w == b"={" || w == b"=[") {
            matlab_points += 5;
        }
        if line.contains(&b'{') || line.contains(&b'}') {
            objective_c_points += 1;
        }
    }

    let mut scores = [
        ("MATLAB", matlab_points),
        ("Objective-C", objective_c_points),
        ("Mathematica", mathematica_points),
        ("MUMPS", mumps_points),
        ("Mercury", mercury_points),
    ];
    scores.sort_by_key(|b| std::cmp::Reverse(b.1));
    scores[0].0
}

pub fn disambiguate_h(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"@interface")
            || trimmed.starts_with(b"@protocol")
            || trimmed.starts_with(b"@implementation")
            || trimmed.starts_with(b"@property")
            || trimmed.starts_with(b"@synthesize")
            || trimmed.starts_with(b"@end")
            || (trimmed.starts_with(b"#import")
                && (trimmed.contains(&b'<') || trimmed.contains(&b'"'))
                && (line.windows(11).any(|w| w == b"Foundation/")
                    || line.windows(6).any(|w| w == b"Cocoa/")
                    || line.windows(6).any(|w| w == b"UIKit/")
                    || line.windows(7).any(|w| w == b"AppKit/")))
        {
            return "Objective-C";
        }
    }
    "C/C++ Header"
}

pub fn disambiguate_pl(data: &[u8]) -> &'static str {
    let mut perl_points = 0;
    let mut prolog_points = 0;

    for (i, line) in lines_iter(data).enumerate() {
        let trimmed = trim_ascii(line);
        if trimmed.is_empty() {
            continue;
        }

        if i == 0 && trimmed.starts_with(b"#!") && trimmed.windows(4).any(|w| w == b"perl") {
            return "Perl";
        }

        if trimmed.starts_with(b"=head")
            || trimmed.starts_with(b"=pod")
            || trimmed.starts_with(b"=item")
            || trimmed.starts_with(b"=cut")
            || trimmed.starts_with(b"sub ")
            || trimmed.starts_with(b"my $")
            || trimmed.starts_with(b"use strict")
            || trimmed.starts_with(b"use warnings")
        {
            perl_points += 5;
        }

        if trimmed.ends_with(b";") {
            perl_points += 1;
        }
        if trimmed.contains(&b'{') || trimmed.contains(&b'}') {
            perl_points += 1;
        }

        if line.windows(2).any(|w| w == b":-") {
            prolog_points += 5;
        }
        if !trimmed.starts_with(b"#") && trimmed.ends_with(b".") {
            prolog_points += 2;
        }
    }

    if perl_points >= prolog_points {
        "Perl"
    } else {
        "Prolog"
    }
}

pub fn disambiguate_p6(data: &[u8]) -> &'static str {
    let l = disambiguate_pl(data);
    if l == "Perl" {
        "Raku"
    } else {
        "Prolog"
    }
}

pub fn disambiguate_f(data: &[u8]) -> &'static str {
    let mut forth_points = 0;
    let mut fortran_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.is_empty() {
            continue;
        }

        if trimmed.starts_with(b": ") {
            forth_points += 3;
        }

        if !line.is_empty() {
            let col1 = line[0];
            if ((col1 == b'c' || col1 == b'C') && (line.len() == 1 || !line[1].is_ascii_alphabetic()))
                || col1 == b'*'
                || col1 == b'!'
            {
                fortran_points += 2;
            }
        }

        if line.starts_with(b"      ") {
            let body = trim_ascii(&line[6..]);
            if body.starts_with(b"subroutine")
                || body.starts_with(b"SUBROUTINE")
                || body.starts_with(b"program")
                || body.starts_with(b"PROGRAM")
                || body.starts_with(b"implicit")
                || body.starts_with(b"IMPLICIT")
                || body.starts_with(b"dimension")
                || body.starts_with(b"DIMENSION")
            {
                fortran_points += 5;
            }
        }
    }

    if forth_points > fortran_points {
        "Forth"
    } else {
        "Fortran 77"
    }
}

pub fn disambiguate_fs(data: &[u8]) -> &'static str {
    let mut forth_points = 0;
    let mut fsharp_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b": ") {
            forth_points += 3;
        }
        if trimmed.starts_with(b"#light")
            || trimmed.starts_with(b"let ")
            || trimmed.starts_with(b"let rec ")
            || trimmed.starts_with(b"module ")
            || trimmed.starts_with(b"open ")
            || trimmed.starts_with(b"namespace ")
            || trimmed.starts_with(b"type ")
        {
            fsharp_points += 3;
        }
    }

    if forth_points > fsharp_points {
        "Forth"
    } else {
        "F#"
    }
}

pub fn disambiguate_cl(data: &[u8]) -> &'static str {
    let mut lisp_points = 0;
    let mut opencl_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b";") {
            lisp_points += 2;
        }
        if trimmed.starts_with(b"(def")
            || trimmed.starts_with(b"(in-package")
            || trimmed.starts_with(b"(eval")
            || trimmed.starts_with(b"(let")
        {
            lisp_points += 3;
        }
        if trimmed.starts_with(b"__kernel")
            || trimmed.starts_with(b"__global")
            || trimmed.starts_with(b"__constant")
            || trimmed.starts_with(b"int ")
            || trimmed.starts_with(b"float ")
            || trimmed.starts_with(b"void ")
            || trimmed.contains(&b'{')
        {
            opencl_points += 2;
        }
    }

    if lisp_points >= opencl_points {
        "Lisp"
    } else {
        "OpenCL"
    }
}

pub fn disambiguate_jl(data: &[u8]) -> &'static str {
    let mut lisp_points = 0;
    let mut julia_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b";") {
            lisp_points += 2;
        }
        if trimmed.starts_with(b"(def") {
            lisp_points += 3;
        }
        if trimmed.starts_with(b"function ")
            || trimmed.starts_with(b"end")
            || trimmed.starts_with(b"println")
            || trimmed.starts_with(b"for ")
            || trimmed.starts_with(b"while ")
            || trimmed.starts_with(b"module ")
            || trimmed.starts_with(b"using ")
        {
            julia_points += 2;
        }
    }

    if lisp_points > julia_points {
        "Lisp"
    } else {
        "Julia"
    }
}

pub fn disambiguate_v(data: &[u8]) -> &'static str {
    let mut verilog_points = 0;
    let mut coq_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"module ")
            || trimmed.starts_with(b"endmodule")
            || trimmed.starts_with(b"always ")
            || trimmed.starts_with(b"initial ")
            || trimmed.starts_with(b"input ")
            || trimmed.starts_with(b"output ")
            || trimmed.starts_with(b"reg ")
            || trimmed.starts_with(b"wire ")
        {
            verilog_points += 3;
        }
        if trimmed.starts_with(b"Inductive ")
            || trimmed.starts_with(b"Fixpoint ")
            || trimmed.starts_with(b"Definition ")
            || trimmed.starts_with(b"Theorem ")
            || trimmed.starts_with(b"Lemma ")
            || trimmed.starts_with(b"Proof.")
            || trimmed.starts_with(b"Qed.")
            || trimmed.starts_with(b"Section ")
            || trimmed.starts_with(b"Record ")
            || trimmed.starts_with(b"Require ")
        {
            coq_points += 3;
        }
    }

    if coq_points > verilog_points {
        "Coq"
    } else {
        "Verilog-SystemVerilog"
    }
}

pub fn disambiguate_ts(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"<?xml")
            || trimmed.starts_with(b"<!DOCTYPE TS")
            || trimmed.windows(3).any(|w| w == b"<TS")
            || trimmed.windows(9).any(|w| w == b"<context>")
            || trimmed.windows(9).any(|w| w == b"<message>")
            || trimmed.windows(8).any(|w| w == b"<source>")
            || trimmed.windows(13).any(|w| w == b"<translation>")
        {
            return "Qt Linguist";
        }
    }
    "TypeScript"
}

pub fn disambiguate_cs(data: &[u8]) -> &'static str {
    let mut cs_points = 0;
    let mut smalltalk_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.is_empty() {
            continue;
        }
        if trimmed.ends_with(b"!") || trimmed.ends_with(b"].") {
            smalltalk_points += 2;
        }
        if trimmed.starts_with(b"using ")
            || trimmed.starts_with(b"namespace ")
            || trimmed.starts_with(b"public ")
            || trimmed.starts_with(b"private ")
            || trimmed.starts_with(b"class ")
            || trimmed.starts_with(b"//")
            || trimmed.ends_with(b";")
        {
            cs_points += 2;
        }
    }

    if smalltalk_points > cs_points {
        "Smalltalk"
    } else {
        "C#"
    }
}

pub fn disambiguate_cls(data: &[u8]) -> &'static str {
    let mut vb_points = 0;
    let mut tex_points = 0;
    let mut apex_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"%")
            || trimmed.starts_with(b"\\documentclass")
            || trimmed.starts_with(b"\\begin")
            || trimmed.starts_with(b"\\def")
        {
            tex_points += 3;
        } else {
            if trimmed.starts_with(b"VERSION ")
                || trimmed.starts_with(b"Attribute VB_")
                || trimmed.starts_with(b"End Sub")
                || trimmed.starts_with(b"Dim ")
            {
                vb_points += 3;
            }
            if trimmed.starts_with(b"public class ")
                || trimmed.starts_with(b"global class ")
                || trimmed.starts_with(b"private class ")
                || trimmed.starts_with(b"@isTest")
                || trimmed.contains(&b'{')
                || trimmed.contains(&b'}')
            {
                apex_points += 3;
            }
        }
    }

    if tex_points >= vb_points && tex_points >= apex_points {
        "TeX"
    } else if apex_points >= vb_points {
        "Apex Class"
    } else {
        "Visual Basic"
    }
}

pub fn disambiguate_pp(data: &[u8]) -> &'static str {
    let mut pascal_points = 0;
    let mut puppet_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"class ")
            || trimmed.starts_with(b"package ")
            || trimmed.starts_with(b"file ")
            || trimmed.starts_with(b"service ")
            || trimmed.contains(&b'$')
            || line.windows(2).any(|w| w == b"=>")
        {
            puppet_points += 2;
        }
        if trimmed.starts_with(b"program ")
            || trimmed.starts_with(b"unit ")
            || trimmed.starts_with(b"procedure ")
            || trimmed.starts_with(b"function ")
            || trimmed.starts_with(b"begin")
            || trimmed.starts_with(b"end.")
            || trimmed.starts_with(b"writeln")
            || line.windows(2).any(|w| w == b":=")
        {
            pascal_points += 2;
        }
    }

    if puppet_points > pascal_points {
        "Puppet"
    } else {
        "Pascal"
    }
}

pub fn disambiguate_inc(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"<?php") {
            return "PHP";
        }
        if trimmed.starts_with(b"implicit none")
            || trimmed.starts_with(b"subroutine ")
            || trimmed.starts_with(b"module ")
        {
            return "Fortran 90";
        }
        if trimmed.starts_with(b"program ")
            || trimmed.starts_with(b"begin")
            || trimmed.starts_with(b"writeln")
            || trimmed.starts_with(b"end.")
        {
            return "Pascal";
        }
        if trimmed.starts_with(b"Float:") || trimmed.starts_with(b"bool:") {
            return "Pawn";
        }
        if trimmed.starts_with(b"SRC_URI")
            || trimmed.starts_with(b"inherit ")
            || trimmed.starts_with(b"do_compile")
        {
            return "BitBake";
        }
        if trimmed.starts_with(b"section .")
            || trimmed.starts_with(b"org ")
            || trimmed.starts_with(b".org ")
        {
            return "Assembly";
        }
    }
    "PHP"
}

pub fn disambiguate_al(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"codeunit ")
            || trimmed.starts_with(b"page ")
            || trimmed.starts_with(b"table ")
            || trimmed.starts_with(b"report ")
            || trimmed.starts_with(b"query ")
            || trimmed.starts_with(b"namespace ")
            || trimmed.starts_with(b"using ")
        {
            return "AL";
        }
    }
    "Perl"
}

pub fn disambiguate_pro(data: &[u8]) -> &'static str {
    let mut idl_points = 0;
    let mut qt_points = 0;
    let mut prolog_points = 0;
    let mut proguard_points = 0;

    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"-keep") || trimmed.starts_with(b"-dontobfuscate") {
            proguard_points += 5;
        }
        if trimmed.starts_with(b"TEMPLATE =")
            || trimmed.starts_with(b"CONFIG +=")
            || trimmed.starts_with(b"CONFIG -=")
            || trimmed.starts_with(b"SOURCES +=")
            || trimmed.starts_with(b"QT +=")
        {
            qt_points += 5;
        }
        if line.windows(2).any(|w| w == b":-") {
            prolog_points += 3;
        }
        if trimmed.starts_with(b";") || trimmed.starts_with(b"pro ") {
            idl_points += 3;
        }
    }

    let mut scores = [
        ("ProGuard", proguard_points),
        ("Qt Project", qt_points),
        ("Prolog", prolog_points),
        ("IDL", idl_points),
    ];
    scores.sort_by_key(|b| std::cmp::Reverse(b.1));
    if scores[0].1 > 0 {
        scores[0].0
    } else {
        "Prolog"
    }
}

pub fn disambiguate_d(data: &[u8]) -> &'static str {
    if let Some((lang, _)) = match_shebang(data) {
        return lang;
    }
    "D"
}

pub fn disambiguate_p(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"Float:") || trimmed.starts_with(b"bool:") {
            return "Pawn";
        }
        if trimmed.starts_with(b"program ")
            || trimmed.starts_with(b"begin")
            || trimmed.starts_with(b"writeln")
        {
            return "Pascal";
        }
    }
    "Pascal"
}

pub fn disambiguate_sls(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.contains(&b'{') && trimmed.contains(&b'%') {
            return "SaltStack";
        }
        if trimmed.starts_with(b"(define") || trimmed.starts_with(b"(lambda") {
            return "Scheme";
        }
    }
    "Scheme"
}

pub fn disambiguate_il(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b".class")
            || trimmed.starts_with(b".assembly")
            || trimmed.starts_with(b".method")
            || trimmed.starts_with(b".module")
        {
            return ".NET IL";
        }
        if trimmed.starts_with(b";") {
            return "SKILL";
        }
    }
    ".NET IL"
}

pub fn disambiguate_cj(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"func ")
            || trimmed.starts_with(b"import ")
            || trimmed.starts_with(b"main()")
        {
            return "Cangjie";
        }
        if trimmed.starts_with(b";") || trimmed.starts_with(b"(") {
            return "Clojure";
        }
    }
    "Clojure"
}

pub fn disambiguate_inf(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"[Version]")
            || trimmed.starts_with(b"[Strings]")
            || trimmed.starts_with(b";")
        {
            return "Windows INF";
        }
        if trimmed.starts_with(b"DCL ")
            || trimmed.starts_with(b"STATE ")
            || trimmed.starts_with(b"ENDSTATE")
        {
            return "TNSDL";
        }
    }
    "Windows INF"
}

pub fn disambiguate_ui(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        if line.windows(20).any(|w| w == b"generated with glade") {
            return "Glade";
        }
    }
    "XML (Qt/GTK)"
}

pub fn disambiguate_build_xml(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        let trimmed = trim_ascii(line);
        if trimmed.starts_with(b"<project")
            || line.windows(15).any(|w| w == b"xmlns:artifact=")
        {
            return "Ant";
        }
    }
    "XML"
}

pub fn disambiguate_pom_xml(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        if line.windows(29).any(|w| w == b"xmlns=\"http://maven.apache.or") {
            return "Maven";
        }
    }
    "XML"
}

pub fn disambiguate_tpl(data: &[u8]) -> &'static str {
    for line in lines_iter(data) {
        if line.contains(&b'{') && (line.windows(2).any(|w| w == b"{$")
            || line.windows(8).any(|w| w == b"{include")
            || line.windows(8).any(|w| w == b"{foreach")
            || line.windows(3).any(|w| w == b"{if"))
        {
            return "Smarty";
        }
    }
    "(unknown)"
}

pub fn match_shebang(data: &[u8]) -> Option<(&'static str, CommentSyntax)> {
    if !data.starts_with(b"#!") {
        return None;
    }
    let first_line = lines_iter(data).next()?;
    let s = std::str::from_utf8(&first_line[2..]).ok()?;
    let parts: Vec<&str> = s.split_whitespace().collect();
    if parts.is_empty() {
        return None;
    }

    let mut interp = Path::new(parts[0])
        .file_name()
        .and_then(|f| f.to_str())
        .unwrap_or(parts[0]);

    if interp == "env" {
        let mut idx = 1;
        while idx < parts.len() && parts[idx].starts_with('-') {
            idx += 1;
        }
        if idx < parts.len() {
            interp = Path::new(parts[idx])
                .file_name()
                .and_then(|f| f.to_str())
                .unwrap_or(parts[idx]);
        }
    }

    let base_interp = if let Some(stripped) = interp.strip_prefix("python") {
        if stripped.chars().all(|c| c.is_ascii_digit() || c == '.') {
            "python"
        } else {
            interp
        }
    } else if let Some(stripped) = interp.strip_prefix("perl") {
        if stripped.chars().all(|c| c.is_ascii_digit() || c == '.') {
            "perl"
        } else {
            interp
        }
    } else if let Some(stripped) = interp.strip_prefix("php") {
        if stripped.chars().all(|c| c.is_ascii_digit() || c == '.') {
            "php"
        } else {
            interp
        }
    } else {
        interp
    };

    match base_interp {
        "python" | "pypy" => Some(("Python", CommentSyntax::Python)),
        "bash" => Some(("Bourne Again Shell", CommentSyntax::Hash)),
        "sh" => Some(("Bourne Shell", CommentSyntax::Hash)),
        "zsh" => Some(("zsh", CommentSyntax::Hash)),
        "csh" | "tcsh" => Some(("C Shell", CommentSyntax::Hash)),
        "ksh" => Some(("Korn Shell", CommentSyntax::Hash)),
        "fish" => Some(("Fish Shell", CommentSyntax::Hash)),
        "perl" | "miniperl" => Some(("Perl", CommentSyntax::Perl)),
        "perl6" | "raku" | "rakudo" => Some(("Raku", CommentSyntax::Hash)),
        "ruby" => Some(("Ruby", CommentSyntax::Ruby)),
        "node" | "nodejs" | "bun" => Some(("JavaScript", CommentSyntax::Slash)),
        "deno" | "ts-node" => Some(("TypeScript", CommentSyntax::Slash)),
        "php" => Some(("PHP", CommentSyntax::Slash)),
        "lua" | "luajit" => Some(("Lua", CommentSyntax::Lua)),
        "luau" => Some(("Luau", CommentSyntax::Lua)),
        "crystal" => Some(("Crystal", CommentSyntax::Ruby)),
        "groovy" => Some(("Groovy", CommentSyntax::Slash)),
        "tcl" | "tclsh" | "wish" => Some(("Tcl/Tk", CommentSyntax::Hash)),
        "awk" | "gawk" | "mawk" | "nawk" => Some(("awk", CommentSyntax::Hash)),
        "sed" => Some(("sed", CommentSyntax::Hash)),
        "make" | "gmake" => Some(("make", CommentSyntax::Hash)),
        "Rscript" => Some(("R", CommentSyntax::Hash)),
        "julia" => Some(("Julia", CommentSyntax::Hash)),
        "elixir" => Some(("Elixir", CommentSyntax::Hash)),
        "erl" | "escript" => Some(("Erlang", CommentSyntax::Percent)),
        "swipl" => Some(("Prolog", CommentSyntax::Percent)),
        "dmd" => Some(("D", CommentSyntax::Slash)),
        "dtrace" => Some(("dtrace", CommentSyntax::Slash)),
        "rexx" | "regina" => Some(("Rexx", CommentSyntax::Slash)),
        "octave" => Some(("Octave", CommentSyntax::Matlab)),
        "nextflow" => Some(("Nextflow", CommentSyntax::Slash)),
        "bc" => Some(("bc", CommentSyntax::Hash)),
        "kermit" => Some(("Kermit", CommentSyntax::Hash)),
        "nu" => Some(("Nu", CommentSyntax::Hash)),
        "wren" => Some(("Wren", CommentSyntax::Slash)),
        "scala" => Some(("Scala", CommentSyntax::Slash)),
        "swift" => Some(("Swift", CommentSyntax::Slash)),
        "dart" => Some(("Dart", CommentSyntax::Slash)),
        _ => None,
    }
}

pub fn classify(path: &Path, data: &[u8]) -> (&'static str, CommentSyntax) {
    let filename = match path.file_name().and_then(|f| f.to_str()) {
        Some(f) => f,
        None => return ("(unknown)", CommentSyntax::None),
    };

    if filename == "-" || filename.is_empty() {
        if let Some((lang, syntax)) = match_shebang(data) {
            return (lang, syntax);
        }
        return ("(unknown)", CommentSyntax::None);
    }

    if is_not_code_filename(filename) {
        return ("(unknown)", CommentSyntax::None);
    }

    if let Some((lang, syntax)) = match_exact_filename(filename, data) {
        return (lang, syntax);
    }

    let lower_name = filename.to_ascii_lowercase();

    let dot_indices: Vec<usize> = lower_name.match_indices('.').map(|(i, _)| i).collect();

    let mut candidate_exts: Vec<&str> = Vec::with_capacity(3);
    if dot_indices.len() >= 3 {
        let i = dot_indices[dot_indices.len() - 3];
        candidate_exts.push(&lower_name[i + 1..]);
    }
    if dot_indices.len() >= 2 {
        let i = dot_indices[dot_indices.len() - 2];
        candidate_exts.push(&lower_name[i + 1..]);
    }
    if let Some(&i) = dot_indices.last() {
        candidate_exts.push(&lower_name[i + 1..]);
    }

    for ext in candidate_exts {
        if is_not_code_extension(ext) {
            return ("(unknown)", CommentSyntax::None);
        }

        if ext.contains('.') {
            if let Ok(idx) = COMPOUND_EXTENSIONS.binary_search_by_key(&ext, |&(k, _)| k) {
                let mapped = COMPOUND_EXTENSIONS[idx].1;
                let lang = resolve_disambiguation(mapped, ext, data);
                if lang == "(unknown)" {
                    return ("(unknown)", CommentSyntax::None);
                }
                return (lang, language_comment_syntax(lang));
            }
        } else {
            if let Ok(idx) = SIMPLE_EXTENSIONS.binary_search_by_key(&ext, |&(k, _)| k) {
                let mapped = SIMPLE_EXTENSIONS[idx].1;
                let lang = resolve_disambiguation(mapped, ext, data);
                if lang == "(unknown)" {
                    return ("(unknown)", CommentSyntax::None);
                }
                return (lang, language_comment_syntax(lang));
            }
        }
    }

    if let Some((lang, syntax)) = match_shebang(data) {
        return (lang, syntax);
    }

    ("(unknown)", CommentSyntax::None)
}

#[inline]
fn resolve_disambiguation(mapped: &'static str, ext: &str, data: &[u8]) -> &'static str {
    match mapped {
        "MATLAB/Mathematica/Objective-C/MUMPS/Mercury" => disambiguate_m(data),
        "C/C++ Header" => {
            if ext == "h" {
                disambiguate_h(data)
            } else {
                "C/C++ Header"
            }
        }
        "Perl/Prolog" => disambiguate_pl(data),
        "Raku/Prolog" => disambiguate_p6(data),
        "Fortran 77/Forth" => disambiguate_f(data),
        "F#/Forth" => disambiguate_fs(data),
        "Lisp/OpenCL" => disambiguate_cl(data),
        "Lisp/Julia" => disambiguate_jl(data),
        "Verilog-SystemVerilog/Coq" => disambiguate_v(data),
        "TypeScript/Qt Linguist" => disambiguate_ts(data),
        "C#/Smalltalk" => disambiguate_cs(data),
        "Visual Basic/TeX/Apex Class" => disambiguate_cls(data),
        "Pascal/Puppet" => disambiguate_pp(data),
        "PHP/Pascal/Fortran/Pawn/BitBake/Assembly" => disambiguate_inc(data),
        "Perl/AL" => disambiguate_al(data),
        "IDL/Qt Project/Prolog/ProGuard" => disambiguate_pro(data),
        "D/dtrace" => disambiguate_d(data),
        "Pascal/Pawn" => disambiguate_p(data),
        "Scheme/SaltStack" => disambiguate_sls(data),
        "SKILL/.NET IL" => disambiguate_il(data),
        "Clojure/Cangjie" => disambiguate_cj(data),
        "Windows INF/TNSDL" => disambiguate_inf(data),
        "XML-Qt-GTK/Glade" => disambiguate_ui(data),
        "Smarty" => {
            if ext == "tpl" {
                disambiguate_tpl(data)
            } else {
                "Smarty"
            }
        }
        other => other,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::Path;

    #[test]
    fn test_exact_filenames() {
        assert_eq!(classify(Path::new("Makefile"), b"all:").0, "make");
        assert_eq!(classify(Path::new("makefile"), b"all:").0, "make");
        assert_eq!(classify(Path::new("Dockerfile"), b"FROM rust").0, "Dockerfile");
        assert_eq!(classify(Path::new("Dockerfile.build"), b"FROM rust").0, "Dockerfile");
        assert_eq!(classify(Path::new("app.dockerfile"), b"FROM rust").0, "Dockerfile");
        assert_eq!(classify(Path::new("Containerfile"), b"FROM rust").0, "Containerfile");
        assert_eq!(classify(Path::new("CMakeLists.txt"), b"project(foo)").0, "CMake");
        assert_eq!(classify(Path::new("Cargo.toml"), b"[package]").0, "TOML");
        assert_eq!(classify(Path::new("meson.build"), b"project()").0, "Meson");
        assert_eq!(classify(Path::new("Rakefile"), b"task :default").0, "Ruby");
        assert_eq!(classify(Path::new("Gemfile"), b"source 'rubygems'").0, "Ruby");
        assert_eq!(classify(Path::new("Jenkinsfile"), b"pipeline {}").0, "Groovy");
        assert_eq!(classify(Path::new("BUILD"), b"rust_binary()").0, "Bazel");
        assert_eq!(classify(Path::new("Justfile"), b"build:").0, "Justfile");
    }

    #[test]
    fn test_compound_extensions() {
        assert_eq!(classify(Path::new("page.blade.php"), b"<div>").0, "Blade");
        assert_eq!(classify(Path::new("build.gradle.kts"), b"plugins {}").0, "Gradle");
        assert_eq!(classify(Path::new("config.cmake.in"), b"@VAR@").0, "CMake");
    }

    #[test]
    fn test_standard_extensions() {
        let (l, s) = classify(Path::new("main.rs"), b"fn main() {}");
        assert_eq!(l, "Rust");
        assert_eq!(s, CommentSyntax::Slash);

        let (l, s) = classify(Path::new("test.py"), b"def foo(): pass");
        assert_eq!(l, "Python");
        assert_eq!(s, CommentSyntax::Python);

        let (l, s) = classify(Path::new("script.sh"), b"echo hi");
        assert_eq!(l, "Bourne Shell");
        assert_eq!(s, CommentSyntax::Hash);

        let (l, s) = classify(Path::new("Main.java"), b"class Main {}");
        assert_eq!(l, "Java");
        assert_eq!(s, CommentSyntax::Slash);

        let (l, s) = classify(Path::new("index.ts"), b"let x: number = 1;");
        assert_eq!(l, "TypeScript");
        assert_eq!(s, CommentSyntax::Slash);

        let (l, s) = classify(Path::new("data.json"), b"{}");
        assert_eq!(l, "JSON");
        assert_eq!(s, CommentSyntax::None);
    }

    #[test]
    fn test_shebang_matching() {
        let (l, s) = classify(Path::new("unknown_script"), b"#!/usr/bin/env python3\nprint(1)");
        assert_eq!(l, "Python");
        assert_eq!(s, CommentSyntax::Python);

        let (l, s) = classify(Path::new("my_bash_tool"), b"#!/bin/bash\necho ok");
        assert_eq!(l, "Bourne Again Shell");
        assert_eq!(s, CommentSyntax::Hash);

        let (l, s) = classify(Path::new("node_runner"), b"#!/usr/bin/env node\nconsole.log(1);");
        assert_eq!(l, "JavaScript");
        assert_eq!(s, CommentSyntax::Slash);
    }

    #[test]
    fn test_disambiguation_m() {
        let matlab_code = b"function y = foo(x)\n  y = [1 2 3];\nend";
        assert_eq!(classify(Path::new("math.m"), matlab_code).0, "MATLAB");

        let objc_code = b"#import <Foundation/Foundation.h>\n@interface MyClass : NSObject\n@end";
        assert_eq!(classify(Path::new("view.m"), objc_code).0, "Objective-C");

        let mercury_code = b":- module my_mod.\n:- interface.\n";
        assert_eq!(classify(Path::new("test.m"), mercury_code).0, "Mercury");
    }

    #[test]
    fn test_disambiguation_h() {
        let c_header = b"#ifndef FOO_H\n#define FOO_H\nint foo(void);\n#endif";
        assert_eq!(classify(Path::new("foo.h"), c_header).0, "C/C++ Header");

        let objc_header = b"#import <Foundation/Foundation.h>\n@protocol MyProtocol\n@end";
        assert_eq!(classify(Path::new("foo.h"), objc_header).0, "Objective-C");
    }

    #[test]
    fn test_disambiguation_pl() {
        let perl_code = b"#!/usr/bin/perl\nuse strict;\nmy $x = 1;\n";
        assert_eq!(classify(Path::new("script.pl"), perl_code).0, "Perl");

        let prolog_code = b"likes(mary, food).\nlikes(john, wine).\n:- likes(X, wine).\n";
        assert_eq!(classify(Path::new("logic.pl"), prolog_code).0, "Prolog");
    }

    #[test]
    fn test_disambiguation_f() {
        let fortran_code = b"c Comment\n      program test\n      print *, 'hello'\n      end";
        assert_eq!(classify(Path::new("main.f"), fortran_code).0, "Fortran 77");

        let forth_code = b": square dup * ;\n: main 5 square . ;\n";
        assert_eq!(classify(Path::new("forth.f"), forth_code).0, "Forth");
    }

    #[test]
    fn test_disambiguation_ts() {
        let ts_code = b"export const x: number = 42;\nconsole.log(x);";
        assert_eq!(classify(Path::new("app.ts"), ts_code).0, "TypeScript");

        let qtl_code = b"<?xml version=\"1.0\"?>\n<TS><context><message><source>hi</source></message></context></TS>";
        assert_eq!(classify(Path::new("app.ts"), qtl_code).0, "Qt Linguist");
    }

    #[test]
    fn test_comment_syntax_config() {
        let slash = CommentSyntax::Slash;
        assert_eq!(slash.line_comments(), &["//"]);
        assert_eq!(slash.block_comments(), &[("/*", "*/")]);

        let hash = CommentSyntax::Hash;
        assert_eq!(hash.line_comments(), &["#"]);
        assert_eq!(hash.block_comments(), &[]);

        let py = CommentSyntax::Python;
        assert_eq!(py.line_comments(), &["#"]);
        assert_eq!(py.docstrings(), &[("\"\"\"", "\"\"\""), ("'''", "'''")]);

        let ft = CommentSyntax::Fortran;
        assert_eq!(ft.column_one_comments(), b"cCdD*!");
    }
}
