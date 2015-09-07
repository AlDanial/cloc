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

cloc counts blank lines, comment lines, and physical lines of source code in many programming languages. Given two versions of a code base, cloc can compute differences in blank, comment, and source lines. It is written entirely in Perl with no dependencies outside the standard distribution of Perl v5.6 and higher (code from some external modules is embedded within cloc) and so is quite portable. cloc is known to run on many flavors of Linux, FreeBSD, NetBSD, OpenBSD, Mac OS X, AIX, HP-UX, Solaris, IRIX, z/OS, and Windows. (To run the Perl source version of cloc on Windows one needs ActiveState Perl 5.6.1 or higher, Strawberry Perl, Cygwin, or MobaXTerm with the Perl plug-in installed. Alternatively one can use the Windows binary of cloc generated with PAR::Packer to run on Windows computers that have neither Perl nor Cygwin.)

cloc contains code from David Wheeler's SLOCCount, Damian Conway and Abigail's Perl module Regexp::Common, Sean M. Burke's Perl module Win32::Autoglob, and Tye McQueen's Perl module Algorithm::Diff. Language scale factors were derived from Mayes Consulting, LLC web site http://softwareestimator.com/IndustryData2.htm.

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
