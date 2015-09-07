# cloc
cloc counts blank lines, comment lines, and physical lines of source code in many programming languages.

Originally hosted at http://cloc.sourceforge.net/, cloc began the transition to github in
September 2015.

# Overview

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
