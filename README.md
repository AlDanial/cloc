# cloc
cloc counts blank lines, comment lines, and physical lines of source code in many programming languages.

Originally hosted at http://cloc.sourceforge.net/, cloc began the transition to github in
September 2015.

*   [Overview](#Overview)
*   [Download]
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
    *   [Work with C ompressed Archives](#compressed_arch)
    *   [Differences](#diff)
    *   [Create Custom Language Definitions](#custom_lang)
    *   [Combine Reports](#combine_reports)
    *   [SQL](#sql)
    *   [Third Generat ion Language Scale Factors](#scale_factors)
*   [Limitations](#Limitations)
*   [How to Re quest Support for Additional Languages](#AdditionalLanguages)
*   [Author](#Author)
*   [Acknowledgments](#Acknowledgments)
*   [Copyright](#Copyright)
*   [License](#License)

</div>

</div>

[Overview![^](up.gif)](#___top "click to go to top of document")

[Translations: [Bulgarian](http://www.ajoft.com/wpaper/aj-cloc.html), [Polish](http://www.trevister.com/blog/cloc.html), [Russian](http://carrrsmag.com/blog/cloc.html), [Serbo-Croatian](http://science.webhostinggeeks.com/cloc), [Slovakian](http://jbs24.com/blog/cloc-grof-riadkov-kodu/) [Ukrainian](http://blog.kudoybook.com/cloc/) ]

cloc counts blank lines, comment lines, and physical lines of source code in [many programming languages](#Languages). Given two versions of a code base, cloc can compute differences in blank, comment, and source lines. It is written entirely in Perl with no dependencies outside the standard distribution of Perl v5.6 and higher (code from some external modules is [embedded within cloc](http://cloc.sourceforge.net/index.html#regexp_common)) and so is quite portable. cloc is known to run on many flavors of Linux, FreeBSD, NetBSD, OpenBSD, Mac OS X, AIX, HP-UX, Solaris, IRIX, z/OS, and Windows. (To run the Perl source version of cloc on Windows one needs [ActiveState Perl](http://www.activestate.com/activeperl) 5.6.1 or higher, [Strawberry Perl](http://strawberryperl.com/), [Cygwin](http://www.cygwin.com/), or [MobaXTerm](http://mobaxterm.mobatek.net/) with the Perl plug-in installed. Alternatively one can use the Windows binary of cloc generated with [PAR::Packer](http://search.cpan.org/~rschupp/PAR-Packer-1.019/lib/pp.pm) to run on Windows computers that have neither Perl nor Cygwin.)

cloc contains code from David Wheeler's [SLOCCount](http://www.dwheeler.com/sloccount/), Damian Conway and Abigail's Perl module [Regexp::Common](http://search.cpan.org/%7Eabigail/Regexp-Common-2.120/lib/Regexp/Common.pm), Sean M. Burke's Perl module [Win32::Autoglob](http://search.cpan.org/%7Esburke/Win32-Autoglob-1.01/Autoglob.pm), and Tye McQueen's Perl module [Algorithm::Diff](http://search.cpan.org/%7Etyemq/Algorithm-Diff-1.1902/lib/Algorithm/Diff.pm).  Language scale factors were derived from Mayes Consulting, LLC web site http://softwareestimator.com/IndustryData2.htm.

## Install via package manager
Depending your operating system, one of these installation methods may work for you:
 
    npm install -g cloc                    # https://www.npmjs.com/package/cloc
    sudo apt-get install cloc              # Debian, Ubuntu
    sudo yum install cloc                  # Red Hat, Fedora
    sudo pacman -S cloc                    # Arch
    sudo pkg install cloc                  # FreeBSD
    sudo port install cloc                 # Mac OS X with MacPorts
    
# [License![^](up.gif)](#___top "click to go to top of document")

cloc is licensed under the [GNU General Public License, v 2](http://www.gnu.org/licenses/gpl-2.0.html) , excluding portions which are copied from other sources. Code copied from the Regexp::Common, Win32::Autoglob, and Algorithm::Diff Perl modules is subject to the [Artistic L icense](http://www.opensource.org/licenses/artistic-license-2.0.php).

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

# <a name="regexp_common">Regexp::Common, Digest::MD5, Win32::Autoglob, Algori thm::Diff</a>

Although cloc does not need Perl modules outside those found in the standard distribution, cloc does rely on a few external modules. Code from three of these external modules--Regexp::Common, Win32::Autoglob, and Algorithm::Diff--is embedded within cloc. A fourth module, Digest::MD5, is used only if it is available. If cloc finds Regexp::Common or Algorithm::Diff installed locally it will use those installation. If it doesn't, cloc will install the parts of Regexp::Common and/or Algorithm:Diff it needs to temporary directories that are created at the start of a cloc run then removed when the run is complete. The necessary code from Regexp::Common v2.120 and Algorithm::Diff v1.1902 are embedded within the cloc source code (see subroutines `Install_Regexp_Common()` and `Install_Algorithm_Diff()` ).
Only three lines are needed from Win32::Autoglob and these are included directly in cloc.

Additionally, cloc will use Digest::MD5 to validate uniqueness among input files if Digest::MD5 is installed locally. If Digest::MD5 is not found the file uniqueness check is skipped.

The Windows binary is built on a computer that has both Regexp::Common and Digest::MD5 installed locally.

# [Building a Windows Executable![^](up.gif)](#___top "click to go to top of document")

The default Windows download, <tt>cloc-1.64.exe</tt>, was built with [PAR::Packer](http://search.cpan.org/~rschupp/PAR-Packer-1.019/lib/pp.pm) on a Windows 7 computer with [Strawberry Perl](http://strawberryperl.com/). Windows executables of cloc versions 1.60 and earlier were built with [perl2exe](http://www.indigostar.com/perl2exe.htm) on a 32 bit Windows XP computer. A small modification was made to the cloc source code before passing it to perl2exe; lines 87 and 88 were uncommented:

<pre><font color="gray">85</font>  # Uncomment next two lines when building Windows e
xecutable with perl2exe
<font color="gray">86</font>  # or if running on a system that already has Regex
p::Common. 
<font color="gray">87</font>  <font color="red">#use Regexp::Common;
<font color="gray">88</font>  #$HAVE_Rexexp_Common = 1;</font>
</pre>

#### Why is the Windows executable so large?

Windows executables of cloc versions 1.60 and earlier, created with perl2exe as noted above, are about 1.6 MB, while newer versions, created with <tt>PAR::Packer</tt>, are 11 MB. Why are the newer executables so much larger? My theory is that perl2exe uses smarter tree pruning logic than <tt>PAR::Packer</tt>, but that's pure speculation.

#### Create your own executable
If you have access to perl2exe, you can use it to create a tight Windows executable. See lines 84-87 in the cloc source code for a minor code modification that is necessary when using perl2exe.

Otherwise, to build a Windows executable with <tt>pp</tt> from <tt>PAR::Packer</tt>, first install a Windows-based Perl distribution (for example Strawberry Perl or ActivePerl) following their instructions. Next, open a command prompt, aka a DOS window and install the PAR::Packer module. Finally, invoke the newly installed <tt>pp</tt> command with the cloc souce code to create an <tt>.exe</tt> file:

<pre>C:> perl -MCPAN -e shell
cpan> install PAR::Packer
cpan> exit
C:> pp cloc-1.64.pl
</pre>

A variation on the above is if you installed the portable version of Strawberry Perl, you will need to run <tt>portableshell.bat</tt> first to properly set up your environment. The Strawberry Perl derived executable on the SourceForge download area was created with the portable version on a Windows 7 computer.

# [Basic Use![^](up.gif)](#___top "click to go to top of document")

cloc is a command line program that takes file, directory, and/or archive names as inputs. Here's an example of running cloc against the Perl v5.10.0 source distribution:
<pre>  
_prompt>_ cloc perl-5.10.0.tar.gz
    4076 text files.
    3883 unique files.                                          
    1521 files ignored.

http://cloc.sourceforge.net v 1.50  T=12.0 s (209.2 files/s, 70472.1 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Perl                          2052         110356         130018         292281
C                              135          18718          22862         140483
C/C++ Header                   147           7650          12093          44042
Bourne Shell                   116           3402           5789          36882
Lisp                             1            684           2242           7515
make                             7            498            473           2044
C++                             10            312            277           2000
XML                             26            231              0           1972
yacc                             2            128             97           1549
YAML                             2              2              0            489
DOS Batch                       11             85             50            322
HTML                             1             19              2             98
-------------------------------------------------------------------------------
SUM:                          2510         142085         173903         529677
-------------------------------------------------------------------------------

</pre>

To run cloc on Windows computers, one must first open up a command (aka DOS) window and invoke cloc.exe from the command line there.

# [Options![^](up.gif)](#___top "click to go to top of document")

<pre>  
_prompt>_ cloc
</pre>
