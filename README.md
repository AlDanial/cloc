<a name="___top"></a>
# cloc
*Count Lines of Code*

* * *
cloc counts blank lines, comment lines, and physical lines of source code in many programming languages.

Hosted at http://cloc.sourceforge.net/ since August 2006, cloc began the
transition to GitHub in September 2015.

*   [Overview](#Overview)
*   [Download](https://github.com/AlDanial/cloc/releases/latest)
    *   [npm, apt-get, yum, pacman, pkg, port](#apt-get)
    *   [Stable release](#Stable)
    *   [Development version](#Dev)
*   [License](#License)
*   [Why Use cloc?](#why_use)
*   [Other Counters](#Other_Counters)
*   [Basic Use](#Basic_Use)
*   [Building a Windows Executable](#building_exe)
*   [Options](#Options)
*   [Recognized Languages](#Languages)
*   [How it Works](#How_it_works)
*   [Advanced Use](#Advanced_Use)
    *   [Remove Comments from Source Code](#strip_comments)
    *   [Work with Compressed Archives](#compressed_arch)
    *   [Differences](#diff)
    *   [Create Custom Language Definitions](#custom_lang)
    *   [Combine Reports](#combine_reports)
    *   [SQL](#sql)
    *   [Third Generation Language Scale Factors](#scale_factors)
*   [Limitations](#Limitations)
*   [How to Request Support for Additional Languages](#AdditionalLanguages)
*   [Author](#Author)
*   [Acknowledgments](#Acknowledgments)
*   [Copyright](#Copyright)

<a name="Overview"></a>      []({{{1)
# [Overview![^](up.gif)](#___top "click to go to top of document")

[Translations of this page: 
[Bulgarian](http://www.ajoft.com/wpaper/aj-cloc.html), 
[]( [Polish](http://www.trevister.com/blog/cloc.html), ) 
[Russian](http://carrrsmag.com/blog/cloc.html), 
[Serbo-Croatian](http://science.webhostinggeeks.com/cloc), 
[Slovakian](http://newknowledgez.com/cloc.html),
[Ukrainian](http://blog.kudoybook.com/cloc/) ]

cloc counts blank lines, comment lines, and physical lines of source
code in [many programming languages](#Languages). Given two versions of
a code base, cloc can compute differences in blank, comment, and source
lines. It is written entirely in Perl with no dependencies outside the
standard distribution of Perl v5.6 and higher (code from some external
modules is [embedded within
cloc](https://github.com/AlDanial/cloc#regexp_common)) and so is
quite portable. cloc is known to run on many flavors of Linux, FreeBSD,
NetBSD, OpenBSD, Mac OS X, AIX, HP-UX, Solaris, IRIX, z/OS, and Windows.
(To run the Perl source version of cloc on Windows one needs
[ActiveState Perl](http://www.activestate.com/activeperl) 5.6.1 or
higher, [Strawberry Perl](http://strawberryperl.com/),
[Cygwin](http://www.cygwin.com/), or
[MobaXTerm](http://mobaxterm.mobatek.net/) with the Perl plug-in
installed. Alternatively one can use the Windows binary of cloc
generated with [PAR::Packer](http://search.cpan.org/~rschupp/PAR-Packer-
1.019/lib/pp.pm) to run on Windows computers that have neither Perl nor Cygwin.)

cloc contains code from David Wheeler's 
[SLOCCount](http://www.dwheeler.com/sloccount/), 
Damian Conway and Abigail's Perl module 
[Regexp::Common](http://search.cpan.org/%7Eabigail/Regexp-Common-2.120/lib/Regexp/Common.pm), 
Sean M. Burke's Perl module 
[Win32::Autoglob](http://search.cpan.org/%7Esburke/Win32-Autoglob-1.01/Autoglob.pm), 
and Tye McQueen's Perl module 
[Algorithm::Diff](http://search.cpan.org/%7Etyemq/Algorithm-Diff-1.1902/lib/Algorithm/Diff.pm).  
Language scale factors were derived from Mayes Consulting, LLC web site 
http://softwareestimator.com/IndustryData2.htm.
[](1}}})
<a name="apt-get"></a> []({{{1)
## Install via package manager
Depending your operating system, one of these installation methods may work for you:
 
    npm install -g cloc                    # https://www.npmjs.com/package/cloc
    sudo apt-get install cloc              # Debian, Ubuntu
    sudo yum install cloc                  # Red Hat, Fedora
    sudo pacman -S cloc                    # Arch
    sudo pkg install cloc                  # FreeBSD
    sudo port install cloc                 # Mac OS X with MacPorts
[](1}}})
<a name="Stable"></a> []({{{1)
## Stable release
https://github.com/AlDanial/cloc/releases/latest

<a name="Dev"></a>
## Development version
https://github.com/AlDanial/cloc/raw/master/cloc
[](1}}})
<a name="License"></a> []({{{1)
# [License![^](up.gif)](#___top "click to go to top of document")

cloc is licensed under the [GNU General Public License, v 2]
(http://www.gnu.org/licenses/gpl-2.0.html), excluding portions which 
are copied from other sources. Code
copied from the Regexp::Common, Win32::Autoglob, and Algorithm::Diff
Perl modules is subject to the 
[Artistic L icense](http://www.opensource.org/licenses/artistic-license-2.0.php).
[](1}}})
<a name="why_use"></a> []({{{1)
# [Why Use cloc?![^](up.gif)](#___top "click to go to top of document")

cloc has many features that make it easy to use, thorough, extensible, and portable:

1.  Exists as a single, self-contained file that requires minimal installation effort---just download the file and run it.
2.  Can read language comment definitions from a file and thus potentially work with computer languages that do not yet exist.
3.  Allows results from multiple runs to be summed together by language and by project.
4.  Can produce results in a variety of formats: plain text, SQL, XML, YAML, comma separated values.
5.  Can count code within compressed archives (tar balls, Zip files, Java .ear files).
6.  Has numerous troubleshooting options.
7.  Handles file and directory names with spaces and other unusual characters.
8.  Has no dependencies outside the standard Perl distribution.
9.  Runs on Linux, FreeBSD, NetBSD, OpenBSD, Mac OS X, AIX, HP-UX, Solaris, IRIX, and z/OS systems that have Perl 5.6 or higher. The source version runs on Windows with either ActiveState Perl, Strawberry Perl, Cygwin, or MobaXTerm+Perl plugin. Alternatively on Windows one can run the Windows binary which has no dependencies.
[](1}}})
<a name="Other_Counters"></a> []({{{1)
# [Other Counters![^](up.gif)](#___top "click to go to top of document")

If cloc does not suit your needs here are other freely available counters to consider:

*   [Sonar](http://www.sonarsource.org/)
*   [Ohcount](http://labs.ohloh.net/ohcount)
*   [SLOCCount](http://www.dwheeler.com/sloccount/)
*   [sclc](http://www.cmcrossroads.com/bradapp/clearperl/sclc.html)
*   USC's [CODECOUNT](http://sunset.usc.edu/research/CODECOUNT/)
*   [loc](http://freshmeat.net/projects/loc/)

Other references:

*   QSM's [directory](http://www.qsm.com/CodeCounters.html) of code counting tools.
*   The [Wikipe dia entry](http://en.wikipedia.org/wiki/Source_lines_of_code) for source code line counts.
[](1}}})
# <a name="regexp_common">Regexp::Common, Digest::MD5, Win32::Autoglob, Algori thm::Diff</a> []({{{1)

Although cloc does not need Perl modules outside those found in the
standard distribution, cloc does rely on a few external modules. Code
from three of these external modules--Regexp::Common, Win32::Autoglob,
and Algorithm::Diff--is embedded within cloc. A fourth module,
Digest::MD5, is used only if it is available. If cloc finds
Regexp::Common or Algorithm::Diff installed locally it will use those
installation. If it doesn't, cloc will install the parts of
Regexp::Common and/or Algorithm:Diff it needs to temporary directories
that are created at the start of a cloc run then removed when the run is
complete. The necessary code from Regexp::Common v2.120 and
Algorithm::Diff v1.1902 are embedded within the cloc source code (see
subroutines `Install_Regexp_Common()` and `Install_Algorithm_Diff()` ).
Only three lines are needed from Win32::Autoglob and these are included
directly in cloc.

Additionally, cloc will use Digest::MD5 to validate uniqueness among
input files if Digest::MD5 is installed locally. If Digest::MD5 is not
found the file uniqueness check is skipped.

The Windows binary is built on a computer that has both Regexp::Common
and Digest::MD5 installed locally.
[](1}}})
<a name="building_exe"></a> []({{{1)
# [Building a Windows Executable![^](up.gif)](#___top "click to go to top of document")

The default Windows download, <tt>cloc-1.64.exe</tt>, was built with [PAR::Packer](http://search.cpan.org/~rschupp/PAR-Packer-1.019/lib/pp.pm) 
on a Windows 7 computer with 
[Strawberry Perl](http://strawberryperl.com/). 
Windows executables of cloc versions
1.60 and earlier were built with
[perl2exe](http://www.indigostar.com/perl2exe.htm) on a 32 bit Windows
XP computer. A small modification was made to the cloc source code
before passing it to perl2exe; lines 87 and 88 were uncommented:

<pre>
<font color="gray">85</font>  # Uncomment next two lines when building Windows executable with perl2exe
<font color="gray">86</font>  # or if running on a system that already has Regexp::Common. 
<font color="gray">87</font>  <font color="red">#use Regexp::Common;</font>
<font color="gray">88</font>  <font color="red">#$HAVE_Rexexp_Common = 1;</font>
</pre>

#### Why is the Windows executable so large?

Windows executables of cloc versions 1.60 and earlier, created with
perl2exe as noted above, are about 1.6 MB, while newer versions, created
with <tt>PAR::Packer</tt>, are 11 MB. Why are the newer executables so
much larger? My theory is that perl2exe uses smarter tree pruning logic
than <tt>PAR::Packer</tt>, but that's pure speculation.

#### Create your own executable
If you have access to perl2exe, you can use it to create a tight Windows
executable. See lines 84-87 in the cloc source code for a minor code
modification that is necessary when using perl2exe.

Otherwise, to build a Windows executable with <tt>pp</tt> from
<tt>PAR::Packer</tt>, first install a Windows-based Perl distribution
(for example Strawberry Perl or ActivePerl) following their
instructions. Next, open a command prompt, aka a DOS window and install
the PAR::Packer module. Finally, invoke the newly installed <tt>pp</tt>
command with the cloc source code to create an <tt>.exe</tt> file:

<pre>C:> perl -MCPAN -e shell
cpan> install PAR::Packer
cpan> exit
C:> pp cloc-1.64.pl
</pre>

A variation on the above is if you installed the portable version of Strawberry Perl, you will need to run <tt>portableshell.bat</tt> first to properly set up your environment. The Strawberry Perl derived executable on the GitHub download area was created with the portable version on a Windows 7 computer.
[](1}}})
<a name="Basic_Use"></a> []({{{1)
# [Basic Use![^](up.gif)](#___top "click to go to top of document")

cloc is a command line program that takes file, directory, and/or
archive names as inputs. Here's an example of running cloc against the
Perl v5.22.0 source distribution:

<pre>  
prompt> cloc perl-5.22.0.tar.gz
    5605 text files.
    5386 unique files.                                          
    2176 files ignored.

https://github.com/AlDanial/cloc v 1.65  T=25.49 s (134.7 files/s, 51980.3 lines/s)
-----------------------------------------------------------------------------------
Language                         files          blank        comment           code
-----------------------------------------------------------------------------------
Perl                              2892         136396         184362         536445
C                                  130          24676          33684         155648
C/C++ Header                       148           9766          16569         147858
Bourne Shell                       112           4044           6796          42668
Pascal                               8            458           1603           8592
XML                                 33            142              0           2410
YAML                                49             20             15           2078
C++                                 10            313            277           2033
make                                 4            426            488           1986
Prolog                              12            438              2           1146
JSON                                14              1              0           1037
yacc                                 1             85             76            998
Windows Message File                 1            102             11            489
DOS Batch                           14             92             41            389
Windows Resource File                3             10              0             85
D                                    1              5              7              8
Lisp                                 2              0              3              4
-----------------------------------------------------------------------------------
SUM:                              3434         176974         243934         903874
-----------------------------------------------------------------------------------

</pre>

To run cloc on Windows computers, one must first open up a command (aka DOS) window and invoke cloc.exe from the command line there.
[](1}}})
<a name="Options"></a> []({{{1)
# [Options![^](up.gif)](#___top "click to go to top of document")

<pre>  
prompt> cloc

Usage: cloc [options] <file(s)/dir(s)> | <set 1> <set 2> | <report files>

 Count, or compute differences of, physical lines of source code in the
 given files (may be archives such as compressed tarballs or zip files)
 and/or recursively below the given directories.

 Input Options
   --extract-with=CMD        This option is only needed if cloc is unable
                             to figure out how to extract the contents of
                             the input file(s) by itself.
                             Use CMD to extract binary archive files (e.g.:
                             .tar.gz, .zip, .Z).  Use the literal '&gt;FILE&lt' as
                             a stand-in for the actual file(s) to be
                             extracted.  For example, to count lines of code
                             in the input files
                                gcc-4.2.tar.gz  perl-5.8.8.tar.gz
                             on Unix use
                               --extract-with='gzip -dc &gt;FILE&lt | tar xf -'
                             or, if you have GNU tar,
                               --extract-with='tar zxf &gt;FILE&lt'
                             and on Windows use, for example:
                               --extract-with="\"c:\Program Files\WinZip\WinZip32.exe\" -e -o >FILE<
; ."
                             (if WinZip is installed there).
   --list-file=FILE          Take the list of file and/or directory names to
                             process from FILE, which has one file/directory
                             name per line.  Only exact matches are counted;
                             relative path names will be resolved starting from 
                             the directory where cloc is invoked.  
                             See also --exclude-list-file.
   --unicode                 Check binary files to see if they contain Unicode
                             expanded ASCII text.  This causes performance to
                             drop noticably.

 Processing Options
   --autoconf                Count .in files (as processed by GNU autoconf) of
                             recognized languages.
   --by-file                 Report results for every source file encountered.
   --by-file-by-lang         Report results for every source file encountered
                             in addition to reporting by language.
   --count-and-diff SET1 SET2    
                             First perform direct code counts of source file(s)
                             of SET1 and SET2 separately, then perform a diff 
                             of these.  Inputs may be pairs of files, directories, 
                             or archives.  See also --diff, --diff-alignment,
                             --diff-timeout, --ignore-case, --ignore-whitespace.
   --diff SET1 SET2          Compute differences in code and comments between
                             source file(s) in SET1 and SET2.  The inputs
                             may be pairs of files, directories, or archives.
                             Use --diff-alignment to generate a list showing
                             which file pairs where compared.  See also
                             --count-and-diff, --diff-alignment, --diff-timeout, 
                             --ignore-case, --ignore-whitespace.
   --diff-timeout N          Ignore files which take more than N seconds
                             to process.  Default is 10 seconds.
                             (Large files with many repeated lines can cause 
                             Algorithm::Diff::sdiff() to take hours.)
   --follow-links            [Unix only] Follow symbolic links to directories
                             (sym links to files are always followed).
   --force-lang=LANG[,EXT]
                             Process all files that have a EXT extension
                             with the counter for language LANG.  For
                             example, to count all .f files with the
                             Fortran 90 counter (which expects files to
                             end with .f90) instead of the default Fortran 77
                             counter, use
                               --force-lang="Fortran 90",f
                             If <ext> is omitted, every file will be counted
                             with the <lang> counter.  This option can be
                             specified multiple times (but that is only
                             useful when <ext> is given each time).
                             See also --script-lang, --lang-no-ext.
   --force-lang-def=FILE     Load language processing filters from FILE,
                             then use these filters instead of the built-in
                             filters.  Note:  languages which map to the same 
                             file extension (for example:
                             MATLAB/Objective C/MUMPS/Mercury;  Pascal/PHP; 
                             Lisp/OpenCL; Lisp/Julia; Perl/Prolog) will be 
                             ignored as these require additional processing 
                             that is not expressed in language definition 
                             files.  Use --read-lang-def to define new 
                             language filters without replacing built-in 
                             filters (see also --write-lang-def).
   --ignore-whitespace       Ignore horizontal white space when comparing files
                             with --diff.  See also --ignore-case.
   --ignore-case             Ignore changes in case; consider upper- and lower-
                             case letters equivalent when comparing files with
                             --diff.  See also --ignore-whitespace.
   --lang-no-ext=LANG        Count files without extensions using the LANG
                             counter.  This option overrides internal logic
                             for files without extensions (where such files
                             are checked against known scripting languages
                             by examining the first line for #!).  See also
                             --force-lang, --script-lang.
   --max-file-size=MB        Skip files larger than MB megabytes when
                             traversing directories.  By default, MB=100.
                             cloc's memory requirement is roughly twenty times 
                             larger than the largest file so running with 
                             files larger than 100 MB on a computer with less 
                             than 2 GB of memory will cause problems.  
                             Note:  this check does not apply to files 
                             explicitly passed as command line arguments.
   --read-binary-files       Process binary files in addition to text files.
                             This is usually a bad idea and should only be
                             attempted with text files that have embedded
                             binary data.
   --read-lang-def=FILE      Load new language processing filters from FILE
                             and merge them with those already known to cloc.  
                             If <file> defines a language cloc already knows 
                             about, cloc's definition will take precedence.  
                             Use --force-lang-def to over-ride cloc's 
                             definitions (see also --write-lang-def ).
   --script-lang=LANG,S      Process all files that invoke S as a #!
                             scripting language with the counter for language
                             LANG.  For example, files that begin with
                                #!/usr/local/bin/perl5.8.8
                             will be counted with the Perl counter by using
                                --script-lang=Perl,perl5.8.8
                             The language name is case insensitive but the
                             name of the script language executable, S,
                             must have the right case.  This option can be
                             specified multiple times.  See also --force-lang,
                             --lang-no-ext.
   --sdir=DIR                Use DIR as the scratch directory instead of
                             letting File::Temp chose the location.  Files
                             written to this location are not removed at
                             the end of the run (as they are with File::Temp).
   --skip-uniqueness         Skip the file uniqueness check.  This will give
                             a performance boost at the expense of counting
                             files with identical contents multiple times
                             (if such duplicates exist).
   --stdin-name=FILE         Give a file name to use to determine the language
                             for standard input.
   --strip-comments=EXT      For each file processed, write to the current
                             directory a version of the file which has blank
                             lines and comments removed.  The name of each
                             stripped file is the original file name with
                             .EXT appended to it.  It is written to the
                             current directory unless --original-dir is on.
   --original-dir            [Only effective in combination with
                             --strip-comments]  Write the stripped files
                             to the same directory as the original files.
                                
   --sum-reports             Input arguments are report files previously
                             created with the --report-file option.  Makes
                             a cumulative set of results containing the
                             sum of data from the individual report files.
   --unix                    Override the operating system autodetection
                             logic and run in UNIX mode.  See also
                             --windows, --show-os.
   --windows                 Override the operating system autodetection
                             logic and run in Microsoft Windows mode.
                             See also --unix, --show-os.

 Filter Options
   --exclude-dir=D1[,D2,]  Exclude the given comma separated directories
                             D1, D2, D3, et cetera, from being scanned.  For
                             example  --exclude-dir=.cache,test  will skip
                             all files that have /.cache/ or /test/ as part
                             of their path.
                             Directories named .bzr, .cvs, .hg, .git, and
                             .svn are always excluded.
   --exclude-ext=EXT1[,EXT2[...]]
                             Do not count files having the given file name
                             extensions.
   --exclude-lang=L1[,L2,]   Exclude the given comma separated languages
                             L1, L2, L3, et cetera, from being counted.
   --exclude-list-file=FILE  Ignore files and/or directories whose names
                             appear in FILE.  FILE should have one file
                             name per line.  Only exact matches are ignored;
                             relative path names will be resolved starting from 
                             the directory where cloc is invoked.  
                             See also --list-file.
   --include-lang=L1[,L2,]   Count only the given comma separated languages
                             L1, L2, L3, et cetera.
   --match-d=REGEX           Only count files in directories matching the Perl
                             regex.  For example
                               --match-d='/(src|include)/'
                             only counts files in directories containing
                             /src/ or /include/.
   --not-match-d=REGEX       Count all files except those in directories
                             matching the Perl regex.
   --match-f=REGEX           Only count files whose basenames match the Perl
                             regex.  For example
                               --match-f='^[Ww]idget'
                             only counts files that start with Widget or widget.
   --not-match-f=REGEX       Count all files except those whose basenames
                             match the Perl regex.
   --skip-archive=REGEX      Ignore files that end with the given Perl regular
                             expression.  For example, if given
                               --skip-archive='(zip|tar(.(gz|Z|bz2|xz|7z))?)'
                             the code will skip files that end with .zip,
                             .tar, .tar.gz, .tar.Z, .tar.bz2, .tar.xz, and
                             .tar.7z.
                             
   --skip-win-hidden         On Windows, ignore hidden files.

 Debug Options
   --categorized=FILE        Save names of categorized files to FILE.
   --counted=FILE            Save names of processed source files to FILE.
   --explain=<lang>          Print the filters used to remove comments for
                             language LANG and exit.  In some cases the 
                             filters refer to Perl subroutines rather than
                             regular expressions.  An examination of the
                             source code may be needed for further explanation.
   --diff-alignment=FILE     Write to FILE a list of files and file pairs
                             showing which files were added, removed, and/or
                             compared during a run with --diff.  This switch
                             forces the --diff mode on.
   --help                    Print this usage information and exit.
   --found=FILE              Save names of every file found to FILE.
   --ignored=FILE            Save names of ignored files and the reason they
                             were ignored to FILE.
   --print-filter-stages     Print processed source code before and after 
                             each filter is applied.
   --show-ext[=EXT]          Print information about all known (or just the
                             given) file extensions and exit.
   --show-lang[=LANG]        Print information about all known (or just the
                             given) languages and exit.
   --show-os                 Print the value of the operating system mode
                             and exit.  See also --unix, --windows.
   -v[=N]                    Verbose switch (optional numeric value).
   --version                 Print the version of this program and exit.
   --write-lang-def=FILE     Writes to FILE the language processing filters
                             then exits.  Useful as a first step to creating
                             custom language definitions (see also
                             --force-lang-def, --read-lang-def).

 Output Options
   --3                       Print third-generation language output.
                             (This option can cause report summation to fail
                             if some reports were produced with this option
                             while others were produced without it.)
   --by-percent  X           Instead of comment and blank line counts, show 
                             these values as percentages based on the value 
                             of X in the denominator:
                                X = 'c'   -> # lines of code
                                X = 'cm'  -> # lines of code + comments
                                X = 'cb'  -> # lines of code + blanks
                                X = 'cmb' -> # lines of code + comments + blanks
                             For example, if using method 'c' and your code
                             has twice as many lines of comments as lines 
                             of code, the value in the comment column will 
                             be 200%.  The code column remains a line count.
   --csv                     Write the results as comma separated values.
   --csv-delimiter=C         Use the character C as the delimiter for comma
                             separated files instead of ,.  This switch forces
   --out=FILE                Synonym for --report-file=FILE.
                             --csv to be on.
   --progress-rate=N         Show progress update after every N files are
                             processed (default N=100).  Set N to 0 to
                             suppress progress output (useful when redirecting
                             output to STDOUT).
   --quiet                   Suppress all information messages except for
                             the final report.
   --report-file=FILE        Write the results to FILE instead of STDOUT.
   --sql=FILE                Write results as SQL create and insert statements
                             which can be read by a database program such as
                             SQLite.  If FILE is -, output is sent to STDOUT.
   --sql-append              Append SQL insert statements to the file specified
                             by --sql and do not generate table creation
                             statements.  Only valid with the --sql option.
   --sql-project=NAME        Use NAME as the project identifier for the
                             current run.  Only valid with the --sql option.
   --sql-style=STYLE         Write SQL statements in the given style instead
                             of the default SQLite format.  Currently, the 
                             only style option is Oracle.
   --sum-one                 For plain text reports, show the SUM: output line
                             even if only one input file is processed.
   --xml                     Write the results in XML.
   --xsl=FILE                Reference FILE as an XSL stylesheet within
                             the XML output.  If FILE is 1 (numeric one),
                             writes a default stylesheet, cloc.xsl (or
                             cloc-diff.xsl if --diff is also given).
                             This switch forces --xml on.
   --yaml                    Write the results in YAML.

</pre>
[](1}}})
<a name="Languages"></a> []({{{1)
# [Recognized Languages![^](up.gif)](#___top "click to go to top of document")

<pre>  
prompt> cloc --show-lang

ABAP                       (abap)
ActionScript               (as)
Ada                        (ada, adb, ads, pad)
ADSO/IDSM                  (adso)
AMPLE                      (ample, dofile, startup)
Ant                        (build.xml)
Apex Trigger               (trigger)
Arduino Sketch             (ino, pde)
ASP                        (asa, asp)
ASP.Net                    (asax, ascx, asmx, aspx, master, sitemap, webinfo)
Assembly                   (asm, S, s)
AutoHotkey                 (ahk)
awk                        (awk)
Bourne Again Shell         (bash)
Bourne Shell               (sh)
C                          (c, ec, pgc)
C Shell                    (csh, tcsh)
C#                         (cs)
C++                        (C, c++, cc, cpp, cxx, pcc)
C/C++ Header               (H, h, hh, hpp)
CCS                        (ccs)
Clojure                    (clj)
ClojureScript              (cljs)
CMake                      (cmake, CMakeLists.txt)
COBOL                      (CBL, cbl, cob, COB)
CoffeeScript               (coffee)
ColdFusion                 (cfm)
ColdFusion CFScript        (cfc)
CSS                        (css)
CUDA                       (cu)
Cython                     (pyx)
D/dtrace                   (d)
DAL                        (da)
Dart                       (dart)
diff                       (diff)
DITA                       (dita)
DOORS Extension Language   (dxl)
DOS Batch                  (bat, BAT, BTM, btm, CMD, cmd)
DTD                        (dtd)
ECPP                       (ecpp)
Elixir                     (ex, exs)
ERB                        (erb, ERB)
Erlang                     (erl, hrl)
Expect                     (exp)
F#                         (fs, fsi)
Focus                      (focexec)
Fortran 77                 (f, F, F77, f77, for, FOR, FTN, ftn, pfo)
Fortran 90                 (f90, F90)
Fortran 95                 (f95, F95)
Go                         (go)
Grails                     (gsp)
Groovy                     (gant, gradle, groovy)
Haml                       (haml)
Handlebars                 (handlebars, hbs)
Harbour                    (hb)
Haskell                    (hs, lhs)
HLSL                       (cg, cginc, hlsl, shader)
HTML                       (htm, html)
IDL                        (idl)
IDL/Qt Project/Prolog      (pro)
InstallShield              (ism)
Java                       (java)
Javascript                 (js)
JavaServer Faces           (jsf, xhtml)
JCL                        (jcl)
JSON                       (json)
JSP                        (jsp, jspf)
Kermit                     (ksc)
Korn Shell                 (ksh)
Kotlin                     (kt)
LESS                       (less)
lex                        (l)
Lisp                       (el, lisp, lsp, sc)
Lisp/Julia                 (jl)
Lisp/OpenCL                (cl)
LiveLink OScript           (oscript)
Lua                        (lua)
m4                         (ac, m4)
make                       (am, Gnumakefile, gnumakefile, makefile, Makefile)
MATLAB                     (m)
Maven                      (pom, pom.xml)
Modula3                    (i3, ig, m3, mg)
MSBuild script             (csproj, vbproj, vcproj, wdproj, wixproj)
MUMPS                      (mps, m)
Mustache                   (mustache)
MXML                       (mxml)
NAnt script                (build)
NASTRAN DMAP               (dmap)
Objective C                (m)
Objective C++              (mm)
OCaml                      (ml, mli, mll, mly)
Oracle Forms               (fmt)
Oracle Reports             (rex)
Pascal                     (dpr, p, pas)
Pascal/Puppet              (pp)
Patran Command Language    (pcl, ses)
Perl                       (perl, plh, plx, pm)
Perl/Prolog                (PL, pl)
PHP                        (php, php3, php4, php5)
PHP/Pascal                 (inc)
Pig Latin                  (pig)
PL/I                       (pl1)
PowerShell                 (ps1)
Prolog                     (P)
Protocol Buffers           (proto)
PureScript                 (purs)
Python                     (py)
QML                        (qml)
R                          (R)
Racket                     (rkt, rktl, sch, scm, scrbl, ss)
Razor                      (cshtml)
Rexx                       (rexx)
RobotFramework             (robot, tsv)
Ruby                       (rake, rb)
Ruby HTML                  (rhtml)
Rust                       (rs)
SAS                        (sas)
SASS                       (sass, scss)
Scala                      (scala)
sed                        (sed)
SKILL                      (il)
SKILL++                    (ils)
Smarty                     (smarty, tpl)
Softbridge Basic           (SBL, sbl)
SQL                        (psql, SQL, sql)
SQL Data                   (data.sql)
SQL Stored Procedure       (spc.sql, spoc.sql, sproc.sql, udf.sql)
Standard ML                (fun, sig, sml)
Swift                      (swift)
Tcl/Tk                     (itk, tcl, tk)
Teamcenter met             (met)
Teamcenter mth             (mth)
Titanium Style Sheet       (tss)
TypeScript                 (ts)
Unity-Prefab               (mat, prefab)
Vala                       (vala)
Vala Header                (vapi)
Velocity Template Language (vm)
Verilog-SystemVerilog      (sv, svh, v)
VHDL                       (VHD, vhd, vhdl, VHDL)
vim script                 (vim)
Visual Basic               (bas, cls, ctl, dsr, frm, VB, vb, vba, VBA, VBS, vbs)
Visual Fox Pro             (sca, SCA)
Visualforce Component      (component)
Visualforce Page           (page)
Windows Message File       (mc)
Windows Module Definition  (def)
Windows Resource File      (rc, rc2)
WiX include                (wxi)
WiX source                 (wxs)
WiX string localization    (wxl)
XAML                       (xaml)
xBase                      (prg)
xBase Header               (ch)
XML                        (XML, xml)
XQuery                     (xq, xquery)
XSD                        (XSD, xsd)
XSLT                       (xsl, XSL, xslt, XSLT)
yacc                       (y)
YAML                       (yaml, yml)
</pre>

The above list can be customized by reading language definitions from a
file with the `--read-lang-def` or `--force-lang-def` options.

Eight file extensions map to multiple languages:

*   `.cl` files could be Lisp or OpenCL
*   `.inc` files could be PHP or Pascal
*   `.jl` files could be Lisp or Julia
*   `.m` files could be MATLAB, Mercury, MUMPS, or Objective C
*   `.p` files could be D or dtrace
*   `.pl` files could be Perl or Prolog
*   `.pp` files could be Pascal or Puppet
*   `.pro` files could be IDL, Prolog, or a Qt Project

cloc has subroutines that attempt to identify the correct language based
on the file's contents for these special cases. Language identification
accuracy is a function of how much code the file contains; .m files with
just one or two lines for example, seldom have enough information to
correctly distinguish between MATLAB, Mercury, MUMPS, or Objective C.

Languages with file extension collisions are difficult to customize with
`--read-lang-def` or `--force-lang-def` as they have no mechanism to
identify languages with common extensions. In this situation one must
modify the cloc source code.
[](1}}})
<a name="How_it_works"></a> []({{{1)
# [How It Works![^](up.gif)](#___top "click to go to top of document")

cloc's method of operation resembles SLOCCount's: First, create a list
of files to consider. Next, attempt to determine whether or not found
files contain recognized computer language source code. Finally, for
files identified as source files, invoke language-specific routines to
count the number of source lines.

A more detailed description:

1.  If the input file is an archive (such as a .tar.gz or .zip file),
    create a temporary directory and expand the archive there using a
    system call to an appropriate underlying utility (tar, bzip2, unzip,
    etc) then add this temporary directory as one of the inputs. (This
    works more reliably on Unix than on Windows.)
2.  Use File::Find to recursively descend the input directories and make
    a list of candidate file names. Ignore binary and zero-sized files.
3.  Make sure the files in the candidate list have unique contents
    (first by comparing file sizes, then, for similarly sized files,
    compare MD5 hashes of the file contents with Digest::MD5). For each
    set of identical files, remove all but the first copy, as determined
    by a lexical sort, of identical files from the set. The removed
    files are not included in the report. (The `--skip-uniqueness` switch
    disables the uniqueness tests and forces all copies of files to be
    included in the report.) See also the `--ignored=` switch to see which
    files were ignored and why.
4.  Scan the candidate file list for file extensions which cloc
    associates with programming languages (see the `--show-lang` and 
    `--show-ext` options). Files which match are classified as 
    containing source
    code for that language. Each file without an extensions is opened
    and its first line read to see if it is a Unix shell script
    (anything that begins with #!). If it is shell script, the file is
    classified by that scripting language (if the language is
    recognized). If the file does not have a recognized extension or is
    not a recognzied scripting language, the file is ignored.
5.  All remaining files in the candidate list should now be source files
    for known programming languages. For each of these files:

    1.  Read the entire file into memory.
    2.  Count the number of lines (= L<sub>original</sub>).
    3.  Remove blank lines, then count again (= L<sub>non_blank</sub>).
    4.  Loop over the comment filters defined for this language. (For
        example, C++ has two filters: (1) remove lines that start with
        optional whitespace followed by // and (2) remove text between
        /* and */) Apply each filter to the code to remove comments.
        Count the left over lines (= L<sub>code</sub>).
    5.  Save the counts for this language: 
        * blank lines = L<sub>original</sub> - L<sub>non_blank</sub> 
        * comment lines = L<sub>non_blank</sub> - L<sub>code</sub> 
        * code lines = L<sub>code</sub>

The options modify the algorithm slightly. The `--read-lang-def` option
for example allows the user to read definitions of comment filters,
known file extensions, and known scripting languages from a file. The
code for this option is processed between Steps 2 and 3.
[](1}}})
<a name="Advanced_Use"></a> []({{{1)
# [Advanced Use![^](up.gif)](#___top "click to go to top of document")
[](1}}})
<a name="strip_comments"></a> []({{{1)
##  [Remove Comments from Source Code![^](up.gif)](#___top "click to go to top of document")

How can you tell if cloc correctly identifies comments? One way to
convince yourself cloc is doing the right thing is to use its 
`--strip-comments` option to remove comments and blank lines from files, then
compare the stripped-down files to originals.

Let's try this out with the SQLite amalgamation, a C file containing all
code needed to build the SQLite library along with a header file:

<pre>
prompt> tar zxf sqlite-amalgamation-3.5.6.tar.gz 
prompt> cd sqlite-3.5.6/
prompt> cloc --strip-comments=nc sqlite.c
       1 text file.
       1 unique file.                              
Wrote sqlite3.c.nc
       0 files ignored.

http://cloc.sourceforge.net v 1.03  T=1.0 s (1.0 files/s, 82895.0 lines/s)
-------------------------------------------------------------------------------
Language          files     blank   comment      code    scale   3rd gen. equiv
-------------------------------------------------------------------------------
C                     1      5167     26827     50901 x   0.77 =       39193.77
-------------------------------------------------------------------------------
</pre>

The extension argument given to --strip-comments is arbitrary; here nc was used as an abbreviation for "no comments".

cloc removed over 31,000 lines from the file:

<pre>
prompt> wc -l sqlite3.c sqlite3.c.nc 
  82895 sqlite3.c
  50901 sqlite3.c.nc
 133796 total
prompt> echo "82895 - 50901" | bc
31994
</pre>

We can now compare the original file, sqlite3.c and the one stripped of
comments, sqlite3.c.nc with tools like diff or vimdiff and see what
exactly cloc considered comments and blank lines. A rigorous proof that
the stripped-down file contains the same C code as the original is to
compile these files and compare checksums of the resulting object files.

First, the original source file:

<pre>
prompt> gcc -c sqlite3.c
prompt> md5sum sqlite3.o
cce5f1a2ea27c7e44b2e1047e2588b49  sqlite3.o
</pre>

Next, the version without comments:

<pre>
prompt> mv sqlite3.c.nc sqlite3.c
prompt> gcc -c sqlite3.c
prompt> md5sum sqlite3.o
cce5f1a2ea27c7e44b2e1047e2588b49  sqlite3.o
</pre>

cloc removed over 31,000 lines of comments and blanks but did not modify the source code in any significant way since the resulting object file matches the original. 
[](1}}})
<a name="compressed_arch"></a> []({{{1)
##  [Work with Compressed Archives![^](up.gif)](#___top "click to go to top of document")
Versions of cloc before v1.07 required an
 `--extract-with=CMD` option to tell cloc how
to expand an archive file.  Beginning with v1.07 this is extraction is
attempted automatically.  At the moment the automatic extraction method works
reasonably well on Unix-type OS's for the following file types:
`.tar.gz`,
`.tar.bz2`, 
`.tar.xz`, 
`.tgz`,
`.zip`,
`.ear`.
Some of these extensions work on Windows if one has WinZip installed
in the default location (`C:\Program Files\WinZip\WinZip32.exe`).
Additionally, with newer versions of WinZip, the
[http://www.winzip.com/downcl.htm](command line add-on)
is needed for correct operation; in this case one would invoke cloc with
something like<br>
<pre>
 --extract-with="\"c:\Program Files\WinZip\wzunzip\" -e -o &gt;FILE&lt ."
 </code>
</pre> (ref. [http://sourceforge.net/projects/cloc/forums/forum/600963/topic/4021070?message=8938196](forum post)).

In situations where the automatic extraction fails, one can try the
`--extract-with=CMD`
option to count lines of code within tar files, Zip files, or
other compressed archives for which one has an extraction tool.
cloc takes the user-provided extraction command and expands the archive
to a temporary directory (created with File::Temp),
counts the lines of code in the temporary directory,
then removes that directory.  While not especially helpful when dealing
with a single compressed archive (after all, if you're going to type
the extraction command anyway why not just manually expand the archive?)
this option is handy for working with several archives at once.

For example, say you have the following source tarballs on a Unix machine<br>

    perl-5.8.5.tar.gz
    Python-2.4.2.tar.gz

and you want to count all the code within them.  The command would be
<pre>
cloc --extract-with='gzip -dc &gt;FILE&lt; | tar xf -' perl-5.8.5.tar.gz Python-2.4.2.tar.gz
</pre>
If that Unix machine has GNU tar (which can uncompress and extract in
one step) the command can be shortened to
<pre>
cloc --extract-with='tar zxf &gt;FILE&lt;' perl-5.8.5.tar.gz Python-2.4.2.tar.gz
</pre>
On a Windows computer with WinZip installed in 
`c:\Program Files\WinZip` the command would look like
<pre>
cloc.exe --extract-with="\"c:\Program Files\WinZip\WinZip32.exe\" -e -o &gt;FILE&lt; ." perl-5.8.5.tar.gz Python-2.4.2.tar.gz
</pre>
Java `.ear` files are Zip files that contain additional Zip
files.  cloc can handle nested compressed archives without
difficulty--provided all such files are compressed and archived in the
same way.  Examples of counting a
Java `.ear` file in Unix and Windows:
<pre>
<i>Unix&gt;</i> cloc --extract-with="unzip -d . &gt;FILE&lt; " Project.ear
<i>DOS&gt;</i> cloc.exe --extract-with="\"c:\Program Files\WinZip\WinZip32.exe\" -e -o &gt;FILE&lt; ." Project.ear
</pre>

[](1}}})
<a name="diff"></a> []({{{1)
##  [Differences](#___top "click to go to top of document")
The `--diff` switch allows one to measure the relative change in
source code and comments between two versions of a file, directory,
or archive.  Differences reveal much more than absolute code
counts of two file versions.  For example, say a source file
has 100 lines and its developer delivers a newer version with
102 lines.  Did the developer add two comment lines, 
or delete seventeen source
lines and add fourteen source lines and five comment lines, or did 
the developer
do a complete rewrite, discarding all 100 original lines and
adding 102 lines of all new source?  The diff option tells how
many lines of source were added, removed, modified or stayed
the same, and how many lines of comments were added, removed,
modified or stayed the same.

In addition to file pairs, one can give cloc pairs of
directories, or pairs of file archives, or a file archive
and a directory.  cloc will try to align 
file pairs within the directories or archives and compare diffs
for each pair.  For example, to see what changed between
GCC 4.4.0 and 4.5.0 one could do
<pre>
cloc --diff gcc-4.4.0.tar.bz2  gcc-4.5.0.tar.bz2
</pre>

Be prepared to wait a while for the results though; the `--diff`
option runs much more slowly than an absolute code count.

To see how cloc aligns files between the two archives, use the
`--diff-alignment` option
<pre>
cloc --diff-aligment=align.txt gcc-4.4.0.tar.bz2  gcc-4.5.0.tar.bz2
</pre>
to produce the file `align.txt` which shows the file pairs as well
as files added and deleted.  The symbols `==` and `!=` before each
file pair indicate if the files are identical (`==`)
or if they have different content (`!=`).

Here's sample output showing the difference between the Python 2.6.6 and 2.7
releases:
<pre><i>prompt&gt;</i> cloc --diff Python-2.7.9.tgz Python-2.7.10.tar.xz
    4315 text files.
    4313 text files.s
    2173 files ignored.                                         

4 errors:
Diff error, exceeded timeout:  /tmp/8ToGAnB9Y1/Python-2.7.9/Mac/Modules/qt/_Qtmodule.c
Diff error, exceeded timeout:  /tmp/M6ldvsGaoq/Python-2.7.10/Mac/Modules/qt/_Qtmodule.c
Diff error (quoted comments?):  /tmp/8ToGAnB9Y1/Python-2.7.9/Mac/Modules/qd/qdsupport.py
Diff error (quoted comments?):  /tmp/M6ldvsGaoq/Python-2.7.10/Mac/Modules/qd/qdsupport.py

https://github.com/AlDanial/cloc v 1.65  T=298.59 s (0.0 files/s, 0.0 lines/s)
-----------------------------------------------------------------------------
Language                   files          blank        comment           code
-----------------------------------------------------------------------------
Visual Basic
 same                          2              0              1             12
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
make
 same                         11              0            340           2952
 modified                      1              0              0              1
 added                         0              0              0              0
 removed                       0              0              0              0
diff
 same                          1              0             87            105
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
CSS
 same                          0              0             19            327
 modified                      1              0              0              1
 added                         0              0              0              0
 removed                       0              0              0              0
Objective C
 same                          7              0             61            635
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
NAnt script
 same                          2              0              0             30
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
XML
 same                          3              0              2             72
 modified                      1              0              0              1
 added                         0              0              0              1
 removed                       0              1              0              0
Windows Resource File
 same                          3              0             56            206
 modified                      1              0              0              1
 added                         0              0              0              0
 removed                       0              0              0              0
Expect
 same                          6              0            161            565
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
HTML
 same                         14              0             11           2344
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
vim script
 same                          1              0              7            106
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
C++
 same                          2              0             18            128
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
Windows Module Definition
 same                          7              0            187           2080
 modified                      2              0              0              0
 added                         0              0              0              1
 removed                       0              1              0              2
Prolog
 same                          1              0              0             24
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
Javascript
 same                          3              0             49            229
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
Assembly
 same                         51              0           6794          12298
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
Bourne Shell
 same                         41              0           7698          45024
 modified                      1              0              0              3
 added                         0             13              2             64
 removed                       0              0              0              0
DOS Batch
 same                         29              0            107            494
 modified                      1              0              0              9
 added                         0              1              0              3
 removed                       0              0              0              0
MSBuild script
 same                         77              0              3          38910
 modified                      0              0              0              0
 added                         0              0              0              0
 removed                       0              0              0              0
Python
 same                       1947              0         109012         430335
 modified                    192              0             94            950
 added                         2            323            283           2532
 removed                       2             55             58            646
m4
 same                         18              0            191          15352
 modified                      1              0              0              2
 added                         1             31              0            205
 removed                       0              0              0              0
C
 same                        505              0          37439         347837
 modified                     45              0             13            218
 added                         0             90             33            795
 removed                       0              9              2            148
C/C++ Header
 same                        255              0          10361          66635
 modified                      5              0              5              7
 added                         0              1              3            300
 removed                       0              0              0              0
---------------------------------------------------------------------
SUM:
 same                       2986              0         172604         966700
 modified                    251              0            112           1193
 added                         3            459            321           3901
 removed                       2             66             60            796
---------------------------------------------------------------------
</pre>
A pair of errors occurred.
The first pair was caused by timing out when computing diffs of the file
`Python-X/Mac/Modules/qt/_Qtmodule.c` in each Python version.
This file has > 26,000 lines of C code and takes more than
10 seconds--the default maximum duration for diff'ing a 
single file--on my slow computer.  (Note:  this refers to
performing differences with
the `sdiff()` function in the Perl `Algorithm::Diff` module,
not the command line `diff` utility.)  This error can be
overcome by raising the time to, say, 20 seconds
with `--diff-timeout 20`.

The second error is more problematic.  The files
`Python-X/Mac/Modules/qd/qdsupport.py` 
include Python docstring (text between pairs of triple quotes)
containing C comments.  cloc treats docstrings as comments and handles them
by first converting them to C comments, then using the C comment removing
regular expression.  Nested C comments yield erroneous results however.

[](1}}})
<a name="custom_lang"></a> []({{{1)
##  [Create Custom Language Definitions![^](up.gif)](#___top "click to go to top of document")
cloc can write its language comment definitions to a file or can read
comment definitions from a file, overriding the built-in definitions.
This can be useful when you want to use cloc to count lines of a
language not yet included, to change association of file extensions
to languages, or to modify the way existing languages are counted.

The easiest way to create a custom language definition file is to
make cloc write its definitions to a file, then modify that file:
<pre><i>Unix&gt;</i> cloc --write-lang-def=my_definitions.txt
</pre>
creates the file `my_definitions.txt` which can be modified
then read back in with either the `--read-lang-def` or
`--force-lang-def` option.  The difference between the options is
former merges language definitions from the given file in with
cloc's internal definitions with cloc'taking precedence
if there are overlaps.  The `--force-lang-def` option, on the
other hand, replaces cloc's definitions completely.
This option has a disadvantage in preventing cloc from counting
<a class="u" href="#extcollision" name="extcollision">
languages whose extensions map to multiple languages
</a> as these languages require additional logic that is not easily
expressed in a definitions file.
<pre><i>Unix&gt;</i> cloc --read-lang-def=my_definitions.txt  <i>file1 file2 dir1 ...</i>
</pre>

Each language entry has four parts:
* The language name starting in column 1.
* One or more comment *filters* starting in column 5.
* One or more filename extensions starting in column 5.
* A 3rd generation scale factor starting in column 5.  
  This entry must be provided
  but its value is not important
  unless you want to compare your language to a hypothetical
  third generation programming language.

A filter defines a method to remove comment text from the source file.
For example the entry for C++ looks like this
<pre>C++
    filter remove_matches ^\s*//
    filter call_regexp_common C
    extension C
    extension cc
    extension cpp
    extension cxx
    extension pcc
    3rd_gen_scale 1.51
</pre>
C++ has two filters:  first, remove lines that start with optional
whitespace and are followed by `//`.
Next, remove all C comments.  C comments are difficult to express
as regular expressions so a call is made to Regexp::Common to get the
appropriate regular expression to match C comments which are then removed.

A more complete discussion of the different filter options may appear
here in the future.  The output of cloc's
`--write-lang-def` option should provide enough examples
for motivated individuals to modify or extend cloc's language definitions.

[](1}}})
<a name="combine_reports"></a> []({{{1)
##  [Combine Reports![^](up.gif)](#___top "click to go to top of document")

If you manage multiple software projects you might be interested in
seeing line counts by project, not just by language.
Say you manage three software projects called MySQL, PostgreSQL, and SQLite.
The teams responsible for each of these projects run cloc on their
source code and provide you with the output.
For example MySQL team does

<pre>cloc --report-file=mysql-5.1.42.txt mysql-5.1.42.tar.gz</pre>

and provides you with the file `mysql-5.1.42.txt`.
The contents of the three files you get are

<pre>
<i>Unix&gt;</i> cat mysql-5.1.42.txt
http://cloc.sourceforge.net v 1.50  T=26.0 s (108.1 files/s, 65774.5 lines/s)
--------------------------------------------------------------------------------
Language                      files          blank        comment           code
--------------------------------------------------------------------------------
C++                             615          93609         110909         521041
C                               642          83179          82424         393602
C/C++ Header                   1065          33980          77633         142779
Bourne Shell                    178          14892          11437          74525
Perl                             60           7634           4667          22703
m4                               13           1220            394          10497
make                            119            914           1855           4447
XML                              27            564             23           4107
SQL                              18            517            209           3433
Assembly                         12            161              0           1304
yacc                              2            167             40           1048
lex                               2            332            113            879
Teamcenter def                   43             85            219            701
Javascript                        3             70            140            427
Pascal                            2              0            436            377
HTML                              1              7              0            250
Bourne Again Shell                1              6              1             48
DOS Batch                         8             23             73             36
--------------------------------------------------------------------------------
SUM:                           2811         237360         290573        1182204
--------------------------------------------------------------------------------

<i>Unix&gt;</i> cat sqlite-3.6.22.txt
http://cloc.sourceforge.net v 1.50  T=3.0 s (4.7 files/s, 53833.7 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
C                                2           7459          37993          68944
Bourne Shell                     7           3344           4522          25849
m4                               2            754             20           6557
C/C++ Header                     2            155           4808           1077
make                             1              6              0             13
-------------------------------------------------------------------------------
SUM:                            14          11718          47343         102440
-------------------------------------------------------------------------------

<i>Unix&gt;</i> cat postgresql-8.4.2.txt
http://cloc.sourceforge.net v 1.50  T=16.0 s (129.1 files/s, 64474.9 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
C                              923         102324         167390         563865
C/C++ Header                   556           9180          22723          40990
Bourne Shell                    51           3692           3245          28486
SQL                            260           8246           5645          25862
yacc                             6           2667           2126          22825
Perl                            36            782            696           4894
lex                              8            708           1525           3638
make                           180           1215           1385           3453
m4                              12            199             25           1431
Teamcenter def                  13              4              0           1104
HTML                             2             94              1            410
DOS Batch                        7             53             22            188
XSLT                             5             41             30            111
Assembly                         3             17              0            105
D                                1             14             14             65
CSS                              1             16              7             44
sed                              1              1              7             15
Python                           1              5              1             12
-------------------------------------------------------------------------------
SUM:                          2066         129258         204842         697498
-------------------------------------------------------------------------------
</pre>

While these three files are interesting, you also want to see
the combined counts from all projects.
That can be done with cloc's `--sum_reports`
option:

<pre><i>Unix&gt;</i> cloc --sum-reports --report_file=databases mysql-5.1.42.txt  postgresql-8.4.2.txt  sqlite-3.6.22.txt
Wrote databases.lang
Wrote databases.file
</pre>

The report combination produces two output files, one for sums by
programming language (`databases.lang`) and one by project 
(`databases.file`).
Their contents are
<pre><i>Unix&gt;</i> cat databases.lang
http://cloc.sourceforge.net v 1.50
--------------------------------------------------------------------------------
Language                      files          blank        comment           code
--------------------------------------------------------------------------------
C                              1567         192962         287807        1026411
C++                             615          93609         110909         521041
C/C++ Header                   1623          43315         105164         184846
Bourne Shell                    236          21928          19204         128860
SQL                             278           8763           5854          29295
Perl                             96           8416           5363          27597
yacc                              8           2834           2166          23873
m4                               27           2173            439          18485
make                            300           2135           3240           7913
lex                              10           1040           1638           4517
XML                              27            564             23           4107
Teamcenter def                   56             89            219           1805
Assembly                         15            178              0           1409
HTML                              3            101              1            660
Javascript                        3             70            140            427
Pascal                            2              0            436            377
DOS Batch                        15             76             95            224
XSLT                              5             41             30            111
D                                 1             14             14             65
Bourne Again Shell                1              6              1             48
CSS                               1             16              7             44
sed                               1              1              7             15
Python                            1              5              1             12
--------------------------------------------------------------------------------
SUM:                           4891         378336         542758        1982142
--------------------------------------------------------------------------------

<i>Unix&gt;</i> cat databases.file
----------------------------------------------------------------------------------
Report File                     files          blank        comment           code
----------------------------------------------------------------------------------
mysql-5.1.42.txt                 2811         237360         290573        1182204
postgresql-8.4.2.txt             2066         129258         204842         697498
sqlite-3.6.22.txt                  14          11718          47343         102440
----------------------------------------------------------------------------------
SUM:                             4891         378336         542758        1982142
----------------------------------------------------------------------------------

</pre>

Report files themselves can be summed together.  Say you also manage
development of Perl and Python and you want to keep track
of those line counts separately from your database projects.  First
create reports for Perl and Python separately:

<pre>cloc --report-file=perl-5.10.0.txt perl-5.10.0.tar.gz
cloc --report-file=python-2.6.4.txt Python-2.6.4.tar.bz2
</pre>

then sum these together with

<pre>
<i>Unix&gt;</i> cloc --sum-reports --report_file=script_lang perl-5.10.0.txt python-2.6.4.txt
Wrote script_lang.lang
Wrote script_lang.file

<i>Unix&gt;</i> cat script_lang.lang
http://cloc.sourceforge.net v 1.50
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
C                              518          61871          52705         473034
Python                        1965          76022          95289         365716
Perl                          2052         110356         130018         292281
C/C++ Header                   381          13762          21402         102276
Bourne Shell                   149           9376          11665          81508
Lisp                             2           1154           2745          10448
Assembly                        38           1616           1712           9755
m4                               3            825             34           7124
make                            16            954            804           4829
HTML                            25            516             13           3010
Teamcenter def                   9            170            162           2075
XML                             28            288              0           2034
C++                             10            312            277           2000
yacc                             2            128             97           1549
DOS Batch                       42            175            152            746
Objective C                      7            102             70            635
YAML                             2              2              0            489
CSS                              1             94             19            308
vim script                       1             36              7            105
Expect                           1              0              0             60
NAnt scripts                     2              1              0             30
Visual Basic                     2              1              1             12
-------------------------------------------------------------------------------
SUM:                          5256         277761         317172        1360024
-------------------------------------------------------------------------------

<i>Unix&gt;</i> cat script_lang.file
-------------------------------------------------------------------------------
Report File                  files          blank        comment           code
-------------------------------------------------------------------------------
python-2.6.4.txt              2746         135676         143269         830347
perl-5.10.0.txt               2510         142085         173903         529677
-------------------------------------------------------------------------------
SUM:                          5256         277761         317172        1360024
-------------------------------------------------------------------------------

</pre>

Finally, combine the combination files:

<pre>
<i>Unix&gt;</i> cloc --sum-reports --report_file=everything databases.lang script_lang.lang
Wrote everything.lang
Wrote everything.file

<i>Unix&gt;</i> cat everything.lang
http://cloc.sourceforge.net v 1.50
--------------------------------------------------------------------------------
Language                      files          blank        comment           code
--------------------------------------------------------------------------------
C                              2085         254833         340512        1499445
C++                             625          93921         111186         523041
Python                         1966          76027          95290         365728
Perl                           2148         118772         135381         319878
C/C++ Header                   2004          57077         126566         287122
Bourne Shell                    385          31304          30869         210368
SQL                             278           8763           5854          29295
m4                               30           2998            473          25609
yacc                             10           2962           2263          25422
make                            316           3089           4044          12742
Assembly                         53           1794           1712          11164
Lisp                              2           1154           2745          10448
XML                              55            852             23           6141
lex                              10           1040           1638           4517
Teamcenter def                   65            259            381           3880
HTML                             28            617             14           3670
DOS Batch                        57            251            247            970
Objective C                       7            102             70            635
YAML                              2              2              0            489
Javascript                        3             70            140            427
Pascal                            2              0            436            377
CSS                               2            110             26            352
XSLT                              5             41             30            111
vim script                        1             36              7            105
D                                 1             14             14             65
Expect                            1              0              0             60
Bourne Again Shell                1              6              1             48
NAnt scripts                      2              1              0             30
sed                               1              1              7             15
Visual Basic                      2              1              1             12
--------------------------------------------------------------------------------
SUM:                          10147         656097         859930        3342166
--------------------------------------------------------------------------------

<i>Unix&gt;</i> cat everything.file
-------------------------------------------------------------------------------
Report File                  files          blank        comment           code
-------------------------------------------------------------------------------
databases.lang                4891         378336         542758        1982142
script_lang.lang              5256         277761         317172        1360024
-------------------------------------------------------------------------------
SUM:                         10147         656097         859930        3342166
-------------------------------------------------------------------------------
</pre>

[](1}}})
<a name="sql"></a> []({{{1)
##  [SQL![^](up.gif)](#___top "click to go to top of document")
[](1}}})
<a name="scale_factors"></a> []({{{1)
##  [Third Generation Language Scale Factors![^](up.gif)](#___top "click to go to top of document")
[](1}}})
<a name="Limitations"></a> []({{{1)
#   [Limitations![^](up.gif)](#___top "click to go to top of document")
[](1}}})
<a name="AdditionalLanguages"></a> []({{{1)
#   [How to Request Support for Additional Languages![^](up.gif)](#___top "click to go to top of document")
[](1}}})
<a name="Author"></a> []({{{1)
#   [Author![^](up.gif)](#___top "click to go to top of document")
[](1}}})
<a name="Acknowledgments"></a> []({{{1)
#   [Acknowledgments![^](up.gif)](#___top "click to go to top of document")
[](1}}})
<a name="Copyright"></a> []({{{1)
#   [Copyright![^](up.gif)](#___top "click to go to top of document")
[](1}}})
