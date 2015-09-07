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

# Overview

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
