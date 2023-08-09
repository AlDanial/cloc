#!/usr/bin/env perl
# cloc -- Count Lines of Code                  {{{1
# Copyright (C) 2006-2023 Al Danial <al.danial@gmail.com>
# First release August 2006
#
# Includes code from:
#   - SLOCCount v2.26
#     http://www.dwheeler.com/sloccount/
#     by David Wheeler.
#   - Regexp::Common v2017060201
#     https://metacpan.org/pod/Regexp::Common
#     by Damian Conway and Abigail.
#   - Win32::Autoglob 1.01
#     https://metacpan.org/pod/Win32::Autoglob
#     by Sean M. Burke.
#   - Algorithm::Diff 1.1902
#     https://metacpan.org/pod/Algorithm::Diff
#     by Tye McQueen.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details:
# <http://www.gnu.org/licenses/gpl.txt>.
#
# 1}}}
my $VERSION = "1.97";  # odd number == beta; even number == stable
my $URL     = "github.com/AlDanial/cloc";  # 'https://' pushes header too wide
require 5.10.0;
# use modules                                  {{{1
use warnings;
use strict;

use Getopt::Long;
use File::Basename;
use File::Temp qw { tempfile tempdir };
use File::Find;
use File::Path;
use File::Spec;
use IO::File;
use List::Util qw( min max );
use Cwd;
use POSIX qw { strftime ceil};
# Parallel::ForkManager isn't in the standard distribution.
# Use it only if installed, and only if --processes=N is given.
# The module load happens in get_max_processes().
my $HAVE_Parallel_ForkManager = 0;

# Digest::MD5 isn't in the standard distribution. Use it only if installed.
my $HAVE_Digest_MD5 = 0;
eval "use Digest::MD5;";
if (defined $Digest::MD5::VERSION) {
    $HAVE_Digest_MD5 = 1;
} else {
    warn "Digest::MD5 not installed; will skip file uniqueness checks.\n";
}

# Time::HiRes became standard with Perl 5.8
my $HAVE_Time_HiRes = 0;
eval "use Time::HiRes;";
$HAVE_Time_HiRes = 1 if defined $Time::HiRes::VERSION;

my $HAVE_Rexexp_Common;
# Regexp::Common isn't in the standard distribution.  It will
# be installed in a temp directory if necessary.
eval "use Regexp::Common qw ( comment ) ";
if (defined $Regexp::Common::VERSION) {
    $HAVE_Rexexp_Common = 1;
} else {
    $HAVE_Rexexp_Common = 0;
}

my $HAVE_Algorithm_Diff = 0;
# Algorithm::Diff isn't in the standard distribution.  It will
# be installed in a temp directory if necessary.
eval "use Algorithm::Diff qw ( sdiff ) ";
if (defined $Algorithm::Diff::VERSION) {
    $HAVE_Algorithm_Diff = 1;
} else {
    Install_Algorithm_Diff();
}

# print "2 HAVE_Algorithm_Diff = $HAVE_Algorithm_Diff\n";
# test_alg_diff($ARGV[$#ARGV - 1], $ARGV[$#ARGV]); die;
# die "Hre=$HAVE_Rexexp_Common  Had=$HAVE_Algorithm_Diff";

# Uncomment next two lines when building Windows executable with perl2exe
# or if running on a system that already has Regexp::Common.
#use Regexp::Common;
#$HAVE_Rexexp_Common = 1;

#perl2exe_include "Regexp/Common/whitespace.pm"
#perl2exe_include "Regexp/Common/URI.pm"
#perl2exe_include "Regexp/Common/URI/fax.pm"
#perl2exe_include "Regexp/Common/URI/file.pm"
#perl2exe_include "Regexp/Common/URI/ftp.pm"
#perl2exe_include "Regexp/Common/URI/gopher.pm"
#perl2exe_include "Regexp/Common/URI/http.pm"
#perl2exe_include "Regexp/Common/URI/pop.pm"
#perl2exe_include "Regexp/Common/URI/prospero.pm"
#perl2exe_include "Regexp/Common/URI/news.pm"
#perl2exe_include "Regexp/Common/URI/tel.pm"
#perl2exe_include "Regexp/Common/URI/telnet.pm"
#perl2exe_include "Regexp/Common/URI/tv.pm"
#perl2exe_include "Regexp/Common/URI/wais.pm"
#perl2exe_include "Regexp/Common/CC.pm"
#perl2exe_include "Regexp/Common/SEN.pm"
#perl2exe_include "Regexp/Common/number.pm"
#perl2exe_include "Regexp/Common/delimited.pm"
#perl2exe_include "Regexp/Common/profanity.pm"
#perl2exe_include "Regexp/Common/net.pm"
#perl2exe_include "Regexp/Common/zip.pm"
#perl2exe_include "Regexp/Common/comment.pm"
#perl2exe_include "Regexp/Common/balanced.pm"
#perl2exe_include "Regexp/Common/lingua.pm"
#perl2exe_include "Regexp/Common/list.pm"
#perl2exe_include "File/Glob.pm"

use Text::Tabs qw { expand };
use Cwd qw { cwd };
use File::Glob;
# 1}}}
# Usage information, options processing.       {{{1
my $ON_WINDOWS = 0;
   $ON_WINDOWS = 1 if ($^O =~ /^MSWin/) or ($^O eq "Windows_NT");
if ($ON_WINDOWS and $ENV{'SHELL'}) {
    if ($ENV{'SHELL'} =~ m{^/}) {
        $ON_WINDOWS = 0;  # make Cygwin look like Unix
    } else {
        $ON_WINDOWS = 1;  # MKS defines $SHELL but still acts like Windows
    }
}

my $HAVE_Win32_Long_Path = 0;
# Win32::LongPath is an optional dependency that when available on
# Windows will be used to support reading files past the 255 char
# path length limit.
if ($ON_WINDOWS) {
    eval "use Win32::LongPath;";
    if (defined $Win32::LongPath::VERSION) {
        $HAVE_Win32_Long_Path = 1;
    }
}
my $config_file = '';
if ( $ENV{'HOME'} ) {
    $config_file = File::Spec->catfile( $ENV{'HOME'}, '.config', 'cloc', 'options.txt');
} elsif ( $ENV{'APPDATA'} and $ON_WINDOWS ) {
    $config_file = File::Spec->catfile( $ENV{'APPDATA'}, 'cloc');
}
# $config_file may be updated by check_alternate_config_files()

my $NN     = chr(27) . "[0m";  # normal
   $NN     = "" if $ON_WINDOWS or !(-t STDOUT); # -t STDOUT:  is it a terminal?
my $BB     = chr(27) . "[1m";  # bold
   $BB     = "" if $ON_WINDOWS or !(-t STDOUT);
my $script = basename $0;

#  Intended for v1.88:
#  --git-diff-simindex       Git diff strategy #3:  use git's similarity index
#                            (git diff -M --name-status) to identify file pairs
#                            to compare.  This is especially useful to compare
#                            files that were renamed between the commits.

my $brief_usage  = "
                       cloc -- Count Lines of Code

Usage:
    $script [options] <file(s)/dir(s)/git hash(es)>
        Count physical lines of source code and comments in the given files
        (may be archives such as compressed tarballs or zip files) and/or
        recursively below the given directories or git commit hashes.
        Example:    cloc src/ include/ main.c

    $script [options] --diff <set1>  <set2>
        Compute differences of physical lines of source code and comments
        between any pairwise combination of directory names, archive
        files or git commit hashes.
        Example:    cloc --diff Python-3.5.tar.xz python-3.6/

$script --help  shows full documentation on the options.
https://$URL has numerous examples and more information.
";
my $usage  = "
Usage: $script [options] <file(s)/dir(s)/git hash(es)> | <set 1> <set 2> | <report files>

 Count, or compute differences of, physical lines of source code in the
 given files (may be archives such as compressed tarballs or zip files,
 or git commit hashes or branch names) and/or recursively below the
 given directories.

 ${BB}Input Options${NN}
   --extract-with=<cmd>      This option is only needed if cloc is unable
                             to figure out how to extract the contents of
                             the input file(s) by itself.
                             Use <cmd> to extract binary archive files (e.g.:
                             .tar.gz, .zip, .Z).  Use the literal '>FILE<' as
                             a stand-in for the actual file(s) to be
                             extracted.  For example, to count lines of code
                             in the input files
                                gcc-4.2.tar.gz  perl-5.8.8.tar.gz
                             on Unix use
                               --extract-with='gzip -dc >FILE< | tar xf -'
                             or, if you have GNU tar,
                               --extract-with='tar zxf >FILE<'
                             and on Windows use, for example:
                               --extract-with=\"\\\"c:\\Program Files\\WinZip\\WinZip32.exe\\\" -e -o >FILE< .\"
                             (if WinZip is installed there).
   --list-file=<file>        Take the list of file and/or directory names to
                             process from <file>, which has one file/directory
                             name per line.  Only exact matches are counted;
                             relative path names will be resolved starting from
                             the directory where cloc is invoked.  Set <file>
                             to - to read file names from a STDIN pipe.
                             See also --exclude-list-file, --config.
   --diff-list-file=<file>   Take the pairs of file names to be diff'ed from
                             <file>, whose format matches the output of
                             --diff-alignment.  (Run with that option to
                             see a sample.)  The language identifier at the
                             end of each line is ignored.  This enables --diff
                             mode and bypasses file pair alignment logic.
                             Use --diff-list-files to define the file name
                             pairs in separate files. See also --config.
   --diff-list-files <file1> <file2>
                             Compute differences in code and comments between
                             the files and directories listed in <file1> and
                             <file2>.  Each input file should use the same
                             format as --list-file, where there is one file or
                             directory name per line.  Only exact matches are
                             counted; relative path names will be resolved
                             starting from the directory where cloc is invoked.
                             This enables --diff mode.  See also --list-file,
                             --diff-list-file, --diff.
   --vcs=<VCS>               Invoke a system call to <VCS> to obtain a list of
                             files to work on.  If <VCS> is 'git', then will
                             invoke 'git ls-files' to get a file list and
                             'git submodule status' to get a list of submodules
                             whose contents will be ignored.  See also --git
                             which accepts git commit hashes and branch names.
                             If <VCS> is 'svn' then will invoke 'svn list -R'.
                             The primary benefit is that cloc will then skip
                             files explicitly excluded by the versioning tool
                             in question, ie, those in .gitignore or have the
                             svn:ignore property.
                             Alternatively <VCS> may be any system command
                             that generates a list of files.
                             Note:  cloc must be in a directory which can read
                             the files as they are returned by <VCS>.  cloc will
                             not download files from remote repositories.
                             'svn list -R' may refer to a remote repository
                             to obtain file names (and therefore may require
                             authentication to the remote repository), but
                             the files themselves must be local.
                             Setting <VCS> to 'auto' selects between 'git'
                             and 'svn' (or neither) depending on the presence
                             of a .git or .svn subdirectory below the directory
                             where cloc is invoked.
   --unicode                 Check binary files to see if they contain Unicode
                             expanded ASCII text.  This causes performance to
                             drop noticeably.

 ${BB}Processing Options${NN}
   --autoconf                Count .in files (as processed by GNU autoconf) of
                             recognized languages.  See also --no-autogen.
   --by-file                 Report results for every source file encountered.
   --by-file-by-lang         Report results for every source file encountered
                             in addition to reporting by language.
   --config <file>           Read command line switches from <file> instead of
                             the default location of $config_file.
                             The file should contain one switch, along with
                             arguments (if any), per line.  Blank lines and lines
                             beginning with '#' are skipped.  Options given on
                             the command line take priority over entries read from
                             the file.
                             If a directory is also given with any of these
                             switches: --list-file, --exclude-list-file,
                             --read-lang-def, --force-lang-def, --diff-list-file
                             and a config file exists in that directory, it will
                             take priority over $config_file.
   --count-and-diff <set1> <set2>
                             First perform direct code counts of source file(s)
                             of <set1> and <set2> separately, then perform a diff
                             of these.  Inputs may be pairs of files, directories,
                             or archives.  If --out or --report-file is given,
                             three output files will be created, one for each
                             of the two counts and one for the diff.  See also
                             --diff, --diff-alignment, --diff-timeout,
                             --ignore-case, --ignore-whitespace.
   --diff <set1> <set2>      Compute differences in code and comments between
                             source file(s) of <set1> and <set2>.  The inputs
                             may be any mix of files, directories, archives,
                             or git commit hashes.  Use --diff-alignment to
                             generate a list showing which file pairs where
                             compared.  When comparing git branches, only files
                             which have changed in either commit are compared.
                             See also --git, --count-and-diff, --diff-alignment,
                             --diff-list-file, --diff-timeout, --ignore-case,
                             --ignore-whitespace.
   --diff-timeout <N>        Ignore files which take more than <N> seconds
                             to process.  Default is 10 seconds.  Setting <N>
                             to 0 allows unlimited time.  (Large files with many
                             repeated lines can cause Algorithm::Diff::sdiff()
                             to take hours.) See also --timeout.
   --docstring-as-code       cloc considers docstrings to be comments, but this is
                             not always correct as docstrings represent regular
                             strings when they appear on the right hand side of an
                             assignment or as function arguments.  This switch
                             forces docstrings to be counted as code.
   --follow-links            [Unix only] Follow symbolic links to directories
                             (sym links to files are always followed).
                             See also --stat.
   --force-lang=<lang>[,<ext>]
                             Process all files that have a <ext> extension
                             with the counter for language <lang>.  For
                             example, to count all .f files with the
                             Fortran 90 counter (which expects files to
                             end with .f90) instead of the default Fortran 77
                             counter, use
                               --force-lang=\"Fortran 90\",f
                             If <ext> is omitted, every file will be counted
                             with the <lang> counter.  This option can be
                             specified multiple times (but that is only
                             useful when <ext> is given each time).
                             See also --script-lang, --lang-no-ext.
   --force-lang-def=<file>   Load language processing filters from <file>,
                             then use these filters instead of the built-in
                             filters.  Note:  languages which map to the same
                             file extension (for example:
                             MATLAB/Mathematica/Objective-C/MUMPS/Mercury;
                             Pascal/PHP; Lisp/OpenCL; Lisp/Julia; Perl/Prolog)
                             will be ignored as these require additional
                             processing that is not expressed in language
                             definition files.  Use --read-lang-def to define
                             new language filters without replacing built-in
                             filters (see also --write-lang-def,
                             --write-lang-def-incl-dup, --config).
   --git                     Forces the inputs to be interpreted as git targets
                             (commit hashes, branch names, et cetera) if these
                             are not first identified as file or directory
                             names.  This option overrides the --vcs=git logic
                             if this is given; in other words, --git gets its
                             list of files to work on directly from git using
                             the hash or branch name rather than from
                             'git ls-files'.  This option can be used with
                             --diff to perform line count diffs between git
                             commits, or between a git commit and a file,
                             directory, or archive.  Use -v/--verbose to see
                             the git system commands cloc issues.
   --git-diff-rel            Same as --git --diff, or just --diff if the inputs
                             are recognized as git targets.  Only files which
                             have changed in either commit are compared.
   --git-diff-all            Git diff strategy #2:  compare all files in the
                             repository between the two commits.
   --ignore-whitespace       Ignore horizontal white space when comparing files
                             with --diff.  See also --ignore-case.
   --ignore-case             Ignore changes in case within file contents;
                             consider upper- and lowercase letters equivalent
                             when comparing files with --diff.  See also
                             --ignore-whitespace.
   --ignore-case-ext         Ignore case of file name extensions.  This will
                             cause problems counting some languages
                             (specifically, .c and .C are associated with C and
                             C++; this switch would count .C files as C rather
                             than C++ on *nix operating systems).  File name
                             case insensitivity is always true on Windows.
   --lang-no-ext=<lang>      Count files without extensions using the <lang>
                             counter.  This option overrides internal logic
                             for files without extensions (where such files
                             are checked against known scripting languages
                             by examining the first line for #!).  See also
                             --force-lang, --script-lang.
   --max-file-size=<MB>      Skip files larger than <MB> megabytes when
                             traversing directories.  By default, <MB>=100.
                             cloc's memory requirement is roughly twenty times
                             larger than the largest file so running with
                             files larger than 100 MB on a computer with less
                             than 2 GB of memory will cause problems.
                             Note:  this check does not apply to files
                             explicitly passed as command line arguments.
   --no-autogen[=list]       Ignore files generated by code-production systems
                             such as GNU autoconf.  To see a list of these files
                             (then exit), run with --no-autogen list
                             See also --autoconf.
   --no-recurse              Count files in the given directories without
                             recursively descending below them.
   --original-dir            [Only effective in combination with
                             --strip-comments]  Write the stripped files
                             to the same directory as the original files.
   --only-count-files        Only count files by language.
   --read-binary-files       Process binary files in addition to text files.
                             This is usually a bad idea and should only be
                             attempted with text files that have embedded
                             binary data.
   --read-lang-def=<file>    Load new language processing filters from <file>
                             and merge them with those already known to cloc.
                             If <file> defines a language cloc already knows
                             about, cloc's definition will take precedence.
                             Use --force-lang-def to over-ride cloc's
                             definitions (see also --write-lang-def,
                             --write-lang-def-incl-dup, --config).
   --script-lang=<lang>,<s>  Process all files that invoke <s> as a #!
                             scripting language with the counter for language
                             <lang>.  For example, files that begin with
                                #!/usr/local/bin/perl5.8.8
                             will be counted with the Perl counter by using
                                --script-lang=Perl,perl5.8.8
                             The language name is case insensitive but the
                             name of the script language executable, <s>,
                             must have the right case.  This option can be
                             specified multiple times.  See also --force-lang,
                             --lang-no-ext.
   --sdir=<dir>              Use <dir> as the scratch directory instead of
                             letting File::Temp chose the location.  Files
                             written to this location are not removed at
                             the end of the run (as they are with File::Temp).
   --skip-leading=<N[,ext]>  Skip the first <N> lines of each file.  If a
                             comma separated list of extensions is also given,
                             only skip lines from those file types.  Example:
                               --skip-leading=10,cpp,h
                             will skip the first ten lines of *.cpp and *.h
                             files.  This is useful for ignoring boilerplate
                             text.
   --skip-uniqueness         Skip the file uniqueness check.  This will give
                             a performance boost at the expense of counting
                             files with identical contents multiple times
                             (if such duplicates exist).
   --stat                    Some file systems (AFS, CD-ROM, FAT, HPFS, SMB)
                             do not have directory 'nlink' counts that match
                             the number of its subdirectories.  Consequently
                             cloc may undercount or completely skip the
                             contents of such file systems.  This switch forces
                             File::Find to stat directories to obtain the
                             correct count.  File search speed will decrease.
                             See also --follow-links.
   --stdin-name=<file>       Give a file name to use to determine the language
                             for standard input.  (Use - as the input name to
                             receive source code via STDIN.)
   --strip-comments=<ext>    For each file processed, write to the current
                             directory a version of the file which has blank
                             and commented lines removed (in-line comments
                             persist).  The name of each stripped file is the
                             original file name with .<ext> appended to it.
                             It is written to the current directory unless
                             --original-dir is on.
   --strip-str-comments      Replace comment markers embedded in strings with
                             'xx'.  This attempts to work around a limitation
                             in Regexp::Common::Comment where comment markers
                             embedded in strings are seen as actual comment
                             markers and not strings, often resulting in a
                             'Complex regular subexpression recursion limit'
                             warning and incorrect counts.  There are two
                             disadvantages to using this switch:  1/code count
                             performance drops, and 2/code generated with
                             --strip-comments will contain different strings
                             where ever embedded comments are found.
   --sum-reports             Input arguments are report files previously
                             created with the --report-file option in plain
                             format (eg. not JSON, YAML, XML, or SQL).
                             Makes a cumulative set of results containing the
                             sum of data from the individual report files.
   --timeout <N>             Ignore files which take more than <N> seconds
                             to process at any of the language's filter stages.
                             The default maximum number of seconds spent on a
                             filter stage is the number of lines in the file
                             divided by one thousand.  Setting <N> to 0 allows
                             unlimited time.  See also --diff-timeout.
   --processes=NUM           [Available only on systems with a recent version
                             of the Parallel::ForkManager module.  Not
                             available on Windows.] Sets the maximum number of
                             cores that cloc uses.  The default value of 0
                             disables multiprocessing.
   --unix                    Override the operating system autodetection
                             logic and run in UNIX mode.  See also
                             --windows, --show-os.
   --use-sloccount           If SLOCCount is installed, use its compiled
                             executables c_count, java_count, pascal_count,
                             php_count, and xml_count instead of cloc's
                             counters.  SLOCCount's compiled counters are
                             substantially faster than cloc's and may give
                             a performance improvement when counting projects
                             with large files.  However, these cloc-specific
                             features will not be available: --diff,
                             --count-and-diff, --strip-comments, --unicode.
   --windows                 Override the operating system autodetection
                             logic and run in Microsoft Windows mode.
                             See also --unix, --show-os.

 ${BB}Filter Options${NN}
   --include-content=<regex> Only count files containing text that matches the
                             given regular expression.
   --exclude-content=<regex> Exclude files containing text that matches the given
                             regular expression.
   --exclude-dir=<D1>[,D2,]  Exclude the given comma separated directories
                             D1, D2, D3, et cetera, from being scanned.  For
                             example  --exclude-dir=.cache,test  will skip
                             all files and subdirectories that have /.cache/
                             or /test/ as their parent directory.
                             Directories named .bzr, .cvs, .hg, .git, .svn,
                             and .snapshot are always excluded.
                             This option only works with individual directory
                             names so including file path separators is not
                             allowed.  Use --fullpath and --not-match-d=<regex>
                             to supply a regex matching multiple subdirectories.
   --exclude-ext=<ext1>[,<ext2>[...]]
                             Do not count files having the given file name
                             extensions.
   --exclude-lang=<L1>[,L2[...]]
                             Exclude the given comma separated languages
                             L1, L2, L3, et cetera, from being counted.
   --exclude-list-file=<file>  Ignore files and/or directories whose names
                             appear in <file>.  <file> should have one file
                             name per line.  Only exact matches are ignored;
                             relative path names will be resolved starting from
                             the directory where cloc is invoked.
                             See also --list-file, --config.
   --fullpath                Modifies the behavior of --match-f, --not-match-f,
                             and --not-match-d to include the file's path
                             in the regex, not just the file's basename.
                             (This does not expand each file to include its
                             absolute path, instead it uses as much of
                             the path as is passed in to cloc.)
                             Note:  --match-d always looks at the full
                             path and therefore is unaffected by --fullpath.
   --include-ext=<ext1>[,ext2[...]]
                             Count only languages having the given comma
                             separated file extensions.  Use --show-ext to
                             see the recognized extensions.
   --include-lang=<L1>[,L2[...]]
                             Count only the given comma separated, case-
                             insensitive languages L1, L2, L3, et cetera.  Use
                             --show-lang to see the list of recognized languages.
   --match-d=<regex>         Only count files in directories matching the Perl
                             regex.  For example
                               --match-d='/(src|include)/'
                             only counts files in directories containing
                             /src/ or /include/.  Unlike --not-match-d,
                             --match-f, and --not-match-f, --match-d always
                             compares the fully qualified path against the
                             regex.
   --not-match-d=<regex>     Count all files except those in directories
                             matching the Perl regex.  Only the trailing
                             directory name is compared, for example, when
                             counting in /usr/local/lib, only 'lib' is
                             compared to the regex.
                             Add --fullpath to compare parent directories to
                             the regex.
                             Do not include file path separators at the
                             beginning or end of the regex.
                             This option may be repeated.
   --match-f=<regex>         Only count files whose basenames match the Perl
                             regex.  For example
                               --match-f='^[Ww]idget'
                             only counts files that start with Widget or widget.
                             Add --fullpath to include parent directories
                             in the regex instead of just the basename.
   --not-match-f=<regex>     Count all files except those whose basenames
                             match the Perl regex.  Add --fullpath to include
                             parent directories in the regex instead of just
                             the basename. This option may be repeated.
   --skip-archive=<regex>    Ignore files that end with the given Perl regular
                             expression.  For example, if given
                               --skip-archive='(zip|tar(\.(gz|Z|bz2|xz|7z))?)'
                             the code will skip files that end with .zip,
                             .tar, .tar.gz, .tar.Z, .tar.bz2, .tar.xz, and
                             .tar.7z.
   --skip-win-hidden         On Windows, ignore hidden files.

 ${BB}Debug Options${NN}
   --categorized=<file>      Save file sizes in bytes, identified languages
                             and names of categorized files to <file>.
   --counted=<file>          Save names of processed source files to <file>.
   --diff-alignment=<file>   Write to <file> a list of files and file pairs
                             showing which files were added, removed, and/or
                             compared during a run with --diff.  This switch
                             forces the --diff mode on.
   --explain=<lang>          Print the filters used to remove comments for
                             language <lang> and exit.  In some cases the
                             filters refer to Perl subroutines rather than
                             regular expressions.  An examination of the
                             source code may be needed for further explanation.
   --help                    Print this usage information and exit.
   --found=<file>            Save names of every file found to <file>.
   --ignored=<file>          Save names of ignored files and the reason they
                             were ignored to <file>.
   --print-filter-stages     Print processed source code before and after
                             each filter is applied.
   --show-ext[=<ext>]        Print information about all known (or just the
                             given) file extensions and exit.
   --show-lang[=<lang>]      Print information about all known (or just the
                             given) languages and exit.
   --show-os                 Print the value of the operating system mode
                             and exit.  See also --unix, --windows.
   -v[=<n>]                  Verbose switch (optional numeric value).
   -verbose[=<n>]            Long form of -v.
   --version                 Print the version of this program and exit.
   --write-lang-def=<file>   Writes to <file> the language processing filters
                             then exits.  Useful as a first step to creating
                             custom language definitions. Note: languages which
                             map to the same file extension will be excluded.
                             (See also --force-lang-def, --read-lang-def).
   --write-lang-def-incl-dup=<file>
                             Same as --write-lang-def, but includes duplicated
                             extensions.  This generates a problematic language
                             definition file because cloc will refuse to use
                             it until duplicates are removed.

 ${BB}Output Options${NN}
   --3                       Print third-generation language output.
                             (This option can cause report summation to fail
                             if some reports were produced with this option
                             while others were produced without it.)
   --by-percent  X           Instead of comment and blank line counts, show
                             these values as percentages based on the value
                             of X in the denominator, where X is
                                 c    meaning lines of code
                                 cm   meaning lines of code + comments
                                 cb   meaning lines of code + blanks
                                 cmb  meaning lines of code + comments + blanks
                             For example, if using method 'c' and your code
                             has twice as many lines of comments as lines
                             of code, the value in the comment column will
                             be 200%.  The code column remains a line count.
   --csv                     Write the results as comma separated values.
   --csv-delimiter=<C>       Use the character <C> as the delimiter for comma
                             separated files instead of ,.  This switch forces
   --file-encoding=<E>       Write output files using the <E> encoding instead of
                             the default ASCII (<E> = 'UTF-7').  Examples: 'UTF-16',
                             'euc-kr', 'iso-8859-16'.  Known encodings can be
                             printed with
                               perl -MEncode -e 'print join(\"\\n\", Encode->encodings(\":all\")), \"\\n\"'
   --hide-rate               Do not show elapsed time, line processing rate, or
                             file processing rates in the output header. This
                             makes output deterministic.
   --json                    Write the results as JavaScript Object Notation
                             (JSON) formatted output.
   --md                      Write the results as Markdown-formatted text.
   --out=<file>              Synonym for --report-file=<file>.
   --progress-rate=<n>       Show progress update after every <n> files are
                             processed (default <n>=100).  Set <n> to 0 to
                             suppress progress output (useful when redirecting
                             output to STDOUT).
   --quiet                   Suppress all information messages except for
                             the final report.
   --report-file=<file>      Write the results to <file> instead of STDOUT.
   --summary-cutoff=X:N      Aggregate to 'Other' results having X lines
                             below N where X is one of
                                c   meaning lines of code
                                f   meaning files
                                m   meaning lines of comments
                                cm  meaning lines of code + comments
                             Appending a percent sign to N changes
                             the calculation from straight count to
                             percentage.
                             Ignored with --diff or --by-file.
   --sql=<file>              Write results as SQL create and insert statements
                             which can be read by a database program such as
                             SQLite.  If <file> is -, output is sent to STDOUT.
   --sql-append              Append SQL insert statements to the file specified
                             by --sql and do not generate table creation
                             statements.  Only valid with the --sql option.
   --sql-project=<name>      Use <name> as the project identifier for the
                             current run.  Only valid with the --sql option.
   --sql-style=<style>       Write SQL statements in the given style instead
                             of the default SQLite format.  Styles include
                             'Oracle' and 'Named_Columns'.
   --sum-one                 For plain text reports, show the SUM: output line
                             even if only one input file is processed.
   --xml                     Write the results in XML.
   --xsl=<file>              Reference <file> as an XSL stylesheet within
                             the XML output.  If <file> is 1 (numeric one),
                             writes a default stylesheet, cloc.xsl (or
                             cloc-diff.xsl if --diff is also given).
                             This switch forces --xml on.
   --yaml                    Write the results in YAML.

";
#  Help information for options not yet implemented:
#  --inline                  Process comments that appear at the end
#                            of lines containing code.
#  --html                    Create HTML files of each input file showing
#                            comment and code lines in different colors.

$| = 1;  # flush STDOUT
my $start_time = get_time();
my (
    $opt_categorized          ,
    $opt_found                ,
    @opt_force_lang           ,
    $opt_lang_no_ext          ,
    @opt_script_lang          ,
    $opt_count_diff           ,
    $opt_diff                 ,
    $opt_diff_alignment       ,
    $opt_diff_list_file       ,
    $opt_diff_list_files      ,
    $opt_diff_timeout         ,
    $opt_timeout              ,
    $opt_html                 ,
    $opt_ignored              ,
    $opt_counted              ,
    $opt_show_ext             ,
    $opt_show_lang            ,
    $opt_progress_rate        ,
    $opt_print_filter_stages  ,
    $opt_v                    ,
    $opt_vcs                  ,
    $opt_version              ,
    $opt_include_content      ,
    $opt_exclude_content      ,
    $opt_exclude_lang         ,
    $opt_exclude_list_file    ,
    $opt_exclude_dir          ,
    $opt_explain              ,
    $opt_include_ext          ,
    $opt_include_lang         ,
    $opt_force_lang_def       ,
    $opt_read_lang_def        ,
    $opt_write_lang_def       ,
    $opt_write_lang_def_incl_dup,
    $opt_strip_comments       ,
    $opt_original_dir         ,
    $opt_quiet                ,
    $opt_report_file          ,
    $opt_sdir                 ,
    $opt_sum_reports          ,
    $opt_hide_rate            ,
    $opt_processes            ,
    $opt_unicode              ,
    $opt_no3                  ,   # accept it but don't use it
    $opt_3                    ,
    $opt_extract_with         ,
    $opt_by_file              ,
    $opt_by_file_by_lang      ,
    $opt_by_percent           ,
    $opt_xml                  ,
    $opt_xsl                  ,
    $opt_yaml                 ,
    $opt_csv                  ,
    $opt_csv_delimiter        ,
    $opt_fullpath             ,
    $opt_json                 ,
    $opt_md                   ,
    $opt_match_f              ,
    @opt_not_match_f          ,
    $opt_match_d              ,
    @opt_not_match_d          ,
    $opt_skip_uniqueness      ,
    $opt_list_file            ,
    $opt_help                 ,
    $opt_skip_win_hidden      ,
    $opt_read_binary_files    ,
    $opt_sql                  ,
    $opt_sql_append           ,
    $opt_sql_project          ,
    $opt_sql_style            ,
    $opt_inline               ,
    $opt_exclude_ext          ,
    $opt_ignore_whitespace    ,
    $opt_ignore_case          ,
    $opt_ignore_case_ext      ,
    $opt_follow_links         ,
    $opt_autoconf             ,
    $opt_sum_one              ,
    $opt_stdin_name           ,
    $opt_force_on_windows     ,
    $opt_force_on_unix        ,   # actually forces !$ON_WINDOWS
    $opt_show_os              ,
    $opt_skip_archive         ,
    $opt_max_file_size        ,   # in MB
    $opt_use_sloccount        ,
    $opt_no_autogen           ,
    $opt_force_git            ,
    $opt_git_diff_rel         ,
    $opt_git_diff_all         ,
    $opt_git_diff_simindex    ,
    $opt_config_file          ,
    $opt_strip_str_comments   ,
    $opt_file_encoding        ,
    $opt_docstring_as_code    ,
    $opt_stat                 ,
    $opt_summary_cutoff       ,
    $opt_skip_leading         ,
    $opt_no_recurse           ,
    $opt_only_count_files     ,
   );

my $getopt_success = GetOptions(             # {{{1
   "by_file|by-file"                         => \$opt_by_file             ,
   "by_file_by_lang|by-file-by-lang"         => \$opt_by_file_by_lang     ,
   "categorized=s"                           => \$opt_categorized         ,
   "counted=s"                               => \$opt_counted             ,
   "include_ext|include-ext=s"               => \$opt_include_ext         ,
   "include_lang|include-lang=s"             => \$opt_include_lang        ,
   "include_content|include-content=s"       => \$opt_include_content     ,
   "exclude_content|exclude-content=s"       => \$opt_exclude_content     ,
   "exclude_lang|exclude-lang=s"             => \$opt_exclude_lang        ,
   "exclude_dir|exclude-dir=s"               => \$opt_exclude_dir         ,
   "exclude_list_file|exclude-list-file=s"   => \$opt_exclude_list_file   ,
   "explain=s"                               => \$opt_explain             ,
   "extract_with|extract-with=s"             => \$opt_extract_with        ,
   "found=s"                                 => \$opt_found               ,
   "count_and_diff|count-and-diff"           => \$opt_count_diff          ,
   "diff"                                    => \$opt_diff                ,
   "diff-alignment|diff_alignment=s"         => \$opt_diff_alignment      ,
   "diff-timeout|diff_timeout=i"             => \$opt_diff_timeout        ,
   "diff-list-file|diff_list_file=s"         => \$opt_diff_list_file      ,
   "diff-list-files|diff_list_files"         => \$opt_diff_list_files     ,
   "timeout=i"                               => \$opt_timeout             ,
   "html"                                    => \$opt_html                ,
   "ignored=s"                               => \$opt_ignored             ,
   "quiet"                                   => \$opt_quiet               ,
   "force_lang_def|force-lang-def=s"         => \$opt_force_lang_def      ,
   "read_lang_def|read-lang-def=s"           => \$opt_read_lang_def       ,
   "show_ext|show-ext:s"                     => \$opt_show_ext            ,
   "show_lang|show-lang:s"                   => \$opt_show_lang           ,
   "progress_rate|progress-rate=i"           => \$opt_progress_rate       ,
   "print_filter_stages|print-filter-stages" => \$opt_print_filter_stages ,
   "report_file|report-file=s"               => \$opt_report_file         ,
   "out=s"                                   => \$opt_report_file         ,
   "script_lang|script-lang=s"               => \@opt_script_lang         ,
   "sdir=s"                                  => \$opt_sdir                ,
   "skip_uniqueness|skip-uniqueness"         => \$opt_skip_uniqueness     ,
   "strip_comments|strip-comments=s"         => \$opt_strip_comments      ,
   "original_dir|original-dir"               => \$opt_original_dir        ,
   "sum_reports|sum-reports"                 => \$opt_sum_reports         ,
   "hide_rate|hide-rate"                     => \$opt_hide_rate           ,
   "processes=n"                             => \$opt_processes           ,
   "unicode"                                 => \$opt_unicode             ,
   "no3"                                     => \$opt_no3                 ,  # ignored
   "3"                                       => \$opt_3                   ,
   "v|verbose:i"                             => \$opt_v                   ,
   "vcs=s"                                   => \$opt_vcs                 ,
   "version"                                 => \$opt_version             ,
   "write_lang_def|write-lang-def=s"         => \$opt_write_lang_def      ,
   "write_lang_def_incl_dup|write-lang-def-incl-dup=s" => \$opt_write_lang_def_incl_dup,
   "xml"                                     => \$opt_xml                 ,
   "xsl=s"                                   => \$opt_xsl                 ,
   "force_lang|force-lang=s"                 => \@opt_force_lang          ,
   "lang_no_ext|lang-no-ext=s"               => \$opt_lang_no_ext         ,
   "yaml"                                    => \$opt_yaml                ,
   "csv"                                     => \$opt_csv                 ,
   "csv_delimiter|csv-delimiter=s"           => \$opt_csv_delimiter       ,
   "json"                                    => \$opt_json                ,
   "md"                                      => \$opt_md                  ,
   "fullpath"                                => \$opt_fullpath            ,
   "match_f|match-f=s"                       => \$opt_match_f             ,
   "not_match_f|not-match-f=s"               => \@opt_not_match_f         ,
   "match_d|match-d=s"                       => \$opt_match_d             ,
   "not_match_d|not-match-d=s"               => \@opt_not_match_d         ,
   "list_file|list-file=s"                   => \$opt_list_file           ,
   "help"                                    => \$opt_help                ,
   "skip_win_hidden|skip-win-hidden"         => \$opt_skip_win_hidden     ,
   "read_binary_files|read-binary-files"     => \$opt_read_binary_files   ,
   "sql=s"                                   => \$opt_sql                 ,
   "sql_project|sql-project=s"               => \$opt_sql_project         ,
   "sql_append|sql-append"                   => \$opt_sql_append          ,
   "sql_style|sql-style=s"                   => \$opt_sql_style           ,
   "inline"                                  => \$opt_inline              ,
   "exclude_ext|exclude-ext=s"               => \$opt_exclude_ext         ,
   "ignore_whitespace|ignore-whitespace"     => \$opt_ignore_whitespace   ,
   "ignore_case|ignore-case"                 => \$opt_ignore_case         ,
   "ignore_case_ext|ignore-case-ext"         => \$opt_ignore_case_ext     ,
   "follow_links|follow-links"               => \$opt_follow_links        ,
   "autoconf"                                => \$opt_autoconf            ,
   "sum_one|sum-one"                         => \$opt_sum_one             ,
   "by_percent|by-percent=s"                 => \$opt_by_percent          ,
   "stdin_name|stdin-name=s"                 => \$opt_stdin_name          ,
   "windows"                                 => \$opt_force_on_windows    ,
   "unix"                                    => \$opt_force_on_unix       ,
   "show_os|show-os"                         => \$opt_show_os             ,
   "skip_archive|skip-archive=s"             => \$opt_skip_archive        ,
   "max_file_size|max-file-size=f"           => \$opt_max_file_size       ,
   "use_sloccount|use-sloccount"             => \$opt_use_sloccount       ,
   "no_autogen|no-autogen"                   => \$opt_no_autogen          ,
   "git"                                     => \$opt_force_git           ,
   "git_diff_rel|git-diff-rel"               => \$opt_git_diff_rel        ,
   "git_diff_all|git-diff-all"               => \$opt_git_diff_all        ,
#  "git_diff_simindex|git-diff-simindex"     => \$opt_git_diff_simindex   ,
   "config=s"                                => \$opt_config_file         ,
   "strip_str_comments|strip-str-comments"   => \$opt_strip_str_comments  ,
   "file_encoding|file-encoding=s"           => \$opt_file_encoding       ,
   "docstring_as_code|docstring-as-code"     => \$opt_docstring_as_code   ,
   "stat"                                    => \$opt_stat                ,
   "summary_cutoff|summary-cutoff=s"         => \$opt_summary_cutoff      ,
   "skip_leading|skip-leading:s"             => \$opt_skip_leading        ,
   "no_recurse|no-recurse"                   => \$opt_no_recurse          ,
   "only_count_files|only-count-files"       => \$opt_only_count_files    ,
  );
# 1}}}
$config_file = $opt_config_file if defined $opt_config_file;
load_from_config_file($config_file,          # {{{2
                                                \$opt_by_file             ,
                                                \$opt_by_file_by_lang     ,
                                                \$opt_categorized         ,
                                                \$opt_counted             ,
                                                \$opt_include_ext         ,
                                                \$opt_include_lang        ,
                                                \$opt_include_content     ,
                                                \$opt_exclude_content     ,
                                                \$opt_exclude_lang        ,
                                                \$opt_exclude_dir         ,
                                                \$opt_exclude_list_file   ,
                                                \$opt_explain             ,
                                                \$opt_extract_with        ,
                                                \$opt_found               ,
                                                \$opt_count_diff          ,
                                                \$opt_diff_list_files     ,
                                                \$opt_diff                ,
                                                \$opt_diff_alignment      ,
                                                \$opt_diff_timeout        ,
                                                \$opt_timeout             ,
                                                \$opt_html                ,
                                                \$opt_ignored             ,
                                                \$opt_quiet               ,
                                                \$opt_force_lang_def      ,
                                                \$opt_read_lang_def       ,
                                                \$opt_show_ext            ,
                                                \$opt_show_lang           ,
                                                \$opt_progress_rate       ,
                                                \$opt_print_filter_stages ,
                                                \$opt_report_file         ,
                                                \@opt_script_lang         ,
                                                \$opt_sdir                ,
                                                \$opt_skip_uniqueness     ,
                                                \$opt_strip_comments      ,
                                                \$opt_original_dir        ,
                                                \$opt_sum_reports         ,
                                                \$opt_hide_rate           ,
                                                \$opt_processes           ,
                                                \$opt_unicode             ,
                                                \$opt_3                   ,
                                                \$opt_v                   ,
                                                \$opt_vcs                 ,
                                                \$opt_version             ,
                                                \$opt_write_lang_def      ,
                                                \$opt_write_lang_def_incl_dup,
                                                \$opt_xml                 ,
                                                \$opt_xsl                 ,
                                                \@opt_force_lang          ,
                                                \$opt_lang_no_ext         ,
                                                \$opt_yaml                ,
                                                \$opt_csv                 ,
                                                \$opt_csv_delimiter       ,
                                                \$opt_json                ,
                                                \$opt_md                  ,
                                                \$opt_fullpath            ,
                                                \$opt_match_f             ,
                                                \@opt_not_match_f         ,
                                                \$opt_match_d             ,
                                                \@opt_not_match_d         ,
                                                \$opt_list_file           ,
                                                \$opt_help                ,
                                                \$opt_skip_win_hidden     ,
                                                \$opt_read_binary_files   ,
                                                \$opt_sql                 ,
                                                \$opt_sql_project         ,
                                                \$opt_sql_append          ,
                                                \$opt_sql_style           ,
                                                \$opt_inline              ,
                                                \$opt_exclude_ext         ,
                                                \$opt_ignore_whitespace   ,
                                                \$opt_ignore_case         ,
                                                \$opt_ignore_case_ext     ,
                                                \$opt_follow_links        ,
                                                \$opt_autoconf            ,
                                                \$opt_sum_one             ,
                                                \$opt_by_percent          ,
                                                \$opt_stdin_name          ,
                                                \$opt_force_on_windows    ,
                                                \$opt_force_on_unix       ,
                                                \$opt_show_os             ,
                                                \$opt_skip_archive        ,
                                                \$opt_max_file_size       ,
                                                \$opt_use_sloccount       ,
                                                \$opt_no_autogen          ,
                                                \$opt_force_git           ,
                                                \$opt_strip_str_comments  ,
                                                \$opt_file_encoding       ,
                                                \$opt_docstring_as_code   ,
                                                \$opt_stat                ,
);  # 2}}} Not pretty.  Not at all.
if ($opt_version) {
    printf "$VERSION\n";
    exit;
}
my $opt_git = 0;
$opt_git = 1 if defined($opt_git_diff_all) or
                defined($opt_git_diff_rel) or
                (defined($opt_vcs) and ($opt_vcs eq "git"));
$opt_by_file  = 1 if defined  $opt_by_file_by_lang;
my $CLOC_XSL = "cloc.xsl"; # created with --xsl
   $CLOC_XSL = "cloc-diff.xsl" if $opt_diff;
die "\n" unless $getopt_success;
print $usage and exit if $opt_help;
my %Exclude_Language = ();
   %Exclude_Language = map { $_ => 1 } split(/,/, $opt_exclude_lang)
        if $opt_exclude_lang;
my %Exclude_Dir      = ();
   %Exclude_Dir      = map { $_ => 1 } split(/,/, $opt_exclude_dir )
        if $opt_exclude_dir ;
die unless exclude_dir_validates(\%Exclude_Dir);
my %Include_Ext = ();
   %Include_Ext = map { $_ => 1 } split(/,/, $opt_include_ext)
        if $opt_include_ext;
my %Include_Language = (); # keys are lower case language names
   %Include_Language = map { lc($_) => 1 } split(/,/, $opt_include_lang)
        if $opt_include_lang;
# Forcibly exclude .svn, .cvs, .hg, .git, .bzr directories.  The contents of these
# directories often conflict with files of interest.
$opt_exclude_dir       = 1;
$Exclude_Dir{".svn"}   = 1;
$Exclude_Dir{".cvs"}   = 1;
$Exclude_Dir{".hg"}    = 1;
$Exclude_Dir{".git"}   = 1;
$Exclude_Dir{".bzr"}   = 1;
$Exclude_Dir{".snapshot"} = 1;  # NetApp backups
$Exclude_Dir{".config"} = 1;
$opt_count_diff        = defined $opt_count_diff ? 1 : 0;
$opt_diff              = 1  if $opt_diff_alignment    or
                               $opt_diff_list_file    or
                               $opt_diff_list_files   or
                               $opt_git_diff_rel      or
                               $opt_git_diff_all      or
                               $opt_git_diff_simindex;
$opt_force_git         = 1  if $opt_git_diff_rel      or
                               $opt_git_diff_all      or
                               $opt_git_diff_simindex;
$opt_diff_alignment    = 0  if $opt_diff_list_file;
$opt_exclude_ext       = "" unless $opt_exclude_ext;
$opt_ignore_whitespace = 0  unless $opt_ignore_whitespace;
$opt_ignore_case       = 0  unless $opt_ignore_case;
$opt_ignore_case_ext   = 0  unless $opt_ignore_case_ext;
$opt_lang_no_ext       = 0  unless $opt_lang_no_ext;
$opt_follow_links      = 0  unless $opt_follow_links;
if (defined $opt_diff_timeout) {
    # if defined but with a value of <= 0, set to 2^31-1 seconds = 68 years
    $opt_diff_timeout = 2**31-1 unless $opt_diff_timeout > 0;
} else {
    $opt_diff_timeout  =10; # seconds
}
if (defined $opt_timeout) {
    # if defined but with a value of <= 0, set to 2^31-1 seconds = 68 years
    $opt_timeout = 2**31-1 unless $opt_timeout > 0;
    # else is computed dynamically, ref $max_duration_sec
}
$opt_csv               = 0  unless defined $opt_csv;
$opt_csv               = 1  if $opt_csv_delimiter;
$ON_WINDOWS            = 1  if $opt_force_on_windows;
$ON_WINDOWS            = 0  if $opt_force_on_unix;
$opt_max_file_size     = 100 unless $opt_max_file_size;
my $HAVE_SLOCCOUNT_c_count = 0;
if (!$ON_WINDOWS and $opt_use_sloccount) {
    # Only bother doing this kludgey test is user explicitly wants
    # to use SLOCCount.  Debian based systems will hang if just doing
    #  external_utility_exists("c_count")
    # if c_count is in $PATH; c_count expects to have input.
    $HAVE_SLOCCOUNT_c_count = external_utility_exists("c_count /bin/sh");
}
if ($opt_use_sloccount) {
    if (!$HAVE_SLOCCOUNT_c_count) {
        warn "c_count could not be found; ignoring --use-sloccount\n";
        $opt_use_sloccount = 0;
    } else {
        warn "Using c_count, php_count, xml_count, pascal_count from SLOCCount\n";
        warn "--diff is disabled with --use-sloccount\n" if $opt_diff;
        warn "--count-and-diff is disabled with --use-sloccount\n" if $opt_count_diff;
        warn "--unicode is disabled with --use-sloccount\n" if $opt_unicode;
        warn "--strip-comments is disabled with --use-sloccount\n" if $opt_strip_comments;
        $opt_diff           = 0;
        $opt_count_diff     = undef;
        $opt_unicode        = 0;
        $opt_strip_comments = 0;
    }
}
$opt_vcs = 0 if $opt_force_git;

# replace Windows path separators with /
if ($ON_WINDOWS) {
    map { s{\\}{/}g } @ARGV;
    if ($opt_git) {
        # PowerShell tab expansion automatically prefixes local directories
        # with ".\" (now mapped to "./").   git ls-files output does not
        # include this.  Strip this prefix to permit clean matches. 
        map { s{^\./}{} } @ARGV;
    }
}

my @COUNT_DIFF_ARGV        = undef;
my $COUNT_DIFF_report_file = undef;
if ($opt_count_diff and !$opt_diff_list_file) {
    die "--count-and-diff requires two arguments; got ", scalar @ARGV, "\n"
        if scalar @ARGV != 2;
    # prefix with a dummy term so that $opt_count_diff is the
    # index into @COUNT_DIFF_ARGV to work on at each pass
    @COUNT_DIFF_ARGV = (undef, $ARGV[0],
                               $ARGV[1],
                              [$ARGV[0], $ARGV[1]]);  # 3rd pass: diff them
    $COUNT_DIFF_report_file = $opt_report_file if $opt_report_file;
}

# Options defaults:
$opt_quiet         =   1 if ($opt_md or $opt_json or !(-t STDOUT))
                            and !defined $opt_report_file;
$opt_progress_rate = 100 unless defined $opt_progress_rate;
$opt_progress_rate =   0 if     defined $opt_quiet;
if (!defined $opt_v) {
    $opt_v  = 0;
} elsif (!$opt_v) {
    $opt_v  = 1;
}
if (defined $opt_xsl) {
    $opt_xsl = $CLOC_XSL if $opt_xsl eq "1";
    $opt_xml = 1;
}
my $skip_generate_report = 0;
$opt_sql_style = 0 unless defined $opt_sql_style;
$opt_sql = 0 unless $opt_sql_style or defined $opt_sql;
if ($opt_sql eq "-" || $opt_sql eq "1") { # stream SQL output to STDOUT
    $opt_quiet            = 1;
    $skip_generate_report = 1;
    $opt_by_file          = 1;
    $opt_sum_reports      = 0;
    $opt_progress_rate    = 0;
} elsif ($opt_sql)  { # write SQL output to a file
    $opt_by_file          = 1;
    $skip_generate_report = 1;
    $opt_sum_reports      = 0;
}
if ($opt_sql_style) {
    $opt_sql_style = lc $opt_sql_style;
    if (!grep { lc $_ eq $opt_sql_style } qw ( Oracle Named_Columns )) {
        die "'$opt_sql_style' is not a recognized SQL style.\n";
    }
}
$opt_by_percent = '' unless defined $opt_by_percent;
if ($opt_by_percent and $opt_by_percent !~ m/^(c|cm|cb|cmb)$/i) {
    die "--by-percent must be either 'c', 'cm', 'cb', or 'cmb'\n";
}
$opt_by_percent = lc $opt_by_percent;

if (defined $opt_vcs) {
    if ($opt_vcs eq "auto") {
        if      (is_dir(".git")) {
            $opt_vcs = "git";
        } elsif (is_dir(".svn")) {
            $opt_vcs = "svn";
        } else {
            warn "--vcs auto:  unable to determine versioning system\n";
        }
    }
    if      ($opt_vcs eq "git") {
        $opt_vcs = "git ls-files";
        my @submodules = invoke_generator('git submodule status');
        foreach my $SM (@submodules) {
            $SM =~ s/^\s+//;        # may have leading space
            $SM =~ s/\(\S+\)\s*$//; # may end with something like (heads/master)
            my ($checksum, $dir) = split(' ', $SM, 2);
            $dir =~ s/\s+$//;
            $Exclude_Dir{$dir} = 1;
        }
    } elsif ($opt_vcs eq "svn") {
        $opt_vcs = "svn list -R";
    }
}

my $list_no_autogen = 0;
if (defined $opt_no_autogen and scalar @ARGV == 1 and $ARGV[0] eq "list") {
    $list_no_autogen = 1;
}
if ($opt_summary_cutoff) {
    my $error = summary_cutoff_error($opt_summary_cutoff);
    die "$error\n" if $error;
}

if (!$opt_config_file) {
    # if not explicitly given, look for a config file in other
    # possible locations
    my $other_loc = check_alternate_config_files($opt_list_file,
        $opt_exclude_list_file, $opt_read_lang_def, $opt_force_lang_def,
        $opt_diff_list_file);
    $opt_config_file = $other_loc if $other_loc;
}

die $brief_usage unless defined $opt_version         or
                        defined $opt_show_lang       or
                        defined $opt_show_ext        or
                        defined $opt_show_os         or
                        defined $opt_write_lang_def  or
                        defined $opt_write_lang_def_incl_dup  or
                        defined $opt_list_file       or
                        defined $opt_diff_list_file  or
                        defined $opt_vcs             or
                        defined $opt_xsl             or
                        defined $opt_explain         or
                        $list_no_autogen             or
                        scalar @ARGV >= 1;
if (!$opt_diff_list_file) {
    die "--diff requires two arguments; got ", scalar @ARGV, "\n"
        if $opt_diff and !$opt_sum_reports and scalar @ARGV != 2;
    die "--diff arguments are identical; nothing done", "\n"
        if $opt_diff and !$opt_sum_reports and scalar @ARGV == 2
                                           and $ARGV[0] eq $ARGV[1];
}
trick_pp_packer_encode() if $ON_WINDOWS and $opt_file_encoding;
$File::Find::dont_use_nlink = 1 if $opt_stat or top_level_SMB_dir(\@ARGV);
my @git_similarity = (); # only populated with --git-diff-simindex
my %git_metadata   = ();
get_git_metadata(\@ARGV, \%git_metadata) if $opt_force_git;
#use Data::Dumper;
#print Dumper(\%git_metadata);
replace_git_hash_with_tarfile(\@ARGV, \@git_similarity);
# 1}}}
# Step 1:  Initialize global constants.        {{{1
#
my $nFiles_Found = 0;  # updated in make_file_list
my (%Language_by_Extension, %Language_by_Script,
    %Filters_by_Language, %Not_Code_Extension, %Not_Code_Filename,
    %Language_by_File, %Scale_Factor, %Known_Binary_Archives,
    %Language_by_Prefix, %EOL_Continuation_re,
   );
my $ALREADY_SHOWED_HEADER = 0;
my $ALREADY_SHOWED_XML_SECTION = 0;
my %Error_Codes = ( 'Unable to read'                => -1,
                    'Neither file nor directory'    => -2,
                    'Diff error (quoted comments?)' => -3,
                    'Diff error, exceeded timeout'  => -4,
                    'Line count, exceeded timeout'  => -5,
                  );
my %Extension_Collision = (
    'ADSO/IDSM'                                     => [ 'adso' ] ,
    'C#/Smalltalk'                                  => [ 'cs'   ] ,
    'D/dtrace'                                      => [ 'd'    ] ,
    'F#/Forth'                                      => [ 'fs'   ] ,
    'Fortran 77/Forth'                              => [ 'f', 'for' ] ,
    'IDL/Qt Project/Prolog/ProGuard'                => [ 'pro'  ] ,
    'Lisp/Julia'                                    => [ 'jl'   ] ,
    'Lisp/OpenCL'                                   => [ 'cl'   ] ,
    'MATLAB/Mathematica/Objective-C/MUMPS/Mercury'  => [ 'm'    ] ,
    'Pascal/Puppet'                                 => [ 'pp'   ] ,
    'Perl/Prolog'                                   => [ 'pl', 'PL'  ] ,
    'PHP/Pascal'                                    => [ 'inc'  ] ,
    'Raku/Prolog'                                   => [ 'p6', 'P6'  ] ,
    'Qt/Glade'                                      => [ 'ui'   ] ,
    'TypeScript/Qt Linguist'                        => [ 'ts'   ] ,
    'Verilog-SystemVerilog/Coq'                     => [ 'v'    ] ,
    'Visual Basic/TeX/Apex Class'                   => [ 'cls'  ] ,
    'Scheme/SaltStack'                              => [ 'sls'  ] ,
);
my @Autogen_to_ignore = no_autogen_files($list_no_autogen);
if ($opt_force_lang_def) {
    # replace cloc's definitions
    read_lang_def(
        $opt_force_lang_def    , #        Sample values:
        \%Language_by_Extension, # Language_by_Extension{f}    = 'Fortran 77'
        \%Language_by_Script   , # Language_by_Script{sh}      = 'Bourne Shell'
        \%Language_by_File     , # Language_by_File{makefile}  = 'make'
        \%Filters_by_Language  , # Filters_by_Language{Bourne Shell}[0] =
                                 #      [ 'remove_matches' , '^\s*#'  ]
        \%Not_Code_Extension   , # Not_Code_Extension{jpg}     = 1
        \%Not_Code_Filename    , # Not_Code_Filename{README}   = 1
        \%Scale_Factor         , # Scale_Factor{Perl}          = 4.0
        \%EOL_Continuation_re  , # EOL_Continuation_re{C++}    = '\\$'
        );
} else {
    set_constants(               #
        \%Language_by_Extension, # Language_by_Extension{f}    = 'Fortran 77'
        \%Language_by_Script   , # Language_by_Script{sh}      = 'Bourne Shell'
        \%Language_by_File     , # Language_by_File{makefile}  = 'make'
        \%Language_by_Prefix   , # Language_by_Prefix{Dockerfile}  = 'Dockerfile'
        \%Filters_by_Language  , # Filters_by_Language{Bourne Shell}[0] =
                                 #      [ 'remove_matches' , '^\s*#'  ]
        \%Not_Code_Extension   , # Not_Code_Extension{jpg}     = 1
        \%Not_Code_Filename    , # Not_Code_Filename{README}   = 1
        \%Scale_Factor         , # Scale_Factor{Perl}          = 4.0
        \%Known_Binary_Archives, # Known_Binary_Archives{.tar} = 1
        \%EOL_Continuation_re  , # EOL_Continuation_re{C++}    = '\\$'
        );
        if ($opt_no_autogen) {
            foreach my $F (@Autogen_to_ignore) { $Not_Code_Filename{ $F } = 1; }
        }
}
if ($opt_read_lang_def) {
    # augment cloc's definitions (keep cloc's where there are overlaps)
    merge_lang_def(
        $opt_read_lang_def     , #        Sample values:
        \%Language_by_Extension, # Language_by_Extension{f}    = 'Fortran 77'
        \%Language_by_Script   , # Language_by_Script{sh}      = 'Bourne Shell'
        \%Language_by_File     , # Language_by_File{makefile}  = 'make'
        \%Filters_by_Language  , # Filters_by_Language{Bourne Shell}[0] =
                                 #      [ 'remove_matches' , '^\s*#'  ]
        \%Not_Code_Extension   , # Not_Code_Extension{jpg}     = 1
        \%Not_Code_Filename    , # Not_Code_Filename{README}   = 1
        \%Scale_Factor         , # Scale_Factor{Perl}          = 4.0
        \%EOL_Continuation_re  , # EOL_Continuation_re{C++}    = '\\$'
        );
}
if ($opt_lang_no_ext and !defined $Filters_by_Language{$opt_lang_no_ext}) {
    die_unknown_lang($opt_lang_no_ext, "--lang-no-ext")
}
check_scale_existence(\%Filters_by_Language, \%Language_by_Extension,
                      \%Scale_Factor);

my $nCounted = 0;

# Process command line provided extension-to-language mapping overrides.
# Make a hash of known languages in lower case for easier matching.
my %Recognized_Language_lc = (); # key = language name in lc, value = true name
foreach my $language (keys %Filters_by_Language) {
    my $lang_lc = lc $language;
    $Recognized_Language_lc{$lang_lc} = $language;
}
my %Forced_Extension = (); # file name extensions which user wants to count
my $All_One_Language = 0;  # set to !0 if --force-lang's <ext> is missing
foreach my $pair (@opt_force_lang) {
    my ($lang, $extension) = split(',', $pair);
    my $lang_lc = lc $lang;
    if (defined $extension) {
        $Forced_Extension{$extension} = $lang;

        die_unknown_lang($lang, "--force-lang")
            unless $Recognized_Language_lc{$lang_lc};

        $Language_by_Extension{$extension} = $Recognized_Language_lc{$lang_lc};
    } else {
        # the scary case--count everything as this language
        $All_One_Language = $Recognized_Language_lc{$lang_lc};
    }
}

foreach my $pair (@opt_script_lang) {
    my ($lang, $script_name) = split(',', $pair);
    my $lang_lc = lc $lang;
    if (!defined $script_name) {
        die "The --script-lang option requires a comma separated pair of ".
            "strings.\n";
    }

    die_unknown_lang($lang, "--script-lang")
        unless $Recognized_Language_lc{$lang_lc};

    $Language_by_Script{$script_name} = $Recognized_Language_lc{$lang_lc};
}

# If user provided a language definition file, make sure those
# extensions aren't rejected.
foreach my $ext (%Language_by_Extension) {
    next unless defined $Not_Code_Extension{$ext};
    delete $Not_Code_Extension{$ext};
}

# If user provided file extensions to ignore, add these to
# the exclusion list.
foreach my $ext (map { $_ => 1 } split(/,/, $opt_exclude_ext ) ) {
    $ext = lc $ext if $ON_WINDOWS or $opt_ignore_case_ext;
    $Not_Code_Extension{$ext} = 1;
}

# If SQL or --by-file output is requested, keep track of directory names
# generated by File::Temp::tempdir and used to temporarily hold the results
# of compressed archives.  Contents of the SQL table 't' will be much
# cleaner if these meaningless directory names are stripped from the front
# of files pulled from the archives.
my %TEMP_DIR = ();
my $TEMP_OFF =  0;  # Needed for --sdir; keep track of the number of
                    # scratch directories made in this run to avoid
                    # file overwrites by multiple extractions to same
                    # sdir.
# Also track locations where temporary installations, if necessary, of
# Algorithm::Diff and/or Regexp::Common are done.  Make sure these
# directories are not counted as inputs (ref bug #80 2012-11-23).
my %TEMP_INST = ();

# invert %Language_by_Script hash to get an easy-to-look-up list of known
# scripting languages
my %Script_Language = map { $_ => 1 } values %Language_by_Script ;
# 1}}}
# Step 2:  Early exits for display, summation. {{{1
#
print_extension_info(   $opt_show_ext     ) if defined $opt_show_ext ;
print_language_info(    $opt_show_lang, '') if defined $opt_show_lang;
print_language_filters( $opt_explain      ) if defined $opt_explain  ;
exit if (defined $opt_show_ext)  or
        (defined $opt_show_lang) or
        (defined $opt_explain)   or
        $list_no_autogen;

Top_of_Processing_Loop:
# Sorry, coding purists.  Using a goto to implement --count-and-diff
# which has to do three passes over the main code, starting with
# a clean slate each time.
if ($opt_count_diff) {
    @ARGV = ( $COUNT_DIFF_ARGV[ $opt_count_diff ] );
    if ($opt_count_diff == 3) {
        $opt_diff = 1;
        @ARGV = @{$COUNT_DIFF_ARGV[ $opt_count_diff ]}; # last arg is list of list
    } elsif ($opt_diff_list_files) {
        $opt_diff = 0;
    }
    if ($opt_report_file) {
        # Instead of just one output file, will have three.
        # Keep their names unique otherwise results are clobbered.
        # Replace file path separators with underscores otherwise
        # may end up with illegal file names.
        my ($fn_0, $fn_1) = (undef, undef);
        if ($ON_WINDOWS) {
            ($fn_0 = $ARGV[0]) =~ s{\\}{_}g;
             $fn_0 =~ s{:}{_}g;
             $fn_0 =~ s{/}{_}g;
            ($fn_1 = $ARGV[1]) =~ s{\\}{_}g if defined $ARGV[1];
             $fn_1 =~ s{:}{_}g              if defined $ARGV[1];
             $fn_1 =~ s{/}{_}g              if defined $ARGV[1];
        } else {
            ($fn_0 = $ARGV[0]) =~ s{/}{_}g;
            ($fn_1 = $ARGV[1]) =~ s{/}{_}g  if defined $ARGV[1];
        }

        if      ($opt_count_diff == 3) {
            $opt_report_file = $COUNT_DIFF_report_file . ".diff.$fn_0.$fn_1";
        } else {
            $opt_report_file = $COUNT_DIFF_report_file . ".$fn_0";
        }
    } else {
        # STDOUT; print a header showing what it's working on
        if ($opt_count_diff == 3) {
            print "\ndiff $ARGV[0] $ARGV[1]::\n";
        } else {
            print "\n" if $opt_count_diff > 1;
            print "$ARGV[0]::\n";
        }
    }
    $ALREADY_SHOWED_HEADER      = 0;
    $ALREADY_SHOWED_XML_SECTION = 0;
}

#print "Before glob have [", join(",", @ARGV), "]\n";
@ARGV = windows_glob(@ARGV) if $ON_WINDOWS;
#print "after  glob have [", join(",", @ARGV), "]\n";

# filter out archive files if requested to do so
if (defined $opt_skip_archive) {
    my @non_archive = ();
    foreach my $candidate (@ARGV) {
        if ($candidate !~ m/${opt_skip_archive}$/) {
            push @non_archive, $candidate;

        }
    }
    @ARGV = @non_archive;
}

if ($opt_sum_reports and $opt_diff) {
    my @results = ();
    if ($opt_csv and !defined($opt_csv_delimiter)) {
        $opt_csv_delimiter = ",";
    }
    if ($opt_list_file) { # read inputs from the list file
        my @list = read_list_file($opt_list_file);
        if ($opt_csv) {
            @results = combine_csv_diffs($opt_csv_delimiter, \@list);
        } else {
            @results = combine_diffs(\@list);
        }
    } elsif ($opt_vcs) { # read inputs from the VCS generator
        my @list = invoke_generator($opt_vcs, \@ARGV);
        if ($opt_csv) {
            @results = combine_csv_diffs($opt_csv_delimiter, \@list);
        } else {
            @results = combine_diffs(\@list);
        }
    } else { # get inputs from the command line
        if ($opt_csv) {
            @results = combine_csv_diffs($opt_csv_delimiter, \@ARGV);
        } else {
            @results = combine_diffs(\@ARGV);
        }
    }
    if ($opt_report_file) {
        write_file($opt_report_file, {}, @results);
    } else {
        print "\n", join("\n", @results), "\n";
    }
    exit;
}
if ($opt_sum_reports) {
    my %Results = ();
    foreach my $type( "by language", "by report file" ) {
        my $found_lang = undef;
        if ($opt_list_file or $opt_vcs) {
            # read inputs from the list file
            my @list;
            if ($opt_vcs) {
                @list = invoke_generator($opt_vcs, \@ARGV);
            } else {
                @list = read_list_file($opt_list_file);
            }
            $found_lang = combine_results(\@list,
                                           $type,
                                          \%{$Results{ $type }},
                                          \%Filters_by_Language );
        } else { # get inputs from the command line
            $found_lang = combine_results(\@ARGV,
                                           $type,
                                          \%{$Results{ $type }},
                                          \%Filters_by_Language );
        }
        next unless %Results;
        my $end_time = get_time();
        my @results  = generate_report($VERSION, $end_time - $start_time,
                                       $type,
                                      \%{$Results{ $type }}, \%Scale_Factor);
        if ($opt_report_file) {
            my $ext  = ".lang";
               $ext  = ".file" unless $type eq "by language";
            next if !$found_lang and  $ext  eq ".lang";
            write_file($opt_report_file . $ext, {}, @results);
        } else {
            print "\n", join("\n", @results), "\n";
        }
    }
    exit;
}
if ($opt_write_lang_def or $opt_write_lang_def_incl_dup) {
    my $file = $opt_write_lang_def          if $opt_write_lang_def;
       $file = $opt_write_lang_def_incl_dup if $opt_write_lang_def_incl_dup;
    write_lang_def($file                 ,
                  \%Language_by_Extension,
                  \%Language_by_Script   ,
                  \%Language_by_File     ,
                  \%Filters_by_Language  ,
                  \%Not_Code_Extension   ,
                  \%Not_Code_Filename    ,
                  \%Scale_Factor         ,
                  \%EOL_Continuation_re  ,
                  );
    exit;
}
if ($opt_show_os) {
    if ($ON_WINDOWS) {
        print "Windows\n";
    } else {
        print "UNIX\n";
    }
    exit;
}

my $max_processes = get_max_processes();

# 1}}}
# Step 3:  Create a list of files to consider. {{{1
#  a) If inputs are binary archives, first cd to a temp
#     directory, expand the archive with the user-given
#     extraction tool, then add the temp directory to
#     the list of dirs to process.
#  b) Create a list of every file that might contain source
#     code.  Ignore binary files, zero-sized files, and
#     any file in a directory the user says to exclude.
#  c) Determine the language for each file in the list.
#
my @binary_archive = ();
my $cwd            = cwd();
if ($opt_extract_with) {
#print "cwd main = [$cwd]\n";
    my @extract_location = ();
    foreach my $bin_file (@ARGV) {
        my $extract_dir = undef;
        if ($opt_sdir) {
            ++$TEMP_OFF;
            $extract_dir = "$opt_sdir/$TEMP_OFF";
            File::Path::rmtree($extract_dir) if     is_dir($extract_dir);
            File::Path::mkpath($extract_dir) unless is_dir($extract_dir);
        } else {
            $extract_dir = tempdir( CLEANUP => 1 );  # 1 = delete on exit
        }
        $TEMP_DIR{ $extract_dir } = 1 if $opt_sql or $opt_by_file;
        print "mkdir $extract_dir\n"  if $opt_v;
        print "cd    $extract_dir\n"  if $opt_v;
        chdir $extract_dir;
        my $bin_file_full_path = "";
        if (File::Spec->file_name_is_absolute( $bin_file )) {
            $bin_file_full_path = $bin_file;
#print "bin_file_full_path (was ful) = [$bin_file_full_path]\n";
        } else {
            $bin_file_full_path = File::Spec->catfile( $cwd, $bin_file );
#print "bin_file_full_path (was rel) = [$bin_file_full_path]\n";
        }
        my     $extract_cmd = uncompress_archive_cmd($bin_file_full_path);
        print  $extract_cmd, "\n" if $opt_v;
        system $extract_cmd;
        push @extract_location, $extract_dir;
        chdir $cwd;
    }
    # It is possible that the binary archive itself contains additional
    # files compressed the same way (true for Java .ear files).  Go
    # through all the files that were extracted, see if they are binary
    # archives and try to extract them.  Lather, rinse, repeat.
    my $binary_archives_exist = 1;
    my $count_binary_archives = 0;
    my $previous_count        = 0;
    my $n_pass                = 0;
    while ($binary_archives_exist) {
        @binary_archive = ();
        foreach my $dir (@extract_location) {
            find(\&archive_files, $dir);  # populates global @binary_archive
        }
        foreach my $archive (@binary_archive) {
            my $extract_dir = undef;
            if ($opt_sdir) {
                ++$TEMP_OFF;
                $extract_dir = "$opt_sdir/$TEMP_OFF";
                File::Path::rmtree($extract_dir) if     is_dir($extract_dir);
                File::Path::mkpath($extract_dir) unless is_dir($extract_dir);
            } else {
                $extract_dir = tempdir( CLEANUP => 1 );  # 1 = delete on exit
            }
            $TEMP_DIR{ $extract_dir } = 1 if $opt_sql or $opt_by_file;
            print "mkdir $extract_dir\n"  if $opt_v;
            print "cd    $extract_dir\n"  if $opt_v;
            chdir  $extract_dir;

            my     $extract_cmd = uncompress_archive_cmd($archive);
            print  $extract_cmd, "\n" if $opt_v;
            system $extract_cmd;
            push @extract_location, $extract_dir;
            unlink $archive;  # otherwise will be extracting it forever
        }
        $count_binary_archives = scalar @binary_archive;
        if ($count_binary_archives == $previous_count) {
            $binary_archives_exist = 0;
        }
        $previous_count = $count_binary_archives;
    }
    chdir $cwd;

    @ARGV = @extract_location;
} else {
    # see if any of the inputs need to be auto-uncompressed &/or expanded
    my @updated_ARGS = ();
    replace_git_hash_with_tarfile(\@ARGV, \@git_similarity) if $opt_force_git;
    foreach my $Arg (@ARGV) {
        if (is_dir($Arg)) {
            push @updated_ARGS, $Arg;
            next;
        }
        my $full_path = "";
        if (File::Spec->file_name_is_absolute( $Arg )) {
            $full_path = $Arg;
        } else {
            $full_path = File::Spec->catfile( $cwd, $Arg );
        }
#print "full_path = [$full_path]\n";
        my $extract_cmd = uncompress_archive_cmd($full_path);
        if ($extract_cmd) {
            my $extract_dir = undef;
            if ($opt_sdir) {
                ++$TEMP_OFF;
                $extract_dir = "$opt_sdir/$TEMP_OFF";
                File::Path::rmtree($extract_dir) if     is_dir($extract_dir);
                File::Path::mkpath($extract_dir) unless is_dir($extract_dir);
            } else {
                $extract_dir = tempdir( CLEANUP => 1 ); # 1 = delete on exit
            }
            $TEMP_DIR{ $extract_dir } = 1 if $opt_sql or $opt_by_file;
            print "mkdir $extract_dir\n"  if $opt_v;
            print "cd    $extract_dir\n"  if $opt_v;
            chdir  $extract_dir;
            print  $extract_cmd, "\n" if $opt_v;
            system $extract_cmd;
            push @updated_ARGS, $extract_dir;
            chdir $cwd;
        } else {
            # this is a conventional, uncompressed, unarchived file
            # or a directory; keep as-is
            push @updated_ARGS, $Arg;
        }
    }
    @ARGV = @updated_ARGS;

    # make sure we're not counting any directory containing
    # temporary installations of Regexp::Common, Algorithm::Diff
    foreach my $d (sort keys %TEMP_INST) {
        foreach my $a (@ARGV) {
            next unless is_dir($a);
            if ($opt_v > 2) {
                printf "Comparing %s (location of %s) to input [%s]\n",
                        $d, $TEMP_INST{$d}, $a;
            }
            if ($a eq $d) {
                die "File::Temp::tempdir chose directory ",
                    $d, " to install ", $TEMP_INST{$d}, " but this ",
                    "matches one of your input directories.  Rerun ",
                    "with --sdir and supply a different temporary ",
                    "directory for ", $TEMP_INST{$d}, "\n";
            }
        }
    }
}
# 1}}}
my @Errors    = ();
my @file_list = ();  # global variable updated in files()
my %Ignored   = ();  # files that are not counted (language not recognized or
                     # problems reading the file)
my @Lines_Out = ();
my %upper_lower_map = ();  # global variable (needed only on Windows) to
                           # track case of original filename, populated in
                           # make_file_list() if $ON_WINDOWS
if ($opt_diff) {
# Step 4:  Separate code from non-code files.  {{{1
my @fh            = ();
my @files_for_set = ();
my @files_added_tot = ();
my @files_removed_tot = ();
my @file_pairs_tot = ();
# make file lists for each separate argument
if ($opt_diff_list_file) {
    @files_for_set = ( (), () );
    file_pairs_from_file($opt_diff_list_file, # in
                        \@files_added_tot   , # out
                        \@files_removed_tot , # out
                        \@file_pairs_tot    , # out
                       );
    foreach my $F (@files_added_tot) {
        if ($ON_WINDOWS) {
            (my $lc = lc $F) =~ s{\\}{/}g;
            $upper_lower_map{$lc} = $F;
            $F = $lc;
        }
        push @{$files_for_set[1]}, $F;
    }
    foreach my $F (@files_removed_tot) {
        if ($ON_WINDOWS) {
            (my $lc = lc $F) =~ s{\\}{/}g;
            $upper_lower_map{$lc} = $F;
            $F = $lc;
        }
        push @{$files_for_set[0]}, $F;
    }
    foreach my $pair (@file_pairs_tot) {
        if ($ON_WINDOWS) {
            push @{$files_for_set[0]}, lc $pair->[0];
            push @{$files_for_set[1]}, lc $pair->[1];
        } else {
            push @{$files_for_set[0]}, $pair->[0];
            push @{$files_for_set[1]}, $pair->[1];
        }
    }
    @ARGV = (1, 2); # place holders
}
for (my $i = 0; $i < scalar @ARGV; $i++) {
    if ($opt_diff_list_file) {
        push @fh, make_file_list($files_for_set[$i], $i+1,
                                \%Error_Codes, \@Errors, \%Ignored);
        @{$files_for_set[$i]} = @file_list;
    } elsif ($opt_diff_list_files) {
        my @list_files = read_list_file($ARGV[$i]);
        push @fh, make_file_list(\@list_files, $i+1,
                                \%Error_Codes, \@Errors, \%Ignored);
        @{$files_for_set[$i]} = @file_list;
    } else {
        push @fh, make_file_list([ $ARGV[$i] ], $i+1,
                                \%Error_Codes, \@Errors, \%Ignored);
        @{$files_for_set[$i]} = @file_list;
    }
    if ($opt_exclude_list_file) {
        # note: process_exclude_list_file() references global @file_list
        process_exclude_list_file($opt_exclude_list_file,
                                 \%Exclude_Dir,
                                 \%Ignored);
    }
    if ($opt_no_autogen) {
        exclude_autogenerated_files(\@{$files_for_set[$i]},  # in/out
                                    \%Error_Codes, \@Errors, \%Ignored);
    }
    @file_list = ();
}
# 1}}}
# Step 5:  Remove duplicate files.             {{{1
#
my %Language           = ();
my %unique_source_file = ();
my $n_set = 0;
foreach my $FH (@fh) {  # loop over each pair of file sets
    ++$n_set;
    remove_duplicate_files($FH,
                               \%{$Language{$FH}}               ,
                               \%{$unique_source_file{$FH}}     ,
                          \%Error_Codes                         ,
                               \@Errors                         ,
                               \%Ignored                        );
    if ($opt_exclude_content) {
        exclude_by_regex($opt_exclude_content,              # in
                        \%{$unique_source_file{$FH}},       # in/out
                        \%Ignored);                         # out
    } elsif ($opt_include_content) {
        include_by_regex($opt_include_content,              # in
                        \%{$unique_source_file{$FH}},       # in/out
                        \%Ignored);                         # out
    }

    if ($opt_include_lang) {
        # remove files associated with languages not
        # specified by --include-lang
        my @delete_file = ();
        foreach my $file (keys %{$unique_source_file{$FH}}) {
            my $keep_file = 0;
            foreach my $keep_lang (keys %Include_Language) {
                if (lc($Language{$FH}{$file}) eq $keep_lang) {
                    $keep_file = 1;
                    last;
                }
            }
            next if $keep_file;
            push @delete_file, $file;
        }
        foreach my $file (@delete_file) {
            delete $Language{$FH}{$file};
        }
    }

    printf "%2d: %8d unique file%s.                          \r",
        $n_set,
        plural_form(scalar keys %unique_source_file)
        unless $opt_quiet;
}
# 1}}}
# Step 6:  Count code, comments, blank lines.  {{{1
#
my %Results_by_Language = ();
my %Results_by_File     = ();
my %Delta_by_Language   = ();
my %Delta_by_File       = ();

my %alignment = ();

my $fset_a = $fh[0];
my $fset_b = $fh[1];

my $n_filepairs_compared = 0;
my $tot_counted = 0;

if ( scalar @fh != 2 ) {
    print "Error: incorrect length fh array when preparing diff at step 6.\n";
    exit 1;
}
if (!$opt_diff_list_file) {
    align_by_pairs(\%{$unique_source_file{$fset_a}}      , # in
                   \%{$unique_source_file{$fset_b}}      , # in
                   \@files_added_tot                     , # out
                   \@files_removed_tot                   , # out
                   \@file_pairs_tot                      , # out
                  );
}

#use Data::Dumper;
#print "added : ", Dumper(\@files_added_tot);
#print "removed : ", Dumper(\@files_removed_tot);
#print "pairs : ", Dumper(\@file_pairs_tot);

if ( $max_processes == 0) {
    # Multiprocessing is disabled
    my $part = count_filesets ( $fset_a, $fset_b, \@files_added_tot,
                               \@files_removed_tot, \@file_pairs_tot,
                               0, \%Language, \%Ignored);
    %Results_by_File = %{$part->{'results_by_file'}};
    %Results_by_Language= %{$part->{'results_by_language'}};
    %Delta_by_File = %{$part->{'delta_by_file'}};
    %Delta_by_Language= %{$part->{'delta_by_language'}};
    %Ignored = ( %Ignored, %{$part->{'ignored'}});
    %alignment = %{$part->{'alignment'}};
    $n_filepairs_compared = $part->{'n_filepairs_compared'};
    push ( @Errors, @{$part->{'errors'}});
} else {
    # Multiprocessing is enabled
    # Do not create more processes than the amount of data to be processed
    my $num_processes = min(max(scalar @files_added_tot,
                                scalar @files_removed_tot,
                                scalar @file_pairs_tot),
                            $max_processes);
    # ... but use at least one process.
       $num_processes = 1
            if $num_processes == 0;
    # Start processes for counting
    my $pm = Parallel::ForkManager->new($num_processes);
    # When processes finish, they will use the embedded subroutine for
    # merging the data into global variables.
    $pm->run_on_finish ( sub {
        my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $part) = @_;
        my $part_ignored = $part->{'ignored'};
        my $part_result_by_file = $part->{'results_by_file'};
        my $part_result_by_language = $part->{'results_by_language'};
        my $part_delta_by_file = $part->{'delta_by_file'};
        my $part_delta_by_language = $part->{'delta_by_language'};
        my $part_alignment = $part->{'alignment'};
        my $part_errors = $part->{'errors'};
           $tot_counted += scalar keys %$part_result_by_file;
           $n_filepairs_compared += $part->{'n_filepairs_compared'};
        # Since files are processed by multiple processes, we can't measure
        # the number of processed files exactly. We approximate this by showing
        # the number of files counted by finished processes.
        printf "Counting:  %d\r", $tot_counted
                 if $opt_progress_rate;

        foreach my $this_language ( keys %$part_result_by_language ) {
            my $counts = $part_result_by_language->{$this_language};
            foreach my $inner_key ( keys %$counts ) {
                $Results_by_Language{$this_language}{$inner_key} +=
                    $counts->{$inner_key};
            }
        }

        foreach my $this_language ( keys %$part_delta_by_language ) {
            my $counts = $part_delta_by_language->{$this_language};
            foreach my $inner_key ( keys %$counts ) {
                my $statuses = $counts->{$inner_key};
                foreach my $inner_status ( keys %$statuses ) {
                    $Delta_by_Language{$this_language}{$inner_key}{$inner_status} +=
                          $counts->{$inner_key}->{$inner_status};
                }
            }
        }

        foreach my $label ( keys %$part_alignment ) {
            my $inner = $part_alignment->{$label};
            foreach my $key ( keys %$inner ) {
                $alignment{$label}{$key} = 1;
            }
        }

        %Results_by_File = ( %Results_by_File, %$part_result_by_file );
        %Delta_by_File = ( %Delta_by_File, %$part_delta_by_file );
        %Ignored = (%Ignored, %$part_ignored );
        push ( @Errors, @$part_errors );
    } );

    my $num_filepairs_per_part = ceil ( ( scalar @file_pairs_tot ) / $num_processes );
    my $num_filesremoved_per_part = ceil ( ( scalar @files_removed_tot ) / $num_processes );
    my $num_filesadded_per_part = ceil ( ( scalar @files_added_tot ) / $num_processes );

    while ( 1 ) {
        my @files_added_part = splice @files_added_tot, 0, $num_filesadded_per_part;
        my @files_removed_part = splice @files_removed_tot, 0, $num_filesremoved_per_part;
        my @filepairs_part = splice @file_pairs_tot, 0, $num_filepairs_per_part;
        if ( scalar @files_added_part == 0 and scalar @files_removed_part == 0 and
             scalar @filepairs_part == 0 ) {
            last;
        }

        $pm->start() and next;
        my $count_result = count_filesets ( $fset_a, $fset_b,
            \@files_added_part, \@files_removed_part,
            \@filepairs_part, 1, \%Language, \%Ignored );
        $pm->finish(0 , $count_result);
    }
    # Wait for processes to finish
    $pm->wait_all_children();
}

# Write alignment data, if needed
if ($opt_diff_alignment) {
    write_alignment_data ( $opt_diff_alignment, $n_filepairs_compared, \%alignment ) ;
}

my $separator = defined $opt_csv_delimiter ? $opt_csv_delimiter : ": ";
my @ignored_reasons = map { "${_}${separator} $Ignored{$_}" } sort keys %Ignored;
write_file($opt_ignored, {"file_type" => "ignored",
                          "separator" => ": ",
                          "columns"   => ["file", "reason"],
                         }, @ignored_reasons   ) if $opt_ignored;
write_file($opt_counted, {}, sort keys %Results_by_File) if $opt_counted;
# 1}}}
# Step 7:  Assemble results.                   {{{1
#
my $end_time = get_time();
printf "%8d file%s ignored.                           \n",
    plural_form(scalar keys %Ignored) unless $opt_quiet;
print_errors(\%Error_Codes, \@Errors) if @Errors;
if (!%Delta_by_Language) {
    print "Nothing to count.\n";
    exit;
}

if ($opt_by_file) {
    @Lines_Out = diff_report($VERSION, get_time() - $start_time,
                            "by file",
                            \%Delta_by_File, \%Scale_Factor);
} else {
    @Lines_Out = diff_report($VERSION, get_time() - $start_time,
                            "by language",
                            \%Delta_by_Language, \%Scale_Factor);
}

# 1}}}
} else {
# Step 4:  Separate code from non-code files.  {{{1
if ($opt_exclude_list_file) {
    # note: process_exclude_list_file() references global @file_list
    process_exclude_list_file($opt_exclude_list_file,
                             \%Exclude_Dir,
                             \%Ignored);
}
my $fh = 0;
if ($opt_list_file or $opt_diff_list_files or $opt_vcs) {
    my @list;
    if ($opt_vcs) {
        @list = invoke_generator($opt_vcs, \@ARGV);
    } elsif ($opt_list_file) {
        @list = read_list_file($opt_list_file);
    } else {
        @list = read_list_file($ARGV[0]);
    }
    $fh = make_file_list(\@list, 0, \%Error_Codes, \@Errors, \%Ignored);
} else {
    $fh = make_file_list(\@ARGV, 0, \%Error_Codes, \@Errors, \%Ignored);
    #     make_file_list populates global variable @file_list via call to
    #     File::Find's find() which in turn calls files()
}
if ($opt_skip_win_hidden and $ON_WINDOWS) {
    my @file_list_minus_hidden = ();
    # eval code to run on Unix without 'missing Win32::File module' error.
    my $win32_file_invocation = '
        use Win32::File;
        foreach my $F (@file_list) {
            my $attr = undef;
            Win32::File::GetAttributes($F, $attr);
            if ($attr & HIDDEN) {
                $Ignored{$F} = "Windows hidden file";
                print "Ignoring $F since it is a Windows hidden file\n"
                    if $opt_v > 1;
            } else {
                push @file_list_minus_hidden, $F;
            }
        }';
    eval $win32_file_invocation;
    @file_list = @file_list_minus_hidden;
}
if ($opt_no_autogen) {
    exclude_autogenerated_files(\@file_list,  # in/out
                                \%Error_Codes, \@Errors, \%Ignored);
}
#printf "%8d file%s excluded.                     \n",
#   plural_form(scalar keys %Ignored)
#   unless $opt_quiet;
# die print ": ", join("\n: ", @file_list), "\n";
# 1}}}
# Step 5:  Remove duplicate files.             {{{1
#
my %Language           = ();
my %unique_source_file = ();
remove_duplicate_files($fh                          ,   # in
                           \%Language               ,   # out
                           \%unique_source_file     ,   # out
                      \%Error_Codes                 ,   # in
                           \@Errors                 ,   # out
                           \%Ignored                );  # out
if ($opt_exclude_content) {
    exclude_by_regex($opt_exclude_content,              # in
                    \%unique_source_file ,              # in/out
                    \%Ignored);                         # out
} elsif ($opt_include_content) {
    include_by_regex($opt_include_content,              # in
                    \%unique_source_file ,              # in/out
                    \%Ignored);                         # out
}
printf "%8d unique file%s.                              \n",
    plural_form(scalar keys %unique_source_file)
    unless $opt_quiet;
# 1}}}
# Step 6:  Count code, comments, blank lines.  {{{1
#
my %Results_by_Language = ();
my %Results_by_File     = ();
my @results_parts  = ();
my @sorted_files = sort keys %unique_source_file;

if ( $max_processes == 0) {
    # Multiprocessing is disabled
    my $part = count_files ( \@sorted_files , 0, \%Language);
    %Results_by_File = %{$part->{'results_by_file'}};
    %Results_by_Language= %{$part->{'results_by_language'}};
    %Ignored = ( %Ignored, %{$part->{'ignored'}});
    push ( @Errors, @{$part->{'errors'}});
} else {
    # Do not create more processes than the number of files to be processed
    my $num_files = scalar @sorted_files;
    my $num_processes = $num_files >= $max_processes ? $max_processes : $num_files;
    # Use at least one process.
       $num_processes = 1
            if $num_processes == 0;
    # Start processes for counting
    my $pm = Parallel::ForkManager->new($num_processes);
    # When processes finish, they will use the embedded subroutine for
    # merging the data into global variables.
    $pm->run_on_finish ( sub {
        my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $part) = @_;
        my $part_ignored = $part->{'ignored'};
        my $part_result_by_file = $part->{'results_by_file'};
        my $part_result_by_language = $part->{'results_by_language'};
        my $part_errors = $part->{'errors'};
        my $nCounted+= scalar keys %$part_result_by_file;
        # Since files are processed by multiple processes, we can't measure
        # the number of processed files exactly. We approximate this by showing
        # the number of files counted by finished processes.
        printf "Counting:  %d\r", $nCounted
                 if $opt_progress_rate;

        foreach my $this_language ( keys %$part_result_by_language ) {
            my $counts = $part_result_by_language->{$this_language};
            foreach my $inner_key ( keys %$counts ) {
                $Results_by_Language{$this_language}{$inner_key} +=
                    $counts->{$inner_key};
            }
        }
        %Results_by_File = ( %Results_by_File, %$part_result_by_file );
        %Ignored = (%Ignored, %$part_ignored);
        push ( @Errors, @$part_errors);
    } );
    my $num_files_per_part = ceil ( ( scalar @sorted_files ) / $num_processes );
    while ( my @part = splice @sorted_files, 0 , $num_files_per_part ) {
        $pm->start() and next;
        my $count_result = count_files ( \@part, 1, \%Language );
        $pm->finish(0 , $count_result);
    }
    # Wait for processes to finish
    $pm->wait_all_children();
}

my $separator = defined $opt_csv_delimiter ? $opt_csv_delimiter : ": ";
my @ignored_reasons = map { "${_}${separator} $Ignored{$_}" } sort keys %Ignored;
write_file($opt_ignored, {"file_type" => "ignored",
                          "separator" => $separator,
                          "columns"   => ["file", "reason"],
                         }, @ignored_reasons   ) if $opt_ignored;
if ($opt_summary_cutoff) {
    %Results_by_Language = apply_cutoff($opt_summary_cutoff,
                                       \%Results_by_Language);
}
write_file($opt_counted, {}, sort keys %Results_by_File) if $opt_counted;
# 1}}}
# Step 7:  Assemble results.                   {{{1
#
my $end_time = get_time();
printf "%8d file%s ignored.\n", plural_form(scalar keys %Ignored)
    unless $opt_quiet;
print_errors(\%Error_Codes, \@Errors) if @Errors;
if (!%Results_by_Language) {
    write_null_results($opt_json, $opt_xml, $opt_report_file);
    exit;
}

generate_sql($end_time - $start_time,
            \%Results_by_File, \%Scale_Factor) if $opt_sql;

exit if $skip_generate_report;
if      ($opt_by_file_by_lang) {
    push @Lines_Out, generate_report( $VERSION, $end_time - $start_time,
                                      "by file",
                                      \%Results_by_File,    \%Scale_Factor);
    push @Lines_Out, generate_report( $VERSION, $end_time - $start_time,
                                      "by language",
                                      \%Results_by_Language, \%Scale_Factor);
} elsif ($opt_by_file) {
    push @Lines_Out, generate_report( $VERSION, $end_time - $start_time,
                                      "by file",
                                      \%Results_by_File,    \%Scale_Factor);
} else {
    push @Lines_Out, generate_report( $VERSION, $end_time - $start_time,
                                      "by language",
                                      \%Results_by_Language, \%Scale_Factor);
}
# 1}}}
}
if ($opt_report_file) { write_file($opt_report_file, {}, @Lines_Out); }
else {
    print "\n" unless $opt_quiet;
    print join("\n", @Lines_Out), "\n";
}
if ($opt_count_diff) {
    ++$opt_count_diff;
    exit if $opt_count_diff > 3;
    goto Top_of_Processing_Loop;
}
sub summary_cutoff_error {                   # {{{
    my ($parameter) = @_;
    print "-> summary_cutoff_is_ok($parameter)\n" if $opt_v > 2;
    my %known_keys = ( 'c' => 1, 'f' => 1, 'm' => 1, 'cm' => 1 );
    my $result = "";
    my $by_pct = 0;
    my ($key, $value);
    if ($parameter !~ /:/) {
        $result = "expected a colon in --summary-cutoff argument";
    } else {
        ($key, $value) = split(':', $parameter, 2);
        if ($value =~ /%$/) {
            $by_pct = 1;
            $value =~ s/%$//;
        }
        if (!$known_keys{$key}) {
            $result = "--summary-cutoff argument:  '$key' is not 'c', 'f', 'm' or 'cm'";
        }
        if ($value !~ /^\d+(\.\d*)?$/) {
            $result = "--summary-cutoff argument:  '$value' is not a number";
        }
    }
    print "<- summary_cutoff_is_ok($result)\n" if $opt_v > 2;
    return $result;
} # 1}}}
sub apply_cutoff {                           # {{{1
    my ($criterion,
        $rhh_by_lang) = @_;

    my %aggregated_Results_by_Language = ();
    my $by_pct = 0;
    my ($key, $value) = split(':', $criterion, 2);
    if ($value =~ /%$/) {
        $by_pct = 1;
        $value =~ s/%$//;
    }

    my %sum = ();
    if ($by_pct) {
        foreach my $lang (keys %{$rhh_by_lang}) {
            foreach my $category (qw(nFiles comment blank code)) {
                $sum{$category} += $rhh_by_lang->{$lang}{$category};
            }
        }
        if      ($key eq 'c') {
            $value *= $sum{'code'}/100;
        } elsif ($key eq 'f') {
            $value *= $sum{'nFiles'}/100;
        } elsif ($key eq 'm') {
            $value *= $sum{'comment'}/100;
        } elsif ($key eq 'cm') {
            $value *= ($sum{'code'} + $sum{'comment'})/100;
        }
    }

    foreach my $lang (keys %{$rhh_by_lang}) {
        my %sum = ();
        my $agg_lang = $lang;
        if      ($key eq 'c') {
            $agg_lang = 'Other' if $rhh_by_lang->{$lang}{'code'}    <= $value;
        } elsif ($key eq 'f') {
            $agg_lang = 'Other' if $rhh_by_lang->{$lang}{'nFiles'}  <= $value;
        } elsif ($key eq 'm') {
            $agg_lang = 'Other' if $rhh_by_lang->{$lang}{'comment'} <= $value;
        } elsif ($key eq 'cm') {
            $agg_lang = 'Other' if $rhh_by_lang->{$lang}{'code'} +
                                      $rhh_by_lang->{$lang}{'comment'} <= $value;
        }
        foreach my $category (qw(nFiles comment blank code)) {
            $aggregated_Results_by_Language{$agg_lang}{$category} +=
                $rhh_by_lang->{$lang}{$category};
        }
    }

    return %aggregated_Results_by_Language;
} # 1}}}
sub exclude_by_regex {                       # {{{1
    my ($regex,
        $rh_unique_source_file, # in/out
        $rh_ignored           , # out
       ) = @_;
    my @exclude = ();
    foreach my $file (keys %{$rh_unique_source_file}) {
        my $line_num = 0;
        foreach my $line (read_file($file)) {
            ++$line_num;
            if ($line =~ /$regex/) {
                $rh_ignored->{$file} = "line $line_num match for --exclude-content=$regex";
                push @exclude, $file;
                last;
            }
        }
    }
    foreach my $file (@exclude) {
        delete $rh_unique_source_file->{$file};
    }
} # 1}}}
sub include_by_regex {                       # {{{1
    my ($regex,
        $rh_unique_source_file, # in/out
        $rh_ignored           , # out
       ) = @_;
    my @exclude = ();
    foreach my $file (keys %{$rh_unique_source_file}) {
        my $keep_this_one = 0;
        foreach my $line (read_file($file)) {
            if ($line =~ /$regex/) {
                $keep_this_one = 1;
                last;
            }
        }
        if (!$keep_this_one) {
            $rh_ignored->{$file} = "does not satisfy --include-content=$regex";
            push @exclude, $file;
        }
    }
    foreach my $file (@exclude) {
        delete $rh_unique_source_file->{$file};
    }
} # 1}}}
sub get_max_processes {                      # {{{1
    # If user has specified valid number of processes, use that.
    if (defined $opt_processes) {
        eval "use Parallel::ForkManager 0.7.6;";
        if ( defined $Parallel::ForkManager::VERSION ) {
            $HAVE_Parallel_ForkManager = 1;
        }
        if ( $opt_processes !~ /^\d+$/ ) {
            print "Error: processes option argument must be numeric.\n";
            exit 1;
        }
        elsif ( $opt_processes >0 and ! $HAVE_Parallel_ForkManager ) {
            print "Error: cannot use multiple processes, because " .
                  "Parallel::ForkManager is not installed, or the version is too old.\n";
            exit 1;
        }
    elsif ( $opt_processes >0 and $ON_WINDOWS ) {
            print "Error: cannot use multiple processes on Windows systems.\n";
            exit 1;
        }
        else {
            return $opt_processes;
        }
    }

    # Disable multiprocessing on Windows - does not work reliably
    if ($ON_WINDOWS) {
        return 0;
    }

    # Disable multiprocessing if Parallel::ForkManager is not available
    if ( ! $HAVE_Parallel_ForkManager ) {
        return 0;
    }

    # Set to number of cores on Linux
    if ( $^O =~ /linux/i and -x '/usr/bin/nproc' ) {
        my $numavcores_linux = `/usr/bin/nproc`;
        chomp $numavcores_linux;
        if ( $numavcores_linux =~ /^\d+$/ ) {
            return $numavcores_linux;
        }
    }

    # Set to number of cores on macOS
    if ( $^O =~ /darwin/i and -x '/usr/sbin/sysctl') {
       my $numavcores_macos = `/usr/sbin/sysctl -n hw.physicalcpu`;
       chomp $numavcores_macos;
       if ($numavcores_macos =~ /^\d+$/ ) {
           return $numavcores_macos;
       }
    }

    # Disable multiprocessing in other cases
    return 0;
} # 1}}}
sub exclude_autogenerated_files {            # {{{1
    my ($ra_file_list, # in/out
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
        $rh_Ignored  , # out
       ) = @_;
    print "-> exclude_autogenerated_files()\n" if $opt_v > 2;
    my @file_list_minus_autogen = ();
    foreach my $file (@{$ra_file_list}) {
        if ($file !~ /\.go$/) {
            # at the moment, only know Go autogenerated files
            push @file_list_minus_autogen, $file;
            next;
        }
        my $first_line = first_line($file, 1, $rh_Err, $raa_errors);
        if ($first_line =~ m{^//\s+Code\s+generated\s+.*?\s+DO\s+NOT\s+EDIT\.$}) {
            $rh_Ignored->{$file} = 'Go autogenerated file';
        } else {
            # Go, but not autogenerated
            push @file_list_minus_autogen, $file;
        }
    }
    @{$ra_file_list} = @file_list_minus_autogen;

    if ($opt_force_git) {
        my $repo_dir = git_root_dir();
        my @file_list_minus_linguist = ();
        # if there's a .gitattributes file, look for linguist-generated
        # and linguist-vendored entries to ignore
        my $GA = ".gitattributes";
        if (-f $GA) {
            foreach my $line (read_file($GA)) {
                next unless $line =~ /^(.*?)\s+(linguist-(vendored|generated))/;
                my $re = glob2regex($1);
                foreach my $file (@{$ra_file_list}) {
                    my $full_path = File::Spec->catfile($repo_dir, $file);
                    my $rel_file  = File::Spec->abs2rel($full_path, $cwd);
                    my $match = undef;
                    if ($ON_WINDOWS) {
                        $rel_file =~ s{\\}{/}g;
                        $match = $rel_file =~ m{$re}i;
                    } else {
                        $match = $rel_file =~ m{$re};
                    }
                    if ($match) {
#print "RULE [$rel_file] v [$re]\n";
                        $rh_Ignored->{$file} = "matches $GA rule '$line'";
                    } else {
                        push @file_list_minus_linguist, $file;
                    }
                }
            }
        }
    }
    print "<- exclude_autogenerated_files()\n" if $opt_v > 2;
} # 1}}}
sub git_root_dir {                           # {{{1
    # if in a git repo, return the repo's top level directory
    my $cmd = "git rev-parse --show-toplevel";
    print $cmd, "\n" if $opt_v > 1;
    my $dir = undef;
    chomp($dir = `$cmd`);
    die "Not in a git repository" unless $dir
} # 1}}}
sub file_extension {                         # {{{1
    my ($fname, ) = @_;
    $fname =~ m/\.(\w+)$/;
    if ($1) {
        return $1;
    } else {
        return "";
    }
} # 1}}}
sub count_files {                            # {{{1
    my ($filelist, $counter_type, $language_hash) = @_;
    print "-> count_files()\n" if $opt_v > 2;
    my @p_errors = ();
    my %p_ignored = ();
    my %p_rbl = ();
    my %p_rbf = ();
    my %Language = %{$language_hash};

    foreach my $file (@$filelist) {
        if ( ! $counter_type ) {
            # Multithreading disabled
            $nCounted++;

            printf "Counting:  %d\r", $nCounted
                 unless (!$opt_progress_rate or ($nCounted % $opt_progress_rate));
        }

        next if $Ignored{$file};
        if ($opt_include_ext and not $Include_Ext{ file_extension($file) }) {
            $p_ignored{$file} = "not in --include-ext=$opt_include_ext";
            next;
        }
        if ($opt_include_lang and not $Include_Language{lc($Language{$file})}) {
            $p_ignored{$file} = "not in --include-lang=$opt_include_lang";
            next;
        }
        if ($Exclude_Language{$Language{$file}}) {
            $p_ignored{$file} = "--exclude-lang=$Language{$file}";
            next;
        }
        if ($opt_force_lang_def and ($Language{$file} eq "XML") and
            !defined $Filters_by_Language{XML}) {
            # XML check is attempted for all unidentified text files.
            # This can't be done if user forces language definition
            # that excludes XML.  GH #596
            next;
        }

        my $Filters_by_Language_Language_file = ! @{$Filters_by_Language{$Language{$file}} };
        if ($Filters_by_Language_Language_file) {
            if ($Language{$file} eq "(unknown)") {
                $p_ignored{$file} = "language unknown (#1)";
            } else {
                $p_ignored{$file} = "missing Filters_by_Language{$Language{$file}}";
            }
            next;
        }

        my ($all_line_count, $blank_count, $comment_count, $code_count) = (0, 0, 0, 0);
        if (!$opt_only_count_files) {
            if ($opt_use_sloccount and $Language{$file} =~ /^(C|C\+\+|XML|PHP|Pascal|Java)$/) {
                chomp ($blank_count     = `grep -cv \"[^[:space:]]\" '$file'`);
                chomp ($all_line_count  = `cat '$file' | wc -l`);
                if      ($Language{$file} =~ /^(C|C\+\+)$/) {
                    $code_count = `cat '$file' | c_count      | head -n 1`;
                } elsif ($Language{$file} eq "XML") {
                    $code_count = `cat '$file' | xml_count    | head -n 1`;
                } elsif ($Language{$file} eq "PHP") {
                    $code_count = `cat '$file' | php_count    | head -n 1`;
                } elsif ($Language{$file} eq "Pascal") {
                    $code_count = `cat '$file' | pascal_count | head -n 1`;
                } elsif ($Language{$file} eq "Java") {
                    $code_count = `cat '$file' | java_count   | head -n 1`;
                } else {
                    die "SLOCCount match failure: file=[$file] lang=[$Language{$file}]";
                }
                $code_count = substr($code_count, 0, -2);
                $comment_count = $all_line_count - $code_count - $blank_count;
            } else {
                ($all_line_count,
                $blank_count   ,
                $comment_count ,) = call_counter($file, $Language{$file}, \@Errors);
                $code_count = $all_line_count - $blank_count - $comment_count;
            }
        }

        if ($opt_by_file) {
            $p_rbf{$file}{'code'   } = $code_count     ;
            $p_rbf{$file}{'blank'  } = $blank_count    ;
            $p_rbf{$file}{'comment'} = $comment_count  ;
            $p_rbf{$file}{'lang'   } = $Language{$file};
            $p_rbf{$file}{'nFiles' } = 1;
        } else {
            $p_rbf{$file} = 1;  # just keep track of counted files
        }

        $p_rbl{$Language{$file}}{'nFiles'}++;
        $p_rbl{$Language{$file}}{'code'}    += $code_count   ;
        $p_rbl{$Language{$file}}{'blank'}   += $blank_count  ;
        $p_rbl{$Language{$file}}{'comment'} += $comment_count;

    }
    print "<- count_files()\n" if $opt_v > 2;
    return {
        "ignored" => \%p_ignored,
        "errors"  => \@p_errors,
        "results_by_file" => \%p_rbf,
        "results_by_language" => \%p_rbl,
    }
} # 1}}}
sub count_filesets {                         # {{{1
    my ($fset_a,
        $fset_b,
        $files_added,
        $files_removed,
        $file_pairs,
        $counter_type,
        $language_hash,
        $rh_Ignored) = @_;
    print "-> count_filesets()\n" if $opt_v > 2;
    my @p_errors = ();
    my %p_alignment = ();
    my %p_ignored = ();
    my %p_rbl = ();
    my %p_rbf = ();
    my %p_dbl = ();
    my %p_dbf = ();
    my %Language = %$language_hash;

    my $nCounted = 0;

    my %already_counted = (); # already_counted{ filename } = 1

    if (!@$file_pairs) {
        # Special case where all files were either added or deleted.
        # In this case, one of these arrays will be empty:
        #   @files_added, @files_removed
        # so loop over both to cover both cases.
        my $status = @$files_added ? 'added' : 'removed';
        my $fset = @$files_added ? $fset_b : $fset_a;
        foreach my $file (@$files_added, @$files_removed) {
            next unless defined $Language{$fset}{$file};
            my $Lang = $Language{$fset}{$file};
            next if $Lang eq '(unknown)';
            my ($all_line_count,
                $blank_count   ,
                $comment_count ,
                ) = call_counter($file, $Lang, \@p_errors);
            $already_counted{$file} = 1;
            my $code_count = $all_line_count-$blank_count-$comment_count;
            if ($opt_by_file) {
                $p_dbf{$file}{'code'   }{$status} += $code_count   ;
                $p_dbf{$file}{'blank'  }{$status} += $blank_count  ;
                $p_dbf{$file}{'comment'}{$status} += $comment_count;
                $p_dbf{$file}{'lang'   }{$status}  = $Lang         ;
                $p_dbf{$file}{'nFiles' }{$status} += 1             ;
            }
            $p_dbl{$Lang}{'code'   }{$status} += $code_count   ;
            $p_dbl{$Lang}{'blank'  }{$status} += $blank_count  ;
            $p_dbl{$Lang}{'comment'}{$status} += $comment_count;
            $p_dbl{$Lang}{'nFiles' }{$status} += 1             ;
        }
    }

    #use Data::Dumper::Simple;
    #use Data::Dumper;
    #print Dumper(\@files_added, \@files_removed, \@file_pairs);
    #print "after align_by_pairs:\n";
    #print "added:\n";

    foreach my $f (@$files_added) {
        next if $already_counted{$f};
        #printf "%10s -> %s\n", $f, $Language{$fh[$F+1]}{$f};
        # Don't proceed unless the file (both L and R versions)
        # is in a known language.
        next if $opt_include_ext
            and not $Include_Ext{ file_extension($f) };
        if (!defined $Language{$fset_b}{$f}) {
            $p_ignored{$f} = "excluded or unknown language";
            next;
        }
        next if $opt_include_lang
            and not $Include_Language{lc($Language{$fset_b}{$f})};
        my $this_lang = $Language{$fset_b}{$f};
        if (!defined  $Language{$fset_b}{$f}) {
            # shouldn't happen but could get here if using
            # --diff-list-file which bypasses earlier checks
            $p_ignored{$f} = "empty or uncharacterizeable file";
            next;
        }
        if ($this_lang eq "(unknown)") {
            $p_ignored{$f} = "unknown language";
            next;
        }
        if ($Exclude_Language{$this_lang}) {
            $p_ignored{$f} = "--exclude-lang=$this_lang";
            next;
        }
        $p_alignment{"added"}{sprintf "  + %s ; %s\n", $f, $this_lang} = 1;
        ++$p_dbl{ $this_lang }{'nFiles'}{'added'};
        # Additionally, add contents of file $f to
        # Delta_by_File{$f}{comment/blank/code}{'added'}
        # Delta_by_Language{$lang}{comment/blank/code}{'added'}
        # via the $p_dbl and $p_dbf variables.
        my ($all_line_count,
            $blank_count   ,
            $comment_count ,
           ) = call_counter($f, $this_lang, \@p_errors);
        $p_dbl{ $this_lang }{'comment'}{'added'} += $comment_count;
        $p_dbl{ $this_lang }{'blank'}{'added'}   += $blank_count;
        $p_dbl{ $this_lang }{'code'}{'added'}    +=
           $all_line_count - $blank_count - $comment_count;
        $p_dbf{ $f }{'comment'}{'added'} = $comment_count;
        $p_dbf{ $f }{'blank'}{'added'}   = $blank_count;
        $p_dbf{ $f }{'code'}{'added'}    =
           $all_line_count - $blank_count - $comment_count;
    }

    #print "removed:\n";
    foreach my $f (@$files_removed) {
        next if $already_counted{$f};
        # Don't proceed unless the file (both L and R versions)
        # is in a known language.
        next if $opt_include_ext
            and not $Include_Ext{ file_extension($f) };
        next if $opt_include_lang
            and (not defined $Language{$fset_a}{$f}
             or  not defined $Include_Language{lc($Language{$fset_a}{$f})});
        my $this_lang = $Language{$fset_a}{$f};
        if ((not defined $this_lang) or ($this_lang eq "(unknown)")) {
            $p_ignored{$f} = "unknown language";
            next;
        }
        if ($Exclude_Language{$this_lang}) {
            $p_ignored{$f} = "--exclude-lang=$this_lang";
            next;
        }
        ++$p_dbl{ $this_lang }{'nFiles'}{'removed'};
        $p_alignment{"removed"}{sprintf "  - %s ; %s\n", $f, $this_lang} = 1;
        #printf "%10s -> %s\n", $f, $Language{$fh[$F  ]}{$f};
        # Additionally, add contents of file $f to
        #        Delta_by_File{$f}{comment/blank/code}{'removed'}
        #        Delta_by_Language{$lang}{comment/blank/code}{'removed'}
        # via the $p_dbl and $p_dbf variables.
        my ($all_line_count,
            $blank_count   ,
            $comment_count ,
           ) = call_counter($f, $this_lang, \@p_errors);
        $p_dbl{ $this_lang}{'comment'}{'removed'} += $comment_count;
        $p_dbl{ $this_lang}{'blank'}{'removed'}   += $blank_count;
        $p_dbl{ $this_lang}{'code'}{'removed'}    +=
             $all_line_count - $blank_count - $comment_count;
        $p_dbf{ $f }{'comment'}{'removed'} = $comment_count;
        $p_dbf{ $f }{'blank'}{'removed'}   = $blank_count;
        $p_dbf{ $f }{'code'}{'removed'}    =
            $all_line_count - $blank_count - $comment_count;
    }

    my $n_file_pairs_compared = 0;
    # Don't know ahead of time how many file pairs will be compared
    # since duplicates are weeded out below.  The answer is
    # scalar @file_pairs only if there are no duplicates.

    foreach my $pair (@$file_pairs) {
        my $file_L = $pair->[0];
        my $file_R = $pair->[1];
        my $Lang_L = $Language{$fset_a}{$file_L};
        my $Lang_R = $Language{$fset_b}{$file_R};
        if (!defined($Lang_L) or !defined($Lang_R)) {
            print " -> count_filesets skipping $file_L, $file_R ",
                  "because language cannot be inferred\n" if $opt_v;
            next;
        }
        #print "main step 6 file_L=$file_L    file_R=$file_R\n";
        ++$nCounted;
        printf "Counting:  %d\r", $nCounted
             unless ($counter_type or !$opt_progress_rate or ($nCounted % $opt_progress_rate));
        next if $p_ignored{$file_L} or $p_ignored{$file_R};

        # filter out non-included extensions
        if ($opt_include_ext  and not $Include_Ext{ file_extension($file_L) }
                              and not $Include_Ext{ file_extension($file_R) }) {
            $p_ignored{$file_L} = "not in --include-ext=$opt_include_ext";
            $p_ignored{$file_R} = "not in --include-ext=$opt_include_ext";
            next;
        }
        # filter out non-included languages
        if ($opt_include_lang and not $Include_Language{lc($Lang_L)}
                              and not $Include_Language{lc($Lang_R)}) {
            $p_ignored{$file_L} = "not in --include-lang=$opt_include_lang";
            $p_ignored{$file_R} = "not in --include-lang=$opt_include_lang";
            next;
        }
        # filter out excluded or unrecognized languages
        if ($Exclude_Language{$Lang_L} or $Exclude_Language{$Lang_R}) {
            $p_ignored{$file_L} = "--exclude-lang=$Lang_L";
            $p_ignored{$file_R} = "--exclude-lang=$Lang_R";
            next;
        }

        my $not_Filters_by_Language_Lang_LR = 0;
        #print "file_LR = [$file_L] [$file_R]\n";
        #print "Lang_LR = [$Lang_L] [$Lang_R]\n";
        if (($Lang_L eq "(unknown)") or
            ($Lang_R eq "(unknown)") or
            !(@{$Filters_by_Language{$Lang_L} }) or
            !(@{$Filters_by_Language{$Lang_R} })) {
            $not_Filters_by_Language_Lang_LR = 1;
        }
        if ($not_Filters_by_Language_Lang_LR) {
            if (($Lang_L eq "(unknown)") or ($Lang_R eq "(unknown)")) {
                $p_ignored{$fset_a}{$file_L} = "language unknown (#1)";
                $p_ignored{$fset_b}{$file_R} = "language unknown (#1)";
            } else {
                $p_ignored{$fset_a}{$file_L} = "missing Filters_by_Language{$Lang_L}";
                $p_ignored{$fset_b}{$file_R} = "missing Filters_by_Language{$Lang_R}";
            }
            next;
        }

        # filter out explicitly excluded files
        if ($opt_exclude_list_file and
            ($rh_Ignored->{$file_L} or $rh_Ignored->{$file_R})) {
            my $msg_2;
            if ($rh_Ignored->{$file_L}) {
                $msg_2 = "$file_L (paired to $file_R)";
            } else {
                $msg_2 = "$file_R (paired to $file_L)";
            }
            my $msg_1 = "in --exclude-list-file=$opt_exclude_list_file";
            $p_ignored{$file_L} = "$msg_1, $msg_2";
            $p_ignored{$file_R} = "$msg_1, $msg_2";
            next;
        }

        #print "DIFF($file_L, $file_R)\n";
        # step 0: compare the two files' contents
        chomp ( my @lines_L = read_file($file_L) );
        chomp ( my @lines_R = read_file($file_R) );
        my $language_file_L = "";
        if (defined $Language{$fset_a}{$file_L}) {
            $language_file_L = $Language{$fset_a}{$file_L};
        } else {
            # files $file_L and $file_R do not contain known language
            next;
        }

        my $contents_are_same = 1;
        if (scalar @lines_L == scalar @lines_R) {
            # same size, must compare line-by-line
            for (my $i = 0; $i < scalar @lines_L; $i++) {
               if ($lines_L[$i] ne $lines_R[$i]) {
                   $contents_are_same = 0;
                   last;
               }
            }
            if ($contents_are_same) {
                ++$p_dbl{$language_file_L}{'nFiles'}{'same'};
            } else {
                ++$p_dbl{$language_file_L}{'nFiles'}{'modified'};
            }
        } else {
            $contents_are_same = 0;
            # different sizes, contents have changed
            ++$p_dbl{$language_file_L}{'nFiles'}{'modified'};
        }

        if ($opt_diff_alignment) {
            my $str =  "$file_L | $file_R ; $language_file_L";
            if ($contents_are_same) {
                $p_alignment{"pairs"}{"  == $str"} = 1;
            } else {
                $p_alignment{"pairs"}{"  != $str"} = 1;
            }
            ++$n_file_pairs_compared;
        }

        my ($all_line_count_L, $blank_count_L   , $comment_count_L ,
            $all_line_count_R, $blank_count_R   , $comment_count_R , )  = (0,0,0,0,0,0,);
        if (!$contents_are_same) {
            # step 1: identify comments in both files
            #print "Diff blank removal L language= $Lang_L";
            #print " scalar(lines_L)=", scalar @lines_L, "\n";
            my @original_minus_blanks_L
                    = rm_blanks(  \@lines_L, $Lang_L, \%EOL_Continuation_re);
            #print "1: scalar(original_minus_blanks_L)=", scalar @original_minus_blanks_L, "\n";
            @lines_L    = @original_minus_blanks_L;
            #print "2: scalar(lines_L)=", scalar @lines_L, "\n";
            @lines_L    = add_newlines(\@lines_L); # compensate for rm_comments()
            @lines_L    = rm_comments( \@lines_L, $Lang_L, $file_L,
                                       \%EOL_Continuation_re);
            #print "3: scalar(lines_L)=", scalar @lines_L, "\n";

            #print "Diff blank removal R language= $Lang_R\n";
            my @original_minus_blanks_R
                    = rm_blanks(  \@lines_R, $Lang_R, \%EOL_Continuation_re);
            @lines_R    = @original_minus_blanks_R;
            @lines_R    = add_newlines(\@lines_R); # taken away by rm_comments()
            @lines_R    = rm_comments( \@lines_R, $Lang_R, $file_R,
                                       \%EOL_Continuation_re);

            my (@diff_LL, @diff_LR, );
                   array_diff( $file_L                  ,   # in
                       \@original_minus_blanks_L ,   # in
                       \@lines_L                 ,   # in
                       "comment"                 ,   # in
                       \@diff_LL, \@diff_LR      ,   # out
                       \@p_errors);                    # in/out

            my (@diff_RL, @diff_RR, );
                    array_diff( $file_R                  ,   # in
                       \@original_minus_blanks_R ,   # in
                       \@lines_R                 ,   # in
                       "comment"                 ,   # in
                       \@diff_RL, \@diff_RR      ,   # out
                       \@p_errors);                    # in/out
            # each line of each file is now classified as
            # code or comment
            #use Data::Dumper;
            #print Dumper("diff_LL", \@diff_LL, "diff_LR", \@diff_LR, );
            #print Dumper("diff_RL", \@diff_RL, "diff_RR", \@diff_RR, );
            #die;

            # step 2: separate code from comments for L and R files
            my @code_L = ();
            my @code_R = ();
            my @comm_L = ();
            my @comm_R = ();
            foreach my $line_info (@diff_LL) {
                if      ($line_info->{'type'} eq "code"   ) {
                    push @code_L, $line_info->{char};
                } elsif ($line_info->{'type'} eq "comment") {
                    push @comm_L, $line_info->{char};
                } else {
                    die "Diff unexpected line type ",
                        $line_info->{'type'}, "for $file_L line ",
                        $line_info->{'lnum'};
                }
            }

            foreach my $line_info (@diff_RL) {
                if      ($line_info->{type} eq "code"   ) {
                    push @code_R, $line_info->{'char'};
                } elsif ($line_info->{type} eq "comment") {
                    push @comm_R, $line_info->{'char'};
                } else {
                    die "Diff unexpected line type ",
                        $line_info->{'type'}, "for $file_R line ",
                        $line_info->{'lnum'};
                }
            }

            if ($opt_ignore_whitespace) {
                # strip all whitespace from each line of source code
                # and comments then use these stripped arrays in diffs
                foreach (@code_L) { s/\s+//g }
                foreach (@code_R) { s/\s+//g }
                foreach (@comm_L) { s/\s+//g }
                foreach (@comm_R) { s/\s+//g }
            }
            if ($opt_ignore_case) {
                # change all text to lowercase in diffs
                foreach (@code_L) { $_ = lc }
                foreach (@code_R) { $_ = lc }
                foreach (@comm_L) { $_ = lc }
                foreach (@comm_R) { $_ = lc }
            }
            # step 3: compute code diffs
            array_diff("$file_L v. $file_R"   ,   # in
                       \@code_L               ,   # in
                       \@code_R               ,   # in
                       "revision"             ,   # in
                       \@diff_LL, \@diff_LR   ,   # out
                       \@p_errors);                 # in/out
            #print Dumper("diff_LL", \@diff_LL, "diff_LR", \@diff_LR, );
            #print Dumper("diff_LR", \@diff_LR);
            foreach my $line_info (@diff_LR) {
                my $status = $line_info->{'desc'}; # same|added|removed|modified
                ++$p_dbl{$Lang_L}{'code'}{$status};
                if ($opt_by_file) {
                    ++$p_dbf{$file_L}{'code'}{$status};
                }
            }
            #use Data::Dumper;
            #print Dumper("code diffs:", \@diff_LL, \@diff_LR);

            # step 4: compute comment diffs
            array_diff("$file_L v. $file_R"   ,   # in
                       \@comm_L               ,   # in
                       \@comm_R               ,   # in
                       "revision"             ,   # in
                       \@diff_LL, \@diff_LR   ,   # out
                       \@Errors);                 # in/out
            #print Dumper("comment diff_LR", \@diff_LR);
            foreach my $line_info (@diff_LR) {
                my $status = $line_info->{'desc'}; # same|added|removed|modified
                ++$p_dbl{$Lang_L}{'comment'}{$status};
                if ($opt_by_file) {
                    ++$p_dbf{$file_L}{'comment'}{$status};
                }
            }
            #print Dumper("comment diffs:", \@diff_LL, \@diff_LR);

            # step 5: compute difference in blank lines (kind of pointless)
            next if $Lang_L eq '(unknown)' or
                    $Lang_R eq '(unknown)';
            ($all_line_count_L,
             $blank_count_L   ,
             $comment_count_L ,
            ) = call_counter($file_L, $Lang_L, \@Errors);

            ($all_line_count_R,
             $blank_count_R   ,
             $comment_count_R ,
            ) = call_counter($file_R, $Lang_R, \@Errors);
        } else {
            # L and R file contents are identical, no need to diff
            ($all_line_count_L,
             $blank_count_L   ,
             $comment_count_L ,
            ) = call_counter($file_L, $Lang_L, \@Errors);
            $all_line_count_R = $all_line_count_L;
            $blank_count_R    = $blank_count_L   ;
            $comment_count_R  = $comment_count_L ;
            my $code_lines_R  = $all_line_count_R - ($blank_count_R + $comment_count_R);
            $p_dbl{$Lang_L}{'blank'}{'same'}   += $blank_count_R;
            $p_dbl{$Lang_L}{'comment'}{'same'} += $comment_count_R;
            $p_dbl{$Lang_L}{'code'}{'same'}    += $code_lines_R;
            if ($opt_by_file) {
                $p_dbf{$file_L}{'blank'}{'same'}   += $blank_count_R;
                $p_dbf{$file_L}{'comment'}{'same'} += $comment_count_R;
                $p_dbf{$file_L}{'code'}{'same'}    += $code_lines_R;
            }
        }

        if ($blank_count_L <  $blank_count_R) {
            my $D = $blank_count_R - $blank_count_L;
            $p_dbl{$Lang_L}{'blank'}{'added'}   += $D;
        } else {
            my $D = $blank_count_L - $blank_count_R;
            $p_dbl{$Lang_L}{'blank'}{'removed'} += $D;
        }
        if ($opt_by_file) {
            if ($blank_count_L <  $blank_count_R) {
                my $D = $blank_count_R - $blank_count_L;
                $p_dbf{$file_L}{'blank'}{'added'}   += $D;
            } else {
                my $D = $blank_count_L - $blank_count_R;
                $p_dbf{$file_L}{'blank'}{'removed'} += $D;
            }
        }

        my $code_count_L = $all_line_count_L-$blank_count_L-$comment_count_L;
        if ($opt_by_file) {
            $p_rbf{$file_L}{'code'   } = $code_count_L    ;
            $p_rbf{$file_L}{'blank'  } = $blank_count_L   ;
            $p_rbf{$file_L}{'comment'} = $comment_count_L ;
            $p_rbf{$file_L}{'lang'   } = $Lang_L          ;
            $p_rbf{$file_L}{'nFiles' } = 1                ;
        } else {
            $p_rbf{$file_L} = 1;  # just keep track of counted files
        }

        $p_rbl{$Lang_L}{'nFiles'}++;
        $p_rbl{$Lang_L}{'code'}    += $code_count_L   ;
        $p_rbl{$Lang_L}{'blank'}   += $blank_count_L  ;
        $p_rbl{$Lang_L}{'comment'} += $comment_count_L;
    }

    print "<- count_filesets()\n" if $opt_v > 2;
    return {
        "ignored" => \%p_ignored,
        "errors"  => \@p_errors,
        "results_by_file" => \%p_rbf,
        "results_by_language" => \%p_rbl,
        "delta_by_file" => \%p_dbf,
        "delta_by_language" => \%p_dbl,
        "alignment" => \%p_alignment,
        "n_filepairs_compared" => $n_file_pairs_compared
    }
} # 1}}}
sub write_alignment_data {                   # {{{1
    my ($filename, $n_filepairs_compared, $data ) = @_;
    my @output = ();
    if ( $data->{'added'} ) {
        my %added_lines = %{$data->{'added'}};
        push (@output, "Files added: " . (scalar keys %added_lines) . "\n");
        foreach my $line ( sort keys %added_lines ) {
            push (@output, $line);
        }
        push (@output, "\n" );
    }
    if ( $data->{'removed'} ) {
        my %removed_lines = %{$data->{'removed'}};
        push (@output, "Files removed: " . (scalar keys %removed_lines) . "\n");
        foreach my $line ( sort keys %removed_lines ) {
            push (@output, $line);
        }
        push (@output, "\n");
    }
    if ( $data->{'pairs'} ) {
        my %pairs = %{$data->{'pairs'}};
        push (@output, "File pairs compared: " . $n_filepairs_compared . "\n");
        foreach my $pair ( sort keys %pairs ) {
            push (@output, $pair);
        }
    }
    write_file($filename, {}, @output);
} # 1}}}
sub exclude_dir_validates {                  # {{{1
    my ($rh_Exclude_Dir) = @_;
    my $is_OK = 1;
    foreach my $dir (keys %{$rh_Exclude_Dir}) {
        if (($ON_WINDOWS and $dir =~ m{\\}) or ($dir =~ m{/})) {
            $is_OK = 0;
            warn "--exclude-dir '$dir' :  cannot specify directory paths\n";
        }
    }
    if (!$is_OK) {
        warn "Use '--fullpath --not-match-d=REGEX' instead\n";
    }
    return $is_OK;
} # 1}}}
sub process_exclude_list_file {              # {{{1
    my ($list_file      , # in
        $rh_exclude_dir , # out
        $rh_ignored     , # out
       ) = @_;
    # note: references global @file_list
    print "-> process_exclude_list_file($list_file)\n" if $opt_v > 2;
    # reject a specific set of files and/or directories
    my @reject_list   = read_list_file($list_file);
    my @file_reject_list = ();
    foreach my $F_or_D (@reject_list) {
        if (is_dir($F_or_D)) {
            $rh_exclude_dir->{$F_or_D} = 1;
        } elsif (is_file($F_or_D)) {
            push @file_reject_list, $F_or_D;
        }
    }

    # Normalize file names for better comparison.
    my %normalized_input   = normalize_file_names(@file_list);
    my %normalized_reject  = normalize_file_names(@file_reject_list);
    my %normalized_exclude = normalize_file_names(keys %{$rh_exclude_dir});
    foreach my $F (keys %normalized_input) {
        if ($normalized_reject{$F} or is_excluded($F, \%normalized_exclude)) {
            my $orig_F = $normalized_input{$F};
            $rh_ignored->{$orig_F} = "listed in exclusion file $opt_exclude_list_file";
            print "Ignoring $orig_F because it appears in $opt_exclude_list_file\n"
                if $opt_v > 1;
        }
    }

    print "<- process_exclude_list_file\n" if $opt_v > 2;
} # 1}}}
sub combine_results {                        # {{{1
    # returns 1 if the inputs are categorized by language
    #         0 if no identifiable language was found
    my ($ra_report_files, # in
        $report_type    , # in  "by language" or "by report file"
        $rhh_count      , # out count{TYPE}{nFiles|code|blank|comment|scaled}
        $rhaa_Filters_by_Language , # in
       ) = @_;

    print "-> combine_results(report_type=$report_type)\n" if $opt_v > 2;
    my $found_language = 0;

    foreach my $file (@{$ra_report_files}) {
        my $n_results_found = 0;
        my $IN = open_file('<', $file, 1);
        if (!defined $IN) {
            warn "Unable to read $file; ignoring.\n";
            next;
        }
        while (<$IN>) {
            next if /^(http|Language|SUM|-----)/;
            if (!$opt_by_file  and
                m{^(.*?)\s+         # language
                   (\d+)\s+         # files
                   (\d+)\s+         # blank
                   (\d+)\s+         # comments
                   (\d+)\s+         # code
                   (                #    next four entries missing with -no3
                   x\s+             # x
                   \d+\.\d+\s+      # scale
                   =\s+             # =
                   (\d+\.\d+)\s*    # scaled code
                   )?
                   $}x) {
                if ($report_type eq "by language") {
                    if (!defined $rhaa_Filters_by_Language->{$1}) {
                        warn "Unrecognized language '$1' in $file ignored\n";
                        next;
                    }
                    # above test necessary to avoid trying to sum reports
                    # of reports (which have no language breakdown).
                    $found_language = 1;
                    $rhh_count->{$1   }{'nFiles' } += $2;
                    $rhh_count->{$1   }{'blank'  } += $3;
                    $rhh_count->{$1   }{'comment'} += $4;
                    $rhh_count->{$1   }{'code'   } += $5;
                    $rhh_count->{$1   }{'scaled' } += $7 if $opt_3;
                } else {
                    $rhh_count->{$file}{'nFiles' } += $2;
                    $rhh_count->{$file}{'blank'  } += $3;
                    $rhh_count->{$file}{'comment'} += $4;
                    $rhh_count->{$file}{'code'   } += $5;
                    $rhh_count->{$file}{'scaled' } += $7 if $opt_3;
                }
                ++$n_results_found;
            } elsif ($opt_by_file  and
                m{^(.*?)\s+         # language
                   (\d+)\s+         # blank
                   (\d+)\s+         # comments
                   (\d+)\s+         # code
                   (                #    next four entries missing with -no3
                   x\s+             # x
                   \d+\.\d+\s+      # scale
                   =\s+             # =
                   (\d+\.\d+)\s*    # scaled code
                   )?
                   $}x) {
                if ($report_type eq "by language") {
                    next unless %{$rhaa_Filters_by_Language->{$1}};
                    # above test necessary to avoid trying to sum reports
                    # of reports (which have no language breakdown).
                    $found_language = 1;
                    $rhh_count->{$1   }{'nFiles' } +=  1;
                    $rhh_count->{$1   }{'blank'  } += $2;
                    $rhh_count->{$1   }{'comment'} += $3;
                    $rhh_count->{$1   }{'code'   } += $4;
                    $rhh_count->{$1   }{'scaled' } += $6 if $opt_3;
                } else {
                    $rhh_count->{$file}{'nFiles' } +=  1;
                    $rhh_count->{$file}{'blank'  } += $2;
                    $rhh_count->{$file}{'comment'} += $3;
                    $rhh_count->{$file}{'code'   } += $4;
                    $rhh_count->{$file}{'scaled' } += $6 if $opt_3;
                }
                ++$n_results_found;
            }
        }
        warn "No counts found in $file--is the file format correct?\n"
            unless $n_results_found;
    }
    print "<- combine_results\n" if $opt_v > 2;
    return $found_language;
} # 1}}}
sub compute_denominator {                    # {{{1
    my ($method, $nCode, $nComment, $nBlank, ) = @_;
    print "-> compute_denominator\n" if $opt_v > 2;
    my %den        = ( "c" => $nCode );
       $den{"cm"}  = $den{"c"}  + $nComment;
       $den{"cmb"} = $den{"cm"} + $nBlank;
       $den{"cb"}  = $den{"c"}  + $nBlank;

    print "<- compute_denominator\n" if $opt_v > 2;
    return $den{ $method };
} # 1}}}
sub yaml_to_json_separators {                # {{{1
    # YAML and JSON are closely related.  Their differences can be captured
    # by trailing commas ($C), braces ($open_B, $close_B), and
    # quotes around text ($Q).
    print "-> yaml_to_json_separators()\n" if $opt_v > 2;
    my ($Q, $open_B, $close_B, $start, $C);
    if ($opt_json) {
       $C       = ',';
       $Q       = '"';
       $open_B  = '{';
       $close_B = '}';
       $start   = '{';
    } else {
       $C       = '';
       $Q       = '' ;
       $open_B  = '' ;
       $close_B = '';
       $start   = "---\n# $URL\n";
    }
    print "<- yaml_to_json_separators()\n" if $opt_v > 2;
    return ($Q, $open_B, $close_B, $start, $C);
} # 1}}}
sub diff_report     {                        # {{{1
    # returns an array of lines containing the results
    print "-> diff_report\n" if $opt_v > 2;

    if ($opt_xml) {
        print "<- diff_report\n" if $opt_v > 2;
        return diff_xml_report(@_)
    } elsif ($opt_yaml) {
        print "<- diff_report\n" if $opt_v > 2;
        return diff_yaml_report(@_)
    } elsif ($opt_json) {
        print "<- diff_report\n" if $opt_v > 2;
        return diff_json_report(@_)
    } elsif ($opt_csv or $opt_md) {
        print "<- diff_report\n" if $opt_v > 2;
        return diff_csv_report(@_)
    }

    my ($version    , # in
        $elapsed_sec, # in
        $report_type, # in  "by language" | "by report file" | "by file"
        $rhhh_count , # in  count{TYPE}{nFiles|code|blank|comment}{a|m|r|s}
        $rh_scale   , # in
       ) = @_;
    my %orig_case = ();
    if ($ON_WINDOWS and $report_type eq "by file") {
        # restore the original upper/lowercase version of the file name
        foreach my $lc_file (sort keys %{$rhhh_count}) {
          foreach my $cat (sort keys %{$rhhh_count->{$lc_file}}) {
            foreach my $S (qw(added same modified removed)) {
                $orig_case{ $upper_lower_map{$lc_file} }{$cat}{$S} =
                           $rhhh_count->{$lc_file}{$cat}{$S};
            }
          }
        }
        $rhhh_count = \%orig_case;
    }

#use Data::Dumper;
#print "diff_report: ", Dumper($rhhh_count), "\n";
    my @results       = ();

    my $languages     = ();
    my %sum           = (); # sum{nFiles|blank|comment|code}{same|modified|added|removed}
    my $max_len       = 0;
    foreach my $language (keys %{$rhhh_count}) {
        foreach my $V (qw(nFiles blank comment code)) {
            foreach my $S (qw(added same modified removed)) {
                $rhhh_count->{$language}{$V}{$S} = 0 unless
                    defined $rhhh_count->{$language}{$V}{$S};
                $sum{$V}{$S}  += $rhhh_count->{$language}{$V}{$S};
            }
        }
        $max_len      = length($language) if length($language) > $max_len;
    }
    my $column_1_offset = 0;
       $column_1_offset = $max_len - 17 if $max_len > 17;
    $elapsed_sec = 0.5 unless $elapsed_sec;

    my $spacing_0 = 23;
    my $spacing_1 = 13;
    my $spacing_2 =  9;
    my $spacing_3 = 17;
    if (!$opt_3) {
        $spacing_1 = 19;
        $spacing_2 = 14;
        $spacing_3 = 27;
    }
    $spacing_0 += $column_1_offset;
    $spacing_1 += $column_1_offset;
    $spacing_3 += $column_1_offset;
    my %Format = (
        '1' => { 'xml' => 'name="%s" ',
                 'txt' => "\%-${spacing_0}s ",
               },
        '2' => { 'xml' => 'name="%s" ',
                 'txt' => "\%-${spacing_3}s ",
               },
        '3' => { 'xml' => 'files_count="%d" ',
                 'txt' => '%6d ',
               },
        '4' => { 'xml' => 'blank="%d" comment="%d" code="%d" ',
                 'txt' => "\%${spacing_2}d \%${spacing_2}d \%${spacing_2}d",
               },
        '5' => { 'xml' => 'blank="%.2f" comment="%.2f" code="%d" ',
                 'txt' => "\%3.2f \%3.2f \%${spacing_2}d",
               },
        '6' => { 'xml' => 'factor="%.2f" scaled="%.2f" ',
                 'txt' => ' x %6.2f = %14.2f',
               },
    );
    my $Style = "txt";
       $Style = "xml" if $opt_xml ;
       $Style = "xml" if $opt_yaml;  # not a typo; just set to anything but txt
       $Style = "xml" if $opt_json;  # not a typo; just set to anything but txt
       $Style = "xml" if $opt_csv ;  # not a typo; just set to anything but txt

    my $hyphen_line = sprintf "%s", '-' x (79 + $column_1_offset);
       $hyphen_line = sprintf "%s", '-' x (68 + $column_1_offset)
            if (!$opt_3) and (68 + $column_1_offset) > 79;
    my $data_line  = "";
    my $first_column;
    my $BY_LANGUAGE = 0;
    my $BY_FILE     = 0;
    if      ($report_type eq "by language") {
        $first_column = "Language";
        $BY_LANGUAGE  = 1;
    } elsif ($report_type eq "by file")     {
        $first_column = "File";
        $BY_FILE      = 1;
    } else {
        $first_column = "Report File";
    }

    # column headers
    if (!$opt_3 and $BY_FILE) {
        my $spacing_n = $spacing_1 - 11;
        $data_line  = sprintf "%-${spacing_n}s" , $first_column;
    } else {
        $data_line  = sprintf "%-${spacing_1}s ", $first_column;
    }
    if ($BY_FILE) {
        $data_line .= sprintf "%${spacing_2}s"   , ""     ;
    } else {
        $data_line .= sprintf "%${spacing_2}s "  , "files";
    }
    my $PCT_symbol = "";
       $PCT_symbol = " \%" if $opt_by_percent;
    $data_line .= sprintf "%${spacing_2}s %${spacing_2}s %${spacing_2}s",
        "blank${PCT_symbol}"         ,
        "comment${PCT_symbol}"       ,
        "code";

    if ($Style eq "txt") {
        push @results, $data_line;
        push @results, $hyphen_line;
    }

    # sort diff output in descending order of cumulative entries
    foreach my $lang_or_file (sort {
                                ($rhhh_count->{$b}{'code'}{'added'}    +
                                 $rhhh_count->{$b}{'code'}{'same'}     +
                                 $rhhh_count->{$b}{'code'}{'modified'} +
                                 $rhhh_count->{$b}{'code'}{'removed'}  )  <=>
                                ($rhhh_count->{$a}{'code'}{'added'}    +
                                 $rhhh_count->{$a}{'code'}{'same'}     +
                                 $rhhh_count->{$a}{'code'}{'modified'} +
                                 $rhhh_count->{$a}{'code'}{'removed'})
                              or $a cmp $b }
                                    keys %{$rhhh_count}) {

        if ($BY_FILE) {
            push @results, rm_leading_tempdir($lang_or_file, \%TEMP_DIR);
        } else {
            push @results, $lang_or_file;
        }
        foreach my $S (qw(same modified added removed)) {
            my $indent = $spacing_1 - 2;
            my $line .= sprintf " %-${indent}s", $S;
            if ($BY_FILE) {
                $line .= sprintf "   ";
            } else {
                $line .= sprintf "  %${spacing_2}s", $rhhh_count->{$lang_or_file}{'nFiles'}{$S};
            }
            if ($opt_by_percent) {
                my $DEN = compute_denominator($opt_by_percent  ,
                    $rhhh_count->{$lang_or_file}{'code'}{$S}   ,
                    $rhhh_count->{$lang_or_file}{'comment'}{$S},
                    $rhhh_count->{$lang_or_file}{'blank'}{$S}  );
                if ($rhhh_count->{$lang_or_file}{'code'}{$S} > 0) {
                    $line .= sprintf " %14.2f %14.2f %${spacing_2}s",
                        $rhhh_count->{$lang_or_file}{'blank'}{$S}   / $DEN * 100,
                        $rhhh_count->{$lang_or_file}{'comment'}{$S} / $DEN * 100,
                        $rhhh_count->{$lang_or_file}{'code'}{$S}    ;
                } else {
                    $line .= sprintf " %14.2f %14.2f %${spacing_2}s",
                        0.0, 0.0, $rhhh_count->{$lang_or_file}{'code'}{$S}    ;
                }
            } else {
                $line .= sprintf " %${spacing_2}s %${spacing_2}s %${spacing_2}s",
                    $rhhh_count->{$lang_or_file}{'blank'}{$S}   ,
                    $rhhh_count->{$lang_or_file}{'comment'}{$S} ,
                    $rhhh_count->{$lang_or_file}{'code'}{$S}    ;
            }
            push @results, $line;
        }
    }
    push @results, $hyphen_line;
    push @results, "SUM:";
    my $sum_files    = 0;
    my $sum_lines    = 0;
    foreach my $S (qw(same modified added removed)) {
        my $indent = $spacing_1 - 2;
        my $line .= sprintf " %-${indent}s", $S;
            if ($BY_FILE) {
                $line .= sprintf "   ";
                $sum_files += 1;
            } else {
                $line .= sprintf "  %${spacing_2}s", $sum{'nFiles'}{$S};
                $sum_files += $sum{'nFiles'}{$S};
            }
        if ($opt_by_percent) {
            my $DEN = compute_denominator($opt_by_percent,
                $sum{'code'}{$S}, $sum{'comment'}{$S}, $sum{'blank'}{$S});
            if ($sum{'code'}{$S} > 0) {
                $line .= sprintf " %14.2f %14.2f %${spacing_2}s",
                    $sum{'blank'}{$S}   / $DEN * 100,
                    $sum{'comment'}{$S} / $DEN * 100,
                    $sum{'code'}{$S}    ;
            } else {
                $line .= sprintf " %14.2f %14.2f %${spacing_2}s",
                    0.0, 0.0, $sum{'code'}{$S}    ;
            }
        } else {
            $line .= sprintf " %${spacing_2}s %${spacing_2}s %${spacing_2}s",
                $sum{'blank'}{$S}   ,
                $sum{'comment'}{$S} ,
                $sum{'code'}{$S}    ;
        }
        $sum_lines += $sum{'blank'}{$S} + $sum{'comment'}{$S} + $sum{'code'}{$S};
        push @results, $line;
    }

    my $header_line  = sprintf "%s v %s", $URL, $version;
       $header_line .= sprintf("  T=%.2f s (%.1f files/s, %.1f lines/s)",
                        $elapsed_sec           ,
                        $sum_files/$elapsed_sec,
                        $sum_lines/$elapsed_sec) unless $opt_sum_reports or $opt_hide_rate;
    if ($Style eq "txt") {
        unshift @results, output_header($header_line, $hyphen_line, $BY_FILE);
    }

    push @results, $hyphen_line;
    write_xsl_file() if $opt_xsl and $opt_xsl eq $CLOC_XSL;
    print "<- diff_report\n" if $opt_v > 2;

    return @results;
} # 1}}}
sub xml_yaml_or_json_header {                # {{{1
    my ($URL, $version, $elapsed_sec, $sum_files, $sum_lines, $by_file) = @_;
    print "-> xml_yaml_or_json_header\n" if $opt_v > 2;
    my $header      = "";
    my $file_rate   = $sum_files/$elapsed_sec;
    my $line_rate   = $sum_lines/$elapsed_sec;
    my $type        = "";
       $type        = "diff_" if $opt_diff;
    my $report_file = "";
    if ($opt_report_file) {
        my $Fname = $opt_report_file;
        $Fname =~ s{\\}{\\\\}g if $ON_WINDOWS;
        if ($opt_sum_reports) {
            if ($by_file) {
                $report_file = "  <report_file>$Fname.file</report_file>"
            } else {
                $report_file = "  <report_file>$Fname.lang</report_file>"
            }
        } else {
            $report_file = "  <report_file>$Fname</report_file>"
        }
    }
    if ($opt_xml) {
        $header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
        $header .= "\n<?xml-stylesheet type=\"text/xsl\" href=\"" . $opt_xsl . "\"?>" if $opt_xsl;
        if ($opt_hide_rate) {
            $header .= "<${type}results>
<header>
  <cloc_url>$URL</cloc_url>
  <cloc_version>$version</cloc_version>
  <n_files>$sum_files</n_files>
  <n_lines>$sum_lines</n_lines>";
        } else {
            $header .= "<${type}results>
<header>
  <cloc_url>$URL</cloc_url>
  <cloc_version>$version</cloc_version>
  <elapsed_seconds>$elapsed_sec</elapsed_seconds>
  <n_files>$sum_files</n_files>
  <n_lines>$sum_lines</n_lines>
  <files_per_second>$file_rate</files_per_second>
  <lines_per_second>$line_rate</lines_per_second>";
        }
        $header .= "\n$report_file"
            if $opt_report_file;
        $header .= "\n</header>";
        if (%git_metadata) {
            foreach my $target (keys %git_metadata) {
                $header .= "\n<source>";
                $header .= "\n  <target>$target</target>";
                $header .= "\n  <origin>$git_metadata{$target}{'origin'}</origin>";
                $header .= "\n  <branch>$git_metadata{$target}{'branch'}</branch>";
                $header .= "\n  <commit>$git_metadata{$target}{'commit'}</commit>";
                $header .= "\n</source>";
            }
        }
    } elsif ($opt_yaml or $opt_json) {
        my ($Q, $open_B, $close_B, $start, $C) = yaml_to_json_separators();
        if ($opt_hide_rate) {
            $header = "${start}${Q}header${Q} : $open_B
  ${Q}cloc_url${Q}           : ${Q}$URL${Q}${C}
  ${Q}cloc_version${Q}       : ${Q}$version${Q}${C}
  ${Q}n_files${Q}            : $sum_files${C}
  ${Q}n_lines${Q}            : $sum_lines${C}";
        } else {
            $header = "${start}${Q}header${Q} : $open_B
  ${Q}cloc_url${Q}           : ${Q}$URL${Q}${C}
  ${Q}cloc_version${Q}       : ${Q}$version${Q}${C}
  ${Q}elapsed_seconds${Q}    : $elapsed_sec${C}
  ${Q}n_files${Q}            : $sum_files${C}
  ${Q}n_lines${Q}            : $sum_lines${C}
  ${Q}files_per_second${Q}   : $file_rate${C}
  ${Q}lines_per_second${Q}   : $line_rate";
        }
        if ($opt_report_file) {
            my $Fname = $opt_report_file;
            $Fname =~ s{\\}{\\\\}g if $ON_WINDOWS;
            if ($opt_sum_reports) {
                if ($by_file) {
                    $header .= "$C\n  ${Q}report_file${Q}        : ${Q}$Fname.file${Q}"
                } else {
                    $header .= "$C\n  ${Q}report_file${Q}        : ${Q}$Fname.lang${Q}"
                }
            } else {
                $header .= "$C\n  ${Q}report_file${Q}        : ${Q}$Fname${Q}";
            }
        }
        $header .= "${close_B}${C}";
    }
    print "<- xml_yaml_or_json_header\n" if $opt_v > 2;
    return $header;
} # 1}}}
sub diff_yaml_report {                       # {{{1
    # returns an array of lines containing the results
    my ($version    , # in
        $elapsed_sec, # in
        $report_type, # in  "by language" | "by report file" | "by file"
        $rhhh_count , # in  count{TYPE}{nFiles|code|blank|comment}{a|m|r|s}
        $rh_scale   , # in
       ) = @_;
    print "-> diff_yaml_report\n" if $opt_v > 2;
    $elapsed_sec = 0.5 unless $elapsed_sec;
    my @results       = ();
    my %sum           = ();
    my ($sum_lines, $sum_files, $BY_FILE, $BY_LANGUAGE) =
        diff_header_sum($report_type, $rhhh_count, \%sum);

    if (!$ALREADY_SHOWED_HEADER) {
        push @results,
              xml_yaml_or_json_header($URL, $version, $elapsed_sec,
                                 $sum_files, $sum_lines, $BY_FILE);
        $ALREADY_SHOWED_HEADER = 1;
    }
    foreach my $S (qw(added same modified removed)) {
        push @results, "$S :";
        foreach my $F_or_L (keys %{$rhhh_count}) {
            # force quoted language or filename in case these
            # have embedded funny characters, issue #312
            push @results, "  '" . rm_leading_tempdir($F_or_L, \%TEMP_DIR) . "' :";
            foreach my $k (keys %{$rhhh_count->{$F_or_L}}) {
                next if $k eq "lang"; # present only in those cases
                                      # where code exists for action $S
                $rhhh_count->{$F_or_L}{$k}{$S} = 0 unless
                    defined $rhhh_count->{$F_or_L}{$k}{$S};
                push @results,
                    "    $k : $rhhh_count->{$F_or_L}{$k}{$S}";
            }
        }
    }

    push @results, "SUM :";
    foreach my $S (qw(added same modified removed)) {
        push @results, "  $S :";
        foreach my $topic (keys %sum) {
            push @results, "    $topic : $sum{$topic}{$S}";
        }
    }

    print "<- diff_yaml_report\n" if $opt_v > 2;

    return @results;
} # 1}}}
sub diff_json_report {                       # {{{1
    # returns an array of lines containing the results
    my ($version    , # in
        $elapsed_sec, # in
        $report_type, # in  "by language" | "by report file" | "by file"
        $rhhh_count , # in  count{TYPE}{nFiles|code|blank|comment}{a|m|r|s}
        $rh_scale   , # in
       ) = @_;
    print "-> diff_json_report\n" if $opt_v > 2;
    $elapsed_sec = 0.5 unless $elapsed_sec;
    my @results       = ();
    my %sum           = ();
    my ($sum_lines, $sum_files, $BY_FILE, $BY_LANGUAGE) =
        diff_header_sum($report_type, $rhhh_count, \%sum);

    if (!$ALREADY_SHOWED_HEADER) {
        push @results,
              xml_yaml_or_json_header($URL, $version, $elapsed_sec,
                                 $sum_files, $sum_lines, $BY_FILE);
        $ALREADY_SHOWED_HEADER = 1;
    }
    foreach my $S (qw(added same modified removed)) {
        push @results, " \"$S\" : {";
        foreach my $F_or_L (keys %{$rhhh_count}) {
            push @results, "  \"" . rm_leading_tempdir($F_or_L, \%TEMP_DIR) . "\" : {";
            foreach my $k (keys %{$rhhh_count->{$F_or_L}}) {
                next if $k eq "lang"; # present only in those cases
                                      # where code exists for action $S
                $rhhh_count->{$F_or_L}{$k}{$S} = 0 unless
                    defined $rhhh_count->{$F_or_L}{$k}{$S};
                push @results,
                    "    \"$k\" : $rhhh_count->{$F_or_L}{$k}{$S},";
            }
            $results[-1] =~ s/,\s*$//;
            push @results, "  },"
        }
        $results[-1] =~ s/,\s*$//;
        push @results, "  },"
    }

    push @results, "  \"SUM\" : {";
    foreach my $S (qw(added same modified removed)) {
        push @results, "  \"$S\" : {";
        foreach my $topic (keys %sum) {
            push @results, "    \"$topic\" : $sum{$topic}{$S},";
        }
        $results[-1] =~ s/,\s*$//;
        push @results, "},";
    }

    $results[-1] =~ s/,\s*$//;
    push @results, "} }";
    print "<- diff_json_report\n" if $opt_v > 2;
    return @results;
} # 1}}}
sub diff_header_sum {                        # {{{1
    my ($report_type, # in  "by language" | "by report file" | "by file"
        $rhhh_count , # in  count{TYPE}{nFiles|code|blank|comment}{a|m|r|s}
        $rhh_sum    , # out sum{nFiles|blank|comment|code}{same|modified|added|removed}
       ) = @_;

    my $sum_files = 0;
    my $sum_lines = 0;
    foreach my $language (keys %{$rhhh_count}) {
        foreach my $V (qw(nFiles blank comment code)) {
            foreach my $S (qw(added same modified removed)) {
                $rhhh_count->{$language}{$V}{$S} = 0 unless
                    defined $rhhh_count->{$language}{$V}{$S};
                $rhh_sum->{$V}{$S}  += $rhhh_count->{$language}{$V}{$S};
                if ($V eq "nFiles") {
                    $sum_files += $rhhh_count->{$language}{$V}{$S};
                } else {
                    $sum_lines += $rhhh_count->{$language}{$V}{$S};
                }
            }
        }
    }

    my $BY_LANGUAGE = 0;
    my $BY_FILE     = 0;
    if      ($report_type eq "by language") {
        $BY_LANGUAGE  = 1;
    } elsif ($report_type eq "by file")     {
        $BY_FILE      = 1;
    }
    return $sum_lines, $sum_files, $BY_FILE, $BY_LANGUAGE;
} # 1}}}
sub diff_xml_report {                        # {{{1
    # returns an array of lines containing the results
    my ($version    , # in
        $elapsed_sec, # in
        $report_type, # in  "by language" | "by report file" | "by file"
        $rhhh_count , # in  count{TYPE}{nFiles|code|blank|comment}{a|m|r|s}
        $rh_scale   , # in
       ) = @_;
    print "-> diff_xml_report\n" if $opt_v > 2;
    my ($Q, $open_B, $close_B, $start, $C) = yaml_to_json_separators();

#print "diff_report: ", Dumper($rhhh_count), "\n";
    $elapsed_sec = 0.5 unless $elapsed_sec;
    my @results       = ();
    my %sum           = ();
    my $languages     = ();

    my ($sum_lines, $sum_files, $BY_FILE, $BY_LANGUAGE) =
        diff_header_sum($report_type, $rhhh_count, \%sum);

    my $data_line   = "";

    if (!$ALREADY_SHOWED_HEADER) {
        push @results,
              xml_yaml_or_json_header($URL, $version, $elapsed_sec,
                                 $sum_files, $sum_lines, $BY_FILE);
        $ALREADY_SHOWED_HEADER = 1;
    }

    foreach my $S (qw(same modified added removed)) {
        push @results, "  <$S>";
        foreach my $lang_or_file (sort {
                                     $rhhh_count->{$b}{'code'} <=>
                                     $rhhh_count->{$a}{'code'}
                                   }
                              keys %{$rhhh_count}) {
            my $L = "";

            if ($BY_FILE) {
                $L .= sprintf "    <file name=\"%s\" files_count=\"1\" ",
                    xml_metachars(
                        rm_leading_tempdir($lang_or_file, \%TEMP_DIR));
            } else {
                $L .= sprintf "    <language name=\"%s\" files_count=\"%d\" ",
                        $lang_or_file ,
                        $rhhh_count->{$lang_or_file}{'nFiles'}{$S};
            }
            if ($opt_by_percent) {
              my $DEN = compute_denominator($opt_by_percent            ,
                            $rhhh_count->{$lang_or_file}{'code'}{$S}   ,
                            $rhhh_count->{$lang_or_file}{'comment'}{$S},
                            $rhhh_count->{$lang_or_file}{'blank'}{$S}  );
              foreach my $T (qw(blank comment)) {
                  if ($rhhh_count->{$lang_or_file}{'code'}{$S} > 0) {
                    $L .= sprintf "%s=\"%.2f\" ",
                            $T, $rhhh_count->{$lang_or_file}{$T}{$S} / $DEN * 100;
                  } else {
                    $L .= sprintf "%s=\"0.0\" ", $T;
                  }
              }
              foreach my $T (qw(code)) {
                  $L .= sprintf "%s=\"%d\" ",
                          $T, $rhhh_count->{$lang_or_file}{$T}{$S};
              }
            } else {
              foreach my $T (qw(blank comment code)) {
                  $L .= sprintf "%s=\"%d\" ",
                          $T, $rhhh_count->{$lang_or_file}{$T}{$S};
              }
            }
            push @results, $L . "/>";
        }


        my $L = sprintf "    <total sum_files=\"%d\" ", $sum{'nFiles'}{$S};
        if ($opt_by_percent) {
          my $DEN = compute_denominator($opt_by_percent,
                        $sum{'code'}{$S}   ,
                        $sum{'comment'}{$S},
                        $sum{'blank'}{$S}  );
          foreach my $V (qw(blank comment)) {
              if ($sum{'code'}{$S} > 0) {
                  $L .= sprintf "%s=\"%.2f\" ", $V, $sum{$V}{$S} / $DEN * 100;
              } else {
                  $L .= sprintf "%s=\"0.0\" ", $V;
              }
          }
          foreach my $V (qw(code)) {
              $L .= sprintf "%s=\"%d\" ", $V, $sum{$V}{$S};
          }
        } else {
          foreach my $V (qw(blank comment code)) {
              $L .= sprintf "%s=\"%d\" ", $V, $sum{$V}{$S};
          }
        }
        push @results, $L . "/>";
        push @results, "  </$S>";
    }

    push @results, "</diff_results>";
    write_xsl_file() if $opt_xsl and $opt_xsl eq $CLOC_XSL;
    print "<- diff_xml_report\n" if $opt_v > 2;
    return @results;
} # 1}}}
sub diff_csv_report {                        # {{{1
    # returns an array of lines containing the results
    my ($version    , # in
        $elapsed_sec, # in
        $report_type, # in  "by language" | "by report file" | "by file"
        $rhhh_count , # in  count{TYPE}{nFiles|code|blank|comment}{a|m|r|s}
        $rh_scale   , # in  unused
       ) = @_;
    print "-> diff_csv_report\n" if $opt_v > 2;

    my @results       = ();
    my $languages     = ();

    my $data_line   = "";
    my $BY_LANGUAGE = 0;
    my $BY_FILE     = 0;
    if      ($report_type eq "by language") {
        $BY_LANGUAGE  = 1;
    } elsif ($report_type eq "by file")     {
        $BY_FILE      = 1;
    }
    my $DELIM = ",";
       $DELIM = $opt_csv_delimiter if defined $opt_csv_delimiter;
       $DELIM = "|" if defined $opt_md;

    $elapsed_sec = 0.5 unless $elapsed_sec;

    my $line = "Language${DELIM} ";
       $line = "File${DELIM} " if $BY_FILE;
    foreach my $item (qw(files blank comment code)) {
        next if $BY_FILE and $item eq 'files';
        foreach my $symbol ( '==', '!=', '+', '-', ) {
            $line .= "$symbol $item${DELIM} ";
        }
    }

    my $T_elapsed_sec = "T=$elapsed_sec s";
       $T_elapsed_sec = "" if $opt_hide_rate;

    if ($opt_md) {
        push @results, "cloc|$URL v $version $T_elapsed_sec";
        push @results, "--- | ---";
        push @results, "";
        push @results, $line;
        my @col_header  = ();
        push @col_header, ":-------";
        foreach (1..16) {
            push @col_header, "-------:";
        }
        push @results, join("|", @col_header) . "|";
    } else {
        $line .= "\"$URL v $version $T_elapsed_sec\"";
        push @results, $line;
    }

    foreach my $lang_or_file (keys %{$rhhh_count}) {
        $rhhh_count->{$lang_or_file}{'code'}{'added'} = 0 unless
            defined $rhhh_count->{$lang_or_file}{'code'};
    }
    foreach my $lang_or_file (sort {
                                 $rhhh_count->{$b}{'code'} <=>
                                 $rhhh_count->{$a}{'code'}
                               }
                          keys %{$rhhh_count}) {
        if ($BY_FILE) {
            $line = rm_leading_tempdir($lang_or_file, \%TEMP_DIR) . "$DELIM ";
        } else {
            $line = $lang_or_file . "${DELIM} ";
        }
        if ($opt_by_percent) {
          foreach my $item (qw(nFiles)) {
              next if $BY_FILE and $item eq 'nFiles';
              foreach my $symbol (qw(same modified added removed)) {
                  if (defined $rhhh_count->{$lang_or_file}{$item}{$symbol}) {
                      $line .= "$rhhh_count->{$lang_or_file}{$item}{$symbol}${DELIM} ";
                  } else {
                      $line .= "0${DELIM} ";
                  }
              }
          }
          foreach my $item (qw(blank comment)) {
              foreach my $symbol (qw(same modified added removed)) {
                  if (defined $rhhh_count->{$lang_or_file}{$item}{$symbol} and
                      defined $rhhh_count->{$lang_or_file}{'code'}{$symbol} and
                      $rhhh_count->{$lang_or_file}{'code'}{$symbol} > 0) {
                      $line .= sprintf("%.2f", $rhhh_count->{$lang_or_file}{$item}{$symbol} / $rhhh_count->{$lang_or_file}{'code'}{$symbol} * 100).${DELIM};
                  } else {
                      $line .= "0.00${DELIM} ";
                  }
              }
          }
          foreach my $item (qw(code)) {
              foreach my $symbol (qw(same modified added removed)) {
                  if (defined $rhhh_count->{$lang_or_file}{$item}{$symbol}) {
                      $line .= "$rhhh_count->{$lang_or_file}{$item}{$symbol}${DELIM} ";
                  } else {
                      $line .= "0${DELIM} ";
                  }
              }
          }
        } else {
          foreach my $item (qw(nFiles blank comment code)) {
              next if $BY_FILE and $item eq 'nFiles';
              foreach my $symbol (qw(same modified added removed)) {
                  if (defined $rhhh_count->{$lang_or_file}{$item}{$symbol}) {
                      $line .= "$rhhh_count->{$lang_or_file}{$item}{$symbol}${DELIM} ";
                  } else {
                      $line .= "0${DELIM} ";
                  }
              }
          }
        }
        push @results, $line;
    }

    print "<- diff_csv_report\n" if $opt_v > 2;
    return @results;
} # 1}}}
sub rm_leading_tempdir {                     # {{{1
    my ($in_file, $rh_temp_dirs, ) = @_;
    my $clean_filename = $in_file;
    foreach my $temp_d (keys %{$rh_temp_dirs}) {
        if ($ON_WINDOWS) {
        # \ -> / necessary to allow the next if test's
        # m{} to work in the presence of spaces in file names
            $temp_d         =~ s{\\}{/}g;
            $clean_filename =~ s{\\}{/}g;
        }
        if ($clean_filename =~ m{^$temp_d/}) {
            $clean_filename =~ s{^$temp_d/}{};
            last;
        }
    }
    if ($ON_WINDOWS and $opt_by_file) { # then go back from / to \
        if ($opt_json) {
            $clean_filename =~ s{/}{\\\\}g;
        } else {
            $clean_filename =~ s{/}{\\}g;
        }
    }
    return $clean_filename;
} # 1}}}
sub generate_sql    {                        # {{{1
    my ($elapsed_sec, # in
        $rhh_count  , # in  count{TYPE}{lang|code|blank|comment|scaled}
        $rh_scale   , # in
       ) = @_;
    print "-> generate_sql\n" if $opt_v > 2;

#print "generate_sql A [$opt_sql_project]\n";
    $opt_sql_project = cwd() unless defined $opt_sql_project;
    $opt_sql_project = '' unless defined $opt_sql_project; # have seen cwd() fail
#print "generate_sql B [$opt_sql_project]\n";
    $opt_sql_project =~ s{/}{\\}g if $ON_WINDOWS;
#print "generate_sql C [$opt_sql_project]\n";

    my $schema = undef;
    if ($opt_sql_style eq "oracle") {
        $schema = "
CREATE TABLE metadata
(
  timestamp   TIMESTAMP,
  project     VARCHAR2(500 CHAR),
  elapsed_s   NUMBER(10, 6)
)
/

CREATE TABLE t
(
  project        VARCHAR2(500 CHAR),
  language       VARCHAR2(500 CHAR),
  file_fullname  VARCHAR2(500 CHAR),
  file_dirname   VARCHAR2(500 CHAR),
  file_basename  VARCHAR2(500 CHAR),
  nblank         INTEGER,
  ncomment       INTEGER,
  ncode          INTEGER,
  nscaled        NUMBER(10, 6)
)
/

";
    } else {
        $schema = "
create table metadata (          -- $URL v $VERSION
                timestamp varchar(500),
                Project   varchar(500),
                elapsed_s real);
create table t        (
                Project       varchar(500)   ,
                Language      varchar(500)   ,
                File          varchar(500)   ,
                File_dirname  varchar(500)   ,
                File_basename varchar(500)   ,
                nBlank        integer        ,
                nComment      integer        ,
                nCode         integer        ,
                nScaled       real           );
";
    }
    $opt_sql = "-" if $opt_sql eq "1";

    my $open_mode = ">";
       $open_mode = ">>" if $opt_sql_append;

    my $fh;
    if ($ON_WINDOWS and $HAVE_Win32_Long_Path and $opt_sql ne "-") {
        # only use the Win32::LongPath wrapper here when needed,
        # and only when not writing to STDOUT.
        $fh = open_file($open_mode, $opt_sql, 1);
        die "Unable to write to $opt_sql\n" if !defined $fh;
    } else {
        $fh = new IO::File; # $opt_sql, "w";
        if (!$fh->open("${open_mode}${opt_sql}")) {
            die "Unable to write to $opt_sql  $!\n";
        }
    }
    print $fh $schema unless defined $opt_sql_append;

    my $insert_into_t = "insert into t ";
    if ($opt_sql_style eq "oracle") {
        printf $fh "insert into metadata values(TO_TIMESTAMP('%s','yyyy-mm-dd hh24:mi:ss'), '%s', %f);\n",
                    strftime("%Y-%m-%d %H:%M:%S", localtime(time())),
                    $opt_sql_project, $elapsed_sec;
    } elsif ($opt_sql_style eq "named_columns") {
        print $fh "begin transaction;\n";
        $insert_into_t .= "( Project, Language, File, File_dirname, File_basename, nBlank, nComment, nCode, nScaled )";
    } else {
        print $fh "begin transaction;\n";
        printf $fh "insert into metadata values('%s', '%s', %f);\n",
                    strftime("%Y-%m-%d %H:%M:%S", localtime(time())),
                    $opt_sql_project, $elapsed_sec;
    }

    my $nIns = 0;
    foreach my $file (keys %{$rhh_count}) {
        my $language = $rhh_count->{$file}{'lang'};
        my $clean_filename = $file;
        # If necessary (that is, if the input contained an
        # archive file [.tar.gz, etc]), strip the temporary
        # directory name which was used to expand the archive
        # from the file name.

        $clean_filename = rm_leading_tempdir($clean_filename, \%TEMP_DIR);
        $clean_filename =~ s/\'/''/g;  # double embedded single quotes
                                       # to escape them

        printf $fh "$insert_into_t values('%s', '%s', '%s', '%s', '%s', " .
                   "%d, %d, %d, %f);\n",
                    $opt_sql_project           ,
                    $language                  ,
                    $clean_filename            ,
                    dirname( $clean_filename)  ,
                    basename($clean_filename)  ,
                    $rhh_count->{$file}{'blank'},
                    $rhh_count->{$file}{'comment'},
                    $rhh_count->{$file}{'code'}   ,
                    $rhh_count->{$file}{'code'}*$rh_scale->{$language};

        ++$nIns;
        if (!($nIns % 10_000) and ($opt_sql_style ne "oracle")) {
            print $fh "commit;\n";
            print $fh "begin transaction;\n";
        }
    }
    if ($opt_sql_style ne "oracle") {
        print $fh "commit;\n";
    }

    $fh->close unless $opt_sql eq "-"; # don't try to close STDOUT
    print "<- generate_sql\n" if $opt_v > 2;

    # sample query:
    #
    #   select project, language,
    #          sum(nCode)     as Code,
    #          sum(nComment)  as Comments,
    #          sum(nBlank)    as Blank,
    #          sum(nCode)+sum(nComment)+sum(nBlank) as All_Lines,
    #          100.0*sum(nComment)/(sum(nCode)+sum(nComment)) as Comment_Pct
    #          from t group by Project, Language order by Project, Code desc;
    #
} # 1}}}
sub output_header   {                        # {{{1
    my ($header_line,
        $hyphen_line,
        $BY_FILE    ,)    = @_;
    print "-> output_header\n" if $opt_v > 2;
    my @R = ();
    if      ($opt_xml) {
        if (!$ALREADY_SHOWED_XML_SECTION) {
            push @R, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
            push @R, '<?xml-stylesheet type="text/xsl" href="' .
                            $opt_xsl . '"?>' if $opt_xsl;
            push @R, "<results>";
            push @R, "<header>$header_line</header>";
            $ALREADY_SHOWED_XML_SECTION = 1;
        }
        if ($BY_FILE) {
            push @R, "<files>";
        } else {
            push @R, "<languages>";
        }
    } elsif ($opt_yaml) {
        push @R, "---\n# $header_line";
    } elsif ($opt_csv or $opt_md) {
        # append the header to the end of the column headers
        # to keep the output a bit cleaner from a spreadsheet
        # perspective
    } else {
        if ($ALREADY_SHOWED_HEADER) {
            push @R, "";
        } else {
            push @R, $header_line;
            $ALREADY_SHOWED_HEADER = 1;
        }
        push @R, $hyphen_line;
    }
    print "<- output_header\n" if $opt_v > 2;
    return @R;
} # 1}}}
sub generate_report {                        # {{{1
    # returns an array of lines containing the results
    my ($version    , # in
        $elapsed_sec, # in
        $report_type, # in  "by language" | "by report file" | "by file"
        $rhh_count  , # in  count{TYPE}{nFiles|code|blank|comment|scaled}
                      #       where TYPE = name of language, source file,
                      #                    or report file
        $rh_scale   , # in
       ) = @_;

    my %orig_case = ();
    if ($ON_WINDOWS and $report_type eq "by file") {
        # restore the original upper/lowercase version of the file name
        foreach my $lc_file (sort keys %{$rhh_count}) {
            foreach my $cat (sort keys %{$rhh_count->{$lc_file}}) {
                $orig_case{ $upper_lower_map{$lc_file} }{$cat} =
                           $rhh_count->{$lc_file}{$cat};
            }
        }
        $rhh_count = \%orig_case;
    }
    print "-> generate_report\n" if $opt_v > 2;
    my $DELIM = ",";
       $DELIM = $opt_csv_delimiter if defined $opt_csv_delimiter;
       $DELIM = "|" if defined $opt_md;

    my @results       = ();

    my $languages     = ();

    my $sum_files     = 0;
    my $sum_code      = 0;
    my $sum_blank     = 0;
    my $sum_comment   = 0;
    my $max_len       = 0;
    foreach my $language (keys %{$rhh_count}) {
        $sum_files   += $rhh_count->{$language}{'nFiles'} ;
        $sum_blank   += $rhh_count->{$language}{'blank'}  ;
        $sum_comment += $rhh_count->{$language}{'comment'};
        $sum_code    += $rhh_count->{$language}{'code'}   ;
        $max_len      = length($language) if length($language) > $max_len;
    }
    my $column_1_offset = 0;
       $column_1_offset = $max_len - 17 if $max_len > 17;
    my $sum_lines = $sum_blank + $sum_comment + $sum_code;
    $elapsed_sec = 0.5 unless $elapsed_sec;

    my $spacing_0 = 23;
    my $spacing_1 = 13;
    my $spacing_2 =  9;
    my $spacing_3 = 17;
    if (!$opt_3) {
        $spacing_1 = 19;
        $spacing_2 = 14;
        $spacing_3 = 27;
    }
    $spacing_0 += $column_1_offset;
    $spacing_1 += $column_1_offset;
    $spacing_3 += $column_1_offset;
    my %Format = (
        '1' => { 'xml' => 'name="%s" ',
                 'txt' => "\%-${spacing_0}s ",
               },
        '2' => { 'xml' => 'name="%s" ',
                 'txt' => "\%-${spacing_3}s ",
               },
        '3' => { 'xml' => 'files_count="%d" ',
                 'txt' => '%6d ',
               },
        '4' => { 'xml' => 'blank="%d" comment="%d" code="%d" ',
                 'txt' => "\%${spacing_2}d \%${spacing_2}d \%${spacing_2}d",
               },
        '5' => { 'xml' => 'blank="%3.2f" comment="%3.2f" code="%d" ',
                 'txt' => "\%14.2f \%14.2f \%${spacing_2}d",
               },
        '6' => { 'xml' => 'factor="%.2f" scaled="%.2f" ',
                 'txt' => ' x %6.2f = %14.2f',
               },
    );
    my $Style = "txt";
       $Style = "xml" if $opt_xml ;
       $Style = "xml" if $opt_yaml;  # not a typo; just set to anything but txt
       $Style = "xml" if $opt_json;  # not a typo; just set to anything but txt
       $Style = "xml" if $opt_csv ;  # not a typo; just set to anything but txt

    my $hyphen_line = sprintf "%s", '-' x (79 + $column_1_offset);
       $hyphen_line = sprintf "%s", '-' x (68 + $column_1_offset)
            if (!$opt_sum_reports) and (!$opt_3) and (68 + $column_1_offset) > 79;
    my $data_line  = "";
    my $first_column;
    my $BY_LANGUAGE = 0;
    my $BY_FILE     = 0;
    if      ($report_type eq "by language") {
        $first_column = "Language";
        $BY_LANGUAGE  = 1;
    } elsif ($report_type eq "by file")     {
        $first_column = "File";
        $BY_FILE      = 1;
    } elsif ($report_type eq "by report file")     {
        $first_column = "File";
    } else {
        $first_column = "Report File";
    }

    my $header_line  = sprintf "%s v %s", $URL, $version;
       $header_line .= sprintf("  T=%.2f s (%.1f files/s, %.1f lines/s)",
                        $elapsed_sec           ,
                        $sum_files/$elapsed_sec,
                        $sum_lines/$elapsed_sec) unless $opt_sum_reports or $opt_hide_rate;
    if ($opt_xml or $opt_yaml or $opt_json) {
        if (!$ALREADY_SHOWED_HEADER) {
            if ($opt_by_file_by_lang and $opt_json) {
                push @results, '{ "by_file" : ';
            }
            push @results, xml_yaml_or_json_header($URL, $version, $elapsed_sec,
                                                   $sum_files, $sum_lines, $BY_FILE);
#           $ALREADY_SHOWED_HEADER = 1 unless $opt_sum_reports;
            # --sum-reports yields two xml or yaml files, one by
            # language and one by report file, each of which needs a header
        }
        if ($opt_xml) {
            if ($BY_FILE or ($report_type eq "by report file")) {
                push @results, "<files>";
            } else {
                push @results, "<languages>";
            }
        }
    } else {
        $header_line =~ s/,// if $opt_csv;
        push @results, output_header($header_line, $hyphen_line, $BY_FILE);
    }

    if ($Style eq "txt") {
        # column headers
        if (!$opt_3 and $BY_FILE) {
            my $spacing_n = $spacing_1 - 11;
            $data_line  = sprintf "%-${spacing_n}s ", $first_column;
        } else {
            $data_line  = sprintf "%-${spacing_1}s ", $first_column;
        }
        if ($BY_FILE) {
            $data_line .= sprintf "%${spacing_2}s "  , " "    ;
        } else {
            $data_line .= sprintf "%${spacing_2}s "  , "files";
        }
        my $PCT_symbol = "";
           $PCT_symbol = " \%" if $opt_by_percent;
        $data_line .= sprintf "%${spacing_2}s %${spacing_2}s %${spacing_2}s",
            "blank${PCT_symbol}"   ,
            "comment${PCT_symbol}" ,
            "code";
        $data_line .= sprintf " %8s   %14s",
            "scale"         ,
            "3rd gen. equiv"
              if $opt_3;
        if ($opt_md) {
            my @col_header  = ();
            if ($data_line =~ m{\s%}) {
                $data_line =~ s{\s%}{_%}g;
                foreach my $w ( split(' ', $data_line) ) {
                    $w =~ s{_%}{ %};
                    push @col_header, $w;
                }
            } else {
                push @col_header, split(' ', $data_line);
            }
            my @col_hyphens    = ( '-------:') x scalar(@col_header);
               $col_hyphens[0] =   ':-------'; # first column left justified
            push @results, join("|", @col_header );
            push @results, join("|", @col_hyphens);
        } else {
            push @results, $data_line;
            push @results, $hyphen_line;
        }
    }

    if ($opt_csv)  {
        my $header2;
        if ($BY_FILE) {
            $header2 = "language${DELIM}filename";
        } else {
            $header2 = "files${DELIM}language";
        }
        $header2 .= "${DELIM}blank${DELIM}comment${DELIM}code";
        $header2 .= "${DELIM}scale${DELIM}3rd gen. equiv" if $opt_3;
        $header2 .= ${DELIM} . '"' . $header_line . '"';
        push @results, $header2;
    }

    my $sum_scaled = 0;
    foreach my $lang_or_file (sort {
                                 $rhh_count->{$b}{'code'} <=>
                                 $rhh_count->{$a}{'code'}
                              or $a cmp $b
                                        }
                                   keys %{$rhh_count}) {
        next if $lang_or_file eq "by report file";
        my ($factor, $scaled);
        if ($BY_LANGUAGE or $BY_FILE) {
            $factor = 1;
            if ($BY_LANGUAGE) {
                if (defined $rh_scale->{$lang_or_file}) {
                    $factor = $rh_scale->{$lang_or_file};
                } else {
                    warn "No scale factor for $lang_or_file; using 1.00";
                }
            } else { # by individual code file
                if ($report_type ne "by report file") {
                    next unless defined $rhh_count->{$lang_or_file}{'lang'};
                    next unless defined $rh_scale->{$rhh_count->{$lang_or_file}{'lang'}};
                    $factor = $rh_scale->{$rhh_count->{$lang_or_file}{'lang'}};
                }
            }
            $scaled = $factor*$rhh_count->{$lang_or_file}{'code'};
        } else {
            if (!defined $rhh_count->{$lang_or_file}{'scaled'}) {
                $opt_3 = 0;
                # If we're summing together files previously generated
                # with --no3 then rhh_count->{$lang_or_file}{'scaled'}
                # this variable will be undefined.  That should only
                # happen when summing together by file however.
            } elsif ($BY_LANGUAGE) {
                warn "Missing scaled language info for $lang_or_file\n";
            }
            if ($opt_3) {
                $scaled =         $rhh_count->{$lang_or_file}{'scaled'};
                $factor = $scaled/$rhh_count->{$lang_or_file}{'code'};
            }
        }

        if ($BY_FILE) {
            my $clean_filename = rm_leading_tempdir($lang_or_file, \%TEMP_DIR);
               $clean_filename = xml_metachars($clean_filename) if $opt_xml;
            $data_line  = sprintf $Format{'1'}{$Style}, $clean_filename;
        } else {
            $data_line  = sprintf $Format{'2'}{$Style}, $lang_or_file;
        }
        $data_line .= sprintf $Format{3}{$Style}  ,
                        $rhh_count->{$lang_or_file}{'nFiles'} unless $BY_FILE;
        if ($opt_by_percent) {
          my $DEN = compute_denominator($opt_by_percent       ,
                        $rhh_count->{$lang_or_file}{'code'}   ,
                        $rhh_count->{$lang_or_file}{'comment'},
                        $rhh_count->{$lang_or_file}{'blank'}  );
          $data_line .= sprintf $Format{5}{$Style}  ,
              $rhh_count->{$lang_or_file}{'blank'}   / $DEN * 100,
              $rhh_count->{$lang_or_file}{'comment'} / $DEN * 100,
              $rhh_count->{$lang_or_file}{'code'}   ;
        } else {
          $data_line .= sprintf $Format{4}{$Style}  ,
              $rhh_count->{$lang_or_file}{'blank'}  ,
              $rhh_count->{$lang_or_file}{'comment'},
              $rhh_count->{$lang_or_file}{'code'}   ;
        }
        $data_line .= sprintf $Format{6}{$Style}  ,
            $factor                               ,
            $scaled if $opt_3;
        $sum_scaled  += $scaled if $opt_3;

        if ($opt_xml) {
            if (defined $rhh_count->{$lang_or_file}{'lang'}) {
                my $lang = $rhh_count->{$lang_or_file}{'lang'};
                if (!defined $languages->{$lang}) {
                    $languages->{$lang} = $lang;
                }
                $data_line.=' language="' . $lang . '" ';
            }
            if ($BY_FILE or ($report_type eq "by report file")) {
                push @results, "  <file " . $data_line . "/>";
            } else {
                push @results, "  <language " . $data_line . "/>";
            }
        } elsif ($opt_yaml or $opt_json) {
            my ($Q, $open_B, $close_B, $start, $C) = yaml_to_json_separators();
            if ($opt_yaml) {
                # YAML: force quoted language or filename in case these
                #       have embedded funny characters, issue #312
                push @results,"'" . rm_leading_tempdir($lang_or_file, \%TEMP_DIR). "' :$open_B";
            } else {
                push @results,"${Q}" . rm_leading_tempdir($lang_or_file, \%TEMP_DIR). "${Q} :$open_B";
            }
            push @results,"  ${Q}nFiles${Q}: " . $rhh_count->{$lang_or_file}{'nFiles'} . $C
                unless $BY_FILE;
            if ($opt_by_percent) {
              my $DEN = compute_denominator($opt_by_percent       ,
                            $rhh_count->{$lang_or_file}{'code'}   ,
                            $rhh_count->{$lang_or_file}{'comment'},
                            $rhh_count->{$lang_or_file}{'blank'}  );
              push @results,"  ${Q}blank_pct${Q}: "   .
                sprintf("%3.2f", $rhh_count->{$lang_or_file}{'blank'} / $DEN * 100) . $C;
              push @results,"  ${Q}comment_pct${Q}: " .
                sprintf("%3.2f", $rhh_count->{$lang_or_file}{'comment'} / $DEN * 100) . $C;
              push @results,"  ${Q}code${Q}: "    . $rhh_count->{$lang_or_file}{'code'}  . $C;
            } else {
              push @results,"  ${Q}blank${Q}: "   . $rhh_count->{$lang_or_file}{'blank'}   . $C;
              push @results,"  ${Q}comment${Q}: " . $rhh_count->{$lang_or_file}{'comment'} . $C;
              push @results,"  ${Q}code${Q}: "    . $rhh_count->{$lang_or_file}{'code'}    . $C;
            }
            push @results,"  ${Q}language${Q}: "  . $Q . $rhh_count->{$lang_or_file}{'lang'} . $Q . $C
                if $BY_FILE;
            if ($opt_3) {
                push @results, "  ${Q}scaled${Q}: " . $scaled . $C;
                push @results, "  ${Q}factor${Q}: " . $factor . $C;
            }
            if ($opt_json) { # replace the trailing comma with }, on the last line
                $results[-1] =~ s/,\s*$/},/;
            }
        } elsif ($opt_csv or $opt_md) {
            my $extra_3 = "";
               $extra_3 = "${DELIM}$factor${DELIM}$scaled" if $opt_3;
            my $first_column = undef;
            my $clean_name   = $lang_or_file;
            my $str;
            if ($opt_csv) {
                if ($BY_FILE) {
                    $first_column = $rhh_count->{$lang_or_file}{'lang'};
                    $clean_name   = rm_leading_tempdir($lang_or_file, \%TEMP_DIR);
                } else {
                    $first_column = $rhh_count->{$lang_or_file}{'nFiles'};
                }
                $str = $first_column   . ${DELIM} .
                       $clean_name     . ${DELIM};
            } else {
                if ($BY_FILE) {
                    $first_column = $rhh_count->{$lang_or_file}{'lang'};
                    $clean_name   = rm_leading_tempdir($lang_or_file, \%TEMP_DIR);
                    $str = $clean_name . ${DELIM};
                } else {
                    $first_column = $rhh_count->{$lang_or_file}{'nFiles'};
                    $str = $clean_name     . ${DELIM} .
                           $first_column   . ${DELIM};
                }
            }
            if ($opt_by_percent) {
              my $DEN = compute_denominator($opt_by_percent               ,
                            $rhh_count->{$lang_or_file}{'code'}   ,
                            $rhh_count->{$lang_or_file}{'comment'},
                            $rhh_count->{$lang_or_file}{'blank'}  );
              $str .= sprintf("%3.2f", $rhh_count->{$lang_or_file}{'blank'}   / $DEN * 100) . ${DELIM} .
                      sprintf("%3.2f", $rhh_count->{$lang_or_file}{'comment'} / $DEN * 100) . ${DELIM} .
                      $rhh_count->{$lang_or_file}{'code'};
            } else {
              $str .= $rhh_count->{$lang_or_file}{'blank'}  . ${DELIM} .
                      $rhh_count->{$lang_or_file}{'comment'}. ${DELIM} .
                      $rhh_count->{$lang_or_file}{'code'};
            }
            $str .= $extra_3;
            push @results, $str;

        } else {
            push @results, $data_line;
        }
    }

    my $avg_scale = 1;  # weighted average of scale factors
       $avg_scale = sprintf("%.2f", $sum_scaled / $sum_code)
            if $sum_code and $opt_3;

    if ($opt_xml) {
        $data_line = "";
        if (!$BY_FILE) {
            $data_line .= sprintf "sum_files=\"%d\" ", $sum_files;
        }
        if ($opt_by_percent) {
          my $DEN = compute_denominator($opt_by_percent    ,
                        $sum_code, $sum_comment, $sum_blank);
          $data_line .= sprintf $Format{'5'}{$Style},
              $sum_blank   / $DEN * 100,
              $sum_comment / $DEN * 100,
              $sum_code    ;
        } else {
          $data_line .= sprintf $Format{'4'}{$Style},
              $sum_blank   ,
              $sum_comment ,
              $sum_code    ;
        }
        $data_line .= sprintf $Format{'6'}{$Style},
            $avg_scale   ,
            $sum_scaled  if $opt_3;
        push @results, "  <total " . $data_line . "/>";

        if ($BY_FILE or ($report_type eq "by report file")) {
            push @results, "</files>";
        } else {
            foreach my $language (keys %{$languages}) {
                push @results, '  <language name="' . $language . '"/>';
            }
            push @results, "</languages>";
        }

        if (!$opt_by_file_by_lang or $ALREADY_SHOWED_XML_SECTION) {
            push @results, "</results>";
        } else {
            $ALREADY_SHOWED_XML_SECTION = 1;
        }
    } elsif ($opt_yaml or $opt_json) {
        my ($Q, $open_B, $close_B, $start, $C) = yaml_to_json_separators();
        push @results, "${Q}SUM${Q}: ${open_B}";
        if ($opt_by_percent) {
          my $DEN = compute_denominator($opt_by_percent    ,
                        $sum_code, $sum_comment, $sum_blank);
          push @results, "  ${Q}blank${Q}: "  . sprintf("%.2f", $sum_blank   / $DEN * 100) . $C;
          push @results, "  ${Q}comment${Q}: ". sprintf("%.2f", $sum_comment / $DEN * 100) . $C;
          push @results, "  ${Q}code${Q}: "   . $sum_code    . $C;
        } else {
          push @results, "  ${Q}blank${Q}: "  . $sum_blank   . $C;
          push @results, "  ${Q}comment${Q}: ". $sum_comment . $C;
          push @results, "  ${Q}code${Q}: "   . $sum_code    . $C;
        }
        push @results, "  ${Q}nFiles${Q}: " . $sum_files   . $C;
        if ($opt_3) {
            push @results, "  ${Q}scaled${Q}: " . $sum_scaled . $C;
            push @results, "  ${Q}factor${Q}: " . $avg_scale  . $C;
        }
        if ($opt_json) {
            $results[-1] =~ s/,\s*$/} }/;
            if ($opt_by_file_by_lang) {
                if ($ALREADY_SHOWED_HEADER) {
                    $results[-1] .= ' }';
                } else {
                    $results[-1] .= ', "by_lang" : {';
                }
            }
        }
    } elsif ($opt_csv) {
        my @entries = ();
        if ($opt_by_file) {
            push @entries, "SUM";
            push @entries, "";
        } else {
            push @entries, $sum_files;
            push @entries, "SUM";
        }
        if ($opt_by_percent) {
            my $DEN = compute_denominator($opt_by_percent    ,
                          $sum_code, $sum_comment, $sum_blank);
            push @entries, sprintf("%.2f", $sum_blank   / $DEN * 100);
            push @entries, sprintf("%.2f", $sum_comment / $DEN * 100);
        } else {
            push @entries, $sum_blank;
            push @entries, $sum_comment;
        }
        push @entries, $sum_code;
        if ($opt_3) {
            push @entries, $sum_scaled;
            push @entries, $avg_scale ;
        }
        my $separator = defined $opt_csv_delimiter ? $opt_csv_delimiter : ",";
        push @results, join($separator, @entries);
    } else {

        if ($BY_FILE) {
            $data_line  = sprintf "%-${spacing_0}s ", "SUM:"  ;
        } else {
            $data_line  = sprintf "%-${spacing_1}s ", "SUM:"  ;
            $data_line .= sprintf "%${spacing_2}d ", $sum_files;
        }
        if ($opt_by_percent) {
          my $DEN = compute_denominator($opt_by_percent    ,
                        $sum_code, $sum_comment, $sum_blank);
          $data_line .= sprintf $Format{'5'}{$Style},
              $sum_blank   / $DEN * 100,
              $sum_comment / $DEN * 100,
              $sum_code    ;
        } else {
          $data_line .= sprintf $Format{'4'}{$Style},
              $sum_blank   ,
              $sum_comment ,
              $sum_code    ;
        }
        $data_line .= sprintf $Format{'6'}{$Style},
            $avg_scale   ,
            $sum_scaled if $opt_3;
        if ($opt_md) {
            my @words = split(' ', $data_line);
            my $n_cols = scalar(@words);
#           my $n_cols = scalar(split(' ', $data_line));  # deprecated
            $data_line =~ s/\s+/\|/g;
            my @col_hyphens    = ( '--------') x $n_cols;
            push @results, join("|", @col_hyphens);
            push @results, $data_line   if $sum_files > 1 or $opt_sum_one;
            unshift @results, ( "cloc|$header_line", "--- | ---", "", );
        } else {
            push @results, $hyphen_line if $sum_files > 1 or $opt_sum_one;
            push @results, $data_line   if $sum_files > 1 or $opt_sum_one;
            push @results, $hyphen_line;
        }
    }
    write_xsl_file() if $opt_xsl and $opt_xsl eq $CLOC_XSL;
    $ALREADY_SHOWED_HEADER = 1 unless $opt_sum_reports;
    print "<- generate_report\n" if $opt_v > 2;
    return @results;
} # 1}}}
sub print_errors {                           # {{{1
    my ($rh_Error_Codes, # in
        $raa_errors    , # in
       ) = @_;

    print "-> print_errors\n" if $opt_v > 2;
    my %error_string = reverse(%{$rh_Error_Codes});
    my $nErrors      = scalar @{$raa_errors};
    warn sprintf "\n%d error%s:\n", plural_form(scalar @Errors);
    for (my $i = 0; $i < $nErrors; $i++) {
        warn sprintf "%s:  %s\n",
                     $error_string{ $raa_errors->[$i][0] },
                     $raa_errors->[$i][1] ;
    }
    print "<- print_errors\n" if $opt_v > 2;

} # 1}}}
sub write_lang_def {                         # {{{1
    my ($file                     ,
        $rh_Language_by_Extension , # in
        $rh_Language_by_Script    , # in
        $rh_Language_by_File      , # in
        $rhaa_Filters_by_Language , # in
        $rh_Not_Code_Extension    , # in
        $rh_Not_Code_Filename     , # in
        $rh_Scale_Factor          , # in
        $rh_EOL_Continuation_re   , # in
       ) = @_;

    print "-> write_lang_def($file)\n" if $opt_v > 2;
    my @outlines = ();

    foreach my $language (sort keys %{$rhaa_Filters_by_Language}) {
        next if $language =~ /(Brain|\(unknown\))/;
        next if defined $Extension_Collision{$language};
        push @outlines, $language;
        foreach my $filter (@{$rhaa_Filters_by_Language->{$language}}) {
            my $line = "";
            $line .= sprintf "    filter %s", $filter->[0];
            $line .= sprintf " %s", $filter->[1] if defined $filter->[1];
            # $filter->[0] == 'remove_between_general',
            #                 'remove_between_regex', and
            #                 'remove_matches_2re' have two args
            $line .= sprintf " %s", $filter->[2] if defined $filter->[2];
            # $filter->[0] == 'replace_between_regex' has three or four args
            $line .= sprintf " %s", $filter->[3] if defined $filter->[3];
            $line .= sprintf " %s", $filter->[4] if defined $filter->[4];
            push @outlines, $line;
        }

        # file extension won't appear if the extension maps to
        # multiple languages; work around this
        my $found = 0;
        foreach my $ext (sort keys %{$rh_Language_by_Extension}) {
            if ($language eq $rh_Language_by_Extension->{$ext}) {
                push @outlines, sprintf "    extension %s\n", $ext;
                $found = 1;
            }
        }
        if (!$found and $opt_write_lang_def_incl_dup) {
            foreach my $multilang (sort keys %Extension_Collision) {
                my %Languages = map { $_ => 1 } split('/', $multilang);
                next unless $Languages{$language};
                foreach my $ext (@{$Extension_Collision{$multilang}}) {
                    push @outlines, sprintf "    extension %s\n", $ext;
                }
            }
        }

        foreach my $filename (sort keys %{$rh_Language_by_File}) {
            if ($language eq $rh_Language_by_File->{$filename}) {
                push @outlines, sprintf "    filename %s\n", $filename;
            }
        }
        foreach my $script_exe (sort keys %{$rh_Language_by_Script}) {
            if ($language eq $rh_Language_by_Script->{$script_exe}) {
                push @outlines, sprintf "    script_exe %s\n", $script_exe;
            }
        }
        push @outlines, sprintf "    3rd_gen_scale %.2f\n", $rh_Scale_Factor->{$language};
        if (defined $rh_EOL_Continuation_re->{$language}) {
            push @outlines, sprintf "    end_of_line_continuation %s\n",
                $rh_EOL_Continuation_re->{$language};
        }
    }

    write_file($file, {}, @outlines);
    print "<- write_lang_def\n" if $opt_v > 2;
} # 1}}}
sub read_lang_def {                          # {{{1
    my ($file                     ,
        $rh_Language_by_Extension , # out
        $rh_Language_by_Script    , # out
        $rh_Language_by_File      , # out
        $rhaa_Filters_by_Language , # out
        $rh_Not_Code_Extension    , # out
        $rh_Not_Code_Filename     , # out
        $rh_Scale_Factor          , # out
        $rh_EOL_Continuation_re   , # out
        $rh_EOL_abc,
       ) = @_;


    print "-> read_lang_def($file)\n" if $opt_v > 2;

    my $language = "";
    my @lines = read_file($file);
    foreach (@lines) {
        next if /^\s*#/ or /^\s*$/;

        $_ = lc $_ if $ON_WINDOWS and /^\s+(filename|extension)\s/;

        if (/^(\w+.*?)\s*$/) {
            $language = $1;
            next;
        }
        die "Missing computer language name, line $. of $file\n"
            unless $language;

        if      (/^\s{4}filter\s+(remove_between_(general|2re|regex))
                       \s+(\S+)\s+(\S+)\s*$/x) {
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $3 , $4 ]

        } elsif (/^\s{4}filter\s+(replace_between_regex)
                   \s+(\S+)\s+(\S+)\s+(\S+|\".*\")\s+(\S+)\s*$/x) {
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $2 , $3 , $4 , $5]

        } elsif (/^\s{4}filter\s+(replace_between_regex)
                       \s+(\S+)\s+(\S+)\s+(.*?)\s*$/x) {
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $2 , $3 , $4 ]

        } elsif (/^\s{4}filter\s+(replace_regex)\s+(\S+)\s*$/) {
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $2 , '' ]

        } elsif (/^\s{4}filter\s+(replace_regex)
                       \s+(\S+)\s+(.+?)\s*$/x) {
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $2 , $3 ]

        } elsif (/^\s{4}filter\s+(\w+)\s*$/) {
            push @{$rhaa_Filters_by_Language->{$language}}, [ $1 ]

        } elsif (/^\s{4}filter\s+(\w+)\s+(.*?)\s*$/) {
            push @{$rhaa_Filters_by_Language->{$language}}, [ $1 , $2 ]

        } elsif (/^\s{4}extension\s+(\S+)\s*$/) {
            if (defined $rh_Language_by_Extension->{$1}) {
                die "File extension collision:  $1 ",
                    "maps to languages '$rh_Language_by_Extension->{$1}' ",
                    "and '$language'\n" ,
                    "Edit $file and remove $1 from one of these two ",
                    "language definitions.\n";
            }
            $rh_Language_by_Extension->{$1} = $language;

        } elsif (/^\s{4}filename\s+(\S+)\s*$/) {
            $rh_Language_by_File->{$1} = $language;

        } elsif (/^\s{4}script_exe\s+(\S+)\s*$/) {
            $rh_Language_by_Script->{$1} = $language;

        } elsif (/^\s{4}3rd_gen_scale\s+(\S+)\s*$/) {
            $rh_Scale_Factor->{$language} = $1;

        } elsif (/^\s{4}end_of_line_continuation\s+(\S+)\s*$/) {
            $rh_EOL_Continuation_re->{$language} = $1;

        } else {
            die "Unexpected data line $. of $file:\n$_\n";
        }

    }
    print "<- read_lang_def\n" if $opt_v > 2;
} # 1}}}
sub merge_lang_def {                         # {{{1
    my ($file                     ,
        $rh_Language_by_Extension , # in/out
        $rh_Language_by_Script    , # in/out
        $rh_Language_by_File      , # in/out
        $rhaa_Filters_by_Language , # in/out
        $rh_Not_Code_Extension    , # in/out
        $rh_Not_Code_Filename     , # in/out
        $rh_Scale_Factor          , # in/out
        $rh_EOL_Continuation_re   , # in/out
        $rh_EOL_abc,
       ) = @_;


    print "-> merge_lang_def($file)\n" if $opt_v > 2;

    my $language        = "";
    my $already_know_it = undef;
    my @lines = read_file($file);
    foreach (@lines) {
        next if /^\s*#/ or /^\s*$/;

        $_ = lc $_ if $ON_WINDOWS and /^\s+(filename|extension)\s/;

        if (/^(\w+.*?)\s*$/) {
            $language = $1;
            $already_know_it = defined $rh_Scale_Factor->{$language};
            next;
        }
        die "Missing computer language name, line $. of $file\n"
            unless $language;

        if      (/^\s{4}filter\s+(remove_between_(general|2re|regex))
                       \s+(\S+)\s+(\S+)\s*$/x) {
            next if $already_know_it;
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $3 , $4 ]

        } elsif (/^\s{4}filter\s+(replace_between_regex)
                   \s+(\S+)\s+(\S+)\s+(\S+|\".*\")\s+(\S+)\s*$/x) {
            next if $already_know_it;
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $2 , $3 , $4 , $5]

        } elsif (/^\s{4}filter\s+(replace_between_regex)
                       \s+(\S+)\s+(\S+)\s+(.*?)\s*$/x) {
            next if $already_know_it;
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $2 , $3 , $4 ]

        } elsif (/^\s{4}filter\s+(replace_regex)
                       \s+(\S+)\s+(.+?)\s*$/x) {
            next if $already_know_it;
            push @{$rhaa_Filters_by_Language->{$language}}, [
                  $1 , $2 , $3 ]

        } elsif (/^\s{4}filter\s+(\w+)\s*$/) {
            next if $already_know_it;
            push @{$rhaa_Filters_by_Language->{$language}}, [ $1 ]

        } elsif (/^\s{4}filter\s+(\w+)\s+(.*?)\s*$/) {
            next if $already_know_it;
            push @{$rhaa_Filters_by_Language->{$language}}, [ $1 , $2 ]

        } elsif (/^\s{4}extension\s+(\S+)\s*$/) {
            next if $already_know_it;
            if (defined $rh_Language_by_Extension->{$1}) {
                die "File extension collision:  $1 ",
                    "maps to languages '$rh_Language_by_Extension->{$1}' ",
                    "and '$language'\n" ,
                    "Edit $file and remove $1 from one of these two ",
                    "language definitions.\n";
            }
            $rh_Language_by_Extension->{$1} = $language;

        } elsif (/^\s{4}filename\s+(\S+)\s*$/) {
            next if $already_know_it;
            $rh_Language_by_File->{$1} = $language;

        } elsif (/^\s{4}script_exe\s+(\S+)\s*$/) {
            next if $already_know_it;
            $rh_Language_by_Script->{$1} = $language;

        } elsif (/^\s{4}3rd_gen_scale\s+(\S+)\s*$/) {
            next if $already_know_it;
            $rh_Scale_Factor->{$language} = $1;

        } elsif (/^\s{4}end_of_line_continuation\s+(\S+)\s*$/) {
            next if $already_know_it;
            $rh_EOL_Continuation_re->{$language} = $1;

        } else {
            die "Unexpected data line $. of $file:\n$_\n";
        }

    }
    print "<- merge_lang_def\n" if $opt_v > 2;
} # 1}}}
sub print_extension_info {                   # {{{1
    my ($extension,) = @_;
    if ($extension) {  # show information on this extension
        foreach my $ext (sort {lc $a cmp lc $b or $a cmp $b } keys %Language_by_Extension) {
            # Language_by_Extension{f}    = 'Fortran 77'
            next if $Language_by_Extension{$ext} =~ /Brain/;
            printf "%-15s -> %s\n", $ext, $Language_by_Extension{$ext}
                if $ext =~ m{$extension}i;
        }
    } else {           # show information on all  extensions
        foreach my $ext (sort {lc $a cmp lc $b or $a cmp $b } keys %Language_by_Extension) {
            next if $Language_by_Extension{$ext} =~ /Brain/;
            # Language_by_Extension{f}    = 'Fortran 77'
            printf "%-15s -> %s\n", $ext, $Language_by_Extension{$ext};
        }
    }
} # 1}}}
sub print_language_info {                    # {{{1
    my ($language,
        $prefix ,) = @_;
    my %extensions = (); # the subset matched by the given $language value
    if ($language) {  # show information on this language
        foreach my $ext (sort {lc $a cmp lc $b or $a cmp $b } keys %Language_by_Extension) {
            # Language_by_Extension{f}    = 'Fortran 77'
            push @{$extensions{$Language_by_Extension{$ext}} }, $ext
                if lc $Language_by_Extension{$ext} eq lc $language;
#               if $Language_by_Extension{$ext} =~ m{$language}i;
        }
    } else {          # show information on all  languages
        foreach my $ext (sort {lc $a cmp lc $b  or $a cmp $b } keys %Language_by_Extension) {
            # Language_by_Extension{f}    = 'Fortran 77'
            push @{$extensions{$Language_by_Extension{$ext}} }, $ext
        }
    }

    # add exceptions (one file extension mapping to multiple languages)
    if (!$language or $language =~ /^(Objective-C|MATLAB|Mathematica|MUMPS|Mercury)$/i) {
        push @{$extensions{'Objective-C'}}, "m";
        push @{$extensions{'MATLAB'}}     , "m";
        push @{$extensions{'Mathematica'}}, "m";
        push @{$extensions{'MUMPS'}}      , "m";
        delete $extensions{'MATLAB/Mathematica/Objective-C/MUMPS/Mercury'};
    }
    if (!$language or $language =~ /^(Lisp|OpenCL)$/i) {
        push @{$extensions{'Lisp'}}  , "cl";
        push @{$extensions{'OpenCL'}}, "cl";
        delete $extensions{'Lisp/OpenCL'};
    }
    if (!$language or $language =~ /^(Lisp|Julia)$/i) {
        push @{$extensions{'Lisp'}}  , "jl";
        push @{$extensions{'Julia'}} , "jl";
        delete $extensions{'Lisp/Julia'};
    }
    if (!$language or $language =~ /^(Perl|Prolog)$/i) {
        push @{$extensions{'Perl'}}  , "pl";
        push @{$extensions{'Prolog'}}, "pl";
        delete $extensions{'Perl/Prolog'};
    }
    if (!$language or $language =~ /^(Raku|Prolog)$/i) {
        push @{$extensions{'Perl'}}  , "p6";
        push @{$extensions{'Prolog'}}, "p6";
        delete $extensions{'Perl/Prolog'};
    }
    if (!$language or $language =~ /^(IDL|Qt Project|Prolog|ProGuard)$/i) {
        push @{$extensions{'IDL'}}       , "pro";
        push @{$extensions{'Qt Project'}}, "pro";
        push @{$extensions{'Prolog'}}    , "pro";
        push @{$extensions{'ProGuard'}}  , "pro";
        delete $extensions{'IDL/Qt Project/Prolog/ProGuard'};
    }
    if (!$language or $language =~ /^(D|dtrace)$/i) {
        push @{$extensions{'D'}}       , "d";
        push @{$extensions{'dtrace'}}  , "d";
        delete $extensions{'D/dtrace'};
    }
    if (!$language or $language =~ /^Forth$/) {
        push @{$extensions{'Forth'}}     , "fs";
        push @{$extensions{'Forth'}}     , "f";
        push @{$extensions{'Forth'}}     , "for";
        delete $extensions{'Fortran 77/Forth'};
        delete $extensions{'F#/Forth'};
    }
    if (!$language or $language =~ /^Fortran 77$/) {
        push @{$extensions{'Fortran 77'}}, "f";
        push @{$extensions{'Fortran 77'}}, "for";
        push @{$extensions{'F#'}}        , "fs";
        delete $extensions{'Fortran 77/Forth'};
    }
    if (!$language or $language =~ /^F#$/) {
        push @{$extensions{'F#'}}        , "fs";
        delete $extensions{'F#/Forth'};
    }
    if (!$language or $language =~ /^(Verilog-SystemVerilog|Coq)$/) {
        push @{$extensions{'Coq'}}                   , "v";
        push @{$extensions{'Verilog-SystemVerilog'}} , "v";
        delete $extensions{'Verilog-SystemVerilog/Coq'};
    }
    if (!$language or $language =~ /^(TypeScript|Qt Linguist)$/) {
        push @{$extensions{'TypeScript'}}  , "ts";
        push @{$extensions{'Qt Linguist'}} , "ts";
        delete $extensions{'TypeScript/Qt Linguist'};
    }
    if (!$language or $language =~ /^(Qt|Glade)$/) {
        push @{$extensions{'Glade'}} , "ui";
        push @{$extensions{'Qt'}}    , "ui";
        delete $extensions{'Qt/Glade'};
    }
    if (!$language or $language =~ /^(C#|Smalltalk)$/) {
        push @{$extensions{'C#'}}           , "cs";
        push @{$extensions{'Smalltalk'}}    , "cs";
        delete $extensions{'C#/Smalltalk'};
    }
    if (!$language or $language =~ /^(Visual\s+Basic|TeX|Apex\s+Class)$/i) {
        push @{$extensions{'Visual Basic'}} , "cls";
        push @{$extensions{'TeX'}}          , "cls";
        push @{$extensions{'Apex Class'}}   , "cls";
        delete $extensions{'Visual Basic/TeX/Apex Class'};
    }
    if (!$language or $language =~ /^(Ant)$/i) {
        push @{$extensions{'Ant'}}  , "build.xml";
        delete $extensions{'Ant/XML'};
    }
    if (!$language or $language =~ /^(Scheme|SaltStack)$/i) {
        push @{$extensions{'Scheme'}}    , "sls";
        push @{$extensions{'SaltStack'}} , "sls";
        delete $extensions{'Scheme/SaltStack'};
    }
    if ($opt_explain) {
        return unless $extensions{$language};
        if ($prefix) {
            printf "%s %s\n", $prefix, join(", ", @{$extensions{$language}});
        } else {
            printf "%-26s (%s)\n", $language, join(", ", @{$extensions{$language}});
        }
    } else {
        if (%extensions) {
            foreach my $lang (sort {lc $a cmp lc $b } keys %extensions) {
                next if $lang =~ /Brain/;
                if ($prefix) {
                    printf "%s %s\n", $prefix, join(", ", @{$extensions{$lang}});
                } else {
                    printf "%-26s (%s)\n", $lang, join(", ", @{$extensions{$lang}});
                }
            }
        }
    }
} # 1}}}
sub print_language_filters {                 # {{{1
    my ($language,) = @_;
    if (!$Filters_by_Language{$language} or
        !@{$Filters_by_Language{$language}}) {
        warn "Unknown language: $language\n";
        warn "Use --show-lang to list all defined languages.\n";
        return;
    }
    printf "%s\n", $language;
    foreach my $filter (@{$Filters_by_Language{$language}}) {
        printf "    filter %s", $filter->[0];
        printf "  %s", $filter->[1] if defined $filter->[1];
        printf "  %s", $filter->[2] if defined $filter->[2];
        printf "  %s", $filter->[3] if defined $filter->[3];
        printf "  %s", $filter->[4] if defined $filter->[4];
        print  "\n";
    }
    print_language_info($language, "    extensions:");
} # 1}}}
sub top_level_SMB_dir {                      # {{{1
    # Ref https://github.com/AlDanial/cloc/issues/392, if the
    # user supplies a directory name which is an SMB mount
    # point, this directory will appear to File::Find as
    # though it is empty unless $File::Find::dont_use_nlink
    # is set to 1.  This subroutine checks to see if any SMB
    # mounts (identified from stat()'s fourth entry, nlink,
    # having a value of 2) were passed in on the command line.

    my ($ra_arg_list,) = @_;  # in user supplied file name, directory name, git hash, etc
    foreach my $entry (@{$ra_arg_list}) {
        next unless is_dir($entry);
        # gets here if $entry is a directory; now get its nlink value
        my $nlink;
        if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
            my $stats = statL($entry);
            $nlink = $stats->{nlink} if defined $stats;
        } else {
            my @stats = stat($entry);
            $nlink = $stats[3];
        }
        return 1 if $nlink == 2;  # meaning it is an SMB mount
    }
    return 0;
}
# 1}}}
sub get_git_metadata {                       # {{{1
    my ($ra_arg_list,             # in  file name, directory name and/or
                                  #     git commit hash to examine
        $rh_git_metadata) = @_;   # out repo info
    # Capture git information where possible--origin, branch, commit hash.
    my $prt_args = join(",", @{$ra_arg_list});
    print "-> get_git_metadata($prt_args)\n" if $opt_v > 2;
    foreach my $arg (@{$ra_arg_list}) {
        next if is_file($arg);
        my $origin = `git remote get-url origin 2>&1`;
        next if $origin =~ /^fatal:/;
        chomp($rh_git_metadata->{$arg}{"origin"} = $origin);
        chomp($rh_git_metadata->{$arg}{"branch"} = `git symbolic-ref --short HEAD`);
        if (is_dir($arg)) {
            chomp($rh_git_metadata->{$arg}{"commit"}   = `git rev-parse HEAD`);
        } else {
            chomp($rh_git_metadata->{$arg}{"commit"}   = `git rev-parse $arg`);
        }
    }
    print "<- get_git_metadata()\n" if $opt_v > 2;
} # 1}}}
sub replace_git_hash_with_tarfile {          # {{{1
    my ($ra_arg_list,             # in  file name, directory name and/or
                                  #     git commit hash to examine
        $ra_git_similarity) = @_; # out only if --opt-git-diff-simindex
    # replace git hashes in $ra_arg_list with tar files
    # Diff mode and count mode behave differently:
    #   Diff:
    #       file  git_hash
    #          Extract file from the git repo and only compare to it.
    #       git_hash1  git_hash2
    #          Get listings of all files in git_hash1 and git_hash2.
    #            git ls-tree --name-only -r *git_hash1*
    #            git ls-tree --name-only -r *git_hash2*
    #          Next, get listings of files that changed with git_hash1
    #          and git_hash2.
    #            git diff-tree -r --no-commit-id --name-only *git_hash1* *git_hash2*
    #          Finally, make two tar files of git repos1 and 2 where the file
    #          listing is the union of changes.
    #            git archive -o tarfile1 *git_hash1* \
    #               <union of files that changed and exist in this commit>
    #            git archive -o tarfile2 *git_hash2* \
    #               <union of files that changed and exist in this commit>
    #          To avoid "Argument list too long" error, repeat the git
    #          archive step with chunks of 30,000 files at a time then
    #          merge the tar files as the final step.
    #   Regular count:
    #       Simply make a tar file of all files in the git repo.

    my $prt_args = join(",", @{$ra_arg_list});
    print "-> replace_git_hash_with_tarfile($prt_args)\n" if $opt_v > 2;
#print "ra_arg_list 1: @{$ra_arg_list}\n";

    my $hash_regex = qr/^([a-f\d]{5,40}|master|HEAD)(~\d+)?$/;
    my %replacement_arg_list = ();

    # early exit if none of the inputs look like git hashes
    my %git_hash = ();
    my $i = 0;
    foreach my $file_or_dir (@{$ra_arg_list}) {
        ++$i;
        if (can_read($file_or_dir)) { # readable file or dir; not a git hash
            $replacement_arg_list{$i} = $file_or_dir;
            next;
        } elsif ($opt_force_git or $file_or_dir =~ m/$hash_regex/) {
            $git_hash{$file_or_dir} = $i;
        } # else the input can't be understood; ignore for now
    }
    return unless %git_hash;

#   my $have_tar_git = external_utility_exists($ON_WINDOWS ? "unzip" : "tar --version") &&
    my $have_tar_git = external_utility_exists("tar --version") &&
                       external_utility_exists("git --version");
    if (!$have_tar_git) {
        warn "One or more inputs looks like a git hash but " .
             "either git or tar is unavailable.\n";
        return;
    }

    my %repo_listing = ();  # $repo_listing{hash}{files} = 1;
    foreach my $hash (sort keys %git_hash) {
        my $git_list_cmd = "git ls-tree --name-only -r ";
        if ($hash =~ m/(.*?):(.*?)$/) {
            # requesting specific file(s) from this hash; grep for them
            # Note:  this capability not fully implemented yet
            $git_list_cmd .= "$1|grep '$2'";
        } else {
            $git_list_cmd .= $hash;
        }
        print "$git_list_cmd\n" if $opt_v;
        foreach my $file (`$git_list_cmd`) {
            $file =~ s/\s+$//;
            $repo_listing{$hash}{$file} = 1;
        }
    }

    # logic for each of the modes
    if ($opt_diff) {
#print "A DIFF\n";
        # set the default git diff algorithm
        $opt_git_diff_rel = 1 unless $opt_git_diff_all or
                                     $opt_git_diff_simindex;
        # is it git to git, or git to file/dir ?
        my ($Left, $Right) = @{$ra_arg_list};

#use Data::Dumper;
#print "diff_listing= "; print Dumper(\%diff_listing);
#print "git_hash= "; print Dumper(\%git_hash);
        if ($git_hash{$Left} and $git_hash{$Right}) {
#print "A DIFF git-to-git\n";
            # git to git
            # first make a union of all files that have changed in both commits
            my %files_union = ();

            my @left_files  = ();
            my @right_files = ();
            if ($opt_git_diff_rel) {
                # Strategy 1:  Union files are what git consinders have changed
                #              between the two commits.
                my $git_list_cmd = "git diff-tree -r --no-commit-id --name-only $Left $Right";
                # print "$git_list_cmd\n" if $opt_v;
                foreach my $file (`$git_list_cmd`) {
                    chomp($file);
                    $files_union{$file} = 1;
                }
            } elsif ($opt_git_diff_all) {
                # Strategy 2:  Union files all files in both repos.
                foreach my $file (keys %{$repo_listing{$Left }},
                                  keys %{$repo_listing{$Right}}) {
                   $files_union{$file} = 1;
                }
            } elsif ($opt_git_diff_simindex) {
                # Strategy 3:  Use git's own similarity index to figure
                #              out which files to compare.
                git_similarity_index($Left              , # in
                                     $Right             , # in
                                    \@left_files        , # out
                                    \@right_files       , # out
                                     $ra_git_similarity); # out

            }

#use Data::Dumper;
#print "files_union =\n", Dumper(\%files_union);
#print "repo_listing=\n", Dumper(\%repo_listing);

            # then make truncated tar files of those union files which
            # actually exist in each repo
            foreach my $file (sort keys %files_union) {
                push @left_files , $file if $repo_listing{$Left }{$file};
                push @right_files, $file if $repo_listing{$Right}{$file};
            }
            # backslash whitespace, weird chars within file names (#257, #284)

#           my @Lfiles= map {$_ =~ s/([\s\(\)\[\]{}';\^\$\?])/\\$1/g; $_}   @left_files;
#           my @Lfiles= @left_files;
            if(scalar(@left_files) > 0) {
                $replacement_arg_list{$git_hash{$Left}}  = git_archive($Left , \@left_files);
            } else {
                # In the right side commit ONLY file(s) was added, so no file(s) will exist in the left side commit.
                # Create empty TAR to detect added lines of code.
                $replacement_arg_list{$git_hash{$Left}} = empty_tar();
            }
#           $replacement_arg_list{$git_hash{$Left}}  = git_archive($Left , \@Lfiles);
#           my @Rfiles= map {$_ =~ s/([\s\(\)\[\]{}';\^\$\?])/\\$1/g; $_}   @right_files ;
#           my @Rfiles= @right_files ;
#use Data::Dumper;
#print Dumper('left' , \@left_files);
#print Dumper('right', \@right_files);
#die;

            if(scalar(@right_files) > 0) {
                $replacement_arg_list{$git_hash{$Right}} = git_archive($Right, \@right_files);
            } else {
                 # In the left side commit ONLY file(s) was deleted, so file(s) will not exist in right side commit.
                 # Create empty TAR to detect removed lines of code.
                 $replacement_arg_list{$git_hash{$Right}} = empty_tar();
            }
#           $replacement_arg_list{$git_hash{$Right}} = git_archive($Right, \@Rfiles);
#write_file("/tmp/Lfiles.txt", {}, sort @Lfiles);
#write_file("/tmp/Rfiles.txt", {}, sort @Rfiles);
#write_file("/tmp/files_union.txt", {}, sort keys %files_union);

        } else {
#print "A DIFF git-to-file or file-to-git Left=$Left Right=$Right\n";
            # git to file/dir or file/dir to git
            if      ($git_hash{$Left}  and $repo_listing{$Left}{$Right} ) {
#print "A DIFF 1\n";
                # $Left is a git hash and $Right is a file
                $replacement_arg_list{$git_hash{$Left}}  = git_archive($Left, $Right);
            } elsif ($git_hash{$Right} and $repo_listing{$Right}{$Left}) {
#print "A DIFF 2\n";
                # $Left is a file and $Right is a git hash
                $replacement_arg_list{$git_hash{$Right}} = git_archive($Right, $Left);
            } elsif ($git_hash{$Left}) {
#print "A DIFF 3\n";
                # assume Right is a directory; tar the entire git archive at this hash
                $replacement_arg_list{$git_hash{$Left}}  = git_archive($Left, "");
            } else {
#print "A DIFF 4\n";
                # assume Left  is a directory; tar the entire git archive at this hash
                $replacement_arg_list{$git_hash{$Right}} = git_archive($Right, "");
            }
        }
    } else {
#print "B COUNT\n";
        foreach my $hash (sort keys %git_hash) {
            $replacement_arg_list{$git_hash{$hash}} = git_archive($hash);
        }
    }
# print "git_hash= "; print Dumper(\%git_hash);
#print "repo_listing= "; print Dumper(\%repo_listing);

    # replace the input arg list with the new one
    @{$ra_arg_list} = ();
    foreach my $index (sort {$a <=> $b} keys %replacement_arg_list) {
        push @{$ra_arg_list}, $replacement_arg_list{$index};
    }

#print "ra_arg_list 2: @{$ra_arg_list}\n";
    print "<- replace_git_hash_with_tarfile()\n" if $opt_v > 2;
} # 1}}}
sub git_similarity_index {                   # {{{
    my ($git_hash_Left    ,       # in
        $git_hash_Right   ,       # in
        $ra_left_files    ,       # out
        $ra_right_files   ,       # out
        $ra_git_similarity) = @_; # out
    die "this option is not yet implemented";
    print "-> git_similarity_index($git_hash_Left, $git_hash_Right)\n" if $opt_v > 2;
    my $cmd = "git diff -M --name-status $git_hash_Left $git_hash_Right";
    print  $cmd, "\n" if $opt_v;
    open(GSIM, "$cmd |") or die "Unable to run $cmd  $!";
    while (<GSIM>) {
        print "git similarity> $_";
    }
    close(GSIM);
    print "<- git_similarity_index\n" if $opt_v > 2;
} # 1}}}
sub empty_tar {                              # {{{1
    my ($Tarfh, $Tarfile);
    if ($opt_sdir) {
      File::Path::mkpath($opt_sdir) unless is_dir($opt_sdir);
      ($Tarfh, $Tarfile) = tempfile(UNLINK => 1, DIR => $opt_sdir, SUFFIX => $ON_WINDOWS ? '.zip' : '.tar');  # delete on exit
    } else {
      ($Tarfh, $Tarfile) = tempfile(UNLINK => 1, SUFFIX => $ON_WINDOWS ? '.zip' : '.tar');  # delete on exit
    }
    my $cmd = $ON_WINDOWS ? "type nul > $Tarfile" : "tar -cf $Tarfile -T /dev/null";
    print  $cmd, "\n" if $opt_v;
    system $cmd;
    if (!can_read($Tarfile)) {
        # not readable
        die "Failed to create empty tarfile.";
    }

    return $Tarfile;
} # 1}}}
sub git_archive {                            # {{{1
    # Invoke 'git archive' as a system command to create a tar file
    # using the given argument(s).
    my ($A1, $A2) = @_;
    print "-> git_archive($A1)\n" if $opt_v > 2;

    my $args = undef;
    my @File_Set = ( );
    my $n_sets   = 1;
    if (ref $A2 eq 'ARRAY') {
        # Avoid "Argument list too long" for the git archive command
        # by splitting the inputs into sets of 10,000 files (issue 273).
        my $FILES_PER_ARCHIVE = 1_000;
           $FILES_PER_ARCHIVE =   100 if $ON_WINDOWS; # github.com/AlDanial/cloc/issues/404

        my $n_files  = scalar(@{$A2});
        $n_sets = $n_files/$FILES_PER_ARCHIVE;
        $n_sets = 1 + int($n_sets) if $n_sets > int($n_sets);
        $n_sets = 1 if !$n_sets;
        foreach my $i (0..$n_sets-1) {
            @{$File_Set[$i]} = ( );
            my $start = $i*$FILES_PER_ARCHIVE;
            my $end   = smaller(($i+1)*$FILES_PER_ARCHIVE, $n_files) - 1;
            # Wrap each file name in single quotes to protect spaces
            # and other odd characters.  File names that themselves have
            # single quotes are instead wrapped in double quotes.  File
            # names with both single and double quotes... jeez.
            foreach my $fname (@{$A2}[$start .. $end]) {
                if      ($fname =~ /^".*?\\".*?"$/) {
                    # git pre-handles filenames with double quotes by backslashing
                    # each double quote then surrounding entire name in double
                    # quotes; undo this otherwise archive command crashes
                    $fname =~ s/\\"/"/g;
                    $fname =~ s/^"(.*)"$/$1/;
                } elsif ($fname =~ /'/ or $ON_WINDOWS) {
                    push @{$File_Set[$i]}, "\"$fname\"";
                } else {
                    push @{$File_Set[$i]}, "'$fname'";
                }
            }
            unshift @{$File_Set[$i]}, "$A1 ";  # prepend git hash to beginning of list

##xx#        # don't include \$ in the regex because git handles these correctly
#            # to each word in @{$A2}[$start .. $end]: first backslash each
#            # single quote, then wrap all entries in single quotes (#320)
#            push @File_Set,
#                 "$A1 " . join(" ", map {$_ =~ s/'/\'/g; $_ =~ s/^(.*)$/'$1'/g; $_}
##                "$A1 " . join(" ", map {$_ =~ s/([\s\(\)\[\]{}';\^\?])/\\$1/g; $_}
#                              @{$A2}[$start .. $end]);
        }
    } else {
        if (defined $A2) {
            push @{$File_Set[0]}, "$A1 $A2";
        } else {
            push @{$File_Set[0]}, "$A1";
        }
    }

    my $files_this_commit = join(" ", @{$File_Set[0]});
    print "   git_archive(file_set[0]=$files_this_commit)\n" if $opt_v > 2;
    my ($Tarfh, $Tarfile);
    if ($opt_sdir) {
      File::Path::mkpath($opt_sdir) unless is_dir($opt_sdir);
      ($Tarfh, $Tarfile) = tempfile(UNLINK => 1, DIR => $opt_sdir, SUFFIX => '.tar');  # delete on exit
    } else {
      ($Tarfh, $Tarfile) = tempfile(UNLINK => 1, SUFFIX => '.tar');  # delete on exit
    }
    my $cmd = "git archive -o $Tarfile $files_this_commit";
    print  $cmd, "\n" if $opt_v;
    system $cmd;
    if (!can_read($Tarfile) or !get_size($Tarfile)) {
        # not readable, or zero sized
        die "Failed to create tarfile of files from git.";
    }
    if ($n_sets > 1) {
        if ($ON_WINDOWS) {
            my @tar_files = ( $Tarfile );
            my $start_dir = cwd;
            foreach my $i (1..$n_sets-1) {
                my $fname = sprintf "%s_extra_%08d", $Tarfile, $i;
                my $files_this_commit = join(" ", @{$File_Set[$i]});
                my $cmd = "git archive -o $fname $files_this_commit";
                print  $cmd, "\n" if $opt_v;
                system $cmd;
                push @tar_files, $fname;
            }
            # Windows tar can't combine tar files so expand
            # them all to one directory then re-tar
            my $extract_dir = tempdir( CLEANUP => 0 );  # 1 = delete on exit
            chdir "$extract_dir";
            foreach my $T (@tar_files) {
                next unless is_file($T) and get_size($T);
                my $cmd = "tar -x -f \"$T\"";
                print  $cmd, "\n" if $opt_v;
                system $cmd;
                unlink "$T";
            }
            chdir "..";
            $Tarfile .= ".final.tar";
            my $cmd = "tar -c -f \"${Tarfile}\" \"$extract_dir\"";
            print  $cmd, "\n" if $opt_v;
            system $cmd;
            chdir "$start_dir";
        } else {
            foreach my $i (1..$n_sets-1) {
                my $files_this_commit = join(" ", @{$File_Set[$i]});
                my $cmd = "git archive -o ${Tarfile}_extra $files_this_commit";
                print  $cmd, "\n" if $opt_v;
                system $cmd;
                # and merge into the first one
                $cmd = "tar -A -f ${Tarfile} ${Tarfile}_extra";
                print  $cmd, "\n" if $opt_v;
                system $cmd;
            }
            unlink "${Tarfile}_extra";
        }
    }
    print "<- git_archive() made $Tarfile\n" if $opt_v > 2;
    return $Tarfile
} # 1}}}
sub smaller {                                # {{{1
    my( $a, $b ) = @_;
    return $a < $b ? $a : $b;
} # 1}}}
sub lower_on_Windows {                       # {{{1
    # If on Unix(-like), do nothing, just return the input.
    # If on Windows, return a lowercase version of the file
    # and also update %upper_lower_map with this new entry.
    # Needed in make_file_list() because the full file list
    # isn't known until the end of that routine--where
    # %upper_lower_map is ordinarily populated.
    my ($path,) = @_;
    return $path unless $ON_WINDOWS;
    my $lower = lc $path;
    $upper_lower_map{$lower} = $path;
    return $lower;
}
# }}}
sub make_file_list {                         # {{{1
    my ($ra_arg_list,  # in   file and/or directory names to examine
        $iteration  ,  # in   0 if only called once, 1 or 2 if twice for diff
        $rh_Err     ,  # in   hash of error codes
        $raa_errors ,  # out  errors encountered
        $rh_ignored ,  # out  files not recognized as computer languages
        ) = @_;
    print "-> make_file_list(@{$ra_arg_list})\n" if $opt_v > 2;

    my $separator = defined $opt_csv_delimiter ? $opt_csv_delimiter : ",";
    my ($fh, $filename);
    if ($opt_categorized) {
        if ($iteration) {
            # am being called twice for diff of Left and Right
            my $ext = $iteration == 1 ? "L" : "R";
            $filename = $opt_categorized . "-$ext";
        } else {
            $filename = $opt_categorized;
        }
        $fh = open_file('+>', $filename, 1);  # open for read/write
        die "Unable to write to $filename:  $!\n" unless defined $fh;
    } elsif ($opt_sdir) {
        # write to the user-defined scratch directory
        ++$TEMP_OFF;
        my $scr_dir = "$opt_sdir/$TEMP_OFF";
        File::Path::mkpath($scr_dir) unless is_dir($scr_dir);
        $filename = $scr_dir . '/cloc_file_list.txt';
        $fh = open_file('+>', $filename, 1);  # open for read/write
        die "Unable to write to $filename:  $!\n" unless defined $fh;
    } else {
        # let File::Temp create a suitable temporary file
        ($fh, $filename) = tempfile(UNLINK => 1);  # delete file on exit
        print "Using temp file list [$filename]\n" if $opt_v;
    }

    my @dir_list = ();
    foreach my $file_or_dir (@{$ra_arg_list}) {
        my $size_in_bytes = 0;
        my $F = lower_on_Windows($file_or_dir);
        my $ul_F = $ON_WINDOWS ? $upper_lower_map{$F} : $F;
        if (!can_read($file_or_dir)) {
            push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $F];
            next;
        }
        if (is_file($file_or_dir)) {
            if (!get_size($file_or_dir)) {   # 0 sized file, named pipe, socket
                $rh_ignored->{$F} = 'zero sized file';
                next;
            } elsif (is_binary($file_or_dir) and !$opt_read_binary_files) {
                # avoid binary files unless user insists on reading them
                if ($opt_unicode) {
                    # only ignore if not a Unicode file w/trivial
                    # ASCII transliteration
                    if (!unicode_file($file_or_dir)) {
                        $rh_ignored->{$ul_F} = 'binary file';
                        next;
                    }
                } else {
                    $rh_ignored->{$ul_F} = 'binary file';
                    next;
                }
            }
            push @file_list, "$file_or_dir";
        } elsif (is_dir($file_or_dir)) {
            push @dir_list, $file_or_dir;
        } else {
            push @{$raa_errors}, [$rh_Err->{'Neither file nor directory'} , $F];
            $rh_ignored->{$F} = 'not file, not directory';
        }
    }

    # apply exclusion rules to file names passed in on the command line
    my @new_file_list = ();
    foreach my $File (@file_list) {
        my ($volume, $directories, $filename) = File::Spec->splitpath( $File );
        my $ignore_this_file = 0;
        foreach my $Sub_Dir ( File::Spec->splitdir($directories) ) {
            my $SD = lower_on_Windows($Sub_Dir);
            if ($Exclude_Dir{$Sub_Dir}) {
                $Ignored{$SD} = "($File) --exclude-dir=$Sub_Dir";
                $ignore_this_file = 1;
                last;
            }
        }
        push @new_file_list, $File unless $ignore_this_file;
    }
    @file_list = @new_file_list;
    foreach my $dir (@dir_list) {
        my $D = lower_on_Windows($dir);
#print "make_file_list dir=$dir  Exclude_Dir{$dir}=$Exclude_Dir{$dir}\n";
        # populates global variable @file_list
        if ($Exclude_Dir{$dir}) {
            $Ignored{$D} = "--exclude-dir=$Exclude_Dir{$dir}";
            next;
        }
        if ($opt_no_recurse) {
            if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
                my $d = Win32::LongPath->new();
                $d->opendirL($dir);
                foreach my $entry ($d->readdirL()) {
                    my $F = "$dir/$entry";
                    push @file_list, $F if is_file($F);
                }
                $d->closedirL();
            } else {
                opendir(DIR, $dir);
                push @file_list, grep(is_file($_), readdir(DIR));
                closedir(DIR);
            }
        } else {
            find({wanted     => \&files            ,
                  preprocess => \&find_preprocessor,
                  follow     =>  $opt_follow_links }, $dir);
        }
    }
    if ($opt_follow_links) {
        # giving { 'follow' => 1 } to find() makes it skip the
        # call to find_preprocessor() so have to call this manually
        @file_list = manual_find_preprocessor(@file_list);
    }

    # there's a possibility of file duplication if user provided a list
    # file or --vcs command that returns directory names; squash these
    my %unique_file_list = map { $_ => 1 } @file_list;
    @file_list = sort keys %unique_file_list;

    $nFiles_Found = scalar @file_list;
    printf "%8d text file%s.\n", plural_form($nFiles_Found) unless $opt_quiet;
    write_file($opt_found, {}, sort @file_list) if $opt_found;

    my $nFiles_Categorized = 0;

    foreach my $file (@file_list) {
        my $F = lower_on_Windows($file);
        if ($ON_WINDOWS) {
            (my $lc = lc $file) =~ s{\\}{/}g;
            $upper_lower_map{$lc} = $file;
            $file = $lc;
        }
        printf "classifying $file\n" if $opt_v > 2;

        my $basename = basename $file;
        if ($Not_Code_Filename{$basename}) {
            $rh_ignored->{$F} = "listed in " . '$' .
                "Not_Code_Filename{$basename}";
            next;
        } elsif ($basename =~ m{~$}) {
            $rh_ignored->{$F} = "temporary editor file";
            next;
        }

        my $size_in_bytes;
        if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
            my $stats = statL($file);
            $size_in_bytes = $stats->{size} if defined $stats;
        } else {
            $size_in_bytes = (stat $file)[7];
        }
        my $language      = "";
        if ($All_One_Language) {
            # user over-rode auto-language detection by using
            # --force-lang with just a language name (no extension)
            $language      = $All_One_Language;
        } else {
            $language      = classify_file($file      ,
                                           $rh_Err    ,
                                           $raa_errors,
                                           $rh_ignored);
        }
        if (!defined $size_in_bytes) {
            $rh_ignored->{$F} = "no longer readable";
            next;
        } elsif (!defined $language) {
            $rh_ignored->{$F} = "unable to associate with a language";
            next;
        } elsif ($language eq "(unknown)") {
            # entry should already be in %{$rh_ignored}
            next;
        }
        printf $fh "%d%s%s%s%s\n", $size_in_bytes, $separator,
                                   $language, $separator, $file;
        ++$nFiles_Categorized;
        #printf "classified %d files\n", $nFiles_Categorized
        #    unless (!$opt_progress_rate or
        #            ($nFiles_Categorized % $opt_progress_rate));
    }
    printf "classified %d files\r", $nFiles_Categorized
        if !$opt_quiet and $nFiles_Categorized > 1;
    print "<- make_file_list()\n" if $opt_v > 2;

    return $fh;   # handle to the file containing the list of files to process
}  # 1}}}
sub invoke_generator {                       # {{{1
    my ($generator, $ra_user_inputs) = @_;
    # If user provided file/directory inputs, only return
    # generated files that are in user's request.
    # Populates global variable %Ignored.
    print "-> invoke_generator($generator)\n" if $opt_v > 2;
    open(FH, "$generator |") or
        die "Failed to pipe $generator: $!";
    my @files = ();
    while(<FH>) {
        chomp;
        my $F = $_;
        print "VCS input:  $F\n" if $opt_v >= 2;
        if (!defined $ra_user_inputs or !@{$ra_user_inputs}) {
            push @files, $F;
        } else {
            # is this file desired?
            my $want_this_one = 0;
            foreach my $file_dir (@{$ra_user_inputs}) {
                $file_dir =~ s{\\}{/}g if $ON_WINDOWS;
                if (/^$file_dir/) {
                    $want_this_one = 1;
                    last;
                }
            }
            push @files, $F if $want_this_one;
        }
    }
    close(FH);
    # apply match/not-match file/dir filters to the list so far
    my @post_filter = ();
    foreach my $F (@files) {
        if ($opt_match_f) {
            push @post_filter, $F if basename($F) =~ m{$opt_match_f};
            next;
        }
        if ($opt_match_d) {
            push @post_filter, $F if $F =~ m{$opt_match_d};
            next;
        }
        if (@opt_not_match_d) {
            my $rule;
            if ($opt_fullpath and any_match($F, 0, \$rule, @opt_not_match_d)) {
                $Ignored{$F} = "--not-match-d=$rule";
                next;
            } elsif (any_match(basename($F), 0, \$rule, @opt_not_match_d)) {
                $Ignored{$F} = "--not-match-d (basename) =$rule";
                next;
            }
        }
        if (@opt_not_match_f) {
            my $rule;
            if (any_match(basename($F), 0, \$rule, @opt_not_match_f)) {
                $Ignored{$F} = "--not-match-d =$rule";
                next;
            }
        }
        my $nBytes = get_size($F);
        if (!$nBytes) {
            $Ignored{$F} = 'zero sized file';
            printf "files(%s)  zero size\n", $F if $opt_v > 5;
        }
        next unless $nBytes;
        if ($nBytes > $opt_max_file_size*1024**2) {
            $Ignored{$F} = "file size of " .
                $nBytes/1024**2 . " MB exceeds max file size of " .
                "$opt_max_file_size MB";
            printf "file(%s)  exceeds $opt_max_file_size MB\n",
                $F if $opt_v > 5;
            next;
        }
        my $is_bin = is_binary($F);
        printf "files(%s)  size=%d  -B=%d\n",
            $F, $nBytes, $is_bin if $opt_v > 5;
        $is_bin = 0 if $opt_unicode and unicode_file($_);
        $is_bin = 0 if $opt_read_binary_files;
        next if $is_bin;
        push @post_filter, $F;
    }
    print "<- invoke_generator\n" if $opt_v > 2;
    return @post_filter;
} # 1}}}
sub any_match {                              # {{{1
	my ($string, $entire, $rs_matched_pattern, @patterns) = @_;
	foreach my $pattern (@patterns) {
        if ($entire) {
            if ($string =~ m{^${pattern}$}) {
                ${$rs_matched_pattern} = $pattern;
                return 1;
            }
        } else {
            if ($string =~ m{$pattern}) {
                ${$rs_matched_pattern} = $pattern;
                return 1;
            }
        }
    }
	return 0;
}
# }}}
sub remove_duplicate_files {                 # {{{1
    my ($fh                   , # in
        $rh_Language          , # out
        $rh_unique_source_file, # out
        $rh_Err               , # in
        $raa_errors           , # out  errors encountered
        $rh_ignored           , # out
        ) = @_;

    # Check for duplicate files by comparing file sizes.
    # Where files are equally sized, compare their MD5 checksums.
    print "-> remove_duplicate_files\n" if $opt_v > 2;

    my $separator = defined $opt_csv_delimiter ? $opt_csv_delimiter : ",";
    my $n = 0;
    my %files_by_size = (); # files_by_size{ # bytes } = [ list of files ]
    seek($fh, 0, 0); # rewind to beginning of the temp file
    while (<$fh>) {
        ++$n;
        my ($size_in_bytes, $language, $file) = split(/\Q$separator\E/, $_, 3);
        if (!defined($size_in_bytes) or
            !defined($language)      or
            !defined($file)) {
            print "-> remove_duplicate_files skipping error line [$_]\n"
                if $opt_v;
            next;
        }
        chomp($file);
        $file =~ s{\\}{/}g if $ON_WINDOWS;
        $rh_Language->{$file} = $language;
        push @{$files_by_size{$size_in_bytes}}, $file;
        if ($opt_skip_uniqueness) {
            $rh_unique_source_file->{$file} = 1;
        }
    }
    return if $opt_skip_uniqueness;
    if ($opt_progress_rate and ($n > $opt_progress_rate)) {
        printf "Duplicate file check %d files (%d known unique)\r",
            $n, scalar keys %files_by_size;
    }
    $n = 0;
    foreach my $bytes (sort {$a <=> $b} keys %files_by_size) {
        ++$n;
        printf "Unique: %8d files                                          \r",
            $n unless (!$opt_progress_rate or ($n % $opt_progress_rate));
        if (scalar @{$files_by_size{$bytes}} == 1) {
            # only one file is this big; must be unique
            $rh_unique_source_file->{$files_by_size{$bytes}[0]} = 1;
            next;
        } else {
#print "equally sized files: ",join(", ", @{$files_by_size{$bytes}}), "\n";
            # Files in the list @{$files_by_size{$bytes} all are
            # $bytes long.  Sort the list by file basename.

          # # sorting on basename causes repeatability problems
          # # if the basename is not unique (eg "includeA/x.h"
          # # and "includeB/x.h".  Instead, sort on full path.
          # # Ref bug #114.
          # my @sorted_bn = ();
          # my %BN = map { basename($_) => $_ } @{$files_by_size{$bytes}};
          # foreach my $F (sort keys %BN) {
          #     push @sorted_bn, $BN{$F};
          # }

            my @sorted_bn = sort @{$files_by_size{$bytes}};

            foreach my $F (different_files(\@sorted_bn  ,
                                            $rh_Err     ,
                                            $raa_errors ,
                                            $rh_ignored ) ) {
                $rh_unique_source_file->{$F} = 1;
            }
        }
    }
    print "<- remove_duplicate_files\n" if $opt_v > 2;
} # 1}}}
sub manual_find_preprocessor {               # {{{1
    # When running with --follow-links, find_preprocessor() is not
    # called by find().  Have to do it manually.  Inputs here
    # are only files, which differs from find_preprocessor() which
    # gets directories too.
    # Reads global variable %Exclude_Dir.
    # Populates global variable %Ignored.
    # Reject files/directories in cwd which are in the exclude list.
    print "-> manual_find_preprocessor(", cwd(), ")\n" if $opt_v > 2;
    my @ok = ();

    foreach my $File (@_) {  # pure file or directory name, no separators
        my $Dir = dirname($File);
        my $got_exclude_dir = 0;
        foreach my $d (File::Spec->splitdir( $Dir )) {
            # tests/inputs/issues/407/level2/level/Test/level2 ->
            # $d iterates over tests, inputs, issues, 407,
            #                  level2, level, Test, level2
            # check every item against %Exclude_Dir
            if ($Exclude_Dir{$d}) {
                $got_exclude_dir = $d;
                last;
            }
        }
        if ($got_exclude_dir) {
            $Ignored{$File} = "--exclude-dir=$Exclude_Dir{$got_exclude_dir}";
#print "ignoring $File\n";
        } else {
            if (@opt_not_match_d) {
                my $rule;
                if ($opt_fullpath) {
                    if (any_match($Dir, 1, \$rule, @opt_not_match_d)) {
                        $Ignored{$File} = "--not-match-d=$rule";
#print "matched fullpath\n"
                    } else {
                        push @ok, $File;
                    }
                } elsif (any_match(basename($Dir), 0, \$rule, @opt_not_match_d)) {
                    $Ignored{$File} = "--not-match-d=$rule";
#print "matched partial\n"
                } else {
                    push @ok, $File;
                }
            } else {
                push @ok, $File;
            }
        }
    }

    print "<- manual_find_preprocessor(@ok)\n" if $opt_v > 2;
    return @ok;
} # 1}}}
sub find_preprocessor {                      # {{{1
    # invoked by File::Find's find() each time it enters a new directory
    # Reads global variable %Exclude_Dir.
    # Populates global variable %Ignored.
    # Reject files/directories in cwd which are in the exclude list.
    print "-> find_preprocessor(", cwd(), ")\n" if $opt_v > 2;
    my @ok = ();

#printf "TOP find_preprocessor\n";

    foreach my $F_or_D (@_) {  # pure file or directory name, no separators
        next if $F_or_D =~ /^\.{1,2}$/;  # skip .  and  ..
        if ($Exclude_Dir{$F_or_D}) {
            $Ignored{$File::Find::name} = "--exclude-dir=$Exclude_Dir{$F_or_D}";
        } else {
#printf "  F_or_D=%-20s File::Find::name=%s\n", $F_or_D, $File::Find::name;
            if (@opt_not_match_d) {
                my $rule;
                if ($opt_fullpath) {
                    if (any_match($File::Find::name, 0, \$rule, @opt_not_match_d)) {
                        $Ignored{$File::Find::name} = "--not-match-d=$rule";
                    } else {
                        push @ok, $F_or_D;
                    }
                } elsif (!is_dir($F_or_D) and
                         any_match(basename($File::Find::name), 0, \$rule,
                                   @opt_not_match_d)) {
                    $Ignored{$File::Find::name} = "--not-match-d (basename) =$rule";
                } else {
                    push @ok, $F_or_D;
                }
            } else {
                push @ok, $F_or_D;
            }
        }
    }

    print "<- find_preprocessor(@ok)\n" if $opt_v > 2;
    return @ok;
} # 1}}}
sub files {                                  # {{{1
    # invoked by File::Find's find()   Populates global variable @file_list.
    # See also find_preprocessor() which prunes undesired directories.

    my $Dir = fastcwd(); # not $File::Find::dir which just gives relative path
    my $rule;
    if ($opt_fullpath) {
        # look at as much of the path as is known
        if ($opt_match_f    ) {
            return unless $File::Find::name =~ m{$opt_match_f};
        }
        if (@opt_not_match_f) {
            return if any_match($File::Find::name, 0, \$rule, @opt_not_match_f);
        }
    } else {
        # only look at the basename
        if ($opt_match_f    ) { return unless /$opt_match_f/;     }
        if (@opt_not_match_f) { return if     any_match($_, 0, \$rule, @opt_not_match_f)}
    }
    if ($opt_match_d) {
        return unless "$Dir/" =~ m{$opt_match_d} or $Dir =~ m{$opt_match_d};
    }

    my $nBytes = get_size($_);
    if (!$nBytes and is_file($File::Find::name)) {
        $Ignored{$File::Find::name} = 'zero sized file';
        printf "files(%s)  zero size\n", $File::Find::name if $opt_v > 5;
    }
    return unless $nBytes  ; # attempting other tests w/pipe or socket will hang
    if ($nBytes > $opt_max_file_size*1024**2) {
        $Ignored{$File::Find::name} = "file size of " .
            $nBytes/1024**2 . " MB exceeds max file size of " .
            "$opt_max_file_size MB";
        printf "file(%s)  exceeds $opt_max_file_size MB\n",
            $File::Find::name if $opt_v > 5;
        return;
    }
    my $is_dir = is_dir($_);
    my $is_bin = is_binary($_);
    printf "files(%s)  size=%d is_dir=%d  -B=%d\n",
        $File::Find::name, $nBytes, $is_dir, $is_bin if $opt_v > 5;
    $is_bin = 0 if $opt_unicode and unicode_file($_);
    $is_bin = 0 if $opt_read_binary_files;
    if ($is_bin and !$is_dir) {
        $Ignored{$File::Find::name} = "binary file";
        printf "files(%s)  binary file\n", $File::Find::name if $opt_v > 5;
    }
    return if $is_dir or $is_bin;
    ++$nFiles_Found;
    printf "%8d files\r", $nFiles_Found
        unless (!$opt_progress_rate or ($nFiles_Found % $opt_progress_rate));
    push @file_list, $File::Find::name;
} # 1}}}
sub archive_files {                          # {{{1
    # invoked by File::Find's find()  Populates global variable @binary_archive
    foreach my $ext (keys %Known_Binary_Archives) {
        push @binary_archive, $File::Find::name
            if $File::Find::name =~ m{$ext$};
    }
} # 1}}}
sub open_file {                              # {{{1
    # portable method to open a file. On Windows this uses Win32::LongPath to
    # allow reading/writing files past the 255 char path length limit. When on
    # other operating systems, $use_new_file can be used to specify opening a
    # file with `new IO::File` instead of `open`. Note: `openL` doesn't support
    # the C-like fopen modes ("w", "r+", etc.), it only supports Perl mode
    # strings (">", "+<", etc.). So be sure to only use Perl mode strings to
    # ensure compatibility. Additionally, openL doesn't handle pipe modes; if
    # you need to open a pipe/STDIN/STDOUT, use the native `open` function.
    my ($mode,         # Perl file mode; can not be C-style file mode
        $filename,     # filename to open
        $use_new_file, # whether to use `new IO::File` or `open` when not using Win32::LongPath
        ) = @_;
    if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
        my $file = undef;
        openL(\$file, $mode, $filename);
        return $file;
    } elsif ($use_new_file) {
        return new IO::File $filename, $mode;
    }
    my $file = undef;
    open($file, $mode, $filename);
    return $file;
} # 1}}}
sub unlink_file {                            # {{{1
    # portable method to unlink a file. On Windows this uses Win32::LongPath to
    # allow unlinking files past the 255 char path length limit. Otherwise, the
    # native `unlink` will be used.
    my $filename = shift @_;
    if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
        return unlinkL($filename);
    }
    return unlink $filename;
} # 1}}}
sub is_binary {                              # {{{1
    # portable method to test if item is a binary file. For Windows,
    # Win32::LongPath doesn't provide a testL option for -B, but -B
    # accepts a filehandle which does work with files opened with openL.
    my $item = shift @_;
    if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
        my $IN = open_file('<', $item, 0);
        if (defined $IN) {
            my $res = -B $IN;
            close($IN);
            return $res;
        }
        return;
    }
    return (-B $item);
} # 1}}}
sub can_read {                               # {{{1
    # portable method to test if item can be read
    my $item = shift @_;
    if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
        return testL('r', $item);
    }
    return (-r $item);
} # 1}}}
sub get_size {                               # {{{1
    # portable method to get size in bytes of a file
    my $filename = shift @_;
    if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
        return testL('s', $filename);
    }
    return (-s $filename);
} # 1}}}
sub is_file {                                # {{{1
    # portable method to test if item is a file
    # (-f doesn't work in ActiveState Perl on Windows)
    my $item = shift @_;
    if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
        return testL('f', $item);
    }
    return (-f $item);

#     Was:
####if ($ON_WINDOWS) {
####    my $mode = (stat $item)[2];
####       $mode = 0 unless $mode;
####    if ($mode & 0100000) { return 1; }
####    else                 { return 0; }
####} else {
####    return (-f $item);  # works on Unix, Linux, CygWin, z/OS
####}
} # 1}}}
sub is_dir {                                 # {{{1
    my $item = shift @_;
    if ($ON_WINDOWS and $HAVE_Win32_Long_Path) {
        return testL('d', $item);
    }
    return (-d $item); # should work everywhere now (July 2017)

#     Was:
##### portable method to test if item is a directory
##### (-d doesn't work in older versions of ActiveState Perl on Windows)

####if ($ON_WINDOWS) {
####    my $mode = (stat $item)[2];
####       $mode = 0 unless $mode;
####    if ($mode & 0040000) { return 1; }
####    else                 { return 0; }
####} else {
####    return (-d $item);  # works on Unix, Linux, CygWin, z/OS
####}
} # 1}}}
sub is_excluded {                            # {{{1
    my ($file       , # in
        $excluded   , # in   hash of excluded directories
       ) = @_;
    my($filename, $filepath, $suffix) = fileparse($file);
    foreach my $path (sort keys %{$excluded}) {
        return 1 if ($filepath =~ m{^$path/}i);
    }
} # 1}}}
sub classify_file {                          # {{{1
    my ($full_file   , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
        $rh_ignored  , # out
       ) = @_;

    print "-> classify_file($full_file)\n" if $opt_v > 2;
    my $language = "(unknown)";

    if (basename($full_file) eq "-" && defined $opt_stdin_name) {
       $full_file = $opt_stdin_name;
    }

    my $look_at_first_line = 0;
    my $file = basename $full_file;
    if ($opt_autoconf and $file =~ /\.in$/) {
       $file =~ s/\.in$//;
    }
    return $language if $Not_Code_Filename{$file}; # (unknown)
    return $language if $file =~ m{~$}; # a temp edit file (unknown)
    if (defined $Language_by_File{$file}) {
        if      ($Language_by_File{$file} eq "Ant/XML") {
            return Ant_or_XML(  $full_file, $rh_Err, $raa_errors);
        } elsif ($Language_by_File{$file} eq "Maven/XML") {
            return Maven_or_XML($full_file, $rh_Err, $raa_errors);
        } else {
            return $Language_by_File{$file};
        }
    }

    if ($file =~ /\.([^\.]+)$/) { # has an extension
      print "$full_file extension=[$1]\n" if $opt_v > 2;
      my $extension = $1;
         # Windows file names are case insensitive so map
         # all extensions to lowercase there.
         $extension = lc $extension if $ON_WINDOWS or $opt_ignore_case_ext;
      my @extension_list = ( $extension );
      if ($file =~ /\.([^\.]+\.[^\.]+)$/) { # has a double extension
          my $extension = $1;
          $extension = lc $extension if $ON_WINDOWS or $opt_ignore_case_ext;
          unshift @extension_list, $extension;  # examine double ext first
      }
      if ($file =~ /\.([^\.]+\.[^\.]+\.[^\.]+)$/) { # has a triple extension
          my $extension = $1;
          $extension = lc $extension if $ON_WINDOWS or $opt_ignore_case_ext;
          unshift @extension_list, $extension;  # examine triple ext first
      }
      foreach my $extension (@extension_list) {
        if ($Not_Code_Extension{$extension} and
           !$Forced_Extension{$extension}) {
           # If .1 (for example) is an extension that would ordinarily be
           # ignored but the user has insisted this be counted with the
           # --force-lang option, then go ahead and count it.
            $rh_ignored->{$full_file} =
                'listed in $Not_Code_Extension{' . $extension . '}';
            return $language;
        }
        # handle extension collisions
        if (defined $Language_by_Extension{$extension}) {
            if ($Language_by_Extension{$extension} eq
                'MATLAB/Mathematica/Objective-C/MUMPS/Mercury') {
                my $lang_M_or_O = "";
                matlab_or_objective_C($full_file ,
                                      $rh_Err    ,
                                      $raa_errors,
                                     \$lang_M_or_O);
                if ($lang_M_or_O) {
                    return $lang_M_or_O;
                } else { # an error happened in matlab_or_objective_C()
                    $rh_ignored->{$full_file} =
                        'failure in matlab_or_objective_C()';
                    return $language; # (unknown)
                }
            } elsif ($Language_by_Extension{$extension} eq 'PHP/Pascal') {
                if (really_is_php($full_file)) {
                    return 'PHP';
                } elsif (really_is_incpascal($full_file)) {
                    return 'Pascal';
                } else {
                    return $language; # (unknown)
                }
            } elsif ($Language_by_Extension{$extension} eq 'Pascal/Puppet') {
                my $lang_Pasc_or_Pup = "";
                pascal_or_puppet(     $full_file ,
                                      $rh_Err    ,
                                      $raa_errors,
                                     \$lang_Pasc_or_Pup);
                if ($lang_Pasc_or_Pup) {
                    return $lang_Pasc_or_Pup;
                } else { # an error happened in pascal_or_puppet()
                    $rh_ignored->{$full_file} =
                        'failure in pascal_or_puppet()';
                    return $language; # (unknown)
                }
            } elsif ($Language_by_Extension{$extension} eq 'Lisp/OpenCL') {
                return Lisp_or_OpenCL($full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'Lisp/Julia') {
                return Lisp_or_Julia( $full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'Perl/Prolog') {
                return Perl_or_Prolog($full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'Raku/Prolog') {
                return Raku_or_Prolog($full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq
                     'IDL/Qt Project/Prolog/ProGuard') {
                return IDL_or_QtProject($full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'D/dtrace') {
                # is it D or an init.d shell script?
                my $a_script = really_is_D($full_file, $rh_Err, $raa_errors);
                if ($a_script) {
                    # could be dtrace, sh, bash or anything one would
                    # write an init.d script in
                    if (defined $Language_by_Script{$a_script}) {
                        return $Language_by_Script{$a_script};
                    } else {
                        $rh_ignored->{$full_file} =
                            "Unrecognized script language, '$a_script'";
                    }
                } else {
                    return 'D';
                }
            } elsif ($Language_by_Extension{$extension} eq 'Fortran 77/Forth') {
                return Forth_or_Fortran($full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'F#/Forth') {
                return Forth_or_Fsharp( $full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'Verilog-SystemVerilog/Coq') {
                return Verilog_or_Coq( $full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'Smarty') {
                if ($extension ne "tpl") {
                    # unambiguous -- if ends with .smarty, is Smarty
                    return $Language_by_Extension{$extension};
                }
                # Smarty extension .tpl is generic; make sure the
                # file at least roughly resembles PHP.  Alternatively,
                # if the user forces the issue, do the count.
                my $force_smarty = 0;
                foreach (@opt_force_lang) {
                    if (lc($_) eq "smarty,tpl") {
                        $force_smarty = 1;
                        last;
                    }
                }
                if (really_is_smarty($full_file) or $force_smarty) {
                    return 'Smarty';
                } else {
                    return $language; # (unknown)
                }
            } elsif ($Language_by_Extension{$extension} eq 'TypeScript/Qt Linguist') {
                return TypeScript_or_QtLinguist( $full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'Qt/Glade') {
                return Qt_or_Glade( $full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'C#/Smalltalk') {
                my $L = Csharp_or_Smalltalk( $full_file, $rh_Err, $raa_errors);
                if ($L eq 'C#') {
                    my $lines = first_line($full_file, 2, $rh_Err, $raa_errors);
                    $lines =~ s/\n//mg;
                    if ($lines =~ m[^//-{70,}.*?//\s+<auto-generated>]) {
                        $L = "C# Generated";
                    }
                }
                return $L;
            } elsif ($Language_by_Extension{$extension} eq 'Scheme/SaltStack') {
                return Scheme_or_SaltStack( $full_file, $rh_Err, $raa_errors);
            } elsif ($Language_by_Extension{$extension} eq 'Visual Basic/TeX/Apex Class') {
                my $lang_VB_T_A = "";
                Visual_Basic_or_TeX_or_Apex($full_file ,
                                            $rh_Err    ,
                                            $raa_errors,
                                           \$lang_VB_T_A);
                if ($lang_VB_T_A) {
                    return $lang_VB_T_A;
                } else { # an error happened in Visual_Basic_or_TeX_or_Apex
                    $rh_ignored->{$full_file} =
                        'failure in Visual_Basic_or_TeX_or_Apex()';
                    return $language; # (unknown)
                }
            } elsif ($Language_by_Extension{$extension} eq 'Brainfuck') {
                if (really_is_bf($full_file)) {
                    return $Language_by_Extension{$extension};
                } else {
                    return $language; # (unknown)
                }
            } else {
                return $Language_by_Extension{$extension};
            }
        } else { # has an unmapped file extension
            $look_at_first_line = 1;
        }
      }
      # if all else fails look at the prefix instead of extension
      ( my $stem = $file ) =~ s/^(.*?)\.\S+$/$1/;
      if ($stem and defined($Language_by_Prefix{$stem})) {
          return $Language_by_Prefix{$stem}
      }
    } elsif (defined $Language_by_File{lc $file}) {
        return $Language_by_File{lc $file};
    } elsif ($opt_lang_no_ext and
             defined $Filters_by_Language{$opt_lang_no_ext}) {
        return $opt_lang_no_ext;
    } else {  # no file extension
        $look_at_first_line = 1;
    }

    if ($look_at_first_line) {
        # maybe it is a shell/Perl/Python/Ruby/etc script that
        # starts with pound bang:
        #   #!/usr/bin/perl
        #   #!/usr/bin/env perl
        my ($script_language, $L) = peek_at_first_line($full_file ,
                                                       $rh_Err    ,
                                                       $raa_errors);
        if (!$script_language) {
            $rh_ignored->{$full_file} = "language unknown (#2)";
            # returns (unknown)
        }
        if (defined $Language_by_Script{$script_language}) {
            if (defined $Filters_by_Language{
                            $Language_by_Script{$script_language}}) {
                $language = $Language_by_Script{$script_language};
            } else {
                $rh_ignored->{$full_file} =
                    "undefined:  Filters_by_Language{" .
                    $Language_by_Script{$script_language} .
                    "} for scripting language $script_language";
                # returns (unknown)
            }
        } else {
            # #456:  XML files can have a variety of domain-specific file
            #        extensions.  If the extension is unrecognized, examine
            #        the first line of the file to see if it is XML
            if ($L =~ /<\?xml\s/) {
                $language = "XML";
                delete $rh_ignored->{$full_file};
            } else {
                $rh_ignored->{$full_file} = "language unknown (#3)";
            }
            # returns (unknown)
        }
    }
    print "<- classify_file($full_file)=$language\n" if $opt_v > 2;
    return $language;
} # 1}}}
sub first_line {                             # {{{1
    # return the first $n_lines of text in the file as one string
    my ($file        , # in
        $n_lines     , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;
    my $line = "";
    print "-> first_line($file, $n_lines)\n" if $opt_v > 2;
    if (!can_read($file)) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $line;
    }
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        print "<- first_line($file, $n_lines)\n" if $opt_v > 2;
        return $line;
    }
    # issue 644: Unicode files can have non-zero $n_lines
    # but empty <$IN> contents
    for (my $i = 0; $i < $n_lines; $i++) {
        my $L = <$IN>;
        last unless defined $L;
        chomp($line .= $L);
    }
    $IN->close;
    print "<- first_line($file, $n_lines, '$line')\n" if $opt_v > 2;
    return $line;
} # 1}}}
sub peek_at_first_line {                     # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> peek_at_first_line($file)\n" if $opt_v > 2;

    my $script_language = "";
    my $first_line = first_line($file, 1, $rh_Err, $raa_errors);

    if (defined $first_line) {
#print "peek_at_first_line of [$file] first_line=[$first_line]\n";
        if ($first_line =~ /^#\!\s*(\S.*?)$/) {
#print "peek_at_first_line 1=[$1]\n";
            my @pound_bang = split(' ', $1);
#print "peek_at_first_line basename 0=[", basename($pound_bang[0]), "]\n";
            if (basename($pound_bang[0]) eq "env" and
                scalar @pound_bang > 1) {
                $script_language = $pound_bang[1];
#print "peek_at_first_line pound_bang A $pound_bang[1]\n";
            } else {
                $script_language = basename $pound_bang[0];
#print "peek_at_first_line pound_bang B $script_language\n";
            }
        }
    }
    print "<- peek_at_first_line($file)\n" if $opt_v > 2;
    return ($script_language, $first_line);
} # 1}}}
sub different_files {                        # {{{1
    # See which of the given files are unique by computing each file's MD5
    # sum.  Return the subset of files which are unique.
    my ($ra_files    , # in
        $rh_Err      , # in
        $raa_errors  , # out
        $rh_ignored  , # out
       ) = @_;

    print "-> different_files(@{$ra_files})\n" if $opt_v > 2;
    my %file_hash = ();  # file_hash{md5 hash} = [ file1, file2, ... ]
    foreach my $F (@{$ra_files}) {
        next if is_dir($F);  # needed for Windows
        my $IN = open_file('<', $F, 1);
        if (!defined $IN) {
            push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $F];
            $rh_ignored->{$F} = 'cannot read';
        } else {
            if ($HAVE_Digest_MD5) {
                binmode $IN;
                my $MD5 = Digest::MD5->new->addfile($IN)->hexdigest;
#print "$F, $MD5\n";
                push @{$file_hash{$MD5}}, $F;
            } else {
                # all files treated unique
                push @{$file_hash{$F}}, $F;
            }
            $IN->close;
        }
    }

    # Loop over file sets having identical MD5 sums.  Within
    # each set, pick the file that most resembles known source
    # code.
    my @unique = ();
    for my $md5 (sort keys %file_hash) {
        my $i_best = 0;
        for (my $i = 1; $i < scalar(@{$file_hash{$md5}}); $i++) {
            my $F = $file_hash{$md5}[$i];
            my (@nul_a, %nul_h);
            my $language = classify_file($F, $rh_Err,
                                        # don't save these errors; pointless
                                        \@nul_a, \%nul_h);
            $i_best = $i if $language ne "(unknown)";
        }
        # keep the best one found and identify the rest as ignored
        for (my $i = 0; $i < scalar(@{$file_hash{$md5}}); $i++) {
            if ($i == $i_best) {
                push @unique, $file_hash{$md5}[$i_best];
            } else {
                $rh_ignored->{$file_hash{$md5}[$i]} = "duplicate of " .
                    $file_hash{$md5}[$i_best];
            }
        }

    }
    print "<- different_files(@unique)\n" if $opt_v > 2;
    return @unique;
} # 1}}}
sub call_counter {                           # {{{1
    my ($file     , # in
        $language , # in
        $ra_Errors, # out
       ) = @_;

    # Logic:  pass the file through the following filters:
    #         1. remove leading lines (if --skip-leading)
    #         2. remove blank lines
    #         3. remove comments using each filter defined for this language
    #            (example:  SQL has two, remove_starts_with(--) and
    #             remove_c_comments() )
    #         4. compute comment lines as
    #               total lines - blank lines - lines left over after all
    #                   comment filters have been applied

    print "-> call_counter($file, $language)\n" if $opt_v > 2;
#print "call_counter:  ", Dumper(@routines), "\n";

    my @lines = ();
    my $ascii = "";
    if (is_binary($file) and $opt_unicode) {
        # was binary so must be unicode

        $/ = undef;
        my $IN = open_file('<', $file, 1);
        my $bin_text = <$IN>;
        $IN->close;
        $/ = "\n";

        $ascii = unicode_to_ascii( $bin_text );
        @lines = split("\n", $ascii );
        foreach (@lines) { $_ = "$_\n"; }

    } else {
        # regular text file
        @lines = read_file($file);
        $ascii = join('', @lines);
    }

    # implement --perl-ignore-data here

    if ($opt_skip_leading) {
        my $strip = 1;
        my ($N, @exts) = split(/,/, $opt_skip_leading);
        if (@exts) {
            # only apply if this file's extension is listed
            my $this_file_ext = file_extension($file);
            $strip = grep(/^${this_file_ext}$/, @exts);
        }
        @lines = remove_first_n($N, \@lines) if $strip;
    }

    my @original_lines = @lines;
    my $total_lines    = scalar @lines;

    print_lines($file, "Original file:", \@lines) if $opt_print_filter_stages;
    @lines = rm_blanks(\@lines, $language, \%EOL_Continuation_re); # remove blank lines
    my $blank_lines = $total_lines - scalar @lines;
    print "   call_counter: total_lines=$total_lines  blank_lines=",
        $blank_lines, "\n" if $opt_v > 2;
    print_lines($file, "Blank lines removed:", \@lines)
        if $opt_print_filter_stages;

    @lines = rm_comments(\@lines, $language, $file,
                               \%EOL_Continuation_re, $ra_Errors);

    my $comment_lines = $total_lines - $blank_lines - scalar  @lines;
    if ($opt_strip_comments) {
        my $stripped_file = "";
        if ($opt_original_dir) {
            $stripped_file =          $file . ".$opt_strip_comments";
        } else {
            $stripped_file = basename $file . ".$opt_strip_comments";
        }
        write_file($stripped_file, {}, @lines);
    }
    if ($opt_html and !$opt_diff) {
        chomp(@original_lines);  # includes blank lines, comments
        chomp(@lines);           # no blank lines, no comments

        my (@diff_L, @diff_R, %count);

        # remove blank lines to get better quality diffs; count
        # blank lines separately
        my @original_lines_minus_white = ();
        # however must keep track of how many blank lines were removed and
        # where they were removed so that the HTML display can include it
        my %blank_line  = ();
        my $insert_line = 0;
        foreach (@original_lines) {
            if (/^\s*$/) {
               ++$count{blank}{same};
               ++$blank_line{ $insert_line };
            } else {
                ++$insert_line;
                push @original_lines_minus_white, $_;
            }
        }

        array_diff( $file                       ,   # in
                   \@original_lines_minus_white ,   # in
                   \@lines                      ,   # in
                   "comment"                    ,   # in
                   \@diff_L, \@diff_R,          ,   # out
                    $ra_Errors);                    # in/out
        write_comments_to_html($file, \@diff_L, \@diff_R, \%blank_line);
#print Dumper("count", \%count);
    }

    print "<- call_counter($total_lines, $blank_lines, $comment_lines)\n"
        if $opt_v > 2;
    return ($total_lines, $blank_lines, $comment_lines);
} # 1}}}
sub windows_glob {                           # {{{1
    # Windows doesn't expand wildcards.  Use code from Sean M. Burke's
    # Win32::Autoglob module to do this.
    return map {;
        ( defined($_) and m/[\*\?]/ ) ? sort(glob($_)) : $_
          } @_;
} # 1}}}
sub write_file {                             # {{{1
    my ($file       , # in
        $rh_options , # in
        @lines      , # in
       ) = @_;

    my $local_formatting = 0;
    foreach my $opt (sort keys %{$rh_options}) {
#       print "write_file option $opt = $rh_options->{$opt}\n";
        $local_formatting = 1;
    }
#print "write_file 1 [$file]\n";
    # Do ~ expansion (by Tim LaBerge, fixes bug 2787984)
    my $preglob_filename = $file;
#print "write_file 2 [$preglob_filename]\n";
    if ($ON_WINDOWS) {
        $file = (windows_glob($file))[0];
    } else {
        $file = File::Glob::bsd_glob($file);
    }
#print "write_file 3 [$file]\n";
    $file = $preglob_filename unless $file;
#print "write_file 4 [$file]\n";

    print "-> write_file($file)\n" if $opt_v > 2;

    # Create the destination directory if it doesn't already exist.
    my $abs_file_path = File::Spec->rel2abs( $file );
    my ($volume, $directories, $filename) = File::Spec->splitpath( $abs_file_path );
    mkpath($volume . $directories, 1, 0777);

    my $OUT = undef;
    unlink_file($file);
    if ($opt_file_encoding) {
#       $OUT = IO::File->new($file, ">:$opt_file_encoding");  # doesn't work?
        $OUT = open_file(">:encoding($opt_file_encoding)", $file, 0);
    } else {
        $OUT = open_file('>', $file, 1);
    }

    my $n_col = undef;
    if ($local_formatting) {
        $n_col = scalar @{$rh_options->{'columns'}};
        if ($opt_xml) {
            print $OUT '<?xml version="1.0" encoding="UTF-8"?>', "\n";
            print $OUT "<all_$rh_options->{'file_type'}>\n";
        } elsif ($opt_yaml) {
            print $OUT "---\n";
        } elsif ($opt_md) {
            print $OUT join("|", @{$rh_options->{'columns'}}) , "\n";
            print $OUT join("|", map( ":------", 1 .. $n_col)), "\n";
        }
    }

    if (!defined $OUT) {
        warn "Unable to write to $file\n";
        print "<- write_file\n" if $opt_v > 2;
        return;
    }
    chomp(@lines);

    if ($local_formatting) {
        my @json_lines = ();
        foreach my $L (@lines) {
            my @entries;
            if ($rh_options->{'separator'}) {
                @entries = split($rh_options->{'separator'}, $L, $n_col);
            } else {
                @entries = ( $L );
            }
            if ($opt_xml) {
                print $OUT "  <$rh_options->{'file_type'} ";
                for (my $i = 0; $i < $n_col; $i++) {
                    printf $OUT "%s=\"%s\" ", $rh_options->{'columns'}[$i], $entries[$i];
                }
                print $OUT "/>\n";
            } elsif ($opt_yaml or $opt_json) {
                my @pairs = ();
                for (my $i = 0; $i < $n_col; $i++) {
                    push @pairs,
                        sprintf "\"%s\":\"%s\"", $rh_options->{'columns'}[$i], $entries[$i];
                }
                if ($opt_json) {
                    # JSON can't literal '\x' in filenames, #575
                    $pairs[0] =~ s/\\x//g;
                    push @json_lines, join(", ", @pairs );
                } else {
                    print $OUT "- {", join(", ", @pairs), "}\n";
                }
            } elsif ($opt_csv) {
                print $OUT join(",", @entries), "\n";
            } elsif ($opt_md) {
                print $OUT join("|", @entries), "\n";
            }
        }
        if ($opt_json) {
            print $OUT "[{", join("},\n {", @json_lines), "}]\n";
        }
        if (!$opt_json and !$opt_yaml and !$opt_xml and !$opt_csv) {
            print $OUT join("\n", @lines), "\n";
        }
    } else {
        print $OUT join("\n", @lines), "\n";
    }

    if ($local_formatting and $opt_xml) {
        print $OUT "</all_$rh_options->{'file_type'}>\n";
    }
    $OUT->close;

    if (can_read($file)) {
        print "Wrote $file" unless $opt_quiet;
        print ", $CLOC_XSL" if $opt_xsl and $opt_xsl eq $CLOC_XSL;
        print "\n" unless $opt_quiet;
    }

    print "<- write_file\n" if $opt_v > 2;
} # 1}}}
sub file_pairs_from_file {                   # {{{1
    my ($file             , # in
        $ra_added         , # out
        $ra_removed       , # out
        $ra_compare_list  , # out
       ) = @_;
    #
    # Example valid input format for $file
    # 1)
    #   A/d1/hello.f90 | B/d1/hello.f90
    #   A/hello.C | B/hello.C
    #   A/d2/hi.py | B/d2/hi.py
    #
    # 2)
    # Files added: 1
    #   + B/extra_file.pl ; Perl
    #
    # Files removed: 1
    #   - A/d2/hello.java ; Java
    #
    # File pairs compared: 3
    #   != A/d1/hello.f90 | B/d1/hello.f90 ; Fortran 90
    #   != A/hello.C | B/hello.C ; C++
    #   == A/d2/hi.py | B/d2/hi.py ; Python

    print "-> file_pairs_from_file($file)\n" if $opt_v and $opt_v > 2;
    @{$ra_compare_list} = ();
    my @lines = read_file($file);
    my $mode = "compare";
    foreach my $L (@lines) {
        next if $L =~ /^\s*$/ or $L =~ /^\s*#/;
        chomp($L);
        if      ($L =~ /^Files\s+(added|removed):/) {
            $mode = $1;
        } elsif ($L =~ /^File\s+pairs\s+compared:/) {
            $mode = "compare";
        } elsif ($mode eq "added" or $mode eq "removed") {
            $L =~ m/^\s*[+-]\s+(.*?)\s+;/;
            my $F = $1;
            if (!defined $1) {
                warn "file_pairs_from_file($file) parse failure\n",
                     "in $mode mode for '$L', ignoring\n";
                next;
            }
            if ($mode eq "added") {
                push @{$ra_added}  , $F;
            } else {
                push @{$ra_removed}, $F;
            }
        } else {
            $L =~ m/^\s*([!=]=\s*)?(.*?)\s*\|\s*(.*?)\s*(;.*?)?$/;
            if (!defined $2 or !defined $3) {
                warn "file_pairs_from_file($file) parse failure\n",
                     "in compare mode for '$L', ignoring\n";
                next;
            }
            push @{$ra_compare_list}, ( [$2, $3] );
        }
    }
    print "<- file_pairs_from_file\n" if $opt_v and $opt_v > 2;
}
sub read_file  {                             # {{{1
    my ($file, ) = @_;
    print "-> read_file($file)\n" if $opt_v and $opt_v > 2;
    my %BoM = (
        "fe ff"           => 2 ,
        "ff fe"           => 2 ,
        "ef bb bf"        => 3 ,
        "f7 64 4c"        => 3 ,
        "0e fe ff"        => 3 ,
        "fb ee 28"        => 3 ,
        "00 00 fe ff"     => 4 ,
        "ff fe 00 00"     => 4 ,
        "2b 2f 76 38"     => 4 ,
        "2b 2f 76 39"     => 4 ,
        "2b 2f 76 2b"     => 4 ,
        "2b 2f 76 2f"     => 4 ,
        "dd 73 66 73"     => 4 ,
        "84 31 95 33"     => 4 ,
        "2b 2f 76 38 2d"  => 5 ,
        );

    my @lines = ();
    my $IN = open_file('<', $file, 1);
    if (defined $IN) {
        @lines = <$IN>;
        $IN->close;
        if ($lines[$#lines]) {  # test necessary for zero content files
                                # (superfluous?)
            # Some files don't end with a new line.  Force this:
            $lines[$#lines] .= "\n" unless $lines[$#lines] =~ m/\n$/;
        }
    } else {
        warn "Unable to read $file\n";
    }

    # Are first few characters of the file Unicode Byte Order
    # Marks (http://en.wikipedia.org/wiki/Byte_Order_Mark)?
    # If yes, remove them.
    if (@lines) {
        my @chrs   = split('', $lines[0]);
        my $n_chrs = scalar @chrs;
        my ($n2, $n3, $n4, $n5) = ('', '', '', '');
        $n2 = sprintf("%x %x", map  ord, @chrs[0,1]) if $n_chrs >= 2;
        $n3 = sprintf("%s %x", $n2, ord  $chrs[2])   if $n_chrs >= 3;
        $n4 = sprintf("%s %x", $n3, ord  $chrs[3])   if $n_chrs >= 4;
        $n5 = sprintf("%s %x", $n4, ord  $chrs[4])   if $n_chrs >= 5;
        if      (defined $BoM{$n2}) { $lines[0] = substr $lines[0], 2;
        } elsif (defined $BoM{$n3}) { $lines[0] = substr $lines[0], 3;
        } elsif (defined $BoM{$n4}) { $lines[0] = substr $lines[0], 4;
        } elsif (defined $BoM{$n5}) { $lines[0] = substr $lines[0], 5;
        }
    }

    # Trim DOS line endings.  This allows Windows files
    # to be diff'ed with Unix files without line endings
    # causing every line to differ.
    foreach (@lines) { s/\cM$// }

    print "<- read_file\n" if $opt_v and $opt_v > 2;
    return @lines;
} # 1}}}
sub rm_blanks {                              # {{{1
    my ($ra_in    ,
        $language ,
        $rh_EOL_continuation_re) = @_;
    print "-> rm_blanks(language=$language)\n" if $opt_v > 2;
#print "rm_blanks: language = [$language]\n";
    my @out = ();
    if ($language eq "COBOL") {
        @out = remove_cobol_blanks($ra_in);
    } else {
        # removes blank lines
        if (defined $rh_EOL_continuation_re->{$language}) {
            @out = remove_matches_2re($ra_in, blank_regex($language),
                                      $rh_EOL_continuation_re->{$language});
        } else {
            @out = remove_matches($ra_in, blank_regex($language));
        }
    }

    print "<- rm_blanks(language=$language, n_remain= ",
        scalar(@out), "\n" if $opt_v > 2;
    return @out;
} # 1}}}
sub blank_regex {                            # {{{1
    my ($language) = @_;

    print "-> blank_regex(language=$language)\n" if $opt_v > 2;

    my $blank_regex = '^\s*$';
    if ($language eq "X++") {
        $blank_regex = '^\s*#?\s*$';
    }

    print "<- blank_regex(language=$language) = \"", $blank_regex, "\"\n" if $opt_v > 2;
    return $blank_regex;
} # 1}}}
sub rm_comments {                            # {{{1
    my ($ra_lines , # in, must be free of blank lines
        $language , # in
        $file     , # in (some language counters, eg Haskell, need
                    #     access to the original file)
        $rh_EOL_continuation_re , # in
        $raa_Errors , # out
       ) = @_;
    print "-> rm_comments(file=$file)\n" if $opt_v > 2;
    my @routines       = @{$Filters_by_Language{$language}};
    my @lines          = @{$ra_lines};
    my @original_lines = @{$ra_lines};

    if (!scalar @original_lines) {
        return @lines;
    }

    foreach my $call_string (@routines) {
        my $subroutine = $call_string->[0];
        next if $subroutine eq "rm_comments_in_strings" and !$opt_strip_str_comments;
        if (! defined &{$subroutine}) {
            warn "rm_comments undefined subroutine $subroutine for $file\n";
            next;
        }
        print "rm_comments file=$file sub=$subroutine\n" if $opt_v > 1;
        my @args  = @{$call_string};
        shift @args; # drop the subroutine name
        if (@args and $args[0] eq '>filename<') {
            shift   @args;
            unshift @args, $file;
        }

        # Unusual inputs, namely /* within strings without
        # a corresponding */ can cause huge delays so put a timer on this.
        my $max_duration_sec = scalar(@lines)/1000.0; # est lines per second
           $max_duration_sec = 1.0 if $max_duration_sec < 1;
        if (defined $opt_timeout) {
            $max_duration_sec = $opt_timeout if $opt_timeout > 0;
        }
#my $T_start = Time::HiRes::time();
        eval {
            local $SIG{ALRM} = sub { die "alarm\n" };
            alarm $max_duration_sec;
            no strict 'refs';
            @lines = &{$subroutine}(\@lines, @args);   # apply filter...
            alarm 0;
        };
        if ($@) {
            # timed out
            die unless $@ eq "alarm\n";
            push @{$raa_Errors},
                [ $Error_Codes{'Line count, exceeded timeout'}, $file ];
            @lines = ();
            if ($opt_v) {
                warn "rm_comments($subroutine): exceeded timeout for $file--ignoring\n";
            }
            next;
        }
#print "end time = ",Time::HiRes::time() - $T_start;

        print "   rm_comments after $subroutine line count=",
            scalar(@lines), "\n" if $opt_v > 2;

#print "lines after=\n";
#print Dumper(\@lines);

        print_lines($file, "After $subroutine(@args)", \@lines)
            if $opt_print_filter_stages;
        # then remove blank lines which are created by comment removal
        if (defined $rh_EOL_continuation_re->{$language}) {
            @lines = remove_matches_2re(\@lines, '^\s*$',
                                        $rh_EOL_continuation_re->{$language});
        } else {
            @lines = remove_matches(\@lines, '^\s*$');
        }

        print_lines($file, "post $subroutine(@args) blank cleanup:", \@lines)
            if $opt_print_filter_stages;
    }

    foreach (@lines) { chomp }   # make sure no spurious newlines were added

    # Exception for scripting languages:  treat the first #! line as code.
    # Will need to add it back in if it was removed earlier.
    chomp( $original_lines[0] );
    if (defined $Script_Language{$language} and
        $original_lines[0] =~ /^#!/ and
        (!scalar(@lines) or ($lines[0] ne $original_lines[0]))) {
        unshift @lines, $original_lines[0];  # add the first line back
    }

    print "<- rm_comments\n" if $opt_v > 2;
    return @lines;
} # 1}}}
sub remove_first_n {                         # {{{1
    my ($n, $ra_lines, ) = @_;
    print "-> remove_first_n\n" if $opt_v > 2;

    my @save_lines = ();
    if (scalar @{$ra_lines} > $n) {
        for (my $i = $n; $i < scalar @{$ra_lines}; $i++) {
            push @save_lines, $ra_lines->[$i];
        }
    }

    print "<- remove_first_n\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_f77_comments {                    # {{{1
    my ($ra_lines, ) = @_;
    print "-> remove_f77_comments\n" if $opt_v > 2;

    my @save_lines = ();
    foreach (@{$ra_lines}) {
        next if m{^[*cC]};
        next if m{^\s*!};
        push @save_lines, $_;
    }

    print "<- remove_f77_comments\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_f90_comments {                    # {{{1
    # derived from SLOCCount
    my ($ra_lines, ) = @_;
    print "-> remove_f90_comments\n" if $opt_v > 2;

    my @save_lines = ();
    foreach (@{$ra_lines}) {
        # a comment is              m/^\s*!/
        # an empty line is          m/^\s*$/
        # a HPF statement is        m/^\s*!hpf\$/i
        # an Open MP statement is   m/^\s*!omp\$/i
        if (! m/^(\s*!|\s*$)/ || m/^\s*!(hpf|omp)\$/i) {
            push @save_lines, $_;
        }
    }

    print "<- remove_f90_comments\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub reduce_to_rmd_code_blocks {              #{{{1
    my ($ra_lines) = @_; #in
    print "-> reduce_to_rmd_code_blocks()\n" if $opt_v > 2;

    my $in_code_block = 0;
    my @save_lines = ();
    foreach (@{$ra_lines}) {
        if ( m/^```\{\s*[[:alpha:]]/ ) {
            $in_code_block = 1;
            next;
        }
        if ( m/^```\s*$/ ) {
            $in_code_block = 0;
        }
        next if (!$in_code_block);
        push @save_lines, $_;
    }

    print "<- reduce_to_rmd_code_blocks()\n" if $opt_v> 2;
    return @save_lines;
} # 1}}}
sub remove_matches {                         # {{{1
    my ($ra_lines, # in
        $pattern , # in   Perl regular expression (case insensitive)
       ) = @_;
    print "-> remove_matches(pattern=$pattern)\n" if $opt_v > 2;

    my @save_lines = ();
    foreach (@{$ra_lines}) {
#chomp;
#print "remove_matches [$pattern] [$_]\n";
        next if m{$pattern}i;
#       s{$pattern}{}i;
#       next unless /\S/; # at least one non space
        push @save_lines, $_;
    }

    print "<- remove_matches\n" if $opt_v > 2;
#print "remove_matches returning\n   ", join("\n   ", @save_lines), "\n";
    return @save_lines;
} # 1}}}
sub remove_matches_2re {                     # {{{1
    my ($ra_lines, # in
        $pattern1, # in Perl regex 1 (case insensitive) to match
        $pattern2, # in Perl regex 2 (case insensitive) to not match prev line
       ) = @_;
    print "-> remove_matches_2re(pattern=$pattern1,$pattern2)\n" if $opt_v > 2;

    my @save_lines = ();
    for (my $i = 0; $i < scalar @{$ra_lines}; $i++) {
#       chomp($ra_lines->[$i]);
#print "remove_matches_2re [$pattern1] [$pattern2] [$ra_lines->[$i]]\n";
        if ($i) {
#print "remove_matches_2re prev=[$ra_lines->[$i-1]] this=[$ra_lines->[$i]]\n";
            next if ($ra_lines->[$i]   =~ m{$pattern1}i) and
                    ($ra_lines->[$i-1] !~ m{$pattern2}i);
        } else {
            # on first line
            next if $ra_lines->[$i]   =~  m{$pattern1}i;
        }
        push @save_lines, $ra_lines->[$i];
    }

    print "<- remove_matches_2re\n" if $opt_v > 2;
#print "remove_matches_2re returning\n   ", join("\n   ", @save_lines), "\n";
    return @save_lines;
} # 1}}}
sub remove_inline {                          # {{{1
    my ($ra_lines, # in
        $pattern , # in   Perl regular expression (case insensitive)
       ) = @_;
    print "-> remove_inline(pattern=$pattern)\n" if $opt_v > 2;

    my @save_lines = ();
    unless ($opt_inline) {
        return @{$ra_lines};
    }
    my $nLines_affected = 0;
    foreach (@{$ra_lines}) {
#chomp; print "remove_inline [$pattern] [$_]\n";
        if (m{$pattern}i) {
            ++$nLines_affected;
            s{$pattern}{}i;
        }
        push @save_lines, $_;
    }

    print "<- remove_inline\n" if $opt_v > 2;
#print "remove_inline returning\n   ", join("\n   ", @save_lines), "\n";
    return @save_lines;
} # 1}}}
sub remove_above {                           # {{{1
    my ($ra_lines, $marker, ) = @_;
    print "-> remove_above(marker=$marker)\n" if $opt_v > 2;

    # Make two passes through the code:
    # 1. check if the marker exists
    # 2. remove anything above the marker if it exists,
    #    do nothing if the marker does not exist

    # Pass 1
    my $found_marker = 0;
    for (my $line_number  = 1;
            $line_number <= scalar @{$ra_lines};
            $line_number++) {
        if ($ra_lines->[$line_number-1] =~ m{$marker}) {
            $found_marker = $line_number;
            last;
        }
    }

    # Pass 2 only if needed
    my @save_lines = ();
    if ($found_marker) {
        my $n = 1;
        foreach (@{$ra_lines}) {
            push @save_lines, $_
                if $n >= $found_marker;
            ++$n;
        }
    } else { # marker wasn't found; save all lines
        foreach (@{$ra_lines}) {
            push @save_lines, $_;
        }
    }

    print "<- remove_above\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_below {                           # {{{1
    my ($ra_lines, $marker, ) = @_;
    print "-> remove_below(marker=$marker)\n" if $opt_v > 2;

    my @save_lines = ();
    foreach (@{$ra_lines}) {
        last if m{$marker};
        push @save_lines, $_;
    }

    print "<- remove_below\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_below_above {                     # {{{1
    my ($ra_lines, $marker_below, $marker_above, ) = @_;
    # delete lines delimited by start and end line markers such
    # as Perl POD documentation
    print "-> remove_below_above(markerB=$marker_below, A=$marker_above)\n"
        if $opt_v > 2;

    my @save_lines = ();
    my $between    = 0;
    foreach (@{$ra_lines}) {
        if (!$between and m{$marker_below}) {
            $between    = 1;
            next;
        }
        if ($between and m{$marker_above}) {
            $between    = 0;
            next;
        }
        next if $between;
        push @save_lines, $_;
    }

    print "<- remove_below_above\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_between {                         # {{{1
    my ($ra_lines, $marker, ) = @_;
    # $marker must contain one of the balanced pairs understood
    # by Regexp::Common::balanced, namely
    # '{}'  '()'  '[]'  or  '<>'

    print "-> remove_between(marker=$marker)\n" if $opt_v > 2;
    my %acceptable = ('{}'=>1,  '()'=>1,  '[]'=>1,  '<>'=>1, );
    die "remove_between:  invalid delimiter '$marker'\n",
        "the delimiter must be one of these four pairs:\n",
        "{}  ()  []  <>\n" unless
        $acceptable{$marker};

    Install_Regexp_Common() unless $HAVE_Rexexp_Common;

    my $all_lines = join("", @{$ra_lines});

    no strict 'vars';
    # otherwise get:
    #  Global symbol "%RE" requires explicit package name at cloc line xx.
    if ($all_lines =~ m/$RE{balanced}{-parens => $marker}/) {
        no warnings;
        $all_lines =~ s/$1//g;
    }

    print "<- remove_between\n" if $opt_v > 2;
    return split("\n", $all_lines);
} # 1}}}
sub rm_comments_in_strings {                 # {{{1
    my ($ra_lines, $string_marker, $start_comment, $end_comment, $multiline_mode) = @_;
    $multiline_mode = 0 if not defined $multiline_mode;
    # Replace comments within strings with 'xx'.

    print "-> rm_comments_in_strings(string_marker=$string_marker, " .
          "start_comment=$start_comment, end_comment=$end_comment)\n"
        if $opt_v > 2;

    my @save_lines = ();
    my $in_ml_string = 0;
    foreach my $line (@{$ra_lines}) {
       #print "line=[$line]\n";
        my $new_line = "";

        if ($line !~ /${string_marker}/) {
            # short circuit; no strings on this line
            if ( $in_ml_string ) {
                $line =~ s/\Q${start_comment}\E/xx/g;
                $line =~ s/\Q${end_comment}\E/xx/g if $end_comment;
            }
            push @save_lines, $line;
            next;
        }

        # replace backslashed string markers with 'Q'
        $line =~ s/\\${string_marker}/Q/g;

        if ( $in_ml_string and $line =~ /^(.*?)(${string_marker})(.*)$/ ) {
            # A multiline string ends on this line. Process the part
            # until the end of the multiline string first.
            my ($lastpart_ml_string, $firstpart_marker, $rest_of_line )  = ($1, $2, $3);
            $lastpart_ml_string =~ s/\Q${start_comment}\E/xx/g;
            $lastpart_ml_string =~ s/\Q${end_comment}\E/xx/g if $end_comment;
            $new_line = $lastpart_ml_string . $firstpart_marker;
            $line = $rest_of_line;
            $in_ml_string = 0;
        }

        my @tokens = split(/(${string_marker}.*?${string_marker})/, $line);
        foreach my $t (@tokens) {
           #printf "  t0 = [$t]\n";
            if ($t =~ /${string_marker}.*${string_marker}$/) {
                # enclosed in quotes; process this token
                $t =~ s/\Q${start_comment}\E/xx/g;
                $t =~ s/\Q${end_comment}\E/xx/g if $end_comment;
            }
            elsif ( $multiline_mode and $t =~ /(${string_marker})/ ) {
                # Unclosed quote present in line. If multiline_mode is enabled,
                # consider it the start of a multiline string.
                my $firstpart_marker = $1;
                my @sub_token = split(/${string_marker}/, $t );

                if ( scalar @sub_token == 1 ) {
                    # The line ends with a string marker that starts
                    # a multiline string.
                    $t = $sub_token[0] . $firstpart_marker;
                    $in_ml_string = 1;
                }
                elsif ( scalar @sub_token == 2 ) {
                    # The line has some more content after the string
                    # marker that starts a multiline string
                    $t = $sub_token[0] . $firstpart_marker;
                    $sub_token[1] =~ s/\Q${start_comment}\E/xx/g;
                    $sub_token[1] =~ s/\Q${end_comment}\E/xx/g if $end_comment;
                    $t .= $sub_token[1];
                    $in_ml_string = 1;
                } else {
                    print "Warning: rm_comments_in_string length \@sub_token > 2\n";
                }

            }
            #printf "  t1 = [$t]\n";
            $new_line .= $t;
        }
        push @save_lines, $new_line;
    }

    print "<- rm_comments_in_strings\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_between_general {                 # {{{1
    my ($ra_lines, $start_marker, $end_marker, ) = @_;
    # Start and end markers may be any length strings.

    print "-> remove_between_general(start=$start_marker, end=$end_marker)\n"
        if $opt_v > 2;

    my $all_lines = join("", @{$ra_lines});

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {

        next if /^\s*$/;
        s/\Q$start_marker\E.*?\Q$end_marker\E//g;  # strip one-line comments
        next if /^\s*$/;
        if ($in_comment) {
            if (/\Q$end_marker\E/) {
                s/^.*?\Q$end_marker\E//;
                $in_comment = 0;
            }
            next if $in_comment;
        }
        next if /^\s*$/;
        $in_comment = 1 if /^(.*?)\Q$start_marker\E/; # $1 may be blank or code
        next if defined $1 and $1 =~ /^\s*$/; # leading blank; all comment
        if ($in_comment) {
            # part code, part comment; strip the comment and keep the code
            s/^(.*?)\Q$start_marker\E.*$/$1/;
        }
        push @save_lines, $_;
    }

    print "<- remove_between_general\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_between_regex   {                 # {{{1
    my ($ra_lines, $start_RE, $end_RE, ) = @_;
    # Start and end regex's may be any length strings.

    print "-> remove_between_regex(start=$start_RE, end=$end_RE)\n"
        if $opt_v > 2;

    my $all_lines = join("", @{$ra_lines});

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {

        next if /^\s*$/;
        s/${start_RE}.*?${end_RE}//g;  # strip one-line comments
        next if /^\s*$/;
        if ($in_comment) {
            if (/$end_RE/) {
                s/^.*?${end_RE}//;
                $in_comment = 0;
            }
            next if $in_comment;
        }
        next if /^\s*$/;
        $in_comment = 1 if /^(.*?)${start_RE}/; # $1 may be blank or code
        next if defined $1 and $1 =~ /^\s*$/; # leading blank; all comment
        if ($in_comment) {
            # part code, part comment; strip the comment and keep the code
            s/^(.*?)${start_RE}.*$/$1/;
        }
        push @save_lines, $_;
    }

    print "<- remove_between_regex\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub replace_regex  {                         # {{{1
    my ($ra_lines, $regex, $replace, ) = @_;

    print "-> replace_regex(regex=$regex, replace=$replace)\n"
        if $opt_v > 2;

    my $all_lines = join("", @{$ra_lines});

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {

        next if /^\s*$/;
        s/${regex}/${replace}/g;
        next if /^\s*$/;
        push @save_lines, $_;
    }

    print "<- replace_regex\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub replace_between_regex  {                 # {{{1
    my ($ra_lines, $start_RE, $end_RE, $replace_RE, $multiline_mode ) = @_;
    # If multiline_mode is enabled, $replace_RE should not refer
    # to any captured groups in $start_RE.
    $multiline_mode = 1 if not defined $multiline_mode;
    # Start and end regex's may be any length strings.

    print "-> replace_between_regex(start=$start_RE, end=$end_RE, replace=$replace_RE)\n"
        if $opt_v > 2;

    my $all_lines = join("", @{$ra_lines});

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {

        next if /^\s*$/;
        s/${start_RE}.*?${end_RE}/${replace_RE}/eeg;  # strip one-line comments
        next if /^\s*$/;
        if ($in_comment) {
            if (/$end_RE/) {
                s/^.*?${end_RE}/${replace_RE}/ee;
                $in_comment = 0;
            }
            next if $in_comment;
        }
        next if /^\s*$/;
        $in_comment = 1 if $multiline_mode and /^(.*?)${start_RE}/ ; # $1 may be blank or code
        next if defined $1 and $1 =~ /^\s*$/; # leading blank; all comment
        if ($in_comment) {
            # part code, part comment; strip the comment and keep the code
            s/^(.*?)${start_RE}.*$/$1/;
        }
        push @save_lines, $_;
    }

    print "<- replace_between_regex\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_cobol_blanks {                    # {{{1
    # subroutines derived from SLOCCount
    my ($ra_lines, ) = @_;

    my $free_format = 0;  # Support "free format" source code.
    my @save_lines  = ();

    foreach (@{$ra_lines}) {
        next if m/^\s*$/;
        my $line = expand($_);  # convert tabs to equivalent spaces
        $free_format = 1 if $line =~ m/^......\$.*SET.*SOURCEFORMAT.*FREE/i;
        if ($free_format) {
            push @save_lines, $_;
        } else {
            # Greg Toth:
            #  (1) Treat lines with any alphanum in cols 1-6 and
            #      blanks in cols 7 through 71 as blank line, and
            #  (2) Treat lines with any alphanum in cols 1-6 and
            #      slash (/) in col 7 as blank line (this is a
            #      page eject directive).
            push @save_lines, $_ unless m/^\d{6}\s*$/             or
                                        ($line =~ m/^.{6}\s{66}/) or
                                        ($line =~ m/^......\//);
        }
    }
    return @save_lines;
} # 1}}}
sub remove_cobol_comments {                  # {{{1
    # subroutines derived from SLOCCount
    my ($ra_lines, ) = @_;

    my $free_format = 0;  # Support "free format" source code.
    my @save_lines  = ();

    foreach (@{$ra_lines}) {
        if (m/^......\$.*SET.*SOURCEFORMAT.*FREE/i) {$free_format = 1;}
        if ($free_format) {
            push @save_lines, $_ unless m{^\s*\*};
        } else {
            push @save_lines, $_ unless m{^......\*} or m{^\*};
        }
    }
    return @save_lines;
} # 1}}}
sub remove_jcl_comments {                    # {{{1
    my ($ra_lines, ) = @_;

    print "-> remove_jcl_comments\n" if $opt_v > 2;

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {
        next if /^\s*$/;
        next if m{^//\*};
        last if m{^\s*//\s*$};
        push @save_lines, $_;
    }

    print "<- remove_jcl_comments\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_jsp_comments {                    # {{{1
    #  JSP comment is   <%--  body of comment   --%>
    my ($ra_lines, ) = @_;

    print "-> remove_jsp_comments\n" if $opt_v > 2;

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {

        next if /^\s*$/;
        s/<\%\-\-.*?\-\-\%>//g;  # strip one-line comments
        next if /^\s*$/;
        if ($in_comment) {
            if (/\-\-\%>/) {
                s/^.*?\-\-\%>//;
                $in_comment = 0;
            }
        }
        next if /^\s*$/;
        $in_comment = 1 if /^(.*?)<\%\-\-/;
        next if defined $1 and $1 =~ /^\s*$/;
        next if ($in_comment);
        push @save_lines, $_;
    }

    print "<- remove_jsp_comments\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_html_comments {                   # {{{1
    #  HTML comment is   <!--  body of comment   -->
    #  Need to use my own routine until the HTML comment regex in
    #  the Regexp::Common module can handle  <!--  --  -->
    my ($ra_lines, ) = @_;

    print "-> remove_html_comments\n" if $opt_v > 2;

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {

        next if /^\s*$/;
        s/<!\-\-.*?\-\->//g;  # strip one-line comments
        next if /^\s*$/;
        if ($in_comment) {
            if (/\-\->/) {
                s/^.*?\-\->//;
                $in_comment = 0;
            }
        }
        next if /^\s*$/;
        $in_comment = 1 if /^(.*?)<!\-\-/;
        next if defined $1 and $1 =~ /^\s*$/;
        next if ($in_comment);
        push @save_lines, $_;
    }

    print "<- remove_html_comments\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_bf_comments {                     # {{{1
    my ($ra_lines, ) = @_;

    print "-> remove_bf_comments\n" if $opt_v > 2;

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {

        s/[^<>+-.,\[\]]+//g;
        next if /^\s*$/;
        push @save_lines, $_;
    }

    print "<- remove_bf_comments\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub really_is_bf {                           # {{{1
    my ($file, ) = @_;

    print "-> really_is_bf\n" if $opt_v > 2;
    my $n_bf_indicators  = 0;
    my @lines = read_file($file);
    foreach my $L (@lines) {
        my $ind = 0;
        if ($L =~ /([+-]{4,}  |          # at least four +'s or -'s in a row
                   [\[\]]{4,} |          # at least four [ or ] in a row
                   [<>][+-]   |          # >- or >+ or <+ or <-
                   <{3,}      |          # at least three < in a row
                   ^\s*[\[\]]\s*$)/x) {  # [ or ] on line by itself
            ++$n_bf_indicators;
            $ind = 1;
        }
        # if ($ind) { print "YES: $L"; } else { print "NO : $L"; }
    }
    my $ratio = scalar(@lines) > 0 ? $n_bf_indicators / scalar(@lines) : 0;
    my $decision = ($ratio > 0.5) || ($n_bf_indicators > 5);
    printf "<- really_is_bf(Y/N=%d %s, R=%.3f, N=%d)\n",
            $decision, $file, $ratio, $n_bf_indicators if $opt_v > 2;
    return $decision;
} # 1}}}
sub remove_indented_block {                  # {{{1
    # Haml block comments are defined by a silent comment marker like
    #    /
    # or
    #    -#
    # followed by indented text on subsequent lines.
    # http://haml.info/docs/yardoc/file.REFERENCE.html#comments
    my ($ra_lines, $regex, ) = @_;

    print "-> remove_indented_block\n" if $opt_v > 2;

    my @save_lines = ();
    my $in_comment = 0;
    foreach (@{$ra_lines}) {

        next if /^\s*$/;
        my $line = expand($_);  # convert tabs to equivalent spaces
        if ($in_comment) {
            $line =~ /^(\s*)/;
            # print "indent=", length $1, "\n";
            if (length $1 < $in_comment) {
                # indent level is less than comment level
                # are back in code
                $in_comment = 0;
            } else {
                # still in comments, don't use this line
                next;
            }
        } elsif ($line =~ m{$regex}) {
            if ($1) {
                $in_comment = length($1) + 1; # number of leading spaces + 1
            } else {
                $in_comment = 1;
            }
            # print "in_comment=$in_comment\n";
            next;
        }
        push @save_lines, $line;
    }

    print "<- remove_indented_block\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_haml_block {                      # {{{1
    # Haml block comments are defined by a silent comment marker like
    #    /
    # or
    #    -#
    # followed by indented text on subsequent lines.
    # http://haml.info/docs/yardoc/file.REFERENCE.html#comments
    my ($ra_lines, ) = @_;

    return remove_indented_block($ra_lines, '^(\s*)(/|-#)\s*$');

} # 1}}}
sub remove_pug_block {                       # {{{1
    # Haml block comments are defined by a silent comment marker like
    #    //
    # followed by indented text on subsequent lines.
    # http://jade-lang.com/reference/comments/
    my ($ra_lines, ) = @_;
    return remove_indented_block($ra_lines, '^(\s*)(//)\s*$');
} # 1}}}
sub remove_OCaml_comments {                  # {{{1
    my ($ra_lines, ) = @_;

    print "-> remove_OCaml_comments\n" if $opt_v > 2;

    my @save_lines = ();
    my $in_comment = 0;   # counter to depth of nested comments
    foreach my $L (@{$ra_lines}) {
        next if $L =~ /^\s*$/;
        # make an array of tokens where a token is a start comment
        # marker, end comment marker, string, or anything else
        my $clean_line = ""; # ie, free of comments
        my @tokens = split(/(\(\*|\*\)|".*?")/, $L);
        foreach my $t (@tokens) {
            next unless $t;
            if      ($t eq "(*") {
                ++$in_comment;
            } elsif ($t eq "*)") {
                --$in_comment;
            } elsif (!$in_comment) {
                $clean_line .= $t;
            }
        }
        push @save_lines, $clean_line if $clean_line;
    }
    print "<- remove_OCaml_comments\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub remove_slim_block {                      # {{{1
    # slim comments start with /
    # followed by indented text on subsequent lines.
    # http://www.rubydoc.info/gems/slim/frames
    my ($ra_lines, ) = @_;
    return remove_indented_block($ra_lines, '^(\s*)(/[^!])');
} # 1}}}
sub add_newlines {                           # {{{1
    my ($ra_lines, ) = @_;
    print "-> add_newlines \n" if $opt_v > 2;

    my @save_lines = ();
    foreach (@{$ra_lines}) {

        push @save_lines, "$_\n";
    }

    print "<- add_newlines \n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub docstring_to_C {                         # {{{1
    my ($ra_lines, ) = @_;
    # Converts Python docstrings to C comments.

    if ($opt_docstring_as_code) {
        return @{$ra_lines};
    }

    print "-> docstring_to_C()\n" if $opt_v > 2;

    my $in_docstring = 0;
    foreach (@{$ra_lines}) {
        while (/((""")|('''))/) {
            if (!$in_docstring) {
                s{[uU]?((""")|('''))}{/*};
                $in_docstring = 1;
            } else {
                s{((""")|('''))}{*/};
                $in_docstring = 0;
            }
        }
    }

    print "<- docstring_to_C\n" if $opt_v > 2;
    return @{$ra_lines};
} # 1}}}
sub jupyter_nb {                             # {{{1
    my ($ra_lines, ) = @_;
    # Translate .ipynb file content into an equivalent set of code
    # lines as expected by cloc.

    print "-> jupyter_nb()\n" if $opt_v > 2;

    my @save_lines = ();
    my $in_code   = 0;
    my $in_source = 0;
    foreach (@{$ra_lines}) {
        if (!$in_code and !$in_source and /^\s*"cell_type":\s*"code",\s*$/) {
            $in_code = 1;
        } elsif ($in_code and !$in_source and /^\s*"source":\s*\[\s*$/) {
            $in_source = 1;
        } elsif ($in_code and $in_source) {
            if (/^\s*"\s*\\n",\s*$/) {    #  "\n",  -> empty line
                next;
            } elsif (/^\s*"\s*#/) {       #  comment within the code block
                next;
            } elsif (/^\s*\]\s*$/) {
                $in_code   = 0;
                $in_source = 0;
            } else {
                push @save_lines, $_;
            }
        }
    }

    print "<- jupyter_nb\n" if $opt_v > 2;

    return @save_lines;
} # 1}}}
sub elixir_doc_to_C {                        # {{{1
    my ($ra_lines, ) = @_;
    # Converts Elixir docs to C comments.

    print "-> elixir_doc_to_C()\n" if $opt_v > 2;

    my $in_docstring = 0;
    foreach (@{$ra_lines}) {
        if (!$in_docstring && /(\@(module)?doc\s+(~[sScC])?['"]{3})/) {
            s{$1}{/*};
            $in_docstring = 1;
        } elsif ($in_docstring && /(['"]{3})/) {
            s{$1}{*/};
            $in_docstring = 0;
        }
    }

    print "<- elixir_doc_to_C\n" if $opt_v > 2;
    return @{$ra_lines};
} # 1}}}
sub Forth_paren_to_C  {                      # {{{1
    my ($ra_lines, ) = @_;
    # Converts Forth comment parentheses to C comments.

    print "-> Forth_paren_to_C()\n" if $opt_v > 2;

    my $in_comment = 0;
    my $max_paren_pair_per_line = 255;
    foreach (@{$ra_lines}) {
#print "Forth_paren_to_C: [$_]\n";
        my $n_iter = 0;
        while (/\s\(\s/ or ($in_comment and /\)/)) {
#print "TOP n_iter=$n_iter in_comment=$in_comment\n";
            if (/\s\(\s.*?\)/) {
                # in-line parenthesis comment; handle here
                s/\s+\(\s+.*?\)//g;
#print "B\n";
            } elsif (!$in_comment and /\s\(\s/) {
                s{\s+\(\s+}{/*};
#print "C\n";
                $in_comment = 1;
            } elsif ($in_comment and /\)/) {
                s{\)}{*/};
#print "D\n";
                $in_comment = 0;
            } else {
                # gets here if it can't find a matching
                # close parenthesis; in this case the
                # results will likely be incorrect
                ++$n_iter;
#print "E\n";
                last if $n_iter > $max_paren_pair_per_line;
            }
        }
    }

    print "<- Forth_paren_to_C\n" if $opt_v > 2;
    return @{$ra_lines};
} # 1}}}
sub powershell_to_C {                        # {{{1
    my ($ra_lines, ) = @_;
    # Converts PowerShell block comment markers to C comments.

    print "-> powershell_to_C()\n" if $opt_v > 2;

    my $in_docstring = 0;
    foreach (@{$ra_lines}) {
        s{<#}{/*}g;
        s{#>}{*/}g;
    }

    print "<- powershell_to_C\n" if $opt_v > 2;
    return @{$ra_lines};
} # 1}}}
sub smarty_to_C {                            # {{{1
    my ($ra_lines, ) = @_;
    # Converts Smarty comments to C comments.

    print "-> smarty_to_C()\n" if $opt_v > 2;

    foreach (@{$ra_lines}) {
        s[{\*][/*]g;
        s[\*}][*/]g;
    }

    print "<- smarty_to_C\n" if $opt_v > 2;
    return @{$ra_lines};
} # 1}}}
sub determine_lit_type {                     # {{{1
  my ($file) = @_;

  my $FILE = open_file('<', $file, 0);
  while (<$FILE>) {
    if (m/^\\begin\{code\}/) { close $FILE; return 2; }
    if (m/^>\s/) { close $FILE; return 1; }
  }

  return 0;
} # 1}}}
sub remove_haskell_comments {                # {{{1
    # SLOCCount's haskell_count script with modifications to handle
    # Elm empty and nested block comments.
    # Strips out {- .. -} and -- comments and counts the rest.
    # Pragmas, {-#...}, are counted as SLOC.
    # BUG: Doesn't handle strings with embedded block comment markers gracefully.
    #      In practice, that shouldn't be a problem.
    my ($ra_lines, $file, ) = @_;

    print "-> remove_haskell_comments\n" if $opt_v > 2;

    my @save_lines = ();
    my $in_comment = 0;
    my $incomment  = 0;
    my $inlitblock = 0;
    my $literate   = 0;
    my $is_elm     = 0;

    $is_elm   = 1 if $file =~ /\.elm$/;
    $literate = 1 if $file =~ /\.lhs$/;
    if ($literate) { $literate = determine_lit_type($file) }

    foreach (@{$ra_lines}) {
        chomp;
        if ($literate == 1) {
            if (!s/^>//) { s/.*//; }
        } elsif ($literate == 2) {
            if ($inlitblock) {
                if (m/^\\end\{code\}/) { s/.*//; $inlitblock = 0; }
            } elsif (!$inlitblock) {
                if (m/^\\begin\{code\}/) { s/.*//; $inlitblock = 1; }
                else { s/.*//; }
            }
        }

        # keep pragmas
        if (/^\s*{-#/) {
            push @save_lines, $_;
            next;
        }

        # Elm allows nested comments so track nesting depth
        # with $incomment.

        my $n_open  = () = $_ =~ /{-/g;
        my $n_close = () = $_ =~ /-}/g;
        s/{-.*?-}//g;

        if ($incomment) {
            if (m/\-\}/) {
                s/^.*?\-\}//;
                if ($is_elm) {
                    $incomment += $n_open - $n_close;
                } else {
                    $incomment = 0;
                }
            } else {
                s/.*//;
            }
        } else {
            s/--.*//;
            if (m/{-/ && (!m/{-#/)) {
                s/{-.*//;
                if ($is_elm) {
                    $incomment += $n_open - $n_close;
                } else {
                    $incomment = 1;
                }
            }
        }
        if (m/\S/) { push @save_lines, $_; }
    }
#   if ($incomment) {print "ERROR: ended in comment in $ARGV\n";}

    print "<- remove_haskell_comments\n" if $opt_v > 2;
    return @save_lines;
} # 1}}}
sub print_lines {                            # {{{1
    my ($file     , # in
        $title    , # in
        $ra_lines , # in
       ) = @_;
    printf "->%-30s %s\n", $file, $title;
    for (my $i = 0; $i < scalar @{$ra_lines}; $i++) {
        printf "%5d | %s", $i+1, $ra_lines->[$i];
        print "\n" unless $ra_lines->[$i] =~ m{\n$}
    }
} # 1}}}
sub set_constants {                          # {{{1
    my ($rh_Language_by_Extension , # out
        $rh_Language_by_Script    , # out
        $rh_Language_by_File      , # out
        $rh_Language_by_Prefix    , # out
        $rhaa_Filters_by_Language , # out
        $rh_Not_Code_Extension    , # out
        $rh_Not_Code_Filename     , # out
        $rh_Scale_Factor          , # out
        $rh_Known_Binary_Archives , # out
        $rh_EOL_continuation_re   , # out
       ) = @_;
# 1}}}
%{$rh_Language_by_Extension} = (             # {{{1
            'abap'        => 'ABAP'                  ,
            'ac'          => 'm4'                    ,
            'ada'         => 'Ada'                   ,
            'adb'         => 'Ada'                   ,
            'ads'         => 'Ada'                   ,
            'adso'        => 'ADSO/IDSM'             ,
            'ahkl'        => 'AutoHotkey'            ,
            'ahk'         => 'AutoHotkey'            ,
            'agda'        => 'Agda'                  ,
            'lagda'       => 'Agda'                  ,
            'aj'          => 'AspectJ'               ,
            'am'          => 'make'                  ,
            'ample'       => 'AMPLE'                 ,
            'apl'         => 'APL'                   ,
            'apla'        => 'APL'                   ,
            'aplf'        => 'APL'                   ,
            'aplo'        => 'APL'                   ,
            'apln'        => 'APL'                   ,
            'aplc'        => 'APL'                   ,
            'apli'        => 'APL'                   ,
            'dyalog'      => 'APL'                   ,
            'dyapp'       => 'APL'                   ,
            'mipage'      => 'APL'                   ,
            'as'          => 'ActionScript'          ,
            'adoc'        => 'AsciiDoc'              ,
            'asciidoc'    => 'AsciiDoc'              ,
            'dofile'      => 'AMPLE'                 ,
            'startup'     => 'AMPLE'                 ,
            'axd'         => 'ASP'                   ,
            'ashx'        => 'ASP'                   ,
            'asa'         => 'ASP'                   ,
            'asax'        => 'ASP.NET'               ,
            'ascx'        => 'ASP.NET'               ,
            'asd'         => 'Lisp'                  , # system definition file
            'nasm'        => 'Assembly'              ,
            'a51'         => 'Assembly'              ,
            'asm'         => 'Assembly'              ,
            'asmx'        => 'ASP.NET'               ,
            'asp'         => 'ASP'                   ,
            'aspx'        => 'ASP.NET'               ,
            'master'      => 'ASP.NET'               ,
            'sitemap'     => 'ASP.NET'               ,
            'asy'         => 'Asymptote'             ,
            'cshtml'      => 'Razor'                 ,
            'razor'       => 'Razor'                 , # Client-side Blazor
            'nawk'        => 'awk'                   ,
            'mawk'        => 'awk'                   ,
            'gawk'        => 'awk'                   ,
            'auk'         => 'awk'                   ,
            'awk'         => 'awk'                   ,
            'bash'        => 'Bourne Again Shell'    ,
            'bazel'       => 'Starlark'              ,
            'BUILD'       => 'Bazel'                 ,
            'dxl'         => 'DOORS Extension Language',
            'bat'         => 'DOS Batch'             ,
            'BAT'         => 'DOS Batch'             ,
            'cmd'         => 'DOS Batch'             ,
            'CMD'         => 'DOS Batch'             ,
            'btm'         => 'DOS Batch'             ,
            'BTM'         => 'DOS Batch'             ,
            'blade'       => 'Blade'                 ,
            'blade.php'   => 'Blade'                 ,
            'build.xml'   => 'Ant'                   ,
            'b'           => 'Brainfuck'             ,
            'bf'          => 'Brainfuck'             ,
            'brs'         => 'BrightScript'          ,
            'bzl'         => 'Starlark'              ,
            'btp'         => 'BizTalk Pipeline'      ,
            'odx'         => 'BizTalk Orchestration' ,
            'carbon'      => 'Carbon'                ,
            'cpy'         => 'COBOL'                 ,
            'cobol'       => 'COBOL'                 ,
            'ccp'         => 'COBOL'                 ,
            'cbl'         => 'COBOL'                 ,
            'CBL'         => 'COBOL'                 ,
            'idc'         => 'C'                     ,
            'cats'        => 'C'                     ,
            'c'           => 'C'                     ,
            'c++'         => 'C++'                   ,
            'C'           => 'C++'                   ,
            'cc'          => 'C++'                   ,
            'ccm'         => 'C++'                   ,
            'c++m'        => 'C++'                   ,
            'cppm'        => 'C++'                   ,
            'cxxm'        => 'C++'                   ,
            'h++'         => 'C++'                   ,
            'inl'         => 'C++'                   ,
            'ipp'         => 'C++'                   ,
            'ixx'         => 'C++'                   ,
            'tcc'         => 'C++'                   ,
            'tpp'         => 'C++'                   ,
            'ccs'         => 'CCS'                   ,
            'cfc'         => 'ColdFusion CFScript'   ,
            'cfml'        => 'ColdFusion'            ,
            'cfm'         => 'ColdFusion'            ,
            'chpl'        => 'Chapel'                ,
            'cl'          => 'Lisp/OpenCL'           ,
            'riemann.config'=> 'Clojure'               ,
            'hic'         => 'Clojure'               ,
            'cljx'        => 'Clojure'               ,
            'cljscm'      => 'Clojure'               ,
            'cljs.hl'     => 'Clojure'               ,
            'cl2'         => 'Clojure'               ,
            'boot'        => 'Clojure'               ,
            'clj'         => 'Clojure'               ,
            'cljs'        => 'ClojureScript'         ,
            'cljc'        => 'ClojureC'              ,
            'cls'         => 'Visual Basic/TeX/Apex Class' ,
            'cmake.in'    => 'CMake'                 ,
            'CMakeLists.txt' => 'CMake'              ,
            'cmake'       => 'CMake'                 ,
            'cob'         => 'COBOL'                 ,
            'COB'         => 'COBOL'                 ,
            'cocoa5'      => 'CoCoA 5'               ,
            'c5'          => 'CoCoA 5'               ,
            'cpkg5'       => 'CoCoA 5'               ,
            'cocoa5server'=> 'CoCoA 5'               ,
            'iced'        => 'CoffeeScript'          ,
            'cjsx'        => 'CoffeeScript'          ,
            'cakefile'    => 'CoffeeScript'          ,
            '_coffee'     => 'CoffeeScript'          ,
            'coffee'      => 'CoffeeScript'          ,
            'component'   => 'Visualforce Component' ,
            'cg3'         => 'Constraint Grammar'    ,
            'rlx'         => 'Constraint Grammar'    ,
            'Containerfile'  => 'Containerfile'      ,
            'cpp'         => 'C++'                   ,
            'CPP'         => 'C++'                   ,
            'cr'          => 'Crystal'               ,
            'cs'          => 'C#/Smalltalk'          ,
            'designer.cs' => 'C# Designer'           ,
            'cake'        => 'Cake Build Script'     ,
            'csh'         => 'C Shell'               ,
            'cson'        => 'CSON'                  ,
            'css'         => "CSS"                   ,
            'csv'         => "CSV"                   ,
            'cu'          => 'CUDA'                  ,
            'cuh'         => 'CUDA'                  , # CUDA header file
            'cxx'         => 'C++'                   ,
            'd'           => 'D/dtrace'              ,
# in addition, .d can map to init.d files typically written as
# bash or sh scripts
            'da'          => 'DAL'                   ,
            'dart'        => 'Dart'                  ,
            'dsc'         => 'DenizenScript'         ,
            'derw'        => 'Derw'                  ,
            'def'         => 'Windows Module Definition',
            'dhall'       => 'dhall'                 ,
            'dt'          => 'DIET'                  ,
            'patch'       => 'diff'                  ,
            'diff'        => 'diff'                  ,
            'dmap'        => 'NASTRAN DMAP'          ,
            'sthlp'       => 'Stata'                 ,
            'matah'       => 'Stata'                 ,
            'mata'        => 'Stata'                 ,
            'ihlp'        => 'Stata'                 ,
            'doh'         => 'Stata'                 ,
            'ado'         => 'Stata'                 ,
            'do'          => 'Stata'                 ,
            'DO'          => 'Stata'                 ,
            'Dockerfile'  => 'Dockerfile'            ,
            'dockerfile'  => 'Dockerfile'            ,
            'pascal'      => 'Pascal'                ,
            'lpr'         => 'Pascal'                ,
            'dfm'         => 'Delphi Form'           ,
            'dpr'         => 'Pascal'                ,
            'dita'        => 'DITA'                  ,
            'drl'         => 'Drools'                ,
            'dtd'         => 'DTD'                   ,
            'ec'          => 'C'                     ,
            'ecpp'        => 'ECPP'                  ,
            'eex'         => 'EEx'                   ,
            'el'          => 'Lisp'                  ,
            'elm'         => 'Elm'                   ,
            'exs'         => 'Elixir'                ,
            'ex'          => 'Elixir'                ,
            'ecr'         => 'Embedded Crystal'      ,
            'ejs'         => 'EJS'                   ,
            'erb'         => 'ERB'                   ,
            'ERB'         => 'ERB'                   ,
            'yrl'         => 'Erlang'                ,
            'xrl'         => 'Erlang'                ,
            'rebar.lock'  => 'Erlang'                ,
            'rebar.config.lock'=> 'Erlang'           ,
            'rebar.config'=> 'Erlang'                ,
            'emakefile'   => 'Erlang'                ,
            'app.src'     => 'Erlang'                ,
            'erl'         => 'Erlang'                ,
            'exp'         => 'Expect'                ,
            '4th'         => 'Forth'                 ,
            'fish'        => 'Fish Shell'            ,
            'fsl'         => 'Finite State Language' ,
            'jssm'        => 'Finite State Language' ,
            'fnl'         => 'Fennel'                ,
            'forth'       => 'Forth'                 ,
            'fr'          => 'Forth'                 ,
            'frt'         => 'Forth'                 ,
            'fth'         => 'Forth'                 ,
            'f83'         => 'Forth'                 ,
            'fb'          => 'Forth'                 ,
            'fpm'         => 'Forth'                 ,
            'e4'          => 'Forth'                 ,
            'rx'          => 'Forth'                 ,
            'ft'          => 'Forth'                 ,
            'f77'         => 'Fortran 77'            ,
            'F77'         => 'Fortran 77'            ,
            'f90'         => 'Fortran 90'            ,
            'F90'         => 'Fortran 90'            ,
            'f95'         => 'Fortran 95'            ,
            'F95'         => 'Fortran 95'            ,
            'f'           => 'Fortran 77/Forth'      ,
            'F'           => 'Fortran 77'            ,
            'for'         => 'Fortran 77/Forth'      ,
            'FOR'         => 'Fortran 77'            ,
            'ftl'         => 'Freemarker Template'   ,
            'ftn'         => 'Fortran 77'            ,
            'FTN'         => 'Fortran 77'            ,
            'fmt'         => 'Oracle Forms'          ,
            'focexec'     => 'Focus'                 ,
            'fs'          => 'F#/Forth'              ,
            'fsi'         => 'F#'                    ,
            'fsx'         => 'F# Script'             ,
            'fut'         => 'Futhark'               ,
            'fxml'        => 'FXML'                  ,
            'gnumakefile' => 'make'                  ,
            'Gnumakefile' => 'make'                  ,
            'gd'          => 'GDScript'              ,
            'gdshader'    => 'Godot Shaders'         ,
            'vshader'     => 'GLSL'                  ,
            'vsh'         => 'GLSL'                  ,
            'vrx'         => 'GLSL'                  ,
            'gshader'     => 'GLSL'                  ,
            'glslv'       => 'GLSL'                  ,
            'geo'         => 'GLSL'                  ,
            'fshader'     => 'GLSL'                  ,
            'fsh'         => 'GLSL'                  ,
            'frg'         => 'GLSL'                  ,
            'fp'          => 'GLSL'                  ,
            'fbs'         => 'Flatbuffers'           ,
            'glsl'        => 'GLSL'                  ,
            'graphqls'    => 'GraphQL'               ,
            'gql'         => 'GraphQL'               ,
            'graphql'     => 'GraphQL'               ,
            'vert'        => 'GLSL'                  ,
            'tesc'        => 'GLSL'                  ,
            'tese'        => 'GLSL'                  ,
            'geom'        => 'GLSL'                  ,
            'feature'     => 'Cucumber'              ,
            'frag'        => 'GLSL'                  ,
            'comp'        => 'GLSL'                  ,
            'g'           => 'ANTLR Grammar'         ,
            'g4'          => 'ANTLR Grammar'         ,
            'gleam'       => 'Gleam'                 ,
            'go'          => 'Go'                    ,
            'gsp'         => 'Grails'                ,
            'jenkinsfile' => 'Groovy'                ,
            'gvy'         => 'Groovy'                ,
            'gtpl'        => 'Groovy'                ,
            'grt'         => 'Groovy'                ,
            'groovy'      => 'Groovy'                ,
            'gant'        => 'Groovy'                ,
            'gradle'      => 'Gradle'                ,
            'gradle.kts'  => 'Gradle'                ,
            'h'           => 'C/C++ Header'          ,
            'H'           => 'C/C++ Header'          ,
            'hh'          => 'C/C++ Header'          ,
            'hpp'         => 'C/C++ Header'          ,
            'hxx'         => 'C/C++ Header'          ,
            'hb'          => 'Harbour'               ,
            'hrl'         => 'Erlang'                ,
            'hsc'         => 'Haskell'               ,
            'hs'          => 'Haskell'               ,
            'tfvars'      => 'HCL'                   ,
            'hcl'         => 'HCL'                   ,
            'tf'          => 'HCL'                   ,
            'nomad'       => 'HCL'                   ,
            'hlsli'       => 'HLSL'                  ,
            'fxh'         => 'HLSL'                  ,
            'hlsl'        => 'HLSL'                  ,
            'shader'      => 'HLSL'                  ,
            'cg'          => 'HLSL'                  ,
            'cginc'       => 'HLSL'                  ,
            'haml.deface' => 'Haml'                  ,
            'haml'        => 'Haml'                  ,
            'handlebars'  => 'Handlebars'            ,
            'hbs'         => 'Handlebars'            ,
            'ha'          => 'Hare'                  ,
            'hxsl'        => 'Haxe'                  ,
            'hx'          => 'Haxe'                  ,
            'HC'          => 'HolyC'                 ,
            'hoon'        => 'Hoon'                  ,
            'xht'         => 'HTML'                  ,
            'html.hl'     => 'HTML'                  ,
            'htm'         => 'HTML'                  ,
            'html'        => 'HTML'                  ,
            'heex'        => 'HTML EEx'              ,
            'i3'          => 'Modula3'               ,
            'ice'         => 'Slice'                 ,
            'icl'         => 'Clean'                 ,
            'dcl'         => 'Clean'                 ,
            'dlm'         => 'IDL'                   ,
            'idl'         => 'IDL'                   ,
            'idr'         => 'Idris'                 ,
            'lidr'        => 'Literate Idris'        ,
            'imba'        => 'Imba'                  ,
            'prefs'       => 'INI'                   ,
            'lektorproject'=> 'INI'                  ,
            'buildozer.spec'=> 'INI'                 ,
            'ini'         => 'INI'                   ,
            'ism'         => 'InstallShield'         ,
            'ipl'         => 'IPL'                   ,
            'pro'         => 'IDL/Qt Project/Prolog/ProGuard' ,
            'ig'          => 'Modula3'               ,
            'il'          => 'SKILL'                 ,
            'ils'         => 'SKILL++'               ,
            'inc'         => 'PHP/Pascal'            , # might be PHP or Pascal
            'ino'         => 'Arduino Sketch'        ,
            'ipf'         => 'Igor Pro'              ,
            'pde'         => 'Arduino Sketch'        , # pre 1.0
            'itk'         => 'Tcl/Tk'                ,
            'java'        => 'Java'                  ,
            'jcl'         => 'JCL'                   , # IBM Job Control Lang.
            'jl'          => 'Lisp/Julia'            ,
            'jai'         => 'Jai'                   ,
            'xsjslib'     => 'JavaScript'            ,
            'xsjs'        => 'JavaScript'            ,
            'ssjs'        => 'JavaScript'            ,
            'sjs'         => 'JavaScript'            ,
            'pac'         => 'JavaScript'            ,
            'njs'         => 'JavaScript'            ,
            'mjs'         => 'JavaScript'            ,
            'cjs'         => 'JavaScript'            ,
            'jss'         => 'JavaScript'            ,
            'jsm'         => 'JavaScript'            ,
            'jsfl'        => 'JavaScript'            ,
            'jscad'       => 'JavaScript'            ,
            'jsb'         => 'JavaScript'            ,
            'jakefile'    => 'JavaScript'            ,
            'jake'        => 'JavaScript'            ,
            'bones'       => 'JavaScript'            ,
            '_js'         => 'JavaScript'            ,
            'js'          => 'JavaScript'            ,
            'es6'         => 'JavaScript'            ,
            'jsf'         => 'JavaServer Faces'      ,
            'jsx'         => 'JSX'                   ,
            'xhtml'       => 'XHTML'                 ,
            'jinja'       => 'Jinja Template'        ,
            'jinja2'      => 'Jinja Template'        ,
            'yyp'         => 'JSON'                  ,
            'webmanifest' => 'JSON'                  ,
            'webapp'      => 'JSON'                  ,
            'topojson'    => 'JSON'                  ,
            'tfstate.backup'=> 'JSON'                  ,
            'tfstate'     => 'JSON'                  ,
            'mcmod.info'  => 'JSON'                  ,
            'mcmeta'      => 'JSON'                  ,
            'json-tmlanguage'=> 'JSON'                  ,
            'jsonl'       => 'JSON'                  ,
            'har'         => 'JSON'                  ,
            'gltf'        => 'JSON'                  ,
            'geojson'     => 'JSON'                  ,
            'composer.lock'=> 'JSON'                  ,
            'avsc'        => 'JSON'                  ,
            'watchmanconfig'=> 'JSON'                  ,
            'tern-project'=> 'JSON'                  ,
            'tern-config' => 'JSON'                  ,
            'htmlhintrc'  => 'JSON'                  ,
            'arcconfig'   => 'JSON'                  ,
            'json'        => 'JSON'                  ,
            'json5'       => 'JSON5'                 ,
            'jsp'         => 'JSP'                   , # Java server pages
            'jspf'        => 'JSP'                   , # Java server pages
            'junos'       => 'Juniper Junos'         ,
            'vm'          => 'Velocity Template Language' ,
            'kv'          => 'kvlang'                ,
            'ksc'         => 'Kermit'                ,
            'ksh'         => 'Korn Shell'            ,
            'ktm'         => 'Kotlin'                ,
            'kt'          => 'Kotlin'                ,
            'kts'         => 'Kotlin'                ,
            'hlean'       => 'Lean'                  ,
            'lean'        => 'Lean'                  ,
            'lhs'         => 'Haskell'               ,
            'lex'         => 'lex'                   ,
            'l'           => 'lex'                   ,
            'ld'          => 'Linker Script'         ,
            'lem'         => 'Lem'                   ,
            'less'        => 'LESS'                  ,
            'lfe'         => 'LFE'                   ,
            'liquid'      => 'liquid'                ,
            'lsp'         => 'Lisp'                  ,
            'lisp'        => 'Lisp'                  ,
            'll'          => 'LLVM IR'               ,
            'lgt'         => 'Logtalk'               ,
            'logtalk'     => 'Logtalk'               ,
            'wlua'        => 'Lua'                   ,
            'rbxs'        => 'Lua'                   ,
            'pd_lua'      => 'Lua'                   ,
            'p8'          => 'Lua'                   ,
            'nse'         => 'Lua'                   ,
            'lua'         => 'Lua'                   ,
            'm3'          => 'Modula3'               ,
            'm4'          => 'm4'                    ,
            'makefile'    => 'make'                  ,
            'Makefile'    => 'make'                  ,
            'mao'         => 'Mako'                  ,
            'mako'        => 'Mako'                  ,
            'workbook'    => 'Markdown'              ,
            'ronn'        => 'Markdown'              ,
            'mkdown'      => 'Markdown'              ,
            'mkdn'        => 'Markdown'              ,
            'mkd'         => 'Markdown'              ,
            'mdx'         => 'Markdown'              ,
            'mdwn'        => 'Markdown'              ,
            'mdown'       => 'Markdown'              ,
            'markdown'    => 'Markdown'              ,
            'contents.lr' => 'Markdown'              ,
            'md'          => 'Markdown'              ,
            'mc'          => 'Windows Message File'  ,
            'met'         => 'Teamcenter met'        ,
            'mg'          => 'Modula3'               ,
            'mojom'       => 'Mojo'                  ,
            'meson.build' => 'Meson'                 ,
            'metal'       => 'Metal'                 ,
            'mk'          => 'make'                  ,
#           'mli'         => 'ML'                    , # ML not implemented
#           'ml'          => 'ML'                    ,
            'ml4'         => 'OCaml'                 ,
            'eliomi'      => 'OCaml'                 ,
            'eliom'       => 'OCaml'                 ,
            'ml'          => 'OCaml'                 ,
            'mli'         => 'OCaml'                 ,
            'mly'         => 'OCaml'                 ,
            'mll'         => 'OCaml'                 ,
            'm'           => 'MATLAB/Mathematica/Objective-C/MUMPS/Mercury' ,
            'mm'          => 'Objective-C++'         ,
            'msg'         => 'Gencat NLS'            ,
            'nbp'         => 'Mathematica'           ,
            'mathematica' => 'Mathematica'           ,
            'ma'          => 'Mathematica'           ,
            'cdf'         => 'Mathematica'           ,
            'mt'          => 'Mathematica'           ,
            'wl'          => 'Mathematica'           ,
            'wlt'         => 'Mathematica'           ,
            'mustache'    => 'Mustache'              ,
            'wdproj'      => 'MSBuild script'        ,
            'csproj'      => 'MSBuild script'        ,
            'vcproj'      => 'MSBuild script'        ,
            'wixproj'     => 'MSBuild script'        ,
            'btproj'      => 'MSBuild script'        ,
            'msbuild'     => 'MSBuild script'        ,
            'sln'         => 'Visual Studio Solution',
            'mps'         => 'MUMPS'                 ,
            'mth'         => 'Teamcenter mth'        ,
            'n'           => 'Nemerle'               ,
            'nlogo'       => 'NetLogo'               ,
            'nls'         => 'NetLogo'               ,
            'nims'        => 'Nim'                   ,
            'nimrod'      => 'Nim'                   ,
            'nimble'      => 'Nim'                   ,
            'nim.cfg'     => 'Nim'                   ,
            'nim'         => 'Nim'                   ,
            'nix'         => 'Nix'                   ,
            'nut'         => 'Squirrel'              ,
            'njk'         => 'Nunjucks'              ,
            'odin'        => 'Odin'                  ,
            'oscript'     => 'LiveLink OScript'      ,
            'bod'         => 'Oracle PL/SQL'         ,
            'spc'         => 'Oracle PL/SQL'         ,
            'fnc'         => 'Oracle PL/SQL'         ,
            'prc'         => 'Oracle PL/SQL'         ,
            'trg'         => 'Oracle PL/SQL'         ,
            'pad'         => 'Ada'                   , # Oracle Ada preprocessor
            'page'        => 'Visualforce Page'      ,
            'pas'         => 'Pascal'                ,
            'pcc'         => 'C++'                   , # Oracle C++ preprocessor
            'rexfile'     => 'Perl'                  ,
            'psgi'        => 'Perl'                  ,
            'ph'          => 'Perl'                  ,
            'makefile.pl' => 'Perl'                  ,
            'cpanfile'    => 'Perl'                  ,
            'al'          => 'Perl'                  ,
            'ack'         => 'Perl'                  ,
            'perl'        => 'Perl'                  ,
            'pfo'         => 'Fortran 77'            ,
            'pgc'         => 'C'                     , # Postgres embedded C/C++
            'phpt'        => 'PHP'                   ,
            'phps'        => 'PHP'                   ,
            'phakefile'   => 'PHP'                   ,
            'ctp'         => 'PHP'                   ,
            'aw'          => 'PHP'                   ,
            'php_cs.dist' => 'PHP'                   ,
            'php_cs'      => 'PHP'                   ,
            'php3'        => 'PHP'                   ,
            'php4'        => 'PHP'                   ,
            'php5'        => 'PHP'                   ,
            'php'         => 'PHP'                   ,
            'phtml'       => 'PHP'                   ,
            'pig'         => 'Pig Latin'             ,
            'plh'         => 'Perl'                  ,
            'pl'          => 'Perl/Prolog'           ,
            'PL'          => 'Perl/Prolog'           ,
            'p6'          => 'Raku/Prolog'           ,
            'P6'          => 'Raku/Prolog'           ,
            'plx'         => 'Perl'                  ,
            'pm'          => 'Perl'                  ,
            'pm6'         => 'Raku'                  ,
            'raku'        => 'Raku'                  ,
            'rakumod'     => 'Raku'                  ,
            'pom.xml'     => 'Maven'                 ,
            'pom'         => 'Maven'                 ,
            'scad'        => 'OpenSCAD'              ,
            'yap'         => 'Prolog'                ,
            'prolog'      => 'Prolog'                ,
            'P'           => 'Prolog'                ,
            'p'           => 'Pascal'                ,
            'pp'          => 'Pascal/Puppet'         ,
            'viw'         => 'SQL'                   ,
            'udf'         => 'SQL'                   ,
            'tab'         => 'SQL'                   ,
            'mysql'       => 'SQL'                   ,
            'cql'         => 'SQL'                   ,
            'psql'        => 'SQL'                   ,
            'xpy'         => 'Python'                ,
            'wsgi'        => 'Python'                ,
            'wscript'     => 'Python'                ,
            'workspace'   => 'Python'                ,
            'tac'         => 'Python'                ,
            'snakefile'   => 'Python'                ,
            'sconstruct'  => 'Python'                ,
            'sconscript'  => 'Python'                ,
            'pyt'         => 'Python'                ,
            'pyp'         => 'Python'                ,
            'pyi'         => 'Python'                ,
            'pyde'        => 'Python'                ,
            'py3'         => 'Python'                ,
            'lmi'         => 'Python'                ,
            'gypi'        => 'Python'                ,
            'gyp'         => 'Python'                ,
            'build.bazel' => 'Python'                ,
            'buck'        => 'Python'                ,
            'gclient'     => 'Python'                ,
            'py'          => 'Python'                ,
            'pyw'         => 'Python'                ,
            'ipynb'       => 'Jupyter Notebook'      ,
            'pyj'         => 'RapydScript'           ,
            'pxi'         => 'Cython'                ,
            'pxd'         => 'Cython'                ,
            'pyx'         => 'Cython'                ,
            'qbs'         => 'QML'                   ,
            'qml'         => 'QML'                   ,
            'watchr'      => 'Ruby'                  ,
            'vagrantfile' => 'Ruby'                  ,
            'thorfile'    => 'Ruby'                  ,
            'thor'        => 'Ruby'                  ,
            'snapfile'    => 'Ruby'                  ,
            'ru'          => 'Ruby'                  ,
            'rbx'         => 'Ruby'                  ,
            'rbw'         => 'Ruby'                  ,
            'rbuild'      => 'Ruby'                  ,
            'rabl'        => 'Ruby'                  ,
            'puppetfile'  => 'Ruby'                  ,
            'podfile'     => 'Ruby'                  ,
            'mspec'       => 'Ruby'                  ,
            'mavenfile'   => 'Ruby'                  ,
            'jbuilder'    => 'Ruby'                  ,
            'jarfile'     => 'Ruby'                  ,
            'guardfile'   => 'Ruby'                  ,
            'god'         => 'Ruby'                  ,
            'gemspec'     => 'Ruby'                  ,
            'gemfile.lock'=> 'Ruby'                  ,
            'gemfile'     => 'Ruby'                  ,
            'fastfile'    => 'Ruby'                  ,
            'eye'         => 'Ruby'                  ,
            'deliverfile' => 'Ruby'                  ,
            'dangerfile'  => 'Ruby'                  ,
            'capfile'     => 'Ruby'                  ,
            'buildfile'   => 'Ruby'                  ,
            'builder'     => 'Ruby'                  ,
            'brewfile'    => 'Ruby'                  ,
            'berksfile'   => 'Ruby'                  ,
            'appraisals'  => 'Ruby'                  ,
            'pryrc'       => 'Ruby'                  ,
            'irbrc'       => 'Ruby'                  ,
            'rb'          => 'Ruby'                  ,
            'podspec'     => 'Ruby'                  ,
            'rake'        => 'Ruby'                  ,
         #  'resx'        => 'ASP.NET'               ,
            'rex'         => 'Oracle Reports'        ,
            'pprx'        => 'Rexx'                  ,
            'rexx'        => 'Rexx'                  ,
            'rhtml'       => 'Ruby HTML'             ,
            'circom'      => 'Circom'                ,
            'cairo'       => 'Cairo'                 ,
            'rs.in'       => 'Rust'                  ,
            'rs'          => 'Rust'                  ,
            'rst.txt'     => 'reStructuredText'      ,
            'rest.txt'    => 'reStructuredText'      ,
            'rest'        => 'reStructuredText'      ,
            'rst'         => 'reStructuredText'      ,
            's'           => 'Assembly'              ,
            'S'           => 'Assembly'              ,
            'SCA'         => 'Visual Fox Pro'        ,
            'sca'         => 'Visual Fox Pro'        ,
            'sbt'         => 'Scala'                 ,
            'kojo'        => 'Scala'                 ,
            'scala'       => 'Scala'                 ,
            'sbl'         => 'Softbridge Basic'      ,
            'SBL'         => 'Softbridge Basic'      ,
            'sed'         => 'sed'                   ,
            'sp'          => 'SparForte'             ,
            'sol'         => 'Solidity'              ,
            'p4'          => 'P4'                    ,
            'ses'         => 'Patran Command Language'   ,
            'pcl'         => 'Patran Command Language'   ,
            'peg'         => 'PEG'                   ,
            'pegjs'       => 'peg.js'                ,
            'peggy'       => 'peggy'                 ,
            'pest'        => 'Pest'                  ,
            'tspeg'       => 'tspeg'                 ,
            'jspeg'       => 'tspeg'                 ,
            'pl1'         => 'PL/I'                  ,
            'plm'         => 'PL/M'                  ,
            'lit'         => 'PL/M'                  ,
            'puml'        => 'PlantUML'              ,
            'properties'  => 'Properties'            ,
            'po'          => 'PO File'               ,
            'pony'        => 'Pony'                  ,
            'pbt'         => 'PowerBuilder'          ,
            'sra'         => 'PowerBuilder'          ,
            'srf'         => 'PowerBuilder'          ,
            'srm'         => 'PowerBuilder'          ,
            'srs'         => 'PowerBuilder'          ,
            'sru'         => 'PowerBuilder'          ,
            'srw'         => 'PowerBuilder'          ,
            'jade'        => 'Pug'                   ,
            'pug'         => 'Pug'                   ,
            'purs'        => 'PureScript'            ,
            'prefab'      => 'Unity-Prefab'          ,
            'proto'       => 'Protocol Buffers'      ,
            'mat'         => 'Unity-Prefab'          ,
            'ps1'         => 'PowerShell'            ,
            'psd1'        => 'PowerShell'            ,
            'psm1'        => 'PowerShell'            ,
            'rsx'         => 'R'                     ,
            'rd'          => 'R'                     ,
            'expr-dist'   => 'R'                     ,
            'rprofile'    => 'R'                     ,
            'R'           => 'R'                     ,
            'r'           => 'R'                     ,
            'raml'        => 'RAML'                  ,
            'ring'        => 'Ring'                  ,
            'rh'          => 'Ring'                  ,
            'rform'       => 'Ring'                  ,
            'rktd'        => 'Racket'                ,
            'rkt'         => 'Racket'                ,
            'rktl'        => 'Racket'                ,
            'Rmd'         => 'Rmd'                   ,
            're'          => 'ReasonML'              ,
            'rei'         => 'ReasonML'              ,
            'res'         => 'ReScript'              ,
            'resi'        => 'ReScript'              ,
            'scrbl'       => 'Racket'                ,
            'sps'         => 'Scheme'                ,
            'sc'          => 'Scheme'                ,
            'ss'          => 'Scheme'                ,
            'scm'         => 'Scheme'                ,
            'sch'         => 'Scheme'                ,
            'sls'         => 'Scheme/SaltStack'      ,
            'sld'         => 'Scheme'                ,
            'robot'       => 'RobotFramework'        ,
            'rc'          => 'Windows Resource File' ,
            'rc2'         => 'Windows Resource File' ,
            'sas'         => 'SAS'                   ,
            'sass'        => 'Sass'                  ,
            'scss'        => 'SCSS'                  ,
            'sh'          => 'Bourne Shell'          ,
            'smarty'      => 'Smarty'                ,
            'sml'         => 'Standard ML'           ,
            'sig'         => 'Standard ML'           ,
            'fun'         => 'Standard ML'           ,
            'slim'        => 'Slim'                  ,
            'e'           => 'Specman e'             ,
            'sql'         => 'SQL'                   ,
            'SQL'         => 'SQL'                   ,
            'sproc.sql'   => 'SQL Stored Procedure'  ,
            'spoc.sql'    => 'SQL Stored Procedure'  ,
            'spc.sql'     => 'SQL Stored Procedure'  ,
            'udf.sql'     => 'SQL Stored Procedure'  ,
            'data.sql'    => 'SQL Data'              ,
            'sss'         => 'SugarSS'               ,
            'st'          => 'Smalltalk'             ,
            'styl'        => 'Stylus'                ,
            'i'           => 'SWIG'                  ,
            'svelte'      => 'Svelte'                ,
            'sv'          => 'Verilog-SystemVerilog' ,
            'svh'         => 'Verilog-SystemVerilog' ,
            'svg'         => 'SVG'                   ,
            'SVG'         => 'SVG'                   ,
            'v'           => 'Verilog-SystemVerilog/Coq' ,
            'td'          => 'TableGen'              ,
            'tcl'         => 'Tcl/Tk'                ,
            'tcsh'        => 'C Shell'               ,
            'tk'          => 'Tcl/Tk'                ,
            'teal'        => 'TEAL'                  ,
            'mkvi'        => 'TeX'                   ,
            'mkiv'        => 'TeX'                   ,
            'mkii'        => 'TeX'                   ,
            'ltx'         => 'TeX'                   ,
            'lbx'         => 'TeX'                   ,
            'ins'         => 'TeX'                   ,
            'cbx'         => 'TeX'                   ,
            'bib'         => 'TeX'                   ,
            'bbx'         => 'TeX'                   ,
            'aux'         => 'TeX'                   ,
            'tex'         => 'TeX'                   , # TeX, LaTex, MikTex, ..
            'toml'        => 'TOML'                  ,
            'sty'         => 'TeX'                   ,
#           'cls'         => 'TeX'                   ,
            'dtx'         => 'TeX'                   ,
            'bst'         => 'TeX'                   ,
            'txt'         => 'Text'                  ,
            'text'        => 'Text'                  ,
            'tres'        => 'Godot Resource'        ,
            'tscn'        => 'Godot Scene'           ,
            'thrift'      => 'Thrift'                ,
            'tpl'         => 'Smarty'                ,
            'trigger'     => 'Apex Trigger'          ,
            'ttcn'        => 'TTCN'                  ,
            'ttcn2'       => 'TTCN'                  ,
            'ttcn3'       => 'TTCN'                  ,
            'ttcnpp'      => 'TTCN'                  ,
            'sdl'         => 'TNSDL'                 ,
            'ssc'         => 'TNSDL'                 ,
            'sdt'         => 'TNSDL'                 ,
            'spd'         => 'TNSDL'                 ,
            'sst'         => 'TNSDL'                 ,
            'rou'         => 'TNSDL'                 ,
            'cin'         => 'TNSDL'                 ,
            'cii'         => 'TNSDL'                 ,
            'interface'   => 'TNSDL'                 ,
            'in1'         => 'TNSDL'                 ,
            'in2'         => 'TNSDL'                 ,
            'in3'         => 'TNSDL'                 ,
            'in4'         => 'TNSDL'                 ,
            'inf'         => 'TNSDL'                 ,
            'tpd'         => 'TITAN Project File Information',
            'ts'          => 'TypeScript/Qt Linguist',
            'tsx'         => 'TypeScript'            ,
            'tss'         => 'Titanium Style Sheet'  ,
            'twig'        => 'Twig'                  ,
            'typ'         => 'Typst'                 ,
            'um'          => 'Umka'                  ,
            'ui'          => 'Qt/Glade'              ,
            'glade'       => 'Glade'                 ,
            'vala'        => 'Vala'                  ,
            'vapi'        => 'Vala Header'           ,
            'vhw'         => 'VHDL'                  ,
            'vht'         => 'VHDL'                  ,
            'vhs'         => 'VHDL'                  ,
            'vho'         => 'VHDL'                  ,
            'vhi'         => 'VHDL'                  ,
            'vhf'         => 'VHDL'                  ,
            'vhd'         => 'VHDL'                  ,
            'VHD'         => 'VHDL'                  ,
            'vhdl'        => 'VHDL'                  ,
            'VHDL'        => 'VHDL'                  ,
            'bas'         => 'Visual Basic'          ,
            'BAS'         => 'Visual Basic'          ,
            'ctl'         => 'Visual Basic'          ,
            'dsr'         => 'Visual Basic'          ,
            'frm'         => 'Visual Basic'          ,
            'frx'         => 'Visual Basic'          ,
            'FRX'         => 'Visual Basic'          ,
            'vba'         => 'VB for Applications'   ,
            'VBA'         => 'VB for Applications'   ,
            'vbhtml'      => 'Visual Basic'          ,
            'VBHTML'      => 'Visual Basic'          ,
            'vbproj'      => 'Visual Basic .NET'     ,
            'vbp'         => 'Visual Basic'          , # .vbp - autogenerated
            'vbs'         => 'Visual Basic Script'   ,
            'VBS'         => 'Visual Basic Script'   ,
            'vb'          => 'Visual Basic .NET'     ,
            'VB'          => 'Visual Basic .NET'     ,
            'vbw'         => 'Visual Basic'          , # .vbw - autogenerated
            'vue'         => 'Vuejs Component'       ,
            'webinfo'     => 'ASP.NET'               ,
            'wsdl'        => 'Web Services Description',
            'x'           => 'Logos'                 ,
            'xm'          => 'Logos'                 ,
            'xpo'         => 'X++'                   , # Microsoft Dynamics AX 4.0 export format
            'xmi'         => 'XMI'                   ,
            'XMI'         => 'XMI'                   ,
            'zcml'        => 'XML'                   ,
            'xul'         => 'XML'                   ,
            'xspec'       => 'XML'                   ,
            'xproj'       => 'XML'                   ,
            'xml.dist'    => 'XML'                   ,
            'xliff'       => 'XML'                   ,
            'xlf'         => 'XML'                   ,
            'xib'         => 'XML'                   ,
            'xacro'       => 'XML'                   ,
            'x3d'         => 'XML'                   ,
            'wsf'         => 'XML'                   ,
            'web.release.config'=> 'XML'             ,
            'web.debug.config'=> 'XML'               ,
            'web.config'  => 'XML'                   ,
            'wxml'        => 'WXML'                  ,
            'wxss'        => 'WXSS'                  ,
            'vxml'        => 'XML'                   ,
            'vstemplate'  => 'XML'                   ,
            'vssettings'  => 'XML'                   ,
            'vsixmanifest'=> 'XML'                   ,
            'vcxproj'     => 'XML'                   ,
            'ux'          => 'XML'                   ,
            'urdf'        => 'XML'                   ,
            'tmtheme'     => 'XML'                   ,
            'tmsnippet'   => 'XML'                   ,
            'tmpreferences'=> 'XML'                  ,
            'tmlanguage'  => 'XML'                   ,
            'tml'         => 'XML'                   ,
            'tmcommand'   => 'XML'                   ,
            'targets'     => 'XML'                   ,
            'sublime-snippet'=> 'XML'                   ,
            'sttheme'     => 'XML'                   ,
            'storyboard'  => 'XML'                   ,
            'srdf'        => 'XML'                   ,
            'shproj'      => 'XML'                   ,
            'sfproj'      => 'XML'                   ,
            'settings.stylecop'=> 'XML'                   ,
            'scxml'       => 'XML'                   ,
            'rss'         => 'XML'                   ,
            'resx'        => 'XML'                   ,
            'rdf'         => 'XML'                   ,
            'pt'          => 'XML'                   ,
            'psc1'        => 'XML'                   ,
            'ps1xml'      => 'XML'                   ,
            'props'       => 'XML'                   ,
            'proj'        => 'XML'                   ,
            'plist'       => 'XML'                   ,
            'pkgproj'     => 'XML'                   ,
            'packages.config'=> 'XML'                   ,
            'osm'         => 'XML'                   ,
            'odd'         => 'XML'                   ,
            'nuspec'      => 'XML'                   ,
            'nuget.config'=> 'XML'                   ,
            'nproj'       => 'XML'                   ,
            'ndproj'      => 'XML'                   ,
            'natvis'      => 'XML'                   ,
            'mjml'        => 'XML'                   ,
            'mdpolicy'    => 'XML'                   ,
            'launch'      => 'XML'                   ,
            'kml'         => 'XML'                   ,
            'jsproj'      => 'XML'                   ,
            'jelly'       => 'XML'                   ,
            'ivy'         => 'XML'                   ,
            'iml'         => 'XML'                   ,
            'grxml'       => 'XML'                   ,
            'gmx'         => 'XML'                   ,
            'fsproj'      => 'XML'                   ,
            'filters'     => 'XML'                   ,
            'dotsettings' => 'XML'                   ,
            'dll.config'  => 'XML'                   ,
            'ditaval'     => 'XML'                   ,
            'ditamap'     => 'XML'                   ,
            'depproj'     => 'XML'                   ,
            'ct'          => 'XML'                   ,
            'csl'         => 'XML'                   ,
            'csdef'       => 'XML'                   ,
            'cscfg'       => 'XML'                   ,
            'cproject'    => 'XML'                   ,
            'clixml'      => 'XML'                   ,
            'ccxml'       => 'XML'                   ,
            'ccproj'      => 'XML'                   ,
            'builds'      => 'XML'                   ,
            'axml'        => 'XML'                   ,
            'app.config'  => 'XML'                   ,
            'ant'         => 'XML'                   ,
            'admx'        => 'XML'                   ,
            'adml'        => 'XML'                   ,
            'project'     => 'XML'                   ,
            'classpath'   => 'XML'                   ,
            'xml'         => 'XML'                   ,
            'XML'         => 'XML'                   ,
            'mxml'        => 'MXML'                  ,
            'xml.builder' => 'builder'               ,
            'build'       => 'NAnt script'           ,
            'vim'         => 'vim script'            ,
            'swift'       => 'Swift'                 ,
            'xaml'        => 'XAML'                  ,
            'wast'        => 'WebAssembly'           ,
            'wat'         => 'WebAssembly'           ,
            'wgsl'        => 'WGSL'                  ,
            'wxs'         => 'WiX source'            ,
            'wxi'         => 'WiX include'           ,
            'wxl'         => 'WiX string localization' ,
            'prw'         => 'xBase'                 ,
            'prg'         => 'xBase'                 ,
            'ch'          => 'xBase Header'          ,
            'xqy'         => 'XQuery'                ,
            'xqm'         => 'XQuery'                ,
            'xql'         => 'XQuery'                ,
            'xq'          => 'XQuery'                ,
            'xquery'      => 'XQuery'                ,
            'xsd'         => 'XSD'                   ,
            'XSD'         => 'XSD'                   ,
            'xslt'        => 'XSLT'                  ,
            'XSLT'        => 'XSLT'                  ,
            'xsl'         => 'XSLT'                  ,
            'XSL'         => 'XSLT'                  ,
            'xtend'       => 'Xtend'                 ,
            'yacc'        => 'yacc'                  ,
            'y'           => 'yacc'                  ,
            'yml.mysql'   => 'YAML'                  ,
            'yaml-tmlanguage'=> 'YAML'                  ,
            'syntax'      => 'YAML'                  ,
            'sublime-syntax'=> 'YAML'                  ,
            'rviz'        => 'YAML'                  ,
            'reek'        => 'YAML'                  ,
            'mir'         => 'YAML'                  ,
            'glide.lock'  => 'YAML'                  ,
            'gemrc'       => 'YAML'                  ,
            'clang-tidy'  => 'YAML'                  ,
            'clang-format'=> 'YAML'                  ,
            'yaml'        => 'YAML'                  ,
            'yml'         => 'YAML'                  ,
            'zig'         => 'Zig'                   ,
            'zsh'         => 'zsh'                   ,
            );
# 1}}}
%{$rh_Language_by_Script}    = (             # {{{1
            'awk'      => 'awk'                   ,
            'bash'     => 'Bourne Again Shell'    ,
            'bc'       => 'bc'                    ,# calculator
            'crystal'  => 'Crystal'               ,
            'csh'      => 'C Shell'               ,
            'dmd'      => 'D'                     ,
            'dtrace'   => 'dtrace'                ,
            'escript'  => 'Erlang'                ,
            'groovy'   => 'Groovy'                ,
            'idl'      => 'IDL'                   ,
            'kermit'   => 'Kermit'                ,
            'ksh'      => 'Korn Shell'            ,
            'lua'      => 'Lua'                   ,
            'make'     => 'make'                  ,
            'octave'   => 'Octave'                ,
            'perl5'    => 'Perl'                  ,
            'perl'     => 'Perl'                  ,
            'miniperl' => 'Perl'                  ,
            'php'      => 'PHP'                   ,
            'php5'     => 'PHP'                   ,
            'python'   => 'Python'                ,
            'python2.6'=> 'Python'                ,
            'python2.7'=> 'Python'                ,
            'python3'  => 'Python'                ,
            'python3.3'=> 'Python'                ,
            'python3.4'=> 'Python'                ,
            'python3.5'=> 'Python'                ,
            'python3.6'=> 'Python'                ,
            'python3.7'=> 'Python'                ,
            'python3.8'=> 'Python'                ,
            'perl6'    => 'Raku'                  ,
            'raku'     => 'Raku'                  ,
            'rakudo'   => 'Raku'                  ,
            'rexx'     => 'Rexx'                  ,
            'regina'   => 'Rexx'                  ,
            'ruby'     => 'Ruby'                  ,
            'sed'      => 'sed'                   ,
            'sh'       => 'Bourne Shell'          ,
            'swipl'    => 'Prolog'                ,
            'tcl'      => 'Tcl/Tk'                ,
            'tclsh'    => 'Tcl/Tk'                ,
            'tcsh'     => 'C Shell'               ,
            'wish'     => 'Tcl/Tk'                ,
            'zsh'      => 'zsh'                   ,
            );
# 1}}}
%{$rh_Language_by_File}      = (             # {{{1
            'build.xml'         => 'Ant/XML'            ,
            'BUILD'             => 'Bazel'              ,
            'WORKSPACE'         => 'Bazel'              ,
            'cmakelists.txt'    => 'CMake'              ,
            'CMakeLists.txt'    => 'CMake'              ,
            'Jamfile'           => 'Jam'                ,
            'jamfile'           => 'Jam'                ,
            'Jamrules'          => 'Jam'                ,
            'Makefile'          => 'make'               ,
            'makefile'          => 'make'               ,
            'meson.build'       => 'Meson'              ,
            'Gnumakefile'       => 'make'               ,
            'gnumakefile'       => 'make'               ,
            'pom.xml'           => 'Maven/XML'          ,
            'Rakefile'          => 'Ruby'               ,
            'rakefile'          => 'Ruby'               ,
            'Dockerfile'        => 'Dockerfile'         ,
            'Dockerfile.m4'     => 'Dockerfile'         ,
            'Dockerfile.cmake'  => 'Dockerfile'         ,
            'dockerfile'        => 'Dockerfile'         ,
            'dockerfile.m4'     => 'Dockerfile'         ,
            'dockerfile.cmake'  => 'Dockerfile'         ,
            'Containerfile'     => 'Containerfile'      ,
            );
# 1}}}
%{$rh_Language_by_Prefix}     = (             # {{{1
            'Dockerfile'        => 'Dockerfile'         ,
            'Containerfile'     => 'Containerfile'         ,
            );
# 1}}}
%{$rhaa_Filters_by_Language} = (            # {{{1
    '(unknown)'          => [ ],
    'ABAP'               => [   [ 'remove_matches'      , '^\*'    ], ],
    'ActionScript'       => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Apex Class'         => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'ASP'                => [   [ 'remove_matches'      , '^\s*\47'], ],  # \47 = '
    'ASP.NET'            => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_between_general', '<%--', '--%>' ],
                                [ 'remove_between_general', '<!--', '-->' ],
                            ],
    'Ada'                => [   [ 'remove_matches'      , '^\s*--' ], ],
    'ADSO/IDSM'          => [   [ 'remove_matches'      , '^\s*\*[\+\!]' ], ],
    'Agda'               => [   [ 'remove_haskell_comments', '>filename<' ], ],
    'AMPLE'              => [   [ 'remove_matches'      , '^\s*//' ], ],
    'APL'                => [
                                [ 'remove_matches'      , '^\s*⍝' ],
                            ],
    'Ant/XML'            => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'ANTLR Grammar'      => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Ant'                => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Apex Trigger'       => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Arduino Sketch'     => [ # Arduino IDE inserts problematic 0xA0 characters; strip them
                                [ 'replace_regex' , '\xa0', " " ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'AsciiDoc'           => [
                                [ 'remove_between_general', '////', '////' ],
                                [ 'remove_matches'      , '^\s*\/\/'  ],
                            ],
    'AspectJ'            => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Assembly'           => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_matches'      , '^\s*\@' ],
                                [ 'remove_matches'      , '^\s*\|' ],
                                [ 'remove_matches'      , '^\s*!'  ],
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_inline'       , ';.*$'   ],
                                [ 'remove_inline'       , '\@.*$'  ],
                                [ 'remove_inline'       , '\|.*$'  ],
                                [ 'remove_inline'       , '!.*$'   ],
                                [ 'remove_inline'       , '#.*$'   ],
                                [ 'remove_inline'       , '--.*$'  ],
                                [ 'remove_matches'      , '^\*'    ],  # z/OS Assembly
                            ],
    'Asymptote'          => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'AutoHotkey'         => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_inline'       , ';.*$'   ],
                            ],
    'awk'                => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Bazel'              => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'bc'                 => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Blade'              => [
                                [ 'remove_between_general', '{{--', '--}}' ],
                                [ 'remove_html_comments',                  ],
                            ],
    'Bourne Again Shell' => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Bourne Shell'       => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Brainfuck'          => [ # puerile name for a language
#                               [ 'call_regexp_common'  , 'Brainfuck' ],  # inaccurate
                                [ 'remove_bf_comments',               ],
                            ],
    'BrightScript'       => [
                                [ 'remove_matches'      , '^\s*rem', ],
                                [ 'remove_matches'      , '^\s*\'',  ],
                            ],
    'builder'            => [
                                [ 'remove_matches'      , '^\s*xml_markup.comment!'  ],
                            ],
    'C'                  => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Chapel'       => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'C++'                => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'C/C++ Header'       => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Carbon'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Clean'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Clojure'            => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_matches'      , '^\s*#_'  ],
                            ],
    'ClojureScript'      => [   [ 'remove_matches'      , '^\s*;'  ], ],
    'ClojureC'           => [   [ 'remove_matches'      , '^\s*;'  ], ],
    'CMake'              => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Crystal'            => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Constraint Grammar' => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'CUDA'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Cython'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'docstring_to_C'                 ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'C#/Smalltalk' => [ [ 'die' ,  ], ], # never called
    'C#'                 => [
#                               [ 'remove_matches'      , '^\s*//' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'C# Designer'        => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'C# Generated'        => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Cake Build Script'  => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'CCS'                => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C'      ],
                            ],
    'CSS'                => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C'      ],
                            ],
    'CSV'                => [  # comma separated value files have no comments;
                                [ 'remove_matches'      , '^\s*$'  ],
                            ], # included simply to allow diff's
    'COBOL'              => [   [ 'remove_cobol_comments',         ], ],
    'CoCoA 5'            => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_inline'       , '--.*$'  ],
                            ],
    'CoffeeScript'       => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'ColdFusion'         => [   [ 'remove_html_comments',          ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'HTML'   ], ],
    'ColdFusion CFScript'=> [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Containerfile'      => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Coq'                => [
                                [ 'remove_between_general', '(*', '*)' ],
                            ],
    'Crystal Reports'    => [   [ 'remove_matches'      , '^\s*//' ], ],
    'CSON'               => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Cucumber'           => [
                                [ 'remove_matches'      , '^\s*#'  ],
                            ],
    'D/dtrace'           => [ [ 'die' ,          ], ], # never called
    'D'                  => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'rm_comments_in_strings', '"', '/+', '+/' ],
                                [ 'remove_between_general', '/+', '+/' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'DAL'                => [
                                [ 'remove_between_general', '[', ']', ],
                            ],
    'Dart'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'DenizenScript'      => [ # same as YAML
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Derw'               => [
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_between_general', '{-', '-}' ],
                                [ 'remove_inline'       , '--.*$'  ],
                            ],
    'dhall'              => [   [ 'remove_haskell_comments', '>filename<' ], ],
    'Delphi Form'        => [ # same as Pascal
                                [ 'remove_between_regex', '\{[^$]', '}' ],
                                [ 'remove_between_general', '(*', '*)' ],
                                [ 'remove_matches'      , '^\s*//' ],
                            ],
    'DIET'               => [  # same as Pug
                                [ 'remove_pug_block'    ,          ],
                                [ 'remove_matches'      , '^\s*//' ],
                                [ 'remove_inline'       , '//.*$'  ],
                            ],
    # diff is kind of weird: anything but a space in the first column
    # will count as code, with the exception of #, ---, +++.  Spaces
    # in the first column denote context lines which aren't part of the
    # difference.
    'diff'               => [
                                [ 'remove_matches'      , '^#' ],
                                [ 'remove_matches'      , '^\-\-\-' ],
                                [ 'remove_matches'      , '^\+\+\+' ],
                                [ 'remove_matches'      , '^\s' ],
                            ],
    'DITA'               => [
                                [ 'remove_html_comments',          ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'DOORS Extension Language' => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Drools'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'dtrace'             => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'ECPP'               => [
                                [ 'remove_between_general',
                                  '<%doc>', '</%doc>',             ],
                                [ 'remove_between_general',
                                  '<#'    , '#>'     ,             ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'EEx'                => [
                                [ 'remove_between_general', '<%#', '%>' ],
                            ],
    'EJS'                => [
                                [ 'remove_between_general', '<%#', '%>' ],
                                [ 'remove_html_comments',          ],
                            ],
    'Elm'                => [   [ 'remove_haskell_comments', '>filename<' ], ],
    'Embedded Crystal'   => [
                                [ 'remove_between_general', '<%#', '%>' ],
                            ],
    'ERB'                => [
                                [ 'remove_between_general', '<%#', '%>' ],
                            ],
    'Gencat NLS'         => [   [ 'remove_matches'       , '^\$ .*$' ], ],
    'NASTRAN DMAP'       => [
                                [ 'remove_matches'      , '^\s*\$' ],
                                [ 'remove_inline'       , '\$.*$'  ],
                            ],
    'Dockerfile'         => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'DOS Batch'          => [
                                [ 'remove_matches'      , '^\s*rem' ],
                                [ 'remove_matches'      , '^\s*::'  ],
                            ],
    'DTD'                => [   [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ], ],
    'Elixir'             => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'elixir_doc_to_C'                ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Erlang'             => [
                                [ 'remove_matches'      , '^\s*%'  ],
                                [ 'remove_inline'       , '%.*$'   ],
                            ],
    'Expect'             => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Fennel'             => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_inline'       , ';.*$'   ],
                            ],
    'Finite State Language' => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Fish Shell'         => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Focus'              => [   [ 'remove_matches'      , '^\s*\-\*'  ], ],
    'Forth'              => [
                                [ 'remove_matches'      , '^\s*\\\\.*$'  ],
                                [ 'Forth_paren_to_C'                 ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'      ],
                                [ 'remove_inline'       , '\\\\.*$'  ],
                            ],
    'Fortran 77'         => [
                                [ 'remove_f77_comments' ,          ],
                                [ 'remove_inline'       , '\!.*$'  ],
                            ],
    'Fortran 77/Forth'   => [ [ 'die' ,          ], ], # never called
    'F#/Forth'           => [ [ 'die' ,          ], ], # never called
    'Fortran 90'         => [
                                [ 'remove_f77_comments' ,          ],
                                [ 'remove_f90_comments' ,          ],
                                [ 'remove_inline'       , '\!.*$'  ],
                            ],
    'Fortran 95'         => [
                                [ 'remove_f77_comments' ,          ],
                                [ 'remove_f90_comments' ,          ],
                                [ 'remove_inline'       , '\!.*$'  ],
                            ],
    'Freemarker Template' => [
                                [ 'remove_between_general', '<#--', '-->' ],
                            ],
    'Futhark'            => [
                                [ 'remove_matches'      , '^\s*--'  ],
                            ],
    'FXML'               => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'F#'                 => [
                                [ 'remove_between_general', '(*', '*)' ],
                                [ 'remove_matches'      , '^\s*//' ],
                            ],
    'F# Script'          => [
                                [ 'call_regexp_common'  , 'Pascal' ],
                                [ 'remove_matches'      , '^\s*//' ],
                            ],
    'Flatbuffers'        => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_inline'       , '//.*$'  ],
                            ],
    'Godot Scene'        => [
                                [ 'remove_matches'      , '^\s*;'  ],
                            ],
    'Godot Resource'     => [
                                [ 'remove_matches'      , '^\s*;'  ],
                            ],
    'Godot Shaders'      => [
                                [ 'remove_matches'      , '^\s*//' ],
                                [ 'remove_inline'       , '//.*$'  ],
                            ],
    'GDScript'           => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Glade'              => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Gleam'              => [
                                [ 'remove_matches'      , '^\s*//' ],
                                [ 'remove_inline'       , '//.*$'  ],
                            ],
    'GLSL'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Go'                 => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_inline'       , '//.*$'  ],
                            ],
    'Gradle'             => [ # same as Groovy
                                [ 'remove_inline'       , '//.*$'  ],
                                # separate /* inside quoted strings with two
                                # concatenated strings split between / and *
                                [ 'replace_between_regex', '(["\'])(.*?/)(\*.*?)\g1',
                                  '(.*?)' , '"$1$2$1 + $1$3$1$4"', 0],
                                [ 'rm_comments_in_strings', '"""', '/*', '*/', 1],
                                [ 'rm_comments_in_strings', '"""', '//', '', 1],
                                [ 'rm_comments_in_strings', "'''", '/*', '*/', 1],
                                [ 'rm_comments_in_strings', "'''", '//', '', 1],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Grails'             => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                                [ 'remove_jsp_comments' ,          ],
                                [ 'add_newlines'        ,          ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'GraphQL'            => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'docstring_to_C'                 ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Groovy'             => [
                                [ 'remove_inline'       , '//.*$'  ],
                                # separate /* inside quoted strings with two
                                # concatenated strings split between / and *
                                [ 'replace_between_regex', '(["\'])(.*?/)(\*.*?)\g1',
                                  '(.*?)' , '"$1$2$1 + $1$3$1$4"', 0],
                                [ 'rm_comments_in_strings', '"""', '/*', '*/', 1],
                                [ 'rm_comments_in_strings', '"""', '//', '', 1],
                                [ 'rm_comments_in_strings', "'''", '/*', '*/', 1],
                                [ 'rm_comments_in_strings', "'''", '//', '', 1],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Haml'               => [
                                [ 'remove_haml_block'   ,          ],
                                [ 'remove_html_comments',          ],
                                [ 'remove_matches'      , '^\s*/\s*\S+' ],
                                [ 'remove_matches'      , '^\s*-#\s*\S+' ],
                            ],
    'Handlebars'         => [
                                [ 'remove_between_general', '{{!--', '--}}' ],
                                [ 'remove_between_general', '{{!', '}}' ],
                                [ 'remove_html_comments',          ],
                            ],
    'Harbour'            => [
                                [ 'remove_matches'      , '^\s*\&\&' ],
                                [ 'remove_matches'      , '^\s*\*' ],
                                [ 'remove_matches'      , '^\s*NOTE' ],
                                [ 'remove_matches'      , '^\s*note' ],
                                [ 'remove_matches'      , '^\s*Note' ],
                                [ 'remove_inline'       , '//.*$'  ],
                                [ 'remove_inline'       , '\&\&.*$' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Hare'               => [
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'remove_matches'      , '//.*$' ],
                            ],
    'Haxe'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'HCL'                => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'HLSL'               => [
                                [ 'remove_inline'       , '//.*$'  ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'HTML'               => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'HTML EEx'           => [
                                [ 'remove_matches'       , '^\s*<% #' ],
                                [ 'remove_between_general', '<%!--', '--%>' ],
                            ],
    'HolyC'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Hoon'               => [
                                [ 'remove_matches'      , '^\s*:[:><]' ],
                                [ 'remove_inline'       , ':[:><].*$'  ],
                            ],
    'INI'                => [
                                [ 'remove_matches'      , '^\s*;'  ],
                            ],
    'XHTML'               => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Haskell'            => [   [ 'remove_haskell_comments', '>filename<' ], ],
    'IDL'                => [   [ 'remove_matches'      , '^\s*;'  ], ],
    'IDL/Qt Project/Prolog/ProGuard' => [ [ 'die' ,          ], ], # never called
    'Idris'              => [
                                [ 'remove_haskell_comments', '>filename<' ],
                                [ 'remove_matches'      , '^\s*\|{3}' ],
                            ],
    'Igor Pro'           => [
                                [ 'remove_matches'      , '^\s*//' ],
                                [ 'remove_inline'       , '//.*$'  ],
                            ],
    'Literate Idris'     => [
                                [ 'remove_matches'      , '^[^>]'  ],
                            ],
    'Imba'               => [
                                [ 'remove_matches'      , '^\s*#\s'],
                                [ 'remove_inline'       , '#\s.*$' ],
                                [ 'remove_between_regex', '###', '###' ],
                            ],
    'InstallShield'      => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'IPL'                => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Jai'                => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Jam'                => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'JSP'                => [   [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                                [ 'remove_jsp_comments' ,          ],
                                [ 'remove_matches'      , '^\s*//' ],
                                [ 'add_newlines'        ,          ],
                                [ 'call_regexp_common'  , 'C'      ],
                            ],
    'JavaServer Faces'   => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Java'               => [
                                [ 'replace_regex', '\\\\$', ' '],
                                # Java seems to have more path globs in strings
                                # than other languages.  The variations makes
                                # it tricky to craft a universal fix.
                                [ 'replace_between_regex', '(["\'])(.*?/\*)\g1',
                                  '(.*?)' , '"xx"'],
                                [ 'replace_between_regex', '(["\'])(.*?\*/)\g1',
                                  '(.*?)' , '"xx"'],
                               ## separate /* inside quoted strings with two
                               ## concatenated strings split between / and *
                               ##    -> defeated by "xx/**/*_xx" issue 365
                               #[ 'replace_between_regex', '(["\'])(.*?/)(\*.*?)\g1',
                               #  '(.*?)' , '"$1$2$1 + $1$3$1$4"'],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'JavaScript'         => [
                                [ 'rm_comments_in_strings', "'", '/*', '*/' ],
                                [ 'rm_comments_in_strings', "'", '//', '' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Jinja Template'     => [
                                [ 'remove_between_general', '{#', '#}' ],
                            ],
    'JSX'                => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'JCL'                => [   [ 'remove_jcl_comments' ,          ], ],
    'JSON'               => [   # ECMA-404, the JSON standard definition
                                # makes no provision for JSON comments
                                # so just use a placeholder filter
                                [ 'remove_matches'      , '^\s*$'  ],
                            ],
    'JSON5'              => [   # same as JavaScript
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Julia'              => [
                                [ 'remove_between_general', '#=', '=#' ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'docstring_to_C'                 ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Juniper Junos'      => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'kvlang'             => [
                                ["remove_matches", '^\s*#[^:]'],
                            ],
    'Kotlin'             => [
                                [ 'rm_comments_in_strings', '"""', '/*', '*/', 1],
                                [ 'rm_comments_in_strings', '"""', '//', '', 1],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Lean'               => [
                                [ 'remove_between_general', '/-', '-/' ],
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_inline'       , '--.*$'  ],
                            ],
    'Lem'                => [
                                [ 'remove_OCaml_comments',         ],
                            ],
    'LESS'               => [
#                               [ 'remove_matches'      , '^\s*//' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'LFE'                => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_between_general', '#|', '|#' ],
                            ],
    'Linker Script'      => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/'],
                                [ 'call_regexp_common',     'C'            ],
                            ],
    'liquid'             => [
                                [ 'remove_between_general', '{% comment %}',
                                                            '{% endcomment %}' ],
                                [ 'remove_html_comments',          ],
                            ],
    'Lisp'               => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_between_general', '#|', '|#' ],
                            ],
    'Lisp/OpenCL'        => [ [ 'die' ,          ], ], # never called
    'Lisp/Julia'         => [ [ 'die' ,          ], ], # never called
    'LiveLink OScript'   => [   [ 'remove_matches'      , '^\s*//' ], ],
    'LLVM IR'            => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_inline'       , ';.*$'   ],
                            ],
    'Logos'              => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Logtalk'            => [  # same filters as Prolog
                                [ 'remove_matches'      , '^\s*\%' ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '(//|\%).*$' ],
                            ],
#   'Lua'                => [   [ 'call_regexp_common'  , 'lua'    ], ],
    'Lua'                => [
                                [ 'remove_between_general', '--[=====[', ']=====]' ],
                                [ 'remove_between_general', '--[====[', ']====]' ],
                                [ 'remove_between_general', '--[===[', ']===]' ],
                                [ 'remove_between_general', '--[==[', ']==]' ],
                                [ 'remove_between_general', '--[=[', ']=]' ],
                                [ 'remove_between_general', '--[[', ']]' ],
                                [ 'remove_matches'      , '^\s*\-\-' ],
                            ],
    'make'               => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Meson'              => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'MATLAB'             => [
                                [ 'remove_between_general', '%{', '%}' ],
                                [ 'remove_matches'      , '^\s*%'  ],
                                [ 'remove_inline'       , '%.*$'   ],
                            ],
    'Mathematica'        => [
                                [ 'remove_between_general', '(*', '*)' ],
                            ],
    'Maven/XML'          => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Maven'              => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Mercury'            => [
                                [ 'remove_inline'       , '%.*$'   ],
                                [ 'remove_matches'      , '^\s*%'  ],
                            ],
    'Metal'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Modula3'            => [   [ 'call_regexp_common'  , 'Pascal' ], ],
        # Modula 3 comments are (* ... *) so applying the Pascal filter
        # which also treats { ... } as a comment is not really correct.
    'Mojo'               => [   [ 'call_regexp_common' , 'C++' ], ],
    'Nemerle'            => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Nunjucks'           => [
                                [ 'remove_between_general', '{#', '#}' ],
                            ],
    'Objective-C'        => [
#                               [ 'remove_matches'      , '^\s*//' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Objective-C++'      => [
#                               [ 'remove_matches'      , '^\s*//' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'OCaml'              => [
                                [ 'rm_comments_in_strings', '"', '(*', '*)', 1 ],
                                [ 'remove_OCaml_comments',         ],
                            ],
    'OpenCL'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'PHP/Pascal'               => [ [ 'die' ,          ], ], # never called
    'Mako'               => [
                                [ 'remove_matches'       , '##.*$'  ],
                            ],
    'Markdown'           => [
                                [ 'remove_between_general', '<!--', '-->' ],
                                [ 'remove_between_regex',
                                  '\[(comment|\/\/)?\]\s*:?\s*(<\s*>|#)?\s*\(.*?', '.*?\)' ],
                                # http://stackoverflow.com/questions/4823468/comments-in-markdown
                            ],
    'MATLAB/Mathematica/Objective-C/MUMPS/Mercury' => [ [ 'die' ,          ], ], # never called
    'MUMPS'              => [   [ 'remove_matches'      , '^\s*;'  ], ],
    'Mustache'           => [
                                [ 'remove_between_general', '{{!', '}}' ],
                            ],
    'Nim'                => [
                                [ 'remove_between_general', '#[', ']#' ],
                                [ 'remove_matches'      , '^\s*#'  ],
#                               [ 'docstring_to_C'                 ],
#                               [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'NetLogo'            => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_inline'       , ';.*$'   ],
                            ],
    'Nix'                => [
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Octave'             => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Odin'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'OpenSCAD'           => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Oracle Forms'       => [   [ 'call_regexp_common'  , 'C'      ], ],
    'Oracle Reports'     => [   [ 'call_regexp_common'  , 'C'      ], ],
    'Oracle PL/SQL'      => [
                                [ 'call_regexp_common'  , 'PL/SQL'      ],
                            ],
    'Pascal'             => [
                                [ 'remove_between_regex', '\{[^$]', '}' ],
                                [ 'remove_between_general', '(*', '*)' ],
                                [ 'remove_matches'      , '^\s*//' ],
                            ],
####'Pascal'             => [
####                            [ 'call_regexp_common'  , 'Pascal' ],
####                            [ 'remove_matches'      , '^\s*//' ],
####                        ],
    'Pascal/Puppet'            => [ [ 'die' ,          ], ], # never called
    'Puppet'             => [
                                [ 'remove_matches'      , '^\s*#'   ],
                                [ 'call_regexp_common'  , 'C'       ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'P4'                 => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Patran Command Language'=> [
                                [ 'remove_matches'      , '^\s*#'   ],
                                [ 'remove_matches'      , '^\s*\$#' ],
                                [ 'call_regexp_common'  , 'C'       ],
                            ],
    'Perl'               => [   [ 'remove_below'        , '^__(END|DATA)__'],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_below_above'  , '^=head1', '^=cut'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'PEG'                => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'peg.js'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'peggy'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Pest'               => [
                                [ 'remove_matches'      , '^\s*//'  ],
                                [ 'remove_inline'       , '//.*$'   ],
                            ],
    'tspeg'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Perl/Prolog'        => [ [ 'die' ,          ], ], # never called
    'PL/I'               => [
                                [ 'call_regexp_common'  , 'C'      ],
                            ],
    'PL/M'               => [
                                [ 'call_regexp_common'  , 'C'      ],
                            ],
    'PlantUML'           => [
                                [ 'remove_between_general', "/'", "'/" ],
                                [ 'remove_matches'      , "^\\s*'" ],
                            ],
    'Pig Latin'          => [
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_inline'       , '--.*$'  ],
                                [ 'call_regexp_common'  , 'C'       ],
                            ],
    'ProGuard'           => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'PO File'            => [
                                [ 'remove_matches'      , '^\s*#[^,]' ],  # '#,' is not a comment
                            ],
    'Pony'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'docstring_to_C'                 ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'PowerBuilder'       => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'PowerShell'         => [
                                [ 'powershell_to_C'                ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Prolog'             => [
                                [ 'remove_matches'      , '^\s*\%' ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '(//|\%).*$' ],
                            ],
    'Properties'         => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_matches'      , '^\s*!'  ],
                            ],
    'Protocol Buffers'   => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Pug'                => [
                                [ 'remove_pug_block'    ,          ],
                                [ 'remove_matches'      , '^\s*//' ],
                                [ 'remove_inline'       , '//.*$'  ],
                            ],
    'PureScript'         => [
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_between_general', '{-', '-}' ],
                                [ 'remove_inline'       , '--.*$'  ],
                            ],
    'Python'             => [
                                [ 'remove_matches'      , '/\*'    ],
                                [ 'remove_matches'      , '\*/'    ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'docstring_to_C'                 ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Jupyter Notebook'   => [   # these are JSON files; have no comments
                                # would have to parse JSON for
                                #      "cell_type": "code"
                                # to count code lines
                                [ 'jupyter_nb'                     ],
                                [ 'remove_matches'      , '^\s*$'  ],
                            ],
    'PHP'                => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'QML'                => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_inline'       , '//.*$'  ],
                            ],
    'Qt'                 => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Qt Linguist'        => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Qt Project'         => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'R'                  => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Ring'               => [
                                [ 'remove_inline'       , '#.*$'   ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Rmd'                => [
                                [ 'reduce_to_rmd_code_blocks'      ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Racket'             => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_inline'       , ';.*$'   ],
                            ],
    'Raku'               => [   [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_below_above'  , '^=head1', '^=cut'  ],
                                [ 'remove_below_above'  , '^=begin', '^=end'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Raku/Prolog'        => [ [ 'die' ,          ], ], # never called
    'RAML'               => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'RapydScript'        => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'docstring_to_C'                 ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Razor'              => [
                                [ 'remove_between_general', '@*', '*@' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_between_general', '<!--', '-->' ],
                            ],
    'reStructuredText'   => [
                                [ 'remove_between_regex', '^\.\.', '^[^ \n\t\r\f\.]' ]
                            ],
    'Rexx'               => [   [ 'call_regexp_common'  , 'C'      ], ],
    'ReasonML'           => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'remove_between_general', '/*', '*/' ],
                            ],
    'ReScript'           => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'RobotFramework'     => [
                                [ 'remove_matches'      , '^\s*#'   ],
                                [ 'remove_matches'      , '^\s*Comment' ],
                                [ 'remove_matches'      , '^\s*\*{3}\s+(Variables|Test\s+Cases|Settings|Keywords)\s+\*{3}' ] ,
                                [ 'remove_matches'      , '^\s*\[(Documentation|Tags)\]' ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Ruby'               => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_below_above'  , '^=begin', '^=end' ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Ruby HTML'          => [   [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ], ],
    'Circom'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Cairo'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Rust'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'SaltStack'          => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'SAS'                => [
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_between_general', '*', ';' ],
                            ],
    'Sass'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Scala'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Scheme/SaltStack' => [ [ 'die' ,          ], ], # never called
    'Scheme'             => [
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_inline'       , ';.*$'   ],
                            ],
    'SCSS'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'sed'                => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Slice'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Slim'               => [
                                [ 'remove_slim_block'   ,          ],
                            ],
    'SKILL'              => [
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_matches'      , '^\s*;'  ],
                            ],
    'SKILL++'            => [
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_matches'      , '^\s*;'  ],
                            ],
    'Squirrel'           => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Starlark'           => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'docstring_to_C'                 ],
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'BizTalk Pipeline' =>   [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'BizTalk Orchestration' => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Solidity'           => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'SparForte'          => [
                                [ 'remove_matches'      , '^\s*#!' ],
                                [ 'remove_matches'      , '^\s*--' ],
                            ],
    'Specman e'          => [
                                [ 'pre_post_fix'        , "'>", "<'"],
                                [ 'remove_between_general', "^'>", "^<'" ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++',   ],
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'rm_last_line'        , ],  # undo pre_post_fix addition
                                                              # of trailing line of just <'
                            ],
    'SQL'                => [
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_inline'       , '--.*$'  ],
                            ],
    'SQL Stored Procedure'=> [
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_inline'       , '--.*$'  ],
                            ],
    'SQL Data'           => [
                                [ 'call_regexp_common'  , 'C'      ],
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'remove_inline'       , '--.*$'  ],
                            ],
    'Smalltalk'          => [
                                [ 'call_regexp_common'  , 'Smalltalk'      ],
                            ],
    'Smarty'             => [
                                [ 'smarty_to_C'                    ],
                                [ 'call_regexp_common'  , 'C'      ],
                            ],
    'Standard ML'        => [
                                [ 'remove_between_general', '(*', '*)' ],
                            ],
    'Stata'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Stylus'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'SugarSS'            => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Svelte'             => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'SVG'                => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Swift'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'SWIG'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],

    'm4'                 => [   [ 'remove_matches'      , '^dnl\s'  ], ],
    'C Shell'            => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Kermit'             => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_matches'      , '^\s*;'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Korn Shell'         => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'TableGen'           => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Tcl/Tk'             => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'TEAL'               => [
                                [ 'remove_matches'      , '^\s*//' ],
                            ],
    'Teamcenter met'     => [   [ 'call_regexp_common'  , 'C'      ], ],
    'Teamcenter mth'     => [   [ 'remove_matches'      , '^\s*#'  ], ],
    'TeX'                => [
                                [ 'remove_matches'      , '^\s*%'  ],
                                [ 'remove_inline'       , '%.*$'   ],
                            ],
    'Text'               => [
                                [ 'remove_matches'      , '^\s*$'  ],
                            ],
    'Thrift'             => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Titanium Style Sheet'  => [
                                [ 'remove_matches'      , '^\s*//' ],
                                [ 'remove_inline'       , '//.*$'  ],
                                [ 'remove_between_regex', '/[^/]', '[^/]/' ],
                            ],
    'TNSDL'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'call_regexp_common'  , 'C++'      ],
                            ],
    'TOML'               => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'TTCN'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'      ],
                            ],
    'TITAN Project File Information'               => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Twig'               => [
                                [ 'remove_between_general', '{#', '#}' ],
                            ],
    'TypeScript'         => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Typst'              => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Umka'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Unity-Prefab'       => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'Visual Fox Pro'     =>  [
                                [ 'remove_matches'      , '^\s*\*' ],
                                [ 'remove_inline'       , '\*.*$'  ],
                                [ 'remove_matches'      , '^\s*&&' ],
                                [ 'remove_inline'       , '&&.*$'  ],
                            ],
    'Softbridge Basic'   => [   [ 'remove_above'        , '^\s*Attribute\s+VB_Name\s+=' ],
                                [ 'remove_matches'      , '^\s*Attribute\s+'],
                                [ 'remove_matches'      , '^\s*\47'], ],  # \47 = '
    # http://www.altium.com/files/learningguides/TR0114%20VHDL%20Language%20Reference.pdf
    'Vala'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Vala Header'        => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Verilog-SystemVerilog/Coq' => [ ['die'] ], # never called
    'Verilog-SystemVerilog' => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'VHDL'               => [
                                [ 'remove_matches'      , '^\s*--' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_inline'       , '--.*$'  ],
                            ],
    'vim script'         => [
                                [ 'remove_matches'      , '^\s*"'  ],
                                [ 'remove_inline'       , '".*$'   ],
                            ],
    'Visual Basic Script' => [
                                [ 'remove_above'        , '^\s*Attribute\s+VB_Name\s+=' ],
                                [ 'remove_matches'      , '^\s*Attribute\s+'],
                                [ 'remove_matches'      , '^\s*\47'],     # \47 = '
                            ],
    'Visual Basic .NET' => [
                                [ 'remove_above'        , '^\s*Attribute\s+VB_Name\s+=' ],
                                [ 'remove_matches'      , '^\s*Attribute\s+'],
                                [ 'remove_matches'      , '^\s*\47'],     # \47 = '
                            ],
    'VB for Applications' => [
                                [ 'remove_above'        , '^\s*Attribute\s+VB_Name\s+=' ],
                                [ 'remove_matches'      , '^\s*Attribute\s+'],
                                [ 'remove_matches'      , '^\s*\47'],     # \47 = '
                            ],
    'Visual Basic'       => [
                                [ 'remove_above'        , '^\s*Attribute\s+VB_Name\s+=' ],
                                [ 'remove_matches'      , '^\s*Attribute\s+'],
                                [ 'remove_matches'      , '^\s*\47'],     # \47 = '
                            ],
    'Visualforce Component' => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Visualforce Page'   => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Velocity Template Language' => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                                [ 'remove_jsp_comments' ,          ],
                                [ 'remove_matches'      , '^\s*##' ],
                                [ 'remove_between_general', '#**', '*#' ],
                                [ 'add_newlines'        ,          ],
                            ],
    'Vuejs Component'     => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Teamcenter def'     => [   [ 'remove_matches'      , '^\s*#'  ], ],
    'Windows Module Definition' => [
                                [ 'remove_matches'      , '^\s*;' ],
                                [ 'remove_inline'       , ';.*$'  ],
                            ],
    'yacc'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'YAML'               => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    'lex'                => [   [ 'call_regexp_common'  , 'C'      ], ],
    'XAML'               => [   [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ], ],
    'xBase Header'       => [
#                               [ 'remove_matches'      , '^\s*//' ],
                                [ 'remove_matches'      , '^\s*\&\&' ],
                                [ 'remove_matches'      , '^\s*\*' ],
                                [ 'remove_matches'      , '^\s*NOTE' ],
                                [ 'remove_matches'      , '^\s*note' ],
                                [ 'remove_matches'      , '^\s*Note' ],
                                [ 'remove_inline'       , '\&\&.*$' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'xBase'              => [
#                               [ 'remove_matches'      , '^\s*//' ],
                                [ 'remove_matches'      , '^\s*\&\&' ],
                                [ 'remove_matches'      , '^\s*\*' ],
                                [ 'remove_matches'      , '^\s*NOTE' ],
                                [ 'remove_matches'      , '^\s*note' ],
                                [ 'remove_matches'      , '^\s*Note' ],
                                [ 'remove_inline'       , '\&\&.*$' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'MXML'               => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                                [ 'remove_matches'      , '^\s*//' ],
                                [ 'add_newlines'        ,          ],
                                [ 'call_regexp_common'  , 'C'      ],
                            ],
    'Web Services Description' => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'WebAssembly'           => [
                                [ 'remove_matches'      , '^\s*;;' ],
                            ],
    'WGSL'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Windows Message File'  => [
                                [ 'remove_matches'      , '^\s*;\s*//' ],
                                [ 'call_regexp_common'  , 'C'          ],
                                [ 'remove_matches'      , '^\s*;\s*$'  ],
#                               next line only hypothetical
#                               [ 'remove_matches_2re'  , '^\s*;\s*/\*',
#                                                         '^\s*;\s*\*/', ],
                            ],
    'Windows Resource File' => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'WiX source'         => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'WiX include'        => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'WiX string localization' => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'WXML'               => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'WXSS'               => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C'      ],
                            ],
    'X++'                => [
                                [ 'remove_matches', '\s*#\s*//' ],
                                [ 'remove_between_regex', '#\s*/\*', '\*/' ],
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'XMI'                => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'XML'                => [
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'XQuery'             => [
                                [ 'remove_between_general', '(:', ':)' ],
                            ],
    'XSD'                => [   [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ], ],
    'XSLT'               => [   [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ], ],
    'Xtend'              => [   # copy of Java, plus triple << inline
                                # separate /* inside quoted strings with two
                                # concatenated strings split between / and *
                                [ 'replace_between_regex', '(["\'])(.*?/)(\*.*?)\g1',
                                  '(.*?)' , '"$1$2$1 + $1$3$1$4"', 0],
                                [ 'call_regexp_common'  , 'C++'    ],
                                [ 'remove_matches'      , '^\s*\x{c2ab}{3}'  ], # doesn't work
                                # \xCA2B is unicode << character
                            ],
    'NAnt script'       => [    [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ], ],
    'MSBuild script'    => [    [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ], ],
    'Visual Studio Module' => [
                                [ 'rm_comments_in_strings', '"', '/*', '*/' ],
                                [ 'rm_comments_in_strings', '"', '//', '' ],
                                [ 'call_regexp_common'  , 'C++'    ],
                            ],
    'Visual Studio Solution' => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_html_comments',          ],
                                [ 'call_regexp_common'  , 'HTML'   ],
                            ],
    'Zig'                => [
                                [ 'remove_matches'      , '^\s*//'  ],
                                [ 'remove_inline'       , '//.*$'   ],
                            ],
    'zsh'                => [
                                [ 'remove_matches'      , '^\s*#'  ],
                                [ 'remove_inline'       , '#.*$'   ],
                            ],
    );
# 1}}}
%{$rh_EOL_continuation_re} = (               # {{{1
    'ActionScript'       =>     '\\\\$'         ,
    'AspectJ'            =>     '\\\\$'         ,
    'Assembly'           =>     '\\\\$'         ,
    'ASP'                =>     '\\\\$'         ,
    'ASP.NET'            =>     '\\\\$'         ,
    'Ada'                =>     '\\\\$'         ,
    'awk'                =>     '\\\\$'         ,
    'bc'                 =>     '\\\\$'         ,
    'C'                  =>     '\\\\$'         ,
    'C++'                =>     '\\\\$'         ,
    'C/C++ Header'       =>     '\\\\$'         ,
    'CMake'              =>     '\\\\$'         ,
    'Cython'             =>     '\\\\$'         ,
    'C#'                 =>     '\\\\$'         ,
    'C# Designer'        =>     '\\\\$'         ,
    'Cake Build Script'  =>     '\\\\$'         ,
    'D'                  =>     '\\\\$'         ,
    'Dart'               =>     '\\\\$'         ,
    'Expect'             =>     '\\\\$'         ,
    'Futhark'            =>     '\\\\$'         ,
    'Gencat NLS'         =>     '\\\\$'         ,
    'Go'                 =>     '\\\\$'         ,
    'IDL'                =>     '\$\\$'         ,
    'Igor Pro'           =>     '\\$'           ,
#   'Java'               =>     '\\\\$'         ,
    'JavaScript'         =>     '\\\\$'         ,
    'JSON5'              =>     '\\\\$'         ,
    'JSX'                =>     '\\\\$'         ,
    'LESS'               =>     '\\\\$'         ,
    'Lua'                =>     '\\\\$'         ,
    'make'               =>     '\\\\$'         ,
    'MATLAB'             =>     '\.\.\.\s*$'    ,
    'Meson'              =>     '\\\\$'         ,
    'Metal'              =>     '\\\\$'         ,
    'MXML'               =>     '\\\\$'         ,
    'Objective-C'        =>     '\\\\$'         ,
    'Objective-C++'      =>     '\\\\$'         ,
    'OCaml'              =>     '\\\\$'         ,
    'Octave'             =>     '\.\.\.\s*$'    ,
    'Qt Project'         =>     '\\\\$'         ,
    'Patran Command Language'=> '\\\\$'         ,
    'PowerBuilder'       =>     '\\\\$'         ,
    'PowerShell'         =>     '\\\\$'         ,
    'Python'             =>     '\\\\$'         ,
    'R'                  =>     '\\\\$'         ,
    'Rmd'                =>     '\\\\$'         ,
    'Ruby'               =>     '\\\\$'         ,
    'sed'                =>     '\\\\$'         ,
    'Swift'              =>     '\\\\$'         ,
    'Bourne Again Shell' =>     '\\\\$'         ,
    'Bourne Shell'       =>     '\\\\$'         ,
    'C Shell'            =>     '\\\\$'         ,
    'kvlang'             =>     '\\\\$'         ,
    'Kermit'             =>     '\\\\$'         ,
    'Korn Shell'         =>     '\\\\$'         ,
    'Starlark'           =>     '\\\\$'         ,
    'Solidity'           =>     '\\\\$'         ,
    'Stata'              =>     '///$'          ,
    'Stylus'             =>     '\\\\$'         ,
    'Tcl/Tk'             =>     '\\\\$'         ,
    'TTCN'               =>     '\\\\$'         ,
    'TypeScript'         =>     '\\\\$'         ,
    'lex'                =>     '\\\\$'         ,
    'Vala'               =>     '\\\\$'         ,
    'Vala Header'        =>     '\\\\$'         ,
    'X++'                =>     '\\\\$'         ,
    'zsh'                =>     '\\\\$'         ,
    );
# 1}}}
%{$rh_Not_Code_Extension}    = (             # {{{1
   '1'         => 1,  # Man pages (documentation):
   '2'         => 1,
   '3'         => 1,
   '4'         => 1,
   '5'         => 1,
   '6'         => 1,
   '7'         => 1,
   '8'         => 1,
   '9'         => 1,
   'a'         => 1,  # Static object code.
   'ad'        => 1,  # X application default resource file.
   'afm'       => 1,  # font metrics
   'arc'       => 1,  # arc(1) archive
   'arj'       => 1,  # arj(1) archive
   'au'        => 1,  # Audio sound filearj(1) archive
   'bak'       => 1,  # Backup files - we only want to count the "real" files.
   'bdf'       => 1,
   'bmp'       => 1,
   'bz2'       => 1,  # bzip2(1) compressed file
   'csv'       => 1,
   'desktop'   => 1,
   'dic'       => 1,
   'doc'       => 1,
   'elc'       => 1,
   'eps'       => 1,
   'fig'       => 1,
   'gif'       => 1,
   'gz'        => 1,
   'h5'        => 1,  # hierarchical data format
   'hdf'       => 1,  # hierarchical data format
   'in'        => 1,  # Debatable.
   'jpg'       => 1,
   'kdelnk'    => 1,
   'man'       => 1,
   'mf'        => 1,
   'mp3'       => 1,
   'n'         => 1,
   'o'         => 1,  # Object code is generated from source code.
   'o.cmd'     => 1,  # not DOS Batch; Linux kernel compilation optimization file
   'pbm'       => 1,
   'pdf'       => 1,
   'pfb'       => 1,
   'png'       => 1,
   'ppt'       => 1,
   'pptx'      => 1,
   'ps'        => 1,  # Postscript is _USUALLY_ generated automatically.
   'sgm'       => 1,
   'sgml'      => 1,
   'so'        => 1,  # Dynamically-loaded object code.
   'Tag'       => 1,
   'tfm'       => 1,
   'tgz'       => 1,  # gzipped tarball
   'tiff'      => 1,
   'tsv'       => 1,  # tab separated values
   'vf'        => 1,
   'wav'       => 1,
   'xbm'       => 1,
   'xls'       => 1,
   'xlsx'      => 1,
   'xpm'       => 1,
   'Y'         => 1,  # file compressed with "Yabba"
   'Z'         => 1,  # file compressed with "compress"
   'zip'       => 1,  # zip archive
   'gitignore' => 1,
); # 1}}}
%{$rh_Not_Code_Filename}     = (             # {{{1
   'AUTHORS'     => 1,
   'BUGS'        => 1,
   'BUGS'        => 1,
   'Changelog'   => 1,
   'ChangeLog'   => 1,
   'ChangeLog'   => 1,
   'Changes'     => 1,
   'CHANGES'     => 1,
   'COPYING'     => 1,
   'COPYING'     => 1,
   'DESCRIPTION' => 1, # R packages metafile
   '.cvsignore'  => 1,
   'Entries'     => 1,
   'FAQ'         => 1,
   'INSTALL'     => 1,
   'MAINTAINERS' => 1,
   'MD5SUMS'     => 1,
   'NAMESPACE'   => 1, # R packages metafile
   'NEWS'        => 1,
   'readme'      => 1,
   'Readme'      => 1,
   'README'      => 1,
   'README.tk'   => 1, # used in kdemultimedia, it's confusing.
   'Repository'  => 1,
   'Root'        => 1, # CVS
   'TODO'        => 1,
);
# 1}}}
%{$rh_Scale_Factor}          = (             # {{{1
    '(unknown)'                    =>   0.00,
    '1st generation default'       =>   0.25,
    '2nd generation default'       =>   0.75,
    '3rd generation default'       =>   1.00,
    '4th generation default'       =>   4.00,
    '5th generation default'       =>  16.00,
    'ABAP'                         =>   5.00,
    'ActionScript'                 =>   1.36,
    'Ada'                          =>   0.52,
    'ADSO/IDSM'                    =>   3.00,
    'Agda'                         =>   2.11,
    'ambush'                       =>   2.50,
    'aml'                          =>   1.63,
    'AMPLE'                        =>   2.00,
    'Ant/XML'                      =>   1.90,
    'Ant'                          =>   1.90,
    'ANTLR Grammar'                =>   2.00,
    'SQL'                          =>   6.15,
    'SQL Stored Procedure'         =>   6.15,
    'SQL Data'                     =>   1.00,
    'Apex Class'                   =>   1.50,
    'APL'                          =>   2.50,
    'aps'                          =>   0.96,
    'aps'                          =>   4.71,
    'apt'                          =>   1.13,
    'arc'                          =>   1.63,
    'AsciiDoc'                     =>   1.50,
    'AspectJ'                      =>   1.36,
    'asa'                          =>   1.29,
    'ASP'                          =>   1.29,
    'ASP.NET'                      =>   1.29,
    'aspx'                         =>   1.29,
    'asax'                         =>   1.29,
    'ascx'                         =>   1.29,
    'asmx'                         =>   1.29,
    'config'                       =>   1.29,
    'CCS'                          =>   5.33,
    'Apex Trigger'                 =>   1.4 ,
    'Arduino Sketch'               =>   1.00,
    'Assembly'                     =>   0.25,
    'Assembly (macro)'             =>   0.51,
    'associative default'          =>   1.25,
    'Asymptote'                    =>   2.50,
    'autocoder'                    =>   0.25,
    'AutoHotkey'                   =>   1.29,
    'awk'                          =>   3.81,
    'basic'                        =>   0.75,
    'Bazel'                        =>   1.00,
    'bc'                           =>   1.50,
    'Blade'                        =>   2.00,
    'bliss'                        =>   0.75,
    'bmsgen'                       =>   2.22,
    'bteq'                         =>   6.15,
    'Brainfuck'                    =>   0.10,
    'BrightScript'                 =>   2.00,
    'builder'                      =>   2.00,
    'C'                            =>   0.77,
    'c set 2'                      =>   0.88,
    'C#'                           =>   1.36,
    'C# Designer'                  =>   1.36,
    'C# Generated'                 =>   1.36,
    'Cake Build Script'            =>   1.36,
    'C++'                          =>   1.51,
    'Carbon'                       =>   1.51,
    'ColdFusion'                   =>   4.00,
    'ColdFusion CFScript'          =>   4.00,
    'Chapel'                       =>   2.96,
    'Clean'                        =>   2.50,
    'Clojure'                      =>   1.25,
    'ClojureScript'                =>   1.25,
    'ClojureC'                     =>   1.25,
    'CMake'                        =>   1.00,
    'COBOL'                        =>   1.04,
    'CoCoA 5'                      =>   1.04,
    'CoffeeScript'                 =>   2.00,
    'Constraint Grammar'           =>   4.00,
    'Containerfile'                =>   2.00,
    'Coq'                          =>   5.00,
    'Crystal'                      =>   2.50,
    'Crystal Reports'              =>   4.00,
    'csl'                          =>   1.63,
    'CSON'                         =>   2.50,
    'csp'                          =>   1.51,
    'cssl'                         =>   1.74,
    'CSS'                          =>   1.0,
    'CSV'                          =>   0.1,
    'Cucumber'                     =>   3.00,
    'CUDA'                         =>   1.00,
    'D'                            =>   1.70,
    'DAL'                          =>   1.50,
    'Dart'                         =>   2.00,
    'DenizenScript'                =>   1.00,
    'Delphi Form'                  =>   2.00,
    'DIET'                         =>   2.00,
    'diff'                         =>   1.00,
    'Derw'                         =>   3.00,
    'dhall'                        =>   2.11,
    'DITA'                         =>   1.90,
    'dtrace'                       =>   2.00,
    'NASTRAN DMAP'                 =>   2.35,
    'DOORS Extension Language'     =>   1.50,
    'Dockerfile'                   =>   2.00,
    'DOS Batch'                    =>   0.63,
    'Drools'                       =>   2.00,
    'ECPP'                         =>   1.90,
    'eda/sql'                      =>   6.67,
    'edscheme 3.4'                 =>   1.51,
    'EEx'                          =>   2.00,
    'EJS'                          =>   2.50,
    'Elixir'                       =>   2.11,
    'Elm'                          =>   2.50,
    'Embedded Crystal'             =>   2.00,
    'ERB'                          =>   2.00,
    'Erlang'                       =>   2.11,
    'Fennel'                       =>   2.50,
    'Finite State Language'        =>   2.00,
    'Focus'                        =>   1.90,
    'Forth'                        =>   1.25,
    'Fortran 66'                   =>   0.63,
    'Fortran 77'                   =>   0.75,
    'Fortran 90'                   =>   1.00,
    'Fortran 95'                   =>   1.13,
    'Fortran II'                   =>   0.63,
    'foundation'                   =>   2.76,
    'Freemarker Template'          =>   1.48,
    'Futhark'                      =>   3.00, # Guessed from value of ML
    'F#'                           =>   2.50,
    'F# Script'                    =>   2.50,
    'Flatbuffers'                  =>   2.50,
    'Glade'                        =>   2.00,
    'Gleam'                        =>   2.50,
    'GLSL'                         =>   2.00,
    'gml'                          =>   1.74,
    'gpss'                         =>   1.74,
    'guest'                        =>   2.86,
    'guru'                         =>   1.63,
    'GDScript'                     =>   2.50,
    'Godot Scene'                  =>   2.50,
    'Godot Resource'               =>   2.50,
    'Godot Shaders'                =>   2.50,
    'Go'                           =>   2.50,
    'Gradle'                       =>   4.00,
    'Grails'                       =>   1.48,
    'GraphQL'                      =>   4.00,
    'Groovy'                       =>   4.10,
    'gw basic'                     =>   0.82,
    'HCL'                          =>   2.50,
    'high c'                       =>   0.63,
    'hlevel'                       =>   1.38,
    'hp basic'                     =>   0.63,
    'Haml'                         =>   2.50,
    'Handlebars'                   =>   2.50,
    'Harbour'                      =>   2.00,
    'Hare'                         =>   2.50,
    'Haskell'                      =>   2.11,
    'Haxe'                         =>   2.00,
    'HolyC'                        =>   2.50,
    'Hoon'                         =>   2.00,
    'HTML'                         =>   1.90,
    'HTML EEx'                     =>   3.00,
    'XHTML'                        =>   1.90,
    'XMI'                          =>   1.90,
    'XML'                          =>   1.90,
    'FXML'                         =>   1.90,
    'MXML'                         =>   1.90,
    'XSLT'                         =>   1.90,
    'DTD'                          =>   1.90,
    'XSD'                          =>   1.90,
    'NAnt script'                  =>   1.90,
    'MSBuild script'               =>   1.90,
    'Visual Studio Module'         =>   1.00,
    'Visual Studio Solution'       =>   1.00,
    'HLSL'                         =>   2.00,
    'Idris'                        =>   2.00,
    'Literate Idris'               =>   2.00,
    'Igor Pro'                     =>   4.00,
    'Imba'                         =>   3.00,
    'INI'                          =>   1.00,
    'InstallShield'                =>   1.90,
    'IPL'                          =>   2.00,
    'Jai'                          =>   1.13,
    'Jam'                          =>   2.00,
    'Java'                         =>   1.36,
    'JavaScript'                   =>   1.48,
    'JavaServer Faces'             =>   1.5 ,
    'Jinja Template'               =>   1.5 ,
    'JSON'                         =>   2.50,
    'JSON5'                        =>   2.50,
    'JSP'                          =>   1.48,
    'JSX'                          =>   1.48,
    'Velocity Template Language'   =>   1.00,
    'JCL'                          =>   1.67,
    'Juniper Junos'                =>   2.00,
    'kvlang'                       =>   2.00,
    'Kermit'                       =>   2.00,
    'Korn Shell'                   =>   3.81,
    'Kotlin'                       =>   2.00,
    'Lean'                         =>   3.00,
    'LESS'                         =>   1.50,
    'Lem'                          =>   3.00,
    'LFE'                          =>   1.25,
    'Linker Script'                =>   1.00,
    'liquid'                       =>   3.00,
    'Lisp'                         =>   1.25,
    'LiveLink OScript'             =>   3.5 ,
    'LLVM IR'                      =>   0.90,
    'Logos'                        =>   2.00,
    'Logtalk'                      =>   2.00,
    'm4'                           =>   1.00,
    'make'                         =>   2.50,
    'Mako'                         =>   1.50,
    'Markdown'                     =>   1.00,
    'mathcad'                      =>  16.00,
    'Maven'                        =>   1.90,
    'Meson'                        =>   1.00,
    'Metal'                        =>   1.51,
    'MUMPS'                        =>   4.21,
    'Mustache'                     =>   1.75,
    'Nastran'                      =>   1.13,
    'Nemerle'                      =>   2.50,
    'NetLogo'                      =>   4.00,
    'Nim'                          =>   2.00,
    'Nix'                          =>   2.70,
    'Nunjucks'                     =>   1.5 ,
    'Objective-C'                  =>   2.96,
    'Objective-C++'                =>   2.96,
    'OCaml'                        =>   3.00,
    'Odin'                         =>   2.00,
    'OpenSCAD'                     =>   1.00,
    'Oracle Reports'               =>   2.76,
    'Oracle Forms'                 =>   2.67,
    'Oracle Developer/2000'        =>   3.48,
    'Other'                        =>   1.00,
    'P4'                           =>   1.5 ,
    'Pascal'                       =>   0.88,
    'Patran Command Language'      =>   2.50,
    'Perl'                         =>   4.00,
    'PEG'                          =>   3.00,
    'peg.js'                       =>   3.00,
    'peggy'                        =>   3.00,
    'Pest'                         =>   2.00,
    'tspeg'                        =>   3.00,
    'Pig Latin'                    =>   1.00,
    'PL/I'                         =>   1.38,
    'PL/M'                         =>   1.13,
    'PlantUML'                     =>   2.00,
    'Oracle PL/SQL'                =>   2.58,
    'PO File'                      =>   1.50,
    'Pony'                         =>   3.00,
    'PowerBuilder'                 =>   3.33,
    'PowerShell'                   =>   3.00,
    'problemoriented default'      =>   1.13,
    'ProGuard'                     =>   2.50,
    'Prolog'                       =>   1.25,
    'Properties'                   =>   1.36,
    'Protocol Buffers'             =>   2.00,
    'Pug'                          =>   2.00,
    'Puppet'                       =>   2.00,
    'PureScript'                   =>   2.00,
    'QML'                          =>   1.25,
    'Qt'                           =>   2.00,
    'Qt Linguist'                  =>   1.00,
    'Qt Project'                   =>   1.00,
    'R'                            =>   3.00,
    'Rmd'                          =>   3.00,
    'Racket'                       =>   1.50,
    'Raku'                         =>   4.00,
    'rally'                        =>   2.00,
    'ramis ii'                     =>   2.00,
    'RAML'                         =>   0.90,
    'ReasonML'                     =>   2.50,
    'ReScript'                     =>   2.50,
    'reStructuredText'             =>   1.50,
    'Razor'                        =>   2.00,
    'Rexx'                         =>   1.19,
    'Ring'                         =>   4.20,
    'RobotFramework'               =>   2.50,
    'Circom'                       =>   1.00,
    'Cairo'                        =>   1.00,
    'Rust'                         =>   1.00,
    'sas'                          =>   1.95,
    'Scala'                        =>   4.10,
    'Scheme'                       =>   1.51,
    'Slim'                         =>   3.00,
    'Solidity'                     =>   1.48,
    'Bourne Shell'                 =>   3.81,
    'Bourne Again Shell'           =>   3.81,
    'ksh'                          =>   3.81,
    'zsh'                          =>   3.81,
    'Fish Shell'                   =>   3.81,
    'C Shell'                      =>   3.81,
    'SaltStack'                    =>   2.00,
    'SAS'                          =>   1.5 ,
    'Sass'                         =>   1.5 ,
    'SCSS'                         =>   1.5 ,
    'SKILL'                        =>   2.00,
    'SKILL++'                      =>   2.00,
    'slogan'                       =>   0.98,
    'Slice'                        =>   1.50,
    'Smalltalk'                    =>   4.00,
    'Smarty'                       =>   3.50,
    'Softbridge Basic'             =>   2.76,
    'SparForte'                    =>   3.80,
    'sps'                          =>   0.25,
    'spss'                         =>   2.50,
    'Specman e'                    =>   2.00,
    'SQL'                          =>   2.29,
    'Squirrel'                     =>   2.50,
    'Standard ML'                  =>   3.00,
    'Stata'                        =>   3.00,
    'Stylus'                       =>   1.48,
    'SugarSS'                      =>   2.50,
    'Svelte'                       =>   2.00,
    'SVG'                          =>   1.00,
    'Swift'                        =>   2.50,
    'SWIG'                         =>   2.50,
    'TableGen'                     =>   2.00,
    'Tcl/Tk'                       =>   4.00,
    'TEAL'                         =>   0.50,
    'Teamcenter def'               =>   1.00,
    'Teamcenter met'               =>   1.00,
    'Teamcenter mth'               =>   1.00,
    'TeX'                          =>   1.50,
    'Text'                         =>   0.50,
    'Thrift'                       =>   2.50,
    'Titanium Style Sheet'         =>   2.00,
    'TOML'                         =>   2.76,
    'Twig'                         =>   2.00,
    'TNSDL'                        =>   2.00,
    'TTCN'                         =>   2.00,
    'TITAN Project File Information' =>   1.90,
    'TypeScript'                   =>   2.00,
    'Typst'                        =>   3.00,
    'Umka'                         =>   2.00,
    'Unity-Prefab'                 =>   2.50,
    'Vala'                         =>   1.50,
    'Vala Header'                  =>   1.40,
    'Verilog-SystemVerilog'        =>   1.51,
    'VHDL'                         =>   4.21,
    'vim script'                   =>   3.00,
    'Visual Basic'                 =>   2.76,
    'VB for Applications'          =>   2.76,
    'Visual Basic .NET'            =>   2.76,
    'Visual Basic Script'          =>   2.76,
    'Visual Fox Pro'               =>   4.00, # Visual Fox Pro is not available in the language gearing ratios listed at Mayes Consulting web site
    'Visualforce Component'        =>   1.9 ,
    'Visualforce Page'             =>   1.9 ,
    'Vuejs Component'              =>   2.00,
    'Web Services Description'     =>   1.00,
    'WebAssembly'                  =>   0.45,
    'WGSL'                         =>   2.50,
    'Windows Message File'         =>   1.00,
    'Windows Resource File'        =>   1.00,
    'Windows Module Definition'    =>   1.00,
    'WiX source'                   =>   1.90,
    'WiX include'                  =>   1.90,
    'WiX string localization'      =>   1.90,
    'WXML'                         =>   1.90,
    'WXSS'                         =>   1.00,
    'xBase'                        =>   2.00,
    'xBase Header'                 =>   2.00,
    'xlisp'                        =>   1.25,
    'X++'                          =>   1.51, # This is a guess. Copied from C++, because the overhead for C++ headers might be equivalent to the overhead of structuring elements in XPO files
    'XAML'                         =>   1.90,
    'XQuery'                       =>   2.50,
    'yacc'                         =>   1.51,
    'yacc++'                       =>   1.51,
    'YAML'                         =>   0.90,
    'Expect'                       => 2.00,
    'Gencat NLS'                   => 1.50,
    'C/C++ Header'                 => 1.00,
    'inc'                          => 1.00,
    'lex'                          => 1.00,
    'Julia'                        => 4.00,
    'MATLAB'                       => 4.00,
    'Mathematica'                  => 5.00,
    'Mercury'                      => 3.00,
    'Maven/XML'                    => 2.5,
    'IDL'                          => 3.80,
    'Octave'                       => 4.00,
    'ML'                           => 3.00,
    'Modula3'                      => 2.00,
    'Mojo'                         => 2.00,
    'PHP'                          => 3.50,
    'Jupyter Notebook'             => 4.20,
    'Python'                       => 4.20,
    'RapydScript'                  => 4.20,
    'Starlark'                     => 4.20,
    'BizTalk Pipeline'             => 1.00,
    'BizTalk Orchestration'        => 1.00,
    'Cython'                       => 3.80,
    'Ruby'                         => 4.20,
    'Ruby HTML'                    => 4.00,
    'sed'                          => 4.00,
    'Lua'                          => 4.00,
    'OpenCL'                       => 1.50,
    'Xtend'                        => 2.00,
    'Zig'                          => 2.50,
    # aggregates; value is meaningless
    'C#/Smalltalk'                    => 1.00,
    'D/dtrace'                        => 1.00,
    'F#/Forth'                        => 1.00,
    'Fortran 77/Forth'                => 1.00,
    'Lisp/Julia'                      => 1.00,
    'Lisp/OpenCL'                     => 1.00,
    'PHP/Pascal'                      => 1.00,
    'Pascal/Puppet'                   => 1.00,
    'Perl/Prolog'                     => 1.00,
    'Raku/Prolog'                     => 1.00,
    'Verilog-SystemVerilog/Coq'    => 1.00,
    'MATLAB/Mathematica/Objective-C/MUMPS/Mercury' => 1.00,
    'IDL/Qt Project/Prolog/ProGuard'     => 1.00,
);
# 1}}}
%{$rh_Known_Binary_Archives} = (             # {{{1
            '.tar'     => 1 ,
            '.tar.Z'   => 1 ,
            '.tar.gz'  => 1 ,
            '.tar.bz2' => 1 ,
            '.zip'     => 1 ,
            '.Zip'     => 1 ,
            '.ZIP'     => 1 ,
            '.ear'     => 1 ,  # Java
            '.war'     => 1 ,  # contained within .ear
            '.xz'      => 1 ,
            '.whl'     => 1 ,  # Python wheel files (zip)
            );
# 1}}}
} # end sub set_constants()
sub check_scale_existence {                  # {{{1
    # do a few sanity checks
    my ($rhaa_Filters_by_Language,
        $rh_Language_by_Extension,
        $rh_Scale_Factor) = @_;

    my $OK = 1;
    foreach my $language (sort keys %{$rhaa_Filters_by_Language}) {
        next if defined $Extension_Collision{$language};
        if (!defined $rh_Scale_Factor->{$language}) {
            $OK = 0;
            warn "Missing scale factor for $language\n";
        }
    }

    my %seen_it = ();
    foreach my $ext (sort keys %{$rh_Language_by_Extension}) {
        my $language = $rh_Language_by_Extension->{$ext};
        next if defined $Extension_Collision{$language};
        next if $seen_it{$language};
        if (!$rhaa_Filters_by_Language->{$language}) {
            $OK = 0;
            warn "Missing language filter for $language\n";
        }
        $seen_it{$language} = 1;
    }
    die unless $OK;
} # 1}}}
sub pre_post_fix {                           # {{{1
    # Return the input lines prefixed and postfixed
    # by the given strings.
    my ($ra_lines, $prefix, $postfix ) = @_;
    print "-> pre_post_fix with $prefix, $postfix\n" if $opt_v > 2;

    my $all_lines = $prefix . join(""  , @{$ra_lines}) . $postfix;

    print "<- pre_post_fix\n" if $opt_v > 2;
    return split("\n", $all_lines);
} # 1}}}
sub rm_last_line {                           # {{{1
    # Return all but the last line.
    my ($ra_lines, ) = @_;
    print "-> rm_last_line\n" if $opt_v > 2;
    print "<- rm_last_line\n" if $opt_v > 2;
    my $n = scalar(@{$ra_lines}) - 2;
    return @{$ra_lines}[0..$n];
} # 1}}}
sub call_regexp_common {                     # {{{1
    my ($ra_lines, $language ) = @_;
    print "-> call_regexp_common for $language\n" if $opt_v > 2;

    Install_Regexp_Common() unless $HAVE_Rexexp_Common;

    my $all_lines = undef;
    if ($language eq "C++") { # Regexp::Common's C++ comment regex is multi-line
#       $all_lines = join("\n", @{$ra_lines});
        $all_lines = "";
        foreach (@{$ra_lines}) {
            if (m/\\$/) {  # line ends with a continuation marker
                $all_lines .= $_;
            } else {
                $all_lines .= "$_\n";
            }
        }
    } else {
        $all_lines = join(""  , @{$ra_lines});
    }

    no strict 'vars';
    # otherwise get:
    #  Global symbol "%RE" requires explicit package name at cloc line xx.
    if ($all_lines =~ $RE{comment}{$language}) {
        # Suppress "Use of uninitialized value in regexp compilation" that
        # pops up when $1 is undefined--happens if there's a bug in the $RE
        # This Pascal comment will trigger it:
        #         (* This is { another } test. **)
        # Curiously, testing for "defined $1" breaks the substitution.
        no warnings;
        # Remove comments.
        $all_lines =~ s/$1//g;
    }
    # a bogus use of %RE to avoid:
    # Name "main::RE" used only once: possible typo at cloc line xx.
    print scalar keys %RE if $opt_v < -20;
    print "<- call_regexp_common\n" if $opt_v > 2;
    return split("\n", $all_lines);
} # 1}}}
sub plural_form {                            # {{{1
    # For getting the right plural form on some English nouns.
    my $n = shift @_;
    if ($n == 1) { return ( 1, "" ); }
    else         { return ($n, "s"); }
} # 1}}}
sub matlab_or_objective_C {                  # {{{1
    # Decide if code is MATLAB, Mathematica, Objective-C, MUMPS, or Mercury
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
        $rs_language , # out
       ) = @_;
    print "-> matlab_or_objective_C\n" if $opt_v > 2;
    # matlab markers:
    #   first line starts with "function"
    #   some lines start with "%"
    #   high marks for lines that start with [
    #
    # Objective-C markers:
    #   must have at least two brace characters, { }
    #   has /* ... */ style comments
    #   some lines start with @
    #   some lines start with #include
    #
    # MUMPS:
    #   has ; comment markers
    #   do not match:  \w+\s*=\s*\w
    #   lines begin with   \s*\.?\w+\s+\w
    #   high marks for lines that start with \s*K\s+ or \s*Kill\s+
    #
    # Mercury:
    #   any line that begins with :- immediately triggers this
    #
    # Mathematica:
    #   (* .. *)
    #   BeginPackage

    ${$rs_language} = "";
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return;
    }

    my $DEBUG              = 0;

    my $matlab_points      = 0;
    my $mathematica_points = 0;
    my $objective_C_points = 0;
    my $mumps_points       = 0;
    my $mercury_points     = 0;
    my $has_braces         = 0;
    while (<$IN>) {
        ++$has_braces if $_ =~ m/[{}]/;
#print "LINE $. has_braces=$has_braces\n";
        ++$mumps_points if $. == 1 and m{^[A-Z]};
        if      (m{^\s*/\*} or m {^\s*//}) {   #   /* or //
            $objective_C_points += 5;
            $matlab_points      -= 5;
printf ".m:  /*|//  obj C=% 2d  matlab=% 2d  mathematica=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        } elsif (m{^:-\s+}) {      # gotta be mercury
            $mercury_points = 1000;
            last;
        } elsif (m{\w+\s*=\s*\[}) {      # matrix assignment, very matlab
            $matlab_points += 5;
        }
        if (m{\w+\[}) {      # function call by []
            $mathematica_points += 2;
printf ".m:  \\w=[   obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        } elsif (m{^\s*\w+\s*=\s*}) {    # definitely not MUMPS
            --$mumps_points;
printf ".m:  \\w=    obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        } elsif (m{^\s*\.?(\w)\s+(\w)} and $1 !~ /\d/ and $2 !~ /\d/) {
            ++$mumps_points;
printf ".m:  \\w \\w  obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        } elsif (m{^\s*;}) {
            ++$mumps_points;
printf ".m:  ;      obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        }
        if (m{^\s*#(include|import)}) {
            # Objective-C without a doubt
            $objective_C_points = 1000;
            $matlab_points      = 0;
printf ".m: #include obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
            $has_braces         = 2;
            last;
        } elsif (m{^\s*@(interface|implementation|protocol|public|protected|private|end)\s}o) {
            # Objective-C without a doubt
            $objective_C_points = 1000;
            $matlab_points      = 0;
printf ".m: keyword obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
            last;
        } elsif (m{^\s*BeginPackage}) {
            $mathematica_points += 2;
        } elsif (m{^\s*\[}) {             #   line starts with [  -- very matlab
            $matlab_points += 5;
printf ".m:  [      obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        } elsif (m{^\sK(ill)?\s+}) {
            $mumps_points  += 5;
printf ".m:  Kill   obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        } elsif (m{^\s*function}) {
            --$objective_C_points;
            ++$matlab_points;
printf ".m:  funct  obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        } elsif (m{^\s*%}) {              #   %
            # matlab commented line
            --$objective_C_points;
            ++$matlab_points;
printf ".m:  pcent  obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;
        }
    }
    $IN->close;
printf "END LOOP    obj C=% 2d  matlab=% 2d  mumps=% 2d  mercury= % 2d\n", $objective_C_points, $matlab_points, $mathematica_points, $mumps_points, $mercury_points if $DEBUG;

    # next heuristic is unreliable for small files
#   $objective_C_points = -9.9e20 unless $has_braces >= 2;

    my %points = ( 'MATLAB'      => $matlab_points     ,
                   'Mathematica' => $mathematica_points     ,
                   'MUMPS'       => $mumps_points      ,
                   'Objective-C' => $objective_C_points,
                   'Mercury'     => $mercury_points    , );

    ${$rs_language} = (sort { $points{$b} <=> $points{$a} or $a cmp $b } keys %points)[0];

    print "<- matlab_or_objective_C($file: matlab=$matlab_points, mathematica=$mathematica_points, C=$objective_C_points, mumps=$mumps_points, mercury=$mercury_points) => ${$rs_language}\n"
        if $opt_v > 2;

} # 1}}}
sub Lisp_or_OpenCL {                         # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Lisp_or_OpenCL\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $lisp_points   = 0;
    my $opcl_points = 0;
    while (<$IN>) {
        ++$lisp_points if  /^\s*;/;
        ++$lisp_points if  /\((def|eval|require|export|let|loop|dec|format)/;
        ++$opcl_points if  /^\s*(int|float|const|{)/;
    }
    $IN->close;
    # print "lisp_points=$lisp_points   opcl_points=$opcl_points\n";
    if ($lisp_points > $opcl_points) {
        $lang = "Lisp";
    } else {
        $lang = "OpenCL";
    }

    print "<- Lisp_or_OpenCL\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Lisp_or_Julia {                          # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Lisp_or_Julia\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $lisp_points   = 0;
    my $julia_points = 0;
    while (<$IN>) {
        ++$lisp_points if  /^\s*;/;
        ++$lisp_points if  /\((def|eval|require|export|let|loop|dec|format)/;
        ++$julia_points if  /^\s*(function|end|println|for|while)/;
    }
    $IN->close;
    # print "lisp_points=$lisp_points   julia_points=$julia_points\n";
    if ($lisp_points > $julia_points) {
        $lang = "Lisp";
    } else {
        $lang = "Julia";
    }

    print "<- Lisp_or_Julia\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Perl_or_Prolog {                         # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Perl_or_Prolog\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $perl_points = 0;
    my $prolog_points = 0;
    while (<$IN>) {
        next if /^\s*$/;
        if ($. == 1 and /^#!.*?\bperl/) {
            $perl_points = 100;
            last;
        }
        ++$perl_points   if  /^=(head|over|item|cut)/;
        ++$perl_points   if  /;\s*$/;
        ++$perl_points   if  /(\{|\})/;
        ++$perl_points   if  /^\s*sub\s+/;
        ++$perl_points   if  /\s*<<'/;  # start HERE block
        ++$perl_points   if  /\$(\w+\->|[_!])/;
        ++$prolog_points if !/\s*#/ and /\.\s*$/;
        ++$prolog_points if  /:-/;
    }
    $IN->close;
    # print "perl_points=$perl_points   prolog_points=$prolog_points\n";
    if ($perl_points > $prolog_points) {
        $lang = "Perl";
    } else {
        $lang = "Prolog";
    }

    printf "<- Perl_or_Prolog(%s, Perl=%d Prolog=%d)\n",
        $file, $perl_points, $prolog_points if $opt_v > 2;
    return $lang;
} # 1}}}
sub Raku_or_Prolog {                         # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Raku_or_Prolog\n" if $opt_v > 2;
    my $lang = Perl_or_Prolog($file, $rh_Err, $raa_errors);
    $lang = "Raku" if $lang eq "Perl";

    print "<- Raku_or_Prolog\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub IDL_or_QtProject {                       # {{{1
    # IDL, QtProject, Prolog, or ProGuard
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> IDL_or_QtProject($file)\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $idl_points      = 0;
    my $qtproj_points   = 0;
    my $prolog_points   = 0;
    my $proguard_points = 0;
    while (<$IN>) {
        ++$idl_points      if /^\s*;/;
        ++$idl_points      if /plot\(/i;
        ++$qtproj_points   if /^\s*(qt|configs|sources|template|target|targetpath|subdirs)\b/i;
        ++$qtproj_points   if /qthavemodule/i;
        ++$prolog_points   if /\.\s*$/;
        ++$prolog_points   if /:-/;
        ++$proguard_points if /^\s*#/;
        ++$proguard_points if /^-keep/;
        ++$proguard_points if /^-(dont)?obfuscate/;
    }
    $IN->close;
    # print "idl_points=$idl_points   qtproj_points=$qtproj_points\n";

    my %points = ( 'IDL'        => $idl_points       ,
                   'Qt Project' => $qtproj_points    ,
                   'Prolog'     => $prolog_points    ,
                   'ProGuard'   => $proguard_points  ,
                 );

    $lang = (sort { $points{$b} <=> $points{$a} or $a cmp $b} keys %points)[0];

    print "<- IDL_or_QtProject(idl_points=$idl_points, ",
          "qtproj_points=$qtproj_points, prolog_points=$prolog_points, ",
          "proguard_points=$proguard_points)\n"
           if $opt_v > 2;
    return $lang;
} # 1}}}
sub Ant_or_XML {                             # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Ant_or_XML($file)\n" if $opt_v > 2;

    my $lang = "XML";
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $Ant_points   = 0;
    my $XML_points   = 1;
    while (<$IN>) {
        if (/^\s*<project\s+/) {
            ++$Ant_points  ;
            --$XML_points  ;
        }
        if (/xmlns:artifact="antlib:org.apache.maven.artifact.ant"/) {
            ++$Ant_points  ;
            --$XML_points  ;
        }
    }
    $IN->close;

    if ($XML_points >= $Ant_points) {
        # tie or better goes to XML
        $lang = "XML";
    } else {
        $lang = "Ant";
    }

    print "<- Ant_or_XML($lang)\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Maven_or_XML {                           # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Maven_or_XML($file)\n" if $opt_v > 2;

    my $lang = "XML";
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $Mvn_points   = 0;
    my $XML_points   = 1;
    while (<$IN>) {
        if (/^\s*<project\s+/) {
            ++$Mvn_points  ;
            --$XML_points  ;
        }
        if (m{xmlns="http://maven.apache.org/POM/}) {
            ++$Mvn_points  ;
            --$XML_points  ;
        }
    }
    $IN->close;

    if ($XML_points >= $Mvn_points) {
        # tie or better goes to XML
        $lang = "XML";
    } else {
        $lang = "Maven";
    }

    print "<- Maven_or_XML($lang)\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub pascal_or_puppet {                       # {{{1
    # Decide if code is Pascal or Puppet manifest
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
        $rs_language , # out
       ) = @_;

    print "-> pascal_or_puppet\n" if $opt_v > 2;

    ${$rs_language} = "";
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return;
    }

    my $DEBUG              = 0;
    my $pascal_points      = 0;
    my $puppet_points      = 0;

    while (<$IN>) {

        if ( /^\s*\#\s+/ ) {
                $puppet_points += .001;
                next;
        }

        ++$pascal_points if /\bprogram\s+[A-Za-z]/i;
        ++$pascal_points if /\bunit\s+[A-Za-z]/i;
        ++$pascal_points if /\bmodule\s+[A-Za-z]/i;
        ++$pascal_points if /\bprocedure\b/i;
        ++$pascal_points if /\bfunction\b/i;
        ++$pascal_points if /^\s*interface\s+/i;
        ++$pascal_points if /^\s*implementation\s+/i;
        ++$pascal_points if /^\s*uses\s+/i;
        ++$pascal_points if /(?<!\:\:)\bbegin\b(?!\:\:)/i;
        ++$pascal_points if /(?<!\:\:)\bend\b(?!\:\:)/i;
        ++$pascal_points if /\:\=/;
        ++$pascal_points if /\<\>/;
        ++$pascal_points if /^\s*\{\$(I|INCLUDE)\s+.*\}/i;
        ++$pascal_points if /writeln/;

        ++$puppet_points if /^\s*class\s+/ and not /class\s+operator\s+/;
        ++$puppet_points if /^\s*function\s+[a-z][a-z0-9]+::[a-z][a-z0-9]+\s*/;
        ++$puppet_points if /^\s*type\s+[A-Z]\w+::[A-Z]\w+\s+/;
        ++$puppet_points if /^\s*case\s+/;
        ++$puppet_points if /^\s*package\s+/;
        ++$puppet_points if /^\s*file\s+/;
        ++$puppet_points if /^\s*include\s\w+/;
        ++$puppet_points if /^\s*service\s+/;
        ++$puppet_points if /\s\$\w+\s*\=\s*\S/;
        ++$puppet_points if /\S\s*\=\>\s*\S/;

        # No need to process rest of file if language seems obvious.
        last
                if (abs ($pascal_points - $puppet_points ) > 20 );
    }
    $IN->close;

    print "<- pascal_or_puppet(pascal=$pascal_points, puppet=$puppet_points)\n"
        if $opt_v > 2;

    if ($pascal_points > $puppet_points) {
        ${$rs_language} = "Pascal";
    } else {
        ${$rs_language} = "Puppet";
    }

} # 1}}}
sub Forth_or_Fortran {                       # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Forth_or_Fortran\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $forth_points = 0;
    my $fortran_points = 0;
    while (<$IN>) {
        ++$forth_points if  /^:\s/;
        ++$fortran_points if  /^([c*][^a-z]|\s{6,}(subroutine|program|end|implicit)\s|\s*!)/i;
    }
    $IN->close;
    if ($forth_points > $fortran_points) {
        $lang = "Forth";
    } else {
        $lang = "Fortran 77";
    }

    print "<- Forth_or_Fortran\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Forth_or_Fsharp {                        # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Forth_or_Fsharp\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $forth_points = 0;
    my $fsharp_points = 0;
    while (<$IN>) {
        ++$forth_points if  /^:\s/;
        ++$fsharp_points if  /^\s*(#light|import|let|module|namespace|open|type)/;
    }
    $IN->close;
    if ($forth_points > $fsharp_points) {
        $lang = "Forth";
    } else {
        $lang = "F#";
    }

    print "<- Forth_or_Fsharp\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Verilog_or_Coq {                         # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Verilog_or_Coq\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $coq_points     = 0;
    my $verilog_points = 0;
    while (<$IN>) {
        ++$verilog_points if  /^\s*(module|begin|input|output|always)/;
        ++$coq_points if /\b(Inductive|Fixpoint|Definition|
                             Theorem|Lemma|Proof|Qed|forall|
                             Section|Check|Notation|Variable|
                             Goal|Fail|Require|Scheme|Module|Ltac|
                             Set|Unset|Parameter|Coercion|Axiom|
                             Locate|Type|Record|Existing|Class)\b/x;
    }
    $IN->close;
    if ($coq_points > $verilog_points) {
        $lang = "Coq";
    } else {
        $lang = "Verilog-SystemVerilog";
    }

    print "<- Verilog_or_Coq\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub TypeScript_or_QtLinguist {               # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> TypeScript_or_QtLinguist\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $tscript_points  = 0;
    my $linguist_points = 0;
    while (<$IN>) {
        ++$linguist_points if m{\b</?(message|source|translation)>};
        ++$tscript_points  if /^\s*(var|const|let|class|document)\b/;
        ++$tscript_points  if /[;}]\s*$/;
        ++$tscript_points  if m{^\s*//};
    }
    $IN->close;
    if ($tscript_points >= $linguist_points) {
        $lang = "TypeScript";
    } else {
        $lang = "Qt Linguist";
    }
    print "<- TypeScript_or_QtLinguist\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Qt_or_Glade {                            # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Qt_or_Glade\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $qt_points    =  1;
    my $glade_points = -1;
    while (<$IN>) {
        if (/generated\s+with\s+glade/i) {
            $glade_points =  1;
            $qt_points    = -1;
            last;
        }
    }
    $IN->close;
    if ($glade_points > $qt_points) {
        $lang = "Glade";
    } else {
        $lang = "Qt";
    }
    print "<- Qt_or_Glade\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Csharp_or_Smalltalk {                    # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Csharp_or_Smalltalk($file)\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $cs_points        = 0;
    my $smalltalk_points = 0;
    while (<$IN>) {
        s{//.*?$}{};        # strip inline C# comments for better clarity
        next if /^\s*$/;
        if (/[;}{]\s*$/) {
            ++$cs_points       ;
        } elsif (/^(using|namespace)\s/) {
            $cs_points += 20;
        } elsif (/^\s*(public|private|new)\s/) {
            $cs_points += 20;
        } elsif (/^\s*\[assembly:/) {
            ++$cs_points       ;
        }
        if (/(\!|\]\.)\s*$/) {
            ++$smalltalk_points;
            --$cs_points       ;
        }
    }
    $IN->close;
    if ($smalltalk_points > $cs_points) {
        $lang = "Smalltalk";
    } else {
        $lang = "C#";
    }
    print "<- Csharp_or_Smalltalk($file)=$lang\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Visual_Basic_or_TeX_or_Apex {            # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
        $rs_language , # out
       ) = @_;

    print "-> Visual_Basic_or_TeX_or_Apex($file)\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $VB_points        = 0;
    my $tex_points       = 0;
    my $apex_points      = 0;
    while (<$IN>) {
        next if /^\s*$/;
#print "$_";
        if (/\s*%/ or /\s*\\/) {
            ++$tex_points   ;
        } else {
            if (/^\s*(public|private)\s/i) {
                ++$VB_points    ;
                ++$apex_points  ;
#print "+VB1 +A1";
            } elsif (/^\s*(end|attribute|version)\s/i) {
                ++$VB_points    ;
#print "+VB2";
            }
            if (/[{}]/ or /;\s*$/) {
                ++$apex_points  ;
#print "+A2";
            }
#print "\n";
        }
    }
    $IN->close;

    my %points = ( 'Visual Basic'   => $VB_points   ,
                   'TeX'            => $tex_points  ,
                   'Apex Class'     => $apex_points ,);

    ${$rs_language} = (sort { $points{$b} <=> $points{$a} or $a cmp $b } keys %points)[0];

    print "<- Visual_Basic_or_TeX_or_Apex($file: VB=$VB_points, TeX=$tex_points, Apex=$apex_points\n" if $opt_v > 2;
    return $lang;
} # 1}}}
sub Scheme_or_SaltStack {                    # {{{1
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;

    print "-> Scheme_or_SaltStack($file)\n" if $opt_v > 2;

    my $lang = undef;
    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        push @{$raa_errors}, [$rh_Err->{'Unable to read'} , $file];
        return $lang;
    }
    my $Sch_points = 0;
    my $SS_points  = 0;
    while (<$IN>) {
        next if /^\s*$/;
        if (/{\%.*%}/) {
            $SS_points += 5;
        } elsif (/map\.jinja\b/) {
            $SS_points += 5;
        } elsif (/\((define|lambda|let|cond|do)\s/) {
            $Sch_points += 1;
        } else {
        }
    }
    $IN->close;

    print "<- Scheme_or_SaltStack($file: Scheme=$Sch_points, SaltStack=$SS_points\n" if $opt_v > 2;
    if ($Sch_points > $SS_points) {
        return "Scheme";
    } else {
        return "SaltStack";
    }
} # 1}}}
sub html_colored_text {                      # {{{1
    # http://www.pagetutor.com/pagetutor/makapage/pics/net216-2.gif
    my ($color, $text) = @_;
#?#die "html_colored_text($text)";
    if      ($color =~ /^red$/i)   {
        $color = "#ff0000";
    } elsif ($color =~ /^green$/i) {
        $color = "#00ff00";
    } elsif ($color =~ /^blue$/i)  {
        $color = "#0000ff";
    } elsif ($color =~ /^grey$/i)  {
        $color = "#cccccc";
    }
#   return "" unless $text;
    return '<font color="' . $color . '">' . html_metachars($text) . "</font>";
} # 1}}}
sub xml_metachars {                          # {{{1
    # http://en.wikipedia.org/wiki/Character_encodings_in_HTML#XML_character_references
    my ($string, ) = shift @_;

    my  @in_chars    = split(//, $string);
    my  @out_chars   = ();
    foreach my $c (@in_chars) {
        if      ($c eq '&') { push @out_chars, '&amp;'
        } elsif ($c eq '<') { push @out_chars, '&lt;'
        } elsif ($c eq '>') { push @out_chars, '&gt;'
        } elsif ($c eq '"') { push @out_chars, '&quot;'
        } elsif ($c eq "'") { push @out_chars, '&apos;'
        } else {
            push @out_chars, $c;
        }
    }
    return join "", @out_chars;
} # 1}}}
sub html_metachars {                         # {{{1
    # Replace HTML metacharacters with their printable forms.
    # Future:  use HTML-Encoder-0.00_04/lib/HTML/Encoder.pm
    # from Fabiano Reese Righetti's HTML::Encoder module if
    # this subroutine proves to be too simplistic.
    my ($string, ) = shift @_;

    my  @in_chars    = split(//, $string);
    my  @out_chars   = ();
    foreach my $c (@in_chars) {
        if      ($c eq '<') {
            push @out_chars, '&lt;'
        } elsif ($c eq '>') {
            push @out_chars, '&gt;'
        } elsif ($c eq '&') {
            push @out_chars, '&amp;'
        } else {
            push @out_chars, $c;
        }
    }
    return join "", @out_chars;
} # 1}}}
sub test_alg_diff {                          # {{{1
    my ($file_1 ,
        $file_2 )
       = @_;
    my $fh_1 = open_file('<', $file_1, 1);
    die "Unable to read $file_1:  $!\n" unless defined $fh_1;
    chomp(my @lines_1 = <$fh_1>);
    $fh_1->close;

    my $fh_2 = open_file('<', $file_2, 1);
    die "Unable to read $file_2:  $!\n" unless defined $fh_2;
    chomp(my @lines_2 = <$fh_2>);
    $fh_2->close;

    my $n_no_change = 0;
    my $n_modified  = 0;
    my $n_added     = 0;
    my $n_deleted   = 0;
    my @min_sdiff   = ();
my $NN = chr(27) . "[0m";  # normal
my $BB = chr(27) . "[1m";  # bold

    my @sdiffs = sdiff( \@lines_1, \@lines_2 );
    foreach my $entry (@sdiffs) {
        my ($out_1, $out_2) = ('', '');
        if ($entry->[0] eq 'u') {
            ++$n_no_change;
          # $out_1 = $entry->[1];
          # $out_2 = $entry->[2];
            next;
        }
#       push @min_sdiff, $entry;
        if      ($entry->[0] eq 'c') {
            ++$n_modified;
            ($out_1, $out_2) = diff_two_strings($entry->[1], $entry->[2]);
            $out_1 =~ s/\cA(\w)/${BB}$1${NN}/g;
            $out_2 =~ s/\cA(\w)/${BB}$1${NN}/g;
          # $out_1 =~ s/\cA//g;
          # $out_2 =~ s/\cA//g;
        } elsif ($entry->[0] eq '+') {
            ++$n_added;
            $out_1 = $entry->[1];
            $out_2 = $entry->[2];
        } elsif ($entry->[0] eq '-') {
            ++$n_deleted;
            $out_1 = $entry->[1];
            $out_2 = $entry->[2];
        } elsif ($entry->[0] eq 'u') {
        } else { die "unknown entry->[0]=[$entry->[0]]\n"; }
        printf "%-80s | %s\n", $out_1, $out_2;
    }

#   foreach my $entry (@min_sdiff) {
#       printf "DIFF:  %s  %s  %s\n", @{$entry};
#   }
} # 1}}}
sub write_comments_to_html {                 # {{{1
    my ($filename      , # in
        $rah_diff_L    , # in  see routine array_diff() for explanation
        $rah_diff_R    , # in  see routine array_diff() for explanation
        $rh_blank      , # in  location and counts of blank lines
       ) = @_;

    print "-> write_comments_to_html($filename)\n" if $opt_v > 2;
    my $file = $filename . ".html";

    my $approx_line_count = scalar @{$rah_diff_L};
       $approx_line_count = 1 unless $approx_line_count;
    my $n_digits = 1 + int(log($approx_line_count)/2.30258509299405); # log_10

    my $html_out = html_header($filename);

    my $comment_line_number = 0;
    for (my $i = 0; $i < scalar @{$rah_diff_R}; $i++) {
        if (defined $rh_blank->{$i}) {
            foreach (1..$rh_blank->{$i}) {
                $html_out .= "<!-- blank -->\n";
            }
        }
        my $line_num = "";
        my $pre      = "";
        my $post     = '</span> &nbsp;';
warn "undef rah_diff_R[$i]{type} " unless defined $rah_diff_R->[$i]{type};
        if ($rah_diff_R->[$i]{type} eq 'nonexist') {
            ++$comment_line_number;
            $line_num = sprintf "\&nbsp; <span class=\"clinenum\"> %0${n_digits}d %s",
                            $comment_line_number, $post;
            $pre = '<span class="comment">';
            $html_out .= $line_num;
            $html_out .= $pre .
                         html_metachars($rah_diff_L->[$i]{char}) .
                         $post . "\n";
            next;
        }
        if      ($rah_diff_R->[$i]{type} eq 'code' and
                 $rah_diff_R->[$i]{desc} eq 'same') {
            # entire line remains as-is
            $line_num = sprintf "\&nbsp; <span class=\"linenum\"> %0${n_digits}d %s",
                            $rah_diff_R->[$i]{lnum}, $post;
            $pre    = '<span class="normal">';
            $html_out .= $line_num;
            $html_out .= $pre .
                         html_metachars($rah_diff_R->[$i]{char}) . $post;
#XX     } elsif ($rah_diff_R->[$i]{type} eq 'code') { # code+comments
#XX
#XX         $line_num = '<span class="linenum">' .
#XX                      $rah_diff_R->[$i]{lnum} . $post;
#XX         $html_out .= $line_num;
#XX
#XX         my @strings = @{$rah_diff_R->[$i]{char}{strings}};
#XX         my @type    = @{$rah_diff_R->[$i]{char}{type}};
#XX         for (my $i = 0; $i < scalar @strings; $i++) {
#XX             if ($type[$i] eq 'u') {
#XX                 $pre = '<span class="normal">';
#XX             } else {
#XX                 $pre = '<span class="comment">';
#XX             }
#XX             $html_out .= $pre .  html_metachars($strings[$i]) . $post;
#XX         }
# print Dumper(@strings, @type); die;

        } elsif ($rah_diff_R->[$i]{type} eq 'comment') {
            $line_num = '<span class="clinenum">' . $comment_line_number . $post;
            # entire line is a comment
            $pre    = '<span class="comment">';
            $html_out .= $pre .
                         html_metachars($rah_diff_R->[$i]{char}) . $post;
        }
#printf "%-30s %s %-30s\n", $line_1, $separator, $line_2;
        $html_out .= "\n";
    }

    $html_out .= html_end();

    my $out_file = "$filename.html";
    write_file($out_file, {}, ( $html_out ) );

    print "<- write_comments_to_html\n" if $opt_v > 2;
} # 1}}}
sub array_diff {                             # {{{1
    my ($file          , # in  only used for error reporting
        $ra_lines_L    , # in  array of lines in Left  file (no blank lines)
        $ra_lines_R    , # in  array of lines in Right file (no blank lines)
        $mode          , # in  "comment" | "revision"
        $rah_diff_L    , # out
        $rah_diff_R    , # out
        $raa_Errors    , # in/out
       ) = @_;

    # This routine operates in two ways:
    # A. Computes diffs of the same file with and without comments.
    #    This is used to classify lines as code, comments, or blank.
    # B. Computes diffs of two revisions of a file.  This method
    #    requires a prior run of method A using the older version
    #    of the file because it needs lines to be classified.

    # $rah_diff structure:
    # An array with n entries where n equals the number of lines in
    # an sdiff of the two files.  Each entry in the array describes
    # the contents of the corresponding line in file Left and file Right:
    #  diff[]{type} = blank | code | code+comment | comment | nonexist
    #        {lnum} = line number within the original file (1-based)
    #        {desc} = same | added | removed | modified
    #        {char} = the input line unless {desc} = 'modified' in
    #                 which case
    #        {char}{strings} = [ substrings ]
    #        {char}{type}    = [ disposition (added, removed, etc)]
    #

    @{$rah_diff_L} = ();
    @{$rah_diff_R} = ();

    print "-> array_diff()\n" if $opt_v > 2;
    my $COMMENT_MODE = 0;
       $COMMENT_MODE = 1 if $mode eq "comment";

#print "array_diff(mode=$mode)\n";
#print Dumper("block left:" , $ra_lines_L);
#print Dumper("block right:", $ra_lines_R);

    my @sdiffs = ();
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm $opt_diff_timeout;
        @sdiffs = sdiff($ra_lines_L, $ra_lines_R);
        alarm 0;
    };
    if ($@) {
        # timed out
        die unless $@ eq "alarm\n"; # propagate unexpected errors
        push @{$raa_Errors},
             [ $Error_Codes{'Diff error, exceeded timeout'}, $file ];
        if ($opt_v) {
          warn "array_diff: diff timeout failure for $file--ignoring\n";
        }
        return;
    }

    my $n_L        = 0;
    my $n_R        = 0;
    my $n_sdiff    = 0;  # index to $rah_diff_L, $rah_diff_R
    foreach my $triple (@sdiffs) {
        my $flag   = $triple->[0];
        my $line_L = $triple->[1];
        my $line_R = $triple->[2];
        $rah_diff_L->[$n_sdiff]{char} = $line_L;
        $rah_diff_R->[$n_sdiff]{char} = $line_R;
        if      ($flag eq 'u') {  # u = unchanged
            ++$n_L;
            ++$n_R;
            if ($COMMENT_MODE) {
                # line exists in both with & without comments, must be code
                $rah_diff_L->[$n_sdiff]{type} = "code";
                $rah_diff_R->[$n_sdiff]{type} = "code";
            }
            $rah_diff_L->[$n_sdiff]{desc} = "same";
            $rah_diff_R->[$n_sdiff]{desc} = "same";
            $rah_diff_L->[$n_sdiff]{lnum} = $n_L;
            $rah_diff_R->[$n_sdiff]{lnum} = $n_R;
        } elsif ($flag eq 'c') {  # c = changed
# warn "per line sdiff() commented out\n"; if (0) {
            ++$n_L;
            ++$n_R;

            if ($COMMENT_MODE) {
                # line has text both with & without comments;
                # count as code
                $rah_diff_L->[$n_sdiff]{type} = "code";
                $rah_diff_R->[$n_sdiff]{type} = "code";
            }

            my @chars_L = split '', $line_L;
            my @chars_R = split '', $line_R;

            $rah_diff_L->[$n_sdiff]{desc} = "modified";
            $rah_diff_R->[$n_sdiff]{desc} = "modified";
            $rah_diff_L->[$n_sdiff]{lnum} = $n_L;
            $rah_diff_R->[$n_sdiff]{lnum} = $n_R;

        } elsif ($flag eq '+') {  # + = added
            ++$n_R;
            if ($COMMENT_MODE) {
                # should never get here, but may due to sdiff() bug,
                # ref https://rt.cpan.org/Public/Bug/Display.html?id=131629
                # Rather than failing, ignore and continue.  A possible
                # consequence is counts may be inconsistent.
#####           @{$rah_diff_L} = ();
#####           @{$rah_diff_R} = ();
#####           push @{$raa_Errors},
#####                [ $Error_Codes{'Diff error (quoted comments?)'}, $file ];
                if ($opt_v) {
                  warn "array_diff: diff failure (diff says the\n";
                  warn "comment-free file has added lines).\n";
                  warn "$n_sdiff  $line_L\n";
                }
            }
####        $rah_diff_L->[$n_sdiff]{type} = "nonexist";
            $rah_diff_L->[$n_sdiff]{type} = "comment";
            $rah_diff_L->[$n_sdiff]{desc} = "removed";
            $rah_diff_R->[$n_sdiff]{desc} = "added";
            $rah_diff_R->[$n_sdiff]{lnum} = $n_R;
        } elsif ($flag eq '-') {  # - = removed
            ++$n_L;
            if ($COMMENT_MODE) {
                # line must be comment because blanks already gone
                $rah_diff_L->[$n_sdiff]{type} = "comment";
            }
            $rah_diff_R->[$n_sdiff]{type} = "nonexist";
            $rah_diff_R->[$n_sdiff]{desc} = "removed";
            $rah_diff_L->[$n_sdiff]{desc} = "added";
            $rah_diff_L->[$n_sdiff]{lnum} = $n_L;
        }
#printf "%-30s %s %-30s\n", $line_L, $separator, $line_R;
        ++$n_sdiff;
    }
#use Data::Dumper::Simple;
#print Dumper($rah_diff_L, $rah_diff_R);
#print Dumper($rah_diff_L);

    print "<- array_diff\n" if $opt_v > 2;
} # 1}}}
sub remove_leading_dir {                     # {{{1
    my @filenames = @_;
    #
    #  Input should be a list of file names
    #  with the same leading directory such as
    #
    #      dir1/dir2/a.txt
    #      dir1/dir2/b.txt
    #      dir1/dir2/dir3/c.txt
    #
    #  Output is the same list minus the common
    #  directory path:
    #
    #      a.txt
    #      b.txt
    #      dir3/c.txt
    #
    print "-> remove_leading_dir()\n" if $opt_v > 2;
    my @D = (); # a matrix:   [ [ dir1, dir2 ],         # dir1/dir2/a.txt
                #               [ dir1, dir2 ],         # dir1/dir2/b.txt
                #               [ dir1, dir2 , dir3] ]  # dir1/dir2/dir3/c.txt
    if ($ON_WINDOWS) {
        foreach my $F (@filenames) {
            $F =~ s{\\}{/}g;
            $F = ucfirst($F) if $F =~ /^\w:/;  # uppercase drive letter
        }
    }
    if (scalar @filenames == 1) {
        # special case:  with only one filename
        # cannot determine a baseline, just remove first directory level
        $filenames[0] =~ s{^.*?/}{};
        # print "-> $filenames[0]\n";
        return $filenames[0];
    }
    foreach my $F (@filenames) {
        my ($Vol, $Dir, $File) = File::Spec->splitpath($F);
        my @x = File::Spec->splitdir( $Dir );
        pop @x unless $x[$#x]; # last entry usually null, remove it
        if ($ON_WINDOWS) {
            if (defined($Vol) and $Vol) {
                # put the drive letter, eg, C:, at the front
                unshift @x, uc $Vol;
            }
        }
#print "F=$F, Dir=$Dir  x=[", join("][", @x), "]\n";
        push @D, [ @x ];
    }

    # now loop over columns until either they are all
    # eliminated or a unique column is found

    my @common   = ();  # to contain the common leading directories
    my $mismatch = 0;
    while (!$mismatch) {
        for (my $row = 1; $row < scalar @D; $row++) {
#print "comparing $D[$row][0] to $D[0][0]\n";

            if (!defined $D[$row][0] or !defined $D[0][0] or
                ($D[$row][0] ne $D[0][0])) {
                $mismatch = 1;
                last;
            }
        }
#print "mismatch=$mismatch\n";
        if (!$mismatch) {
            push @common, $D[0][0];
            # all terms in the leading match; unshift the batch
            foreach my $ra (@D) {
                shift @{$ra};
            }
        }
    }

    push @common, " ";  # so that $leading will end with "/ "
    my $leading = File::Spec->catdir( @common );
       $leading =~ s{ $}{};  # now take back the bogus appended space
#print "remove_leading_dir leading=[$leading]\n"; die;
    if ($ON_WINDOWS) {
       $leading =~ s{\\}{/}g;
    }
    foreach my $F (@filenames) {
        $F =~ s{^$leading}{};
    }

    print "<- remove_leading_dir()\n" if $opt_v > 2;
    return @filenames;

} # 1}}}
sub strip_leading_dir {                      # {{{1
    my ($leading, @filenames) = @_;
    #  removes the string $leading from each entry in @filenames
    print "-> strip_leading_dir()\n" if $opt_v > 2;

#print "remove_leading_dir leading=[$leading]\n"; die;
    if ($ON_WINDOWS) {
       $leading =~ s{\\}{/}g;
        foreach my $F (@filenames) {
            $F =~ s{\\}{/}g;
        }
    }
    foreach my $F (@filenames) {
#print "strip_leading_dir F before $F\n";
        if ($ON_WINDOWS) {
            $F =~ s{^$leading}{}i;
        } else {
            $F =~ s{^$leading}{};
        }
#print "strip_leading_dir F after  $F\n";
    }

    print "<- strip_leading_dir()\n" if $opt_v > 2;
    return @filenames;

} # 1}}}
sub find_deepest_file {                      # {{{1
    my @filenames = @_;
    #
    #  Input should be a list of file names
    #  with the same leading directory such as
    #
    #      dir1/dir2/a.txt
    #      dir1/dir2/b.txt
    #      dir1/dir2/dir3/c.txt
    #
    #  Output is the file with the most parent directories:
    #
    #      dir1/dir2/dir3/c.txt

    print "-> find_deepest_file()\n" if $opt_v > 2;

    my $deepest    = undef;
    my $max_subdir = -1;
    foreach my $F (sort @filenames) {
        my ($Vol, $Dir, $File) = File::Spec->splitpath($F);
        my @x = File::Spec->splitdir( $Dir );
        pop @x unless $x[$#x]; # last entry usually null, remove it
        if (scalar @x > $max_subdir) {
            $deepest    = $F;
            $max_subdir = scalar @x;
        }
    }

    print "<- find_deepest_file()\n" if $opt_v > 2;
    return $deepest;

} # 1}}}
sub find_uncommon_parent_dir {               # {{{1
    my ($file_L, $file_R) = @_;
    #
    # example:
    #
    #   file_L = "perl-5.16.1/cpan/CPANPLUS/lib/CPANPLUS/Internals/Source/SQLite/Tie.pm"
    #   file_R = "/tmp/8VxQG0OLbp/perl-5.16.3/cpan/CPANPLUS/lib/CPANPLUS/Internals/Source/SQLite/Tie.pm"
    #
    # then return
    #
    #   "perl-5.16.1",
    #   "/tmp/8VxQG0OLbp/perl-5.16.3",

    my ($Vol_L, $Dir_L, $File_L) = File::Spec->splitpath($file_L);
    my @x_L = File::Spec->splitdir( $Dir_L );
    my ($Vol_R, $Dir_R, $File_R) = File::Spec->splitpath($file_R);
    my @x_R = File::Spec->splitdir( $Dir_R );

    my @common  = ();

    # work backwards
    while ($x_L[$#x_L] eq $x_R[$#x_R]) {
        push @common, $x_L[$#x_L];
        pop  @x_L;
        pop  @x_R;
    }
    my $success = scalar @common;

    my $dirs_L = File::Spec->catdir( @x_L );
    my $dirs_R = File::Spec->catdir( @x_R );
    my $lead_L = File::Spec->catpath( $Vol_L, $dirs_L, "" );
    my $lead_R = File::Spec->catpath( $Vol_R, $dirs_R, "" );

    return $lead_L, $lead_R, $success;

} # 1}}}
sub get_leading_dirs {                       # {{{1
    my ($rh_file_list_L, $rh_file_list_R) = @_;
    # find uniquely named files in both sets to help determine the
    # leading directory positions
    my %unique_filename = ();
    my %basename_L = ();
    my %basename_R = ();
    foreach my $f (keys %{$rh_file_list_L}) {
        my $bn = basename($f);
        $basename_L{ $bn }{'count'}   += 1;
        $basename_L{ $bn }{'fullpath'} = $f;
    }
    foreach my $f (keys %{$rh_file_list_R}) {
        my $bn = basename($f);
        $basename_R{ $bn }{'count'}   += 1;
        $basename_R{ $bn }{'fullpath'} = $f;
    }
    foreach my $f (keys %basename_L) {
        next unless $basename_L{$f}{'count'} == 1;
        next unless defined $basename_R{$f} and $basename_R{$f}{'count'} == 1;
        $unique_filename{$f}{'L'} = $basename_L{ $f }{'fullpath'};
        $unique_filename{$f}{'R'} = $basename_R{ $f }{'fullpath'};
    }
    return undef, undef, 0 unless %unique_filename;

####my %candidate_leading_dir_L = ();
####my %candidate_leading_dir_R = ();
    my ($L_drop, $R_drop) = (undef, undef);
    foreach my $f (keys %unique_filename) {
        my $fL = $unique_filename{ $f }{'L'};
        my $fR = $unique_filename{ $f }{'R'};

        my @DL = File::Spec->splitdir($fL);
        my @DR = File::Spec->splitdir($fR);
#printf "%-36s -> %-36s\n", $fL, $fR;
#print Dumper(@DL, @DR);
        # find the most number of common directories between L and R
        if (!defined $L_drop) {
            $L_drop = dirname $fL;
        }
        if (!defined $R_drop) {
            $R_drop = dirname $fR;
        }
        my $n_path_elements_L = scalar @DL;
        my $n_path_elements_R = scalar @DR;
        my $n_path_elem = $n_path_elements_L < $n_path_elements_R ?
                          $n_path_elements_L : $n_path_elements_R;
        my ($n_L_drop_this_pair, $n_R_drop_this_pair) = (0, 0);
        for (my $i = 0; $i < $n_path_elem; $i++) {
            last if $DL[ $#DL - $i] ne $DR[ $#DR - $i];
            ++$n_L_drop_this_pair;
            ++$n_R_drop_this_pair;
        }
        my $L_common = File::Spec->catdir( @DL[0..($#DL-$n_L_drop_this_pair)] );
        my $R_common = File::Spec->catdir( @DR[0..($#DR-$n_R_drop_this_pair)] );
#print "L_common=$L_common\n";
#print "R_common=$R_common\n";
        $L_drop = $L_common if length $L_common < length $L_drop;
        $R_drop = $R_common if length $R_common < length $R_drop;

        $L_drop = $L_drop . "/" if $L_drop;
        $R_drop = $R_drop . "/" if $R_drop;
########my $ptr_L = length($fL) - 1;
########my $ptr_R = length($fR) - 1;
########my @aL    = split '', $fL;
########my @aR    = split '', $fR;
########while ($ptr_L >= 0 and $ptr_R >= 0) {
########    last if $aL[$ptr_L] ne $aR[$ptr_R];
########    --$ptr_L;
########    --$ptr_R;
########}
########my $leading_dir_L = "";
########   $leading_dir_L = substr($fL, 0, $ptr_L+1) if $ptr_L >= 0;
########my $leading_dir_R = "";
########   $leading_dir_R = substr($fR, 0, $ptr_R+1) if $ptr_R >= 0;
########++$candidate_leading_dir_L{$leading_dir_L};
########++$candidate_leading_dir_R{$leading_dir_R};
    }
#use Data::Dumper::Simple;
    # at this point path separator on Windows is already /
    $L_drop =~ s{//}{/}g;
    $R_drop =~ s{//}{/}g;
#print "L_drop=$L_drop\n";
#print "R_drop=$R_drop\n";
    return $L_drop, $R_drop, 1;
####my $best_L = (sort {
####           $candidate_leading_dir_L{$b} <=>
####           $candidate_leading_dir_L{$a}} keys %candidate_leading_dir_L)[0];
####my $best_R = (sort {
####           $candidate_leading_dir_R{$b} <=>
####           $candidate_leading_dir_R{$a}} keys %candidate_leading_dir_R)[0];
####return $best_L, $best_R, 1;
} # 1}}}
sub align_by_pairs {                         # {{{1
    my ($rh_file_list_L        , # in
        $rh_file_list_R        , # in
        $ra_added              , # out
        $ra_removed            , # out
        $ra_compare_list       , # out
        ) = @_;
    print "-> align_by_pairs()\n" if $opt_v > 2;
    @{$ra_compare_list} = ();

    my @files_L = sort keys %{$rh_file_list_L};
    my @files_R = sort keys %{$rh_file_list_R};
    return () unless @files_L or  @files_R;  # at least one must have stuff
    if ($ON_WINDOWS) {
        foreach (@files_L) { $_ =~ s{\\}{/}g; }
        foreach (@files_R) { $_ =~ s{\\}{/}g; }
        if ($opt_ignore_case_ext) {
            foreach (@files_L) { $_ = lc $_; }
            foreach (@files_R) { $_ = lc $_; }
        }
    }

    if      ( @files_L and !@files_R) {
        # left side has stuff, right side is empty; everything deleted
        @{$ra_added   }     = ();
        @{$ra_removed }     = @files_L;
        @{$ra_compare_list} = ();
        return;
    } elsif (!@files_L and  @files_R) {
        # left side is empty, right side has stuff; everything added
        @{$ra_added   }     = @files_R;
        @{$ra_removed }     = ();
        @{$ra_compare_list} = ();
        return;
    } elsif (scalar(@files_L) == 1 and scalar(@files_R) == 1) {
        # Special case of comparing one file against another.  In
        # this case force the pair to be aligned with each other,
        # otherwise the file naming logic will think one file
        # was added and the other deleted.
        @{$ra_added   }     = ();
        @{$ra_removed }     = ();
        @{$ra_compare_list} = ( [$files_L[0], $files_R[0]] );
        return;
    }
#use Data::Dumper::Simple;
#print Dumper("align_by_pairs", %{$rh_file_list_L}, %{$rh_file_list_R},);
#die;

    # The harder case:  compare groups of files.  This only works
    # if the groups are in different directories so the first step
    # is to strip the leading directory names from file lists to
    # make it possible to align by file names.
    my @files_L_minus_dir = undef;
    my @files_R_minus_dir = undef;

    my $deepest_file_L    = find_deepest_file(@files_L);
    my $deepest_file_R    = find_deepest_file(@files_R);
#print "deepest L = [$deepest_file_L]\n";
#print "deepest R = [$deepest_file_R]\n";
    my ($leading_dir_L, $leading_dir_R, $success) =
                get_leading_dirs($rh_file_list_L, $rh_file_list_R);
#print "leading_dir_L=[$leading_dir_L]\n";
#print "leading_dir_R=[$leading_dir_R]\n";
#print "success      =[$success]\n";
    if ($success) {
        @files_L_minus_dir = strip_leading_dir($leading_dir_L, @files_L);
        @files_R_minus_dir = strip_leading_dir($leading_dir_R, @files_R);
    } else {
        # otherwise fall back to old strategy
        @files_L_minus_dir = remove_leading_dir(@files_L);
        @files_R_minus_dir = remove_leading_dir(@files_R);
    }

    # Keys of the stripped_X arrays are canonical file names;
    # should overlap mostly.  Keys in stripped_L but not in
    # stripped_R are files that have been deleted.  Keys in
    # stripped_R but not in stripped_L have been added.
    my %stripped_L = ();
       @stripped_L{ @files_L_minus_dir } = @files_L;
    my %stripped_R = ();
       @stripped_R{ @files_R_minus_dir } = @files_R;

    my %common = ();
    foreach my $f (keys %stripped_L) {
        $common{$f}  = 1 if     defined $stripped_R{$f};
    }

    my %deleted = ();
    foreach my $f (keys %stripped_L) {
        $deleted{$stripped_L{$f}} = $f unless defined $stripped_R{$f};
    }

    my %added = ();
    foreach my $f (keys %stripped_R) {
        $added{$stripped_R{$f}}   = $f unless defined $stripped_L{$f};
    }

#use Data::Dumper::Simple;
#print Dumper("align_by_pairs", %stripped_L, %stripped_R);
#print Dumper("align_by_pairs", %common, %added, %deleted);

    foreach my $f (keys %common) {
        push @{$ra_compare_list}, [ $stripped_L{$f},
                                    $stripped_R{$f} ];
    }
    @{$ra_added   } = keys %added  ;
    @{$ra_removed } = keys %deleted;

    print "<- align_by_pairs()\n" if $opt_v > 2;
    return;
#print Dumper("align_by_pairs", @files_L_minus_dir, @files_R_minus_dir);
#die;
} # 1}}}
sub html_header {                            # {{{1
    my ($title , ) = @_;

    print "-> html_header\n" if $opt_v > 2;
    return
'<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="GENERATOR" content="cloc http://github.com/AlDanial/cloc">
' .
"
<!-- Created by $script v$VERSION -->
<title>$title</title>
" .
'
<style TYPE="text/css">
<!--
    body {
        color: black;
        background-color: white;
        font-family: monospace
    }

    .whitespace {
        background-color: gray;
    }

    .comment {
        color: gray;
        font-style: italic;
    }

    .clinenum {
        color: red;
    }

    .linenum {
        color: green;
    }
 -->
</style>
</head>
<body>
<pre><tt>
';
    print "<- html_header\n" if $opt_v > 2;
} # 1}}}
sub html_end {                               # {{{1
return
'</tt></pre>
</body>
</html>
';
} # 1}}}
sub die_unknown_lang {                       # {{{1
    my ($lang, $option_name) = @_;
    die "Unknown language '$lang' used with $option_name option.  " .
        "The command\n  $script --show-lang\n" .
        "will print all recognized languages.  Language names are " .
        "case sensitive.\n" ;
} # 1}}}
sub unicode_file {                           # {{{1
    my $file = shift @_;

    print "-> unicode_file($file)\n" if $opt_v > 2;
    return 0 if (get_size($file) > 2_000_000);
    # don't bother trying to test binary files bigger than 2 MB

    my $IN = open_file('<', $file, 1);
    if (!defined $IN) {
        warn "Unable to read $file; ignoring.\n";
        return 0;
    }
    my @lines = <$IN>;
    $IN->close;

    if (unicode_to_ascii( join('', @lines) )) {
        print "<- unicode_file()\n" if $opt_v > 2;
        return 1;
    } else {
        print "<- unicode_file()\n" if $opt_v > 2;
        return 0;
    }

} # 1}}}
sub unicode_to_ascii {                       # {{{1
    my $string = shift @_;

    # A trivial attempt to convert UTF-16 little or big endian
    # files into ASCII.  These files exhibit the following byte
    # sequence:
    #   byte   1:  255
    #   byte   2:  254
    #   byte   3:  ord of ASCII character
    #   byte   4:    0
    #   byte 3+i:  ord of ASCII character
    #   byte 4+i:    0
    # or
    #   byte   1:  255
    #   byte   2:  254
    #   byte   3:    0
    #   byte   4:  ord of ASCII character
    #   byte 3+i:    0
    #   byte 4+i:  ord of ASCII character
    #
    print "-> unicode_to_ascii()\n" if $opt_v > 2;

    my $length  = length $string;
#print "length=$length\n";
    return '' if $length <= 3;
    my @unicode = split(//, $string);

    # check the first 100 characters (= 200 bytes) for big or
    # little endian UTF-16 encoding
    my $max_peek     = $length < 200 ? $length : 200;
    my $max_for_pass = $length < 200 ? 0.9*$max_peek/2 : 90;
    my @view_1   = ();
    for (my $i = 2; $i < $max_peek; $i += 2) { push @view_1, $unicode[$i] }
    my @view_2   = ();
    for (my $i = 3; $i < $max_peek; $i += 2) { push @view_2, $unicode[$i] }

    my $points_1 = 0;
    foreach my $C (@view_1) {
        ++$points_1 if (32 <= ord($C) and ord($C) <= 127) or ord($C) == 13
                                                          or ord($C) == 10
                                                          or ord($C) ==  9;
    }

    my $points_2 = 0;
    foreach my $C (@view_2) {
        ++$points_2 if (32 <= ord($C) and ord($C) <= 127) or ord($C) == 13
                                                          or ord($C) == 10
                                                          or ord($C) ==  9;
    }
#print "points 1: $points_1\n";
#print "points 2: $points_2\n";
#print "max_peek    : $max_peek\n";
#print "max_for_pass: $max_for_pass\n";

    my $offset = undef;
    if    ($points_1 > $max_for_pass) { $offset = 2; }
    elsif ($points_2 > $max_for_pass) { $offset = 3; }
    else                   {
        print "<- unicode_to_ascii() a p1=$points_1 p2=$points_2\n" if $opt_v > 2;
        return '';
    }  # neither big or little endian UTF-16

    my @ascii              = ();
    for (my $i = $offset; $i < $length; $i += 2) {
        # some compound characters are made of HT (9), LF (10), or CR (13)
        # True HT, LF, CR are followed by 00; only add those.
        my $L = $unicode[$i];
        if (ord($L) == 9 or ord($L) == 10 or ord($L) == 13) {
            my $companion;
            if ($points_1) {
                last if $i+1 >= $length;
                $companion = $unicode[$i+1];
            } else {
                $companion = $unicode[$i-1];
            }
            if (ord($companion) == 0) {
                push @ascii, $L;
            } else {
                push @ascii, " ";  # no clue what this letter is
            }
        } else {
            push @ascii, $L;
        }
    }
    print "<- unicode_to_ascii() b p1=$points_1 p2=$points_2\n" if $opt_v > 2;
    return join("", @ascii);
} # 1}}}
sub uncompress_archive_cmd {                 # {{{1
    my ($archive_file, ) = @_;

    # Wrap $archive_file in single or double quotes in the system
    # commands below to avoid filename chicanery (including
    # spaces in the names).

    print "-> uncompress_archive_cmd($archive_file)\n" if $opt_v > 2;
    my $extract_cmd = "";
    my $missing     = "";
    if ($opt_extract_with) {
        ( $extract_cmd = $opt_extract_with ) =~ s/>FILE</$archive_file/g;
    } elsif (basename($archive_file) eq "-" and !$ON_WINDOWS) {
        $extract_cmd = "cat > -";
    } elsif ($archive_file =~ /\.tar$/ and $ON_WINDOWS) {
        $extract_cmd = "tar -xf \"$archive_file\"";
    } elsif (($archive_file =~ /\.tar\.(gz|Z)$/ or
              $archive_file =~ /\.tgz$/       ) and !$ON_WINDOWS)    {
        if (external_utility_exists("gzip --version")) {
            if (external_utility_exists("tar --version")) {
                $extract_cmd = "gzip -dc '$archive_file' | tar xf -";
            } else {
                $missing = "tar";
            }
        } else {
            $missing = "gzip";
        }
    } elsif ($archive_file =~ /\.tar\.bz2$/ and !$ON_WINDOWS)    {
        if (external_utility_exists("bzip2 --help")) {
            if (external_utility_exists("tar --version")) {
                $extract_cmd = "bzip2 -dc '$archive_file' | tar xf -";
            } else {
                $missing = "tar";
            }
        } else {
            $missing = "bzip2";
        }
    } elsif ($archive_file =~ /\.tar\.xz$/ and !$ON_WINDOWS)    {
        if (external_utility_exists("unxz --version")) {
            if (external_utility_exists("tar --version")) {
                $extract_cmd = "unxz -dc '$archive_file' | tar xf -";
            } else {
                $missing = "tar";
            }
        } else {
            $missing = "bzip2";
        }
    } elsif ($archive_file =~ /\.tar$/ and !$ON_WINDOWS)    {
        $extract_cmd = "tar xf '$archive_file'";
    } elsif ($archive_file =~ /\.src\.rpm$/i and !$ON_WINDOWS) {
        if (external_utility_exists("cpio --version")) {
            if (external_utility_exists("rpm2cpio")) {
                $extract_cmd = "rpm2cpio '$archive_file' | cpio -i";
            } else {
                $missing = "rpm2cpio";
            }
        } else {
            $missing = "bzip2";
        }
    } elsif ($archive_file =~ /\.(whl|zip)$/i and !$ON_WINDOWS)    {
        if (external_utility_exists("unzip")) {
            $extract_cmd = "unzip -qq -d . '$archive_file'";
        } else {
            $missing = "unzip";
        }
    } elsif ($archive_file =~ /\.deb$/i and !$ON_WINDOWS)    {
        # only useful if the .deb contains source code--most
        # .deb files just have compiled executables
        if (external_utility_exists("dpkg-deb")) {
            $extract_cmd = "dpkg-deb -x '$archive_file' .";
        } else {
            $missing = "dpkg-deb";
        }
    } elsif ($ON_WINDOWS and $archive_file =~ /\.(whl|zip)$/i) {
        # use unzip on Windows (comes with git-for-Windows)
        if (external_utility_exists("unzip")) {
             $extract_cmd = "unzip -qq -d . \"$archive_file\" ";
        } else {
            $missing = "unzip";
        }
    }
    print "<- uncompress_archive_cmd\n" if $opt_v > 2;
    if ($missing) {
        die "Unable to expand $archive_file because external\n",
            "utility '$missing' is not available.\n",
            "Another possibility is to use the --extract-with option.\n";
    } else {
        return $extract_cmd;
    }
}
# 1}}}
sub read_list_file {                         # {{{1
    my ($file, ) = @_;
    # reads filenames from a STDIN pipe if $file == "-"

    print "-> read_list_file($file)\n" if $opt_v > 2;
    my @entry = ();

    if ($file eq "-") {
        # read from a STDIN pipe
        my $IN;
        open($IN, $file);
        if (!defined $IN) {
            warn "Unable to read $file; ignoring.\n";
            return ();
        }
        while (<$IN>) {
            next if /^\s*$/ or /^\s*#/; # skip empty or commented lines
            s/\cM$//;  # DOS to Unix
            chomp;
            push @entry, $_;
        }
        $IN->close;
    } else {
        # read from an actual file
        foreach my $line (read_file($file)) {
            next if $line =~ /^\s*$/ or $line =~ /^\s*#/;
            $line =~ s/\cM$//;  # DOS to Unix
            chomp $line;
            push @entry, $line;
        }
    }

    print "<- read_list_file\n" if $opt_v > 2;
    return @entry;
}
# 1}}}
sub external_utility_exists {                # {{{1
    my $exe = shift @_;

    my $success      = 0;
    if ($ON_WINDOWS) {
        $success = 1 unless system $exe . ' > nul';
    } else {
        $success = 1 unless system $exe . ' >/dev/null 2>&1';
        if (!$success) {
            $success = 1 unless system "which" . " $exe" . ' >/dev/null 2>&1';
        }
    }

    return $success;
} # 1}}}
sub write_xsl_file {                         # {{{1
    print "-> write_xsl_file\n" if $opt_v > 2;
    my $XSL =             # <style>  </style> {{{2
'<?xml version="1.0" encoding="UTF-8"?>
<!-- XSL file by Paul Schwann, January 2009.
     Fixes for by-file and by-file-by-lang by d_uragan, November 2010.
     -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>CLOC Results</title>
      </head>
      <style type="text/css">
        table {
          table-layout: auto;
          border-collapse: collapse;
          empty-cells: show;
        }
        td, th {
          padding: 4px;
        }
        th {
          background-color: #CCCCCC;
        }
        td {
          text-align: center;
        }
        table, td, tr, th {
          border: thin solid #999999;
        }
      </style>
      <body>
        <h3><xsl:value-of select="results/header"/></h3>
';
# 2}}}

    if ($opt_by_file) {
        $XSL .=             # <table> </table>{{{2
'        <table>
          <thead>
            <tr>
              <th>File</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
              <th>Language</th>
';
        $XSL .=
'             <th>3<sup>rd</sup> Generation Equivalent</th>
              <th>Scale</th>
' if $opt_3;
        $XSL .=
'           </tr>
          </thead>
          <tbody>
          <xsl:for-each select="results/files/file">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
              <td><xsl:value-of select="@language"/></td>
';
        $XSL .=
'             <td><xsl:value-of select="@factor"/></td>
              <td><xsl:value-of select="@scaled"/></td>
' if $opt_3;
        $XSL .=
'           </tr>
          </xsl:for-each>
            <tr>
              <th>Total</th>
              <th><xsl:value-of select="results/files/total/@blank"/></th>
              <th><xsl:value-of select="results/files/total/@comment"/></th>
              <th><xsl:value-of select="results/files/total/@code"/></th>
              <th><xsl:value-of select="results/files/total/@language"/></th>
';
        $XSL .=
'             <th><xsl:value-of select="results/files/total/@factor"/></th>
              <th><xsl:value-of select="results/files/total/@scaled"/></th>
' if $opt_3;
        $XSL .=
'           </tr>
          </tbody>
        </table>
        <br/>
';
# 2}}}
    }

    if (!$opt_by_file or $opt_by_file_by_lang) {
        $XSL .=             # <table> </table> {{{2
'       <table>
          <thead>
            <tr>
              <th>Language</th>
              <th>Files</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
';
        $XSL .=
'             <th>Scale</th>
              <th>3<sup>rd</sup> Generation Equivalent</th>
' if $opt_3;
        $XSL .=
'           </tr>
          </thead>
          <tbody>
          <xsl:for-each select="results/languages/language">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@files_count"/></td>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
';
        $XSL .=
'             <td><xsl:value-of select="@factor"/></td>
              <td><xsl:value-of select="@scaled"/></td>
' if $opt_3;
        $XSL .=
'          </tr>
          </xsl:for-each>
            <tr>
              <th>Total</th>
              <th><xsl:value-of select="results/languages/total/@sum_files"/></th>
              <th><xsl:value-of select="results/languages/total/@blank"/></th>
              <th><xsl:value-of select="results/languages/total/@comment"/></th>
              <th><xsl:value-of select="results/languages/total/@code"/></th>
';
        $XSL .=
'             <th><xsl:value-of select="results/languages/total/@factor"/></th>
              <th><xsl:value-of select="results/languages/total/@scaled"/></th>
' if $opt_3;
        $XSL .=
'           </tr>
          </tbody>
        </table>
';
# 2}}}
    }

    $XSL.= <<'EO_XSL'; # {{{2
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

EO_XSL
# 2}}}

    my $XSL_DIFF = <<'EO_DIFF_XSL'; # {{{2
<?xml version="1.0" encoding="UTF-8"?>
<!-- XSL file by Blazej Kroll, November 2010 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>CLOC Results</title>
      </head>
      <style type="text/css">
        table {
          table-layout: auto;
          border-collapse: collapse;
          empty-cells: show;
          margin: 1em;
        }
        td, th {
          padding: 4px;
        }
        th {
          background-color: #CCCCCC;
        }
        td {
          text-align: center;
        }
        table, td, tr, th {
          border: thin solid #999999;
        }
      </style>
      <body>
        <h3><xsl:value-of select="results/header"/></h3>
EO_DIFF_XSL
# 2}}}

    if ($opt_by_file) {
        $XSL_DIFF.= <<'EO_DIFF_XSL'; # {{{2
        <table>
          <thead>
          <tr><th colspan="4">Same</th>
          </tr>
            <tr>
              <th>File</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
            </tr>
          </thead>
          <tbody>
          <xsl:for-each select="diff_results/same/file">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
            </tr>
          </xsl:for-each>
          </tbody>
        </table>

        <table>
          <thead>
          <tr><th colspan="4">Modified</th>
          </tr>
            <tr>
              <th>File</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
            </tr>
          </thead>
          <tbody>
          <xsl:for-each select="diff_results/modified/file">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
            </tr>
          </xsl:for-each>
          </tbody>
        </table>

        <table>
          <thead>
          <tr><th colspan="4">Added</th>
          </tr>
            <tr>
              <th>File</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
            </tr>
          </thead>
          <tbody>
          <xsl:for-each select="diff_results/added/file">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
            </tr>
          </xsl:for-each>
          </tbody>
        </table>

        <table>
          <thead>
          <tr><th colspan="4">Removed</th>
          </tr>
            <tr>
              <th>File</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
            </tr>
          </thead>
          <tbody>
          <xsl:for-each select="diff_results/removed/file">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
            </tr>
          </xsl:for-each>
          </tbody>
        </table>
EO_DIFF_XSL
# 2}}}
    }

    if (!$opt_by_file or $opt_by_file_by_lang) {
        $XSL_DIFF.= <<'EO_DIFF_XSL'; # {{{2
        <table>
          <thead>
          <tr><th colspan="5">Same</th>
          </tr>
            <tr>
              <th>Language</th>
              <th>Files</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
            </tr>
          </thead>
          <tbody>
          <xsl:for-each select="diff_results/same/language">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@files_count"/></td>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
            </tr>
          </xsl:for-each>
          </tbody>
        </table>

        <table>
          <thead>
          <tr><th colspan="5">Modified</th>
          </tr>
            <tr>
              <th>Language</th>
              <th>Files</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
            </tr>
          </thead>
          <tbody>
          <xsl:for-each select="diff_results/modified/language">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@files_count"/></td>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
            </tr>
          </xsl:for-each>
          </tbody>
        </table>

        <table>
          <thead>
          <tr><th colspan="5">Added</th>
          </tr>
            <tr>
              <th>Language</th>
              <th>Files</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
            </tr>
          </thead>
          <tbody>
          <xsl:for-each select="diff_results/added/language">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@files_count"/></td>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
            </tr>
          </xsl:for-each>
          </tbody>
        </table>

        <table>
          <thead>
          <tr><th colspan="5">Removed</th>
          </tr>
            <tr>
              <th>Language</th>
              <th>Files</th>
              <th>Blank</th>
              <th>Comment</th>
              <th>Code</th>
            </tr>
          </thead>
          <tbody>
          <xsl:for-each select="diff_results/removed/language">
            <tr>
              <th><xsl:value-of select="@name"/></th>
              <td><xsl:value-of select="@files_count"/></td>
              <td><xsl:value-of select="@blank"/></td>
              <td><xsl:value-of select="@comment"/></td>
              <td><xsl:value-of select="@code"/></td>
            </tr>
          </xsl:for-each>
          </tbody>
        </table>
EO_DIFF_XSL
# 2}}}

    }

    $XSL_DIFF.= <<'EO_DIFF_XSL'; # {{{2
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
EO_DIFF_XSL
# 2}}}
    if ($opt_diff) {
        write_file($CLOC_XSL, {}, ( $XSL_DIFF ) );
    } else {
        write_file($CLOC_XSL, {}, ( $XSL ) );
    }
    print "<- write_xsl_file\n" if $opt_v > 2;
} # 1}}}
sub normalize_file_names {                   # {{{1
    print "-> normalize_file_names\n" if $opt_v > 2;
    my (@files, ) = @_;

    # Returns a hash of file names reduced to a canonical form
    # (fully qualified file names, all path separators changed to /,
    # Windows file names lowercased).  Hash values are the original
    # file name.

    my %normalized = ();
    foreach my $F (@files) {
        my $F_norm = $F;
        if ($ON_WINDOWS) {
            $F_norm = lc $F_norm; # for case insensitive file name comparisons
            $F_norm =~ s{\\}{/}g; # Windows directory separators to Unix
            $F_norm =~ s{^\./}{}g;  # remove leading ./
            if (($F_norm !~ m{^/}) and ($F_norm !~ m{^\w:/})) {
                # looks like a relative path; prefix with cwd
                $F_norm = lc "$cwd/$F_norm";
            }
        } else {
            $F_norm =~ s{^\./}{}g;  # remove leading ./
            if ($F_norm !~ m{^/}) {
                # looks like a relative path; prefix with cwd
                $F_norm = "$cwd/$F_norm";
            }
        }
        # Remove trailing / so it does not interfere with further regex code
        # that does not expect it
        $F_norm =~ s{/+$}{};
        $normalized{ $F_norm } = $F;
    }
    print "<- normalize_file_names\n" if $opt_v > 2;
    return %normalized;
} # 1}}}
sub combine_diffs {                          # {{{1
    # subroutine by Andy (awalshe@sf.net)
    # https://sourceforge.net/tracker/?func=detail&aid=3261017&group_id=174787&atid=870625
    my ($ra_files) = @_;
    print "-> combine_diffs\n" if $opt_v > 2;

    my $res   = "$URL v $VERSION\n";
    my $dl    = '-';
    my $width = 79;
    # columns are in this order
    my @cols  = ('files', 'blank', 'comment', 'code');
    my %HoH   = ();

    foreach my $file (@{$ra_files}) {
        my $IN = open_file('<', $file, 1);
        if (!defined $IN) {
            warn "Unable to read $file; ignoring.\n";
            next;
        }

        my $sec;
        while (<$IN>) {
            chomp;
            s/\cM$//;
            next if /^(http|Language|-----)/;
            if (/^[A-Za-z0-9]+/) {        # section title
                $sec = $_;
                chomp($sec);
                $HoH{$sec} = () if ! exists $HoH{$sec};
                next;
            }

            if (/^\s(same|modified|added|removed)/) {  # calculated totals row
                my @ar = grep { $_ ne '' } split(/ /, $_);
                chomp(@ar);
                my $ttl = shift @ar;
                my $i = 0;
                foreach(@ar) {
                    my $t = "${ttl}${dl}${cols[$i]}";
                    $HoH{$sec}{$t} = 0 if ! exists $HoH{$sec}{$t};
                    $HoH{$sec}{$t} += $_;
                    $i++;
                }
            }
        }
        $IN->close;
    }

    # rows are in this order
    my @rows = ('same', 'modified', 'added', 'removed');

    $res .= sprintf("%s\n", "-" x $width);
    $res .= sprintf("%-19s %14s %14s %14s %14s\n", 'Language',
                    $cols[0], $cols[1], $cols[2], $cols[3]);
    $res .= sprintf("%s\n", "-" x $width);

    # no inputs? %HoH will be empty
    return $res unless %HoH;

    for my $sec ( keys %HoH ) {
        next if $sec =~ /SUM:/;
        next unless defined $HoH{$sec};  # eg, the header line
        $res .= "$sec\n";
        foreach (@rows) {
            $res .= sprintf(" %-18s %14s %14s %14s %14s\n",
                            $_, $HoH{$sec}{"${_}${dl}${cols[0]}"},
                                $HoH{$sec}{"${_}${dl}${cols[1]}"},
                                $HoH{$sec}{"${_}${dl}${cols[2]}"},
                                $HoH{$sec}{"${_}${dl}${cols[3]}"});
        }
    }
    $res .= sprintf("%s\n", "-" x $width);
    my $sec = 'SUM:';
    $res .= "$sec\n";
    foreach (@rows) {
        $res .= sprintf(" %-18s %14s %14s %14s %14s\n",
                        $_, $HoH{$sec}{"${_}${dl}${cols[0]}"},
                            $HoH{$sec}{"${_}${dl}${cols[1]}"},
                            $HoH{$sec}{"${_}${dl}${cols[2]}"},
                            $HoH{$sec}{"${_}${dl}${cols[3]}"});
    }
    $res .= sprintf("%s\n", "-" x $width);

    print "<- combine_diffs\n" if $opt_v > 2;
    return $res;
} # 1}}}
sub combine_csv_diffs {                      # {{{1
    my ($delimiter, $ra_files) = @_;
    print "-> combine_csv_diffs\n" if $opt_v > 2;

    my %sum = ();  # sum{ language } = array of 17 values
    foreach my $file (@{$ra_files}) {
        my $IN = open_file('<', $file, 1);
        if (!defined $IN) {
            warn "Unable to read $file; ignoring.\n";
            next;
        }

        my $sec;
        while (<$IN>) {
            next if /^Language${delimiter}\s==\sfiles${delimiter}/;
            chomp;
            my @words = split(/$delimiter/);
            my $n_col = scalar(@words);
            if ($n_col != 18) {
                warn "combine_csv_diffs(): Parse failure line $. of $file\n";
                warn "Expected 18 columns, got $n_col\n";
                die;
            }
            my $Lang = $words[0];
            my @count = map { int($_) } @words[1..16];
            if (defined $sum{$Lang}) {
                for (my $i = 0; $i < 16; $i++) {
                    $sum{$Lang}[$i] += $count[$i];
                }
            } else {
                @{$sum{$Lang}} = @count;
            }
        }
        $IN->close;
    }

    my @header = ("Language", "== files", "!= files", "+ files", "- files",
                  "== blank", "!= blank", "+ blank", "- blank", "== comment",
                  "!= comment", "+ comment", "- comment", "== code",
                  "!= code", "+ code", "- code", "$URL v $VERSION" );

    my $res = join("$delimiter ", @header) . "$delimiter\n";
    foreach my $Lang (sort keys %sum) {
        $res .= $Lang . "$delimiter ";
        for (my $i = 0; $i < 16; $i++) {
            $res .= $sum{$Lang}[$i] . "$delimiter ";
        }
        $res .= "\n";
    }

    print "<- combine_csv_diffs\n" if $opt_v > 2;
    return $res;
} # 1}}}
sub get_time {                               # {{{1
    if ($HAVE_Time_HiRes) {
        return Time::HiRes::time();
    } else {
        return time();
    }
} # 1}}}
sub really_is_D {                            # {{{1
    # Ref bug 131, files ending with .d could be init.d scripts
    # instead of D language source files.
    my ($file        , # in
        $rh_Err      , # in   hash of error codes
        $raa_errors  , # out
       ) = @_;
    print "-> really_is_D($file)\n" if $opt_v > 2;
    my ($possible_script, $L) = peek_at_first_line($file, $rh_Err, $raa_errors);

    print "<- really_is_D($file)\n" if $opt_v > 2;
    return $possible_script;    # null string if D, otherwise a language
} # 1}}}
sub no_autogen_files {                       # {{{1
    # ref https://github.com/AlDanial/cloc/issues/151
    my ($print,) = @_;
    print "-> no_autogen($print)\n" if $opt_v > 2;

    # These sometimes created manually?
    #               acinclude.m4
    #               configure.ac
    #               Makefile.am

    my @files = qw (
                    aclocal.m4
                    announce-gen
                    autogen.sh
                    bootstrap
                    compile
                    config.guess
                    config.h.in
                    config.rpath
                    config.status
                    config.sub
                    configure
                    configure.in
                    depcomp
                    gendocs.sh
                    gitlog-to-changelog
                    git-version-gen
                    gnupload
                    gnu-web-doc-update
                    install-sh
                    libtool
                    libtool.m4
                    link-warning.h
                    ltmain.sh
                    lt~obsolete.m4
                    ltoptions.m4
                    ltsugar.m4
                    ltversion.in
                    ltversion.m4
                    Makefile.in
                    mdate-sh
                    missing
                    mkinstalldirs
                    test-driver
                    texinfo.tex
                    update-copyright
                    useless-if-before-free
                    vc-list-files
                    ylwrap
                   );

    if ($print) {
        printf "cloc will ignore these %d files with --no-autogen:\n", scalar @files;
        foreach my $F (@files) {
            print "    $F\n";
        }
        print "Additionally, Go files with '// Code generated by .* DO NOT EDIT.'\n";
        print "on the first line are ignored.\n";
    }
    print "<- no_autogen()\n" if $opt_v > 2;
    return @files;
} # 1}}}
sub load_from_config_file {                  # {{{1
    # Supports all options except --config itself which would
    # be pointless.
    my ($config_file,
                                                 $rs_by_file             ,
                                                 $rs_by_file_by_lang     ,
                                                 $rs_categorized         ,
                                                 $rs_counted             ,
                                                 $rs_include_ext         ,
                                                 $rs_include_lang        ,
                                                 $rs_include_content     ,
                                                 $rs_exclude_content     ,
                                                 $rs_exclude_lang        ,
                                                 $rs_exclude_dir         ,
                                                 $rs_exclude_list_file   ,
                                                 $rs_explain             ,
                                                 $rs_extract_with        ,
                                                 $rs_found               ,
                                                 $rs_count_diff          ,
                                                 $rs_diff_list_files     ,
                                                 $rs_diff                ,
                                                 $rs_diff_alignment      ,
                                                 $rs_diff_timeout        ,
                                                 $rs_timeout             ,
                                                 $rs_html                ,
                                                 $rs_ignored             ,
                                                 $rs_quiet               ,
                                                 $rs_force_lang_def      ,
                                                 $rs_read_lang_def       ,
                                                 $rs_show_ext            ,
                                                 $rs_show_lang           ,
                                                 $rs_progress_rate       ,
                                                 $rs_print_filter_stages ,
                                                 $rs_report_file         ,
                                                 $ra_script_lang         ,
                                                 $rs_sdir                ,
                                                 $rs_skip_uniqueness     ,
                                                 $rs_strip_comments      ,
                                                 $rs_original_dir        ,
                                                 $rs_sum_reports         ,
                                                 $rs_hide_rate           ,
                                                 $rs_processes           ,
                                                 $rs_unicode             ,
                                                 $rs_3                   ,
                                                 $rs_v                   ,
                                                 $rs_vcs                 ,
                                                 $rs_version             ,
                                                 $rs_write_lang_def      ,
                                                 $rs_write_lang_def_incl_dup,
                                                 $rs_xml                 ,
                                                 $rs_xsl                 ,
                                                 $ra_force_lang          ,
                                                 $rs_lang_no_ext         ,
                                                 $rs_yaml                ,
                                                 $rs_csv                 ,
                                                 $rs_csv_delimiter       ,
                                                 $rs_json                ,
                                                 $rs_md                  ,
                                                 $rs_fullpath            ,
                                                 $rs_match_f             ,
                                                 $ra_not_match_f         ,
                                                 $rs_match_d             ,
                                                 $ra_not_match_d         ,
                                                 $rs_list_file           ,
                                                 $rs_help                ,
                                                 $rs_skip_win_hidden     ,
                                                 $rs_read_binary_files   ,
                                                 $rs_sql                 ,
                                                 $rs_sql_project         ,
                                                 $rs_sql_append          ,
                                                 $rs_sql_style           ,
                                                 $rs_inline              ,
                                                 $rs_exclude_ext         ,
                                                 $rs_ignore_whitespace   ,
                                                 $rs_ignore_case         ,
                                                 $rs_ignore_case_ext     ,
                                                 $rs_follow_links        ,
                                                 $rs_autoconf            ,
                                                 $rs_sum_one             ,
                                                 $rs_by_percent          ,
                                                 $rs_stdin_name          ,
                                                 $rs_force_on_windows    ,
                                                 $rs_force_on_unix       ,
                                                 $rs_show_os             ,
                                                 $rs_skip_archive        ,
                                                 $rs_max_file_size       ,
                                                 $rs_use_sloccount       ,
                                                 $rs_no_autogen          ,
                                                 $rs_force_git           ,
                                                 $rs_strip_str_comments  ,
                                                 $rs_file_encoding       ,
                                                 $rs_docstring_as_code   ,
                                                 $rs_stat                ,
        ) = @_;
        # look for runtime configuration file in
        #    $ENV{'HOME'}/.config/cloc/options.txt         -> POSIX
        #    $ENV{'APPDATA'} . 'cloc'

    print "-> load_from_config_file($config_file)\n" if $opt_v and $opt_v > 2;
    if (!is_file($config_file)) {
        print "<- load_from_config_file() (no such file: $config_file)\n" if $opt_v and $opt_v > 2;
        return;
    } elsif (!can_read($config_file)) {
        print "<- load_from_config_file() (unable to read $config_file)\n" if $opt_v and $opt_v > 2;
        return;
    }
    print "Reading options from $config_file.\n" if defined $opt_v;

    my $has_force_lang = @{$ra_force_lang};
    my $has_script_lang = @{$ra_script_lang};
    my @lines = read_file($config_file);
    foreach (@lines) {
        next if /^\s*$/ or /^\s*#/;
        s/\s*--//;
        s/^\s+//;
        if      (!defined ${$rs_by_file}             and /^(by_file|by-file)/)                                { ${$rs_by_file}            = 1;
        } elsif (!defined ${$rs_by_file_by_lang}     and /^(by_file_by_lang|by-file-by-lang)/)                { ${$rs_by_file_by_lang}    = 1;
        } elsif (!defined ${$rs_categorized}         and /^categorized(=|\s+)(.*?)$/)                         { ${$rs_categorized}        = $2;
        } elsif (!defined ${$rs_counted}             and /^counted(=|\s+)(.*?)$/)                             { ${$rs_counted}            = $2;
        } elsif (!defined ${$rs_include_ext}         and /^(?:include_ext|include-ext)(=|\s+)(.*?)$/)         { ${$rs_include_ext}        = $2;
        } elsif (!defined ${$rs_include_lang}        and /^(?:include_lang|include-lang)(=|\s+)(.*?)$/)       { ${$rs_include_lang}       = $2;
        } elsif (!defined ${$rs_include_content}     and /^(?:include_content|include-content)(=|\s+)(.*?)$/) { ${$rs_include_content}    = $2;
        } elsif (!defined ${$rs_exclude_content}     and /^(?:exclude_content|exclude-content)(=|\s+)(.*?)$/) { ${$rs_exclude_content}    = $2;
        } elsif (!defined ${$rs_exclude_lang}        and /^(?:exclude_lang|exclude-lang)(=|\s+)(.*?)$/)       { ${$rs_exclude_lang}       = $2;
        } elsif (!defined ${$rs_exclude_dir}         and /^(?:exclude_dir|exclude-dir)(=|\s+)(.*?)$/)         { ${$rs_exclude_dir}        = $2;
        } elsif (!defined ${$rs_explain}             and /^explain(=|\s+)(.*?)$/)                             { ${$rs_explain}            = $2;
        } elsif (!defined ${$rs_extract_with}        and /^(?:extract_with|extract-with)(=|\s+)(.*?)$/)       { ${$rs_extract_with}       = $2;
        } elsif (!defined ${$rs_found}               and /^found(=|\s+)(.*?)$/)                               { ${$rs_found}              = $2;
        } elsif (!defined ${$rs_count_diff}          and /^(count_and_diff|count-and-diff)/)                  { ${$rs_count_diff}         = 1;
        } elsif (!defined ${$rs_diff_list_files}     and /^(diff_list_files|diff-list-files)/)                { ${$rs_diff_list_files}    = 1;
        } elsif (!defined ${$rs_diff}                and /^diff/)                                             { ${$rs_diff}               = 1;
        } elsif (!defined ${$rs_diff_alignment}      and /^(?:diff-alignment|diff_alignment)(=|\s+)(.*?)$/)   { ${$rs_diff_alignment}     = $2;
        } elsif (!defined ${$rs_diff_timeout}        and /^(?:diff-timeout|diff_timeout)(=|\s+)i/)            { ${$rs_diff_timeout}       = $1;
        } elsif (!defined ${$rs_timeout}             and /^timeout(=|\s+)i/)                                  { ${$rs_timeout}            = $1;
        } elsif (!defined ${$rs_html}                and /^html/)                                             { ${$rs_html}               = 1;
        } elsif (!defined ${$rs_ignored}             and /^ignored(=|\s+)(.*?)$/)                             { ${$rs_ignored}            = $2;
        } elsif (!defined ${$rs_quiet}               and /^quiet/)                                            { ${$rs_quiet}              = 1;
        } elsif (!defined ${$rs_force_lang_def}      and /^(?:force_lang_def|force-lang-def)(=|\s+)(.*?)$/)   { ${$rs_force_lang_def}     = $2;
        } elsif (!defined ${$rs_read_lang_def}       and /^(?:read_lang_def|read-lang-def)(=|\s+)(.*?)$/)     { ${$rs_read_lang_def}      = $2;
        } elsif (!defined ${$rs_progress_rate}       and /^(?:progress_rate|progress-rate)(=|\s+)(\d+)/)      { ${$rs_progress_rate}      = $2;
        } elsif (!defined ${$rs_print_filter_stages} and /^(print_filter_stages|print-filter-stages)/)        { ${$rs_print_filter_stages}= 1;
        } elsif (!defined ${$rs_report_file}         and /^(?:report_file|report-file)(=|\s+)(.*?)$/)         { ${$rs_report_file}        = $2;
        } elsif (!defined ${$rs_report_file}         and /^out(=|\s+)(.*?)$/)                                 { ${$rs_report_file}        = $2;
        } elsif (!defined ${$rs_sdir}                and /^sdir(=|\s+)(.*?)$/)                                { ${$rs_sdir}               = $2;
        } elsif (!defined ${$rs_skip_uniqueness}     and /^(skip_uniqueness|skip-uniqueness)/)                { ${$rs_skip_uniqueness}    = 1;
        } elsif (!defined ${$rs_strip_comments}      and /^(?:strip_comments|strip-comments)(=|\s+)(.*?)$/)   { ${$rs_strip_comments}     = $2;
        } elsif (!defined ${$rs_original_dir}        and /^(original_dir|original-dir)/)                      { ${$rs_original_dir}       = 1;
        } elsif (!defined ${$rs_sum_reports}         and /^(sum_reports|sum-reports)/)                        { ${$rs_sum_reports}        = 1;
        } elsif (!defined ${$rs_hide_rate}           and /^(hid_rate|hide-rate)/)                             { ${$rs_hide_rate}          = 1;
        } elsif (!defined ${$rs_processes}           and /^processes(=|\s+)(\d+)/)                            { ${$rs_processes}          = $2;
        } elsif (!defined ${$rs_unicode}             and /^unicode/)                                          { ${$rs_unicode}            = 1;
        } elsif (!defined ${$rs_3}                   and /^3/)                                                { ${$rs_3}                  = 1;
        } elsif (!defined ${$rs_vcs}                 and /^vcs(=|\s+)(\S+)/)                                  { ${$rs_vcs}                = $2;
        } elsif (!defined ${$rs_version}             and /^version/)                                          { ${$rs_version}            = 1;
        } elsif (!defined ${$rs_write_lang_def}      and /^(?:write_lang_def|write-lang-def)(=|\s+)(.*?)$/)   { ${$rs_write_lang_def}     = $2;
        } elsif (!defined ${$rs_write_lang_def_incl_dup} and /^(?:write_lang_def_incl_dup|write-lang-def-incl-dup)(=|\s+)(.*?)$/) { ${$rs_write_lang_def_incl_dup} = $2;
        } elsif (!defined ${$rs_xml}                 and /^xml/)                                              { ${$rs_xml}                = 1;
        } elsif (!defined ${$rs_xsl}                 and /^xsl(=|\s+)(.*?)$/)                                 { ${$rs_xsl}                = $2;
        } elsif (!defined ${$rs_lang_no_ext}         and /^(?:lang_no_ext|lang-no-ext)(=|\s+)(.*?)$/)         { ${$rs_lang_no_ext}        = $2;
        } elsif (!defined ${$rs_yaml}                and /^yaml/)                                             { ${$rs_yaml}               = 1;
        } elsif (!defined ${$rs_csv}                 and /^csv/)                                              { ${$rs_csv}                = 1;
        } elsif (!defined ${$rs_csv_delimiter}       and /^(?:csv_delimiter|csv-delimiter)(=|\s+)(.*?)$/)     { ${$rs_csv_delimiter}      = $2;
        } elsif (!defined ${$rs_json}                and /^json/)                                             { ${$rs_json}               = 1;
        } elsif (!defined ${$rs_md}                  and /^md/)                                               { ${$rs_md}                 = 1;
        } elsif (!defined ${$rs_fullpath}            and /^fullpath/)                                         { ${$rs_fullpath}           = 1;
        } elsif (!defined ${$rs_match_f}             and /^(?:match_f|match-f)(=|\s+)(.*?)$/)                 { ${$rs_match_f}            = $2;
        } elsif (!        @{$ra_not_match_f}         and /^(?:not_match_f|not-match-f)(=|\s+)(.*?)$/)         { push @{$ra_not_match_f}   , $2;
        } elsif (!defined ${$rs_match_d}             and /^(?:match_d|match-d)(=|\s+)(.*?)$/)                 { ${$rs_match_d}            = $2;
        } elsif (!        @{$ra_not_match_d}         and /^(?:not_match_d|not-match-d)(=|\s+)(.*?)$/)         { push @{$ra_not_match_d}   , $2;
        } elsif (!defined ${$rs_list_file}           and /^(?:list_file|list-file)(=|\s+)(.*?)$/)             { ${$rs_list_file}          = $2;
        } elsif (!defined ${$rs_help}                and /^help/)                                             { ${$rs_help}               = 1;
        } elsif (!defined ${$rs_skip_win_hidden}     and /^(skip_win_hidden|skip-win-hidden)/)                { ${$rs_skip_win_hidden}    = 1;
        } elsif (!defined ${$rs_read_binary_files}   and /^(read_binary_files|read-binary-files)/)            { ${$rs_read_binary_files}  = 1;
        } elsif (!defined ${$rs_sql}                 and /^sql(=|\s+)(.*?)$/)                                 { ${$rs_sql}                = $2;
        } elsif (!defined ${$rs_sql_project}         and /^(?:sql_project|sql-project)(=|\s+)(.*?)$/)         { ${$rs_sql_project}        = $2;
        } elsif (!defined ${$rs_sql_append}          and /^(sql_append|sql-append)/)                          { ${$rs_sql_append}         = 1;
        } elsif (!defined ${$rs_sql_style}           and /^(?:sql_style|sql-style)(=|\s+)(.*?)$/)             { ${$rs_sql_style}          = $2;
        } elsif (!defined ${$rs_inline}              and /^inline/)                                           { ${$rs_inline}             = 1;
        } elsif (!defined ${$rs_exclude_ext}         and /^(?:exclude_ext|exclude-ext)(=|\s+)(.*?)$/)         { ${$rs_exclude_ext}        = $2;
        } elsif (!defined ${$rs_ignore_whitespace}   and /^(ignore_whitespace|ignore-whitespace)/)            { ${$rs_ignore_whitespace}  = 1;
        } elsif (!defined ${$rs_ignore_case_ext}     and /^(ignore_case_ext|ignore-case-ext)/)                { ${$rs_ignore_case_ext}    = 1;
        } elsif (!defined ${$rs_ignore_case}         and /^(ignore_case|ignore-case)/)                        { ${$rs_ignore_case}        = 1;
        } elsif (!defined ${$rs_follow_links}        and /^(follow_links|follow-links)/)                      { ${$rs_follow_links}       = 1;
        } elsif (!defined ${$rs_autoconf}            and /^autoconf/)                                         { ${$rs_autoconf}           = 1;
        } elsif (!defined ${$rs_sum_one}             and /^(sum_one|sum-one)/)                                { ${$rs_sum_one}            = 1;
        } elsif (!defined ${$rs_by_percent}          and /^(?:by_percent|by-percent)(=|\s+)(.*?)$/)           { ${$rs_by_percent}         = $2;
        } elsif (!defined ${$rs_stdin_name}          and /^(?:stdin_name|stdin-name)(=|\s+)(.*?)$/)           { ${$rs_stdin_name}         = $2;
        } elsif (!defined ${$rs_force_on_windows}    and /^windows/)                                          { ${$rs_force_on_windows}   = 1;
        } elsif (!defined ${$rs_force_on_unix}       and /^unix/)                                             { ${$rs_force_on_unix}      = 1;
        } elsif (!defined ${$rs_show_os}             and /^(show_os|show-os)/)                                { ${$rs_show_os}            = 1;
        } elsif (!defined ${$rs_skip_archive}        and /^(?:skip_archive|skip-archive)(=|\s+)(.*?)$/)       { ${$rs_skip_archive}       = $2;
        } elsif (!defined ${$rs_max_file_size}       and /^(?:max_file_size|max-file-size)(=|\s+)(\d+)/)      { ${$rs_max_file_size}      = $2;
        } elsif (!defined ${$rs_use_sloccount}       and /^(use_sloccount|use-sloccount)/)                    { ${$rs_use_sloccount}      = 1;
        } elsif (!defined ${$rs_no_autogen}          and /^(no_autogen|no-autogen)/)                          { ${$rs_no_autogen}         = 1;
        } elsif (!defined ${$rs_force_git}           and /^git/)                                              { ${$rs_force_git}          = 1;
        } elsif (!defined ${$rs_exclude_list_file}   and /^(?:exclude_list_file|exclude-list-file)(=|\s+)(.*?)$/)
                                                                   { ${$rs_exclude_list_file}  = $2;
        } elsif (!defined ${$rs_v} and /^(verbose|v)((=|\s+)(\d+))?/) {
            if (!defined $4) { ${$rs_v} =  0; }
            else             { ${$rs_v} = $4; }
        } elsif (!$has_script_lang and /^(?:script_lang|script-lang)(=|\s+)(.*?)$/)         {
                                                            push @{$ra_script_lang}          , $2;
        } elsif (!$has_force_lang and /^(?:force_lang|force-lang)(=|\s+)(.*?)$/)           {
                                                            push @{$ra_force_lang}           , $2;
        } elsif (!defined ${$rs_show_ext}          and /^(show_ext|show-ext)((=|\s+)(.*))?$/)  {
            if (!defined $4) { ${$rs_show_ext} =  0; }
            else             { ${$rs_show_ext} = $4; }
        } elsif (!defined ${$rs_show_lang}         and /^(show_lang|show-lang)((=|\s+)(.*))?s/){
            if (!defined $4) { ${$rs_show_lang} =  0; }
            else             { ${$rs_show_lang} = $4; }
        } elsif (!defined ${$rs_strip_str_comments}  and /^(strip_str_comments|strip-str-comments)/)     { ${$rs_strip_str_comments} = 1;
        } elsif (!defined ${$rs_file_encoding}       and /^(?:file_encoding|file-encoding)(=|\s+)(\S+)/) { ${$rs_file_encoding}      = $2;
        } elsif (!defined ${$rs_docstring_as_code}   and /^(docstring_as_code|docstring-as-code)/)       { ${$rs_docstring_as_code}  = 1;
        } elsif (!defined ${$rs_stat}                and /stat/)                                         { ${$rs_stat}               = 1;
        }

    }
} # 1}}}
sub trick_pp_packer_encode {                 # {{{1
    use Encode;
    # PAR::Packer gives 'Unknown PerlIO layer "encoding"' unless it is
    # forced into using this module.
    my ($OUT, $JunkFile) = tempfile(UNLINK => 1);  # delete on exit
    open($OUT, "> :encoding(utf8)", $JunkFile);
    close($OUT);
}
# 1}}}
sub really_is_smarty {                       # {{{1
    # Given filename, returns TRUE if its contents look like Smarty template
    my ($filename, ) = @_;

    print "-> really_is_smarty($filename)\n" if $opt_v > 2;

    my @lines = read_file($filename);

    my $points = 0;
    foreach my $L (@lines) {
        if (($L =~ /\{(if|include)\s/) or
            ($L =~ /\{\/if\}/)         or
            ($L =~ /(\{\*|\*\})/)      or
            ($L =~ /\{\$\w/)) {
            ++$points;
        }
        last if $points >= 2;
    }
    print "<- really_is_smarty(points=$points)\n" if $opt_v > 2;
    return $points >= 2;
} # 1}}}
sub check_alternate_config_files {           # {{{1
    my ($list_file, $exclude_list_file, $read_lang_def,
        $force_lang_def, $diff_list_file, ) = @_;
    my $found_it = "";
    foreach my $file ($list_file,
                      $exclude_list_file,
                      $read_lang_def,
                      $force_lang_def,
                      $diff_list_file ) {
        next unless defined $file;
        my $dir = dirname $file;
        next unless can_read($dir) and is_dir($dir);
        my $bn = basename $config_file;
        if (can_read("$dir/$bn")) {
            $found_it = "$dir/$bn";
            print "Using configuration file $found_it\n" if $opt_v;
            last;
        }
    }
    return $found_it;
}
# 1}}}
sub write_null_results {                     # {{{
    my ($json, $xml, $report_file,) = @_;
    print "-> write_null_results\n" if $opt_v > 2;
    if ((defined $json) or (defined $xml)) {
        my $line = "";
        if (defined $json) {
            $line = "{}";
        } else {
            $line = '<?xml version="1.0" encoding="UTF-8"?><results/>';
        }
        if (defined $report_file) {
            open OUT, ">$report_file" or die "Cannot write to $report_file $!\n";
            print OUT "$line\n";
            close OUT;
        } else {
            print "$line\n";
        }
    }
    print "<- write_null_results\n" if $opt_v > 2;
} # }}}
sub glob2regex {                             # {{{
    # convert simple xpath-style glob pattern to a regex
    my $globstr = shift;
    my $re = $globstr;
    $re =~ s{^["']}{};
    $re =~ s{^\.\/}{};
    $re =~ s{["']$}{};
    $re =~ s{\.}{\\.}g;
    $re =~ s{\*\*}{\cx}g;  # ctrl x  = .*?
    $re =~ s{\*}{\cy}g;    # ctrl y = [^/]*
    $re =~ s{\cx}{.*?}g;
    $re =~ s{\cy}{[^/]*}g;
    return '^' . $re . '$';
} # }}}
# really_is_pascal, really_is_incpascal, really_is_php from SLOCCount
my %php_files    = ();  # really_is_php()
sub really_is_pascal {                       # {{{1
# Given filename, returns TRUE if its contents really are Pascal.

# This isn't as obvious as it seems.
# Many ".p" files are Perl files
# (such as /usr/src/redhat/BUILD/ispell-3.1/dicts/czech/glob.p),
# others are C extractions
# (such as /usr/src/redhat/BUILD/linux/include/linux/umsdos_fs.p
# and some files in linuxconf).
# However, test files in "p2c" really are Pascal, for example.

# Note that /usr/src/redhat/BUILD/ucd-snmp-4.1.1/ov/bitmaps/UCD.20.p
# is actually C code.  The heuristics determine that they're not Pascal,
# but because it ends in ".p" it's not counted as C code either.
# I believe this is actually correct behavior, because frankly it
# looks like it's automatically generated (it's a bitmap expressed as code).
# Rather than guess otherwise, we don't include it in a list of
# source files.  Let's face it, someone who creates C files ending in ".p"
# and expects them to be counted by default as C files in SLOCCount needs
# their head examined.  I suggest examining their head
# with a sucker rod (see syslogd(8) for more on sucker rods).

# This heuristic counts as Pascal such files such as:
#  /usr/src/redhat/BUILD/teTeX-1.0/texk/web2c/tangleboot.p
# Which is hand-generated.  We don't count woven documents now anyway,
# so this is justifiable.

 my $filename = shift;
 chomp($filename);

# The heuristic is as follows: it's Pascal _IF_ it has all of the following
# (ignoring {...} and (*...*) comments):
# 1. "^..program NAME" or "^..unit NAME",
# 2. "procedure", "function", "^..interface", or "^..implementation",
# 3. a "begin", and
# 4. it ends with "end.",
#
# Or it has all of the following:
# 1. "^..module NAME" and
# 2. it ends with "end.".
#
# Or it has all of the following:
# 1. "^..program NAME",
# 2. a "begin", and
# 3. it ends with "end.".
#
# The "end." requirements in particular filter out non-Pascal.
#
# Note (jgb): this does not detect Pascal main files in fpc, like
# fpc-1.0.4/api/test/testterminfo.pas, which does not have "program" in
# it

 my $is_pascal = 0;      # Value to determine.

 my $has_program = 0;
 my $has_unit = 0;
 my $has_module = 0;
 my $has_procedure_or_function = 0;
 my $found_begin = 0;
 my $found_terminating_end = 0;
 my $has_begin = 0;

 my $PASCAL_FILE = open_file('<', $filename, 0);
 die "Can't open $filename to determine if it's pascal.\n" if !defined $PASCAL_FILE;
 while(<$PASCAL_FILE>) {
   s/\{.*?\}//g;  # Ignore {...} comments on this line; imperfect, but effective.
   s/\(\*.*?\*\)//g;  # Ignore (*...*) comments on this line; imperfect, but effective.
   if (m/\bprogram\s+[A-Za-z]/i)  {$has_program=1;}
   if (m/\bunit\s+[A-Za-z]/i)     {$has_unit=1;}
   if (m/\bmodule\s+[A-Za-z]/i)   {$has_module=1;}
   if (m/\bprocedure\b/i)         { $has_procedure_or_function = 1; }
   if (m/\bfunction\b/i)          { $has_procedure_or_function = 1; }
   if (m/^\s*interface\s+/i)      { $has_procedure_or_function = 1; }
   if (m/^\s*implementation\s+/i) { $has_procedure_or_function = 1; }
   if (m/\bbegin\b/i) { $has_begin = 1; }
   # Originally I said:
   # "This heuristic fails if there are multi-line comments after
   # "end."; I haven't seen that in real Pascal programs:"
   # But jgb found there are a good quantity of them in Debian, specially in
   # fpc (at the end of a lot of files there is a multiline comment
   # with the changelog for the file).
   # Therefore, assume Pascal if "end." appears anywhere in the file.
   if (m/end\.\s*$/i) {$found_terminating_end = 1;}
#   elsif (m/\S/) {$found_terminating_end = 0;}
 }
 close($PASCAL_FILE);

 # Okay, we've examined the entire file looking for clues;
 # let's use those clues to determine if it's really Pascal:

 if ( ( ($has_unit || $has_program) && $has_procedure_or_function &&
     $has_begin && $found_terminating_end ) ||
      ( $has_module && $found_terminating_end ) ||
      ( $has_program && $has_begin && $found_terminating_end ) )
          {$is_pascal = 1;}

 return $is_pascal;
} # 1}}}
sub really_is_incpascal {                    # {{{1
# Given filename, returns TRUE if its contents really are Pascal.
# For .inc files (mainly seen in fpc)

 my $filename = shift;
 chomp($filename);

# The heuristic is as follows: it is Pascal if any of the following:
# 1. really_is_pascal returns true
# 2. Any usual reserved word is found (program, unit, const, begin...)

 # If the general routine for Pascal files works, we have it
 if (really_is_pascal($filename)) {
   return 1;
 }

 my $is_pascal = 0;      # Value to determine.
 my $found_begin = 0;

 my $PASCAL_FILE = open_file('<', $filename, 0);
 die "Can't open $filename to determine if it's pascal.\n" if !defined $PASCAL_FILE;
 while(<$PASCAL_FILE>) {
   s/\{.*?\}//g;  # Ignore {...} comments on this line; imperfect, but effective.
   s/\(\*.*?\*\)//g;  # Ignore (*...*) comments on this line; imperfect, but effective.
   if (m/\bprogram\s+[A-Za-z]/i)  {$is_pascal=1;}
   if (m/\bunit\s+[A-Za-z]/i)     {$is_pascal=1;}
   if (m/\bmodule\s+[A-Za-z]/i)   {$is_pascal=1;}
   if (m/\bprocedure\b/i)         {$is_pascal = 1; }
   if (m/\bfunction\b/i)          {$is_pascal = 1; }
   if (m/^\s*interface\s+/i)      {$is_pascal = 1; }
   if (m/^\s*implementation\s+/i) {$is_pascal = 1; }
   if (m/\bconstant\s+/i)         {$is_pascal=1;}
   if (m/\bbegin\b/i) { $found_begin = 1; }
   if ((m/end\.\s*$/i) && ($found_begin = 1)) {$is_pascal = 1;}
   if ($is_pascal) {
     last;
   }
 }

 close($PASCAL_FILE);
 return $is_pascal;
} # 1}}}
sub really_is_php {                          # {{{1
# Given filename, returns TRUE if its contents really is php.

 my $filename = shift;
 chomp($filename);

 my $is_php = 0;      # Value to determine.
 # Need to find a matching pair of surrounds, with ending after beginning:
 my $normal_surround = 0;  # <?; bit 0 = <?, bit 1 = ?>
 my $script_surround = 0;  # <script..>; bit 0 = <script language="php">
 my $asp_surround = 0;     # <%; bit 0 = <%, bit 1 = %>

 # Return cached result, if available:
 if ($php_files{$filename}) { return $php_files{$filename};}

 my $PHP_FILE = open_file('<', $filename, 0);
 die "Can't open $filename to determine if it's php.\n" if !defined $PHP_FILE;
 while(<$PHP_FILE>) {
   if (m/\<\?/)                           { $normal_surround |= 1; }
   if (m/\?\>/ && ($normal_surround & 1)) { $normal_surround |= 2; }
   if (m/\<script.*language="?php"?/i)    { $script_surround |= 1; }
   if (m/\<\/script\>/i && ($script_surround & 1)) { $script_surround |= 2; }
   if (m/\<\%/)                           { $asp_surround |= 1; }
   if (m/\%\>/ && ($asp_surround & 1)) { $asp_surround |= 2; }
 }
 close($PHP_FILE);

 if ( ($normal_surround == 3) || ($script_surround == 3) ||
      ($asp_surround == 3)) {
   $is_php = 1;
 }

 $php_files{$filename} = $is_php; # Store result in cache.

 return $is_php;
} # 1}}}
# vendored modules
sub Install_Regexp_Common {                  # {{{1
    # Installs portions of Damian Conway's & Abigail's Regexp::Common
    # module, version 2017060201 into a temporary directory for the
    # duration of this run.
    my %Regexp_Common_Contents = ();
$Regexp_Common_Contents{'Common'} = <<'EOCommon'; # {{{2
package Regexp::Common;

use 5.10.0;
use strict;

use warnings;
no  warnings 'syntax';

our $VERSION = '2017060201';
our %RE;
our %sub_interface;
our $AUTOLOAD;


sub _croak {
    require Carp;
    goto &Carp::croak;
}

sub _carp {
    require Carp;
    goto &Carp::carp;
}

sub new {
    my ($class, @data) = @_;
    my %self;
    tie %self, $class, @data;
    return \%self;
}

sub TIEHASH {
    my ($class, @data) = @_;
    bless \@data, $class;
}

sub FETCH {
    my ($self, $extra) = @_;
    return bless ref($self)->new(@$self, $extra), ref($self);
}

my %imports = map {$_ => "Regexp::Common::$_"}
              qw /balanced CC     comment   delimited lingua list
                  net      number profanity SEN       URI    whitespace
                  zip/;

sub import {
    shift;  # Shift off the class.
    tie %RE, __PACKAGE__;
    {
        no strict 'refs';
        *{caller() . "::RE"} = \%RE;
    }

    my $saw_import;
    my $no_defaults;
    my %exclude;
    foreach my $entry (grep {!/^RE_/} @_) {
        if ($entry eq 'pattern') {
            no strict 'refs';
            *{caller() . "::pattern"} = \&pattern;
            next;
        }
        # This used to prevent $; from being set. We still recognize it,
        # but we won't do anything.
        if ($entry eq 'clean') {
            next;
        }
        if ($entry eq 'no_defaults') {
            $no_defaults ++;
            next;
        }
        if (my $module = $imports {$entry}) {
            $saw_import ++;
            eval "require $module;";
            die $@ if $@;
            next;
        }
        if ($entry =~ /^!(.*)/ && $imports {$1}) {
            $exclude {$1} ++;
            next;
        }
        # As a last resort, try to load the argument.
        my $module = $entry =~ /^Regexp::Common/
                            ? $entry
                            : "Regexp::Common::" . $entry;
        eval "require $module;";
        die $@ if $@;
    }

    unless ($saw_import || $no_defaults) {
        foreach my $module (values %imports) {
            next if $exclude {$module};
            eval "require $module;";
            die $@ if $@;
        }
    }

    my %exported;
    foreach my $entry (grep {/^RE_/} @_) {
        if ($entry =~ /^RE_(\w+_)?ALL$/) {
            my $m  = defined $1 ? $1 : "";
            my $re = qr /^RE_${m}.*$/;
            while (my ($sub, $interface) = each %sub_interface) {
                next if $exported {$sub};
                next unless $sub =~ /$re/;
                {
                    no strict 'refs';
                    *{caller() . "::$sub"} = $interface;
                }
                $exported {$sub} ++;
            }
        }
        else {
            next if $exported {$entry};
            _croak "Can't export unknown subroutine &$entry"
                unless $sub_interface {$entry};
            {
                no strict 'refs';
                *{caller() . "::$entry"} = $sub_interface {$entry};
            }
            $exported {$entry} ++;
        }
    }
}

sub AUTOLOAD { _croak "Can't $AUTOLOAD" }

sub DESTROY {}

my %cache;

my $fpat = qr/^(-\w+)/;

sub _decache {
        my @args = @{tied %{$_[0]}};
        my @nonflags = grep {!/$fpat/} @args;
        my $cache = get_cache(@nonflags);
        _croak "Can't create unknown regex: \$RE{"
            . join("}{",@args) . "}"
                unless exists $cache->{__VAL__};
        _croak "Perl $] does not support the pattern "
            . "\$RE{" . join("}{",@args)
            . "}.\nYou need Perl $cache->{__VAL__}{version} or later"
                unless ($cache->{__VAL__}{version}||0) <= $];
        my %flags = ( %{$cache->{__VAL__}{default}},
                      map { /$fpat\Q$;\E(.*)/ ? ($1 => $2)
                          : /$fpat/           ? ($1 => undef)
                          :                     ()
                          } @args);
        $cache->{__VAL__}->_clone_with(\@args, \%flags);
}

use overload q{""} => \&_decache;


sub get_cache {
        my $cache = \%cache;
        foreach (@_) {
                $cache = $cache->{$_}
                      || ($cache->{$_} = {});
        }
        return $cache;
}

sub croak_version {
        my ($entry, @args) = @_;
}

sub pattern {
        my %spec = @_;
        _croak 'pattern() requires argument: name => [ @list ]'
                unless $spec{name} && ref $spec{name} eq 'ARRAY';
        _croak 'pattern() requires argument: create => $sub_ref_or_string'
                unless $spec{create};

        if (ref $spec{create} ne "CODE") {
                my $fixed_str = "$spec{create}";
                $spec{create} = sub { $fixed_str }
        }

        my @nonflags;
        my %default;
        foreach ( @{$spec{name}} ) {
                if (/$fpat=(.*)/) {
                        $default{$1} = $2;
                }
                elsif (/$fpat\s*$/) {
                        $default{$1} = undef;
                }
                else {
                        push @nonflags, $_;
                }
        }

        my $entry = get_cache(@nonflags);

        if ($entry->{__VAL__}) {
                _carp "Overriding \$RE{"
                   . join("}{",@nonflags)
                   . "}";
        }

        $entry->{__VAL__} = bless {
                                create  => $spec{create},
                                match   => $spec{match} || \&generic_match,
                                subs    => $spec{subs}  || \&generic_subs,
                                version => $spec{version},
                                default => \%default,
                            }, 'Regexp::Common::Entry';

        foreach (@nonflags) {s/\W/X/g}
        my $subname = "RE_" . join ("_", @nonflags);
        $sub_interface{$subname} = sub {
                push @_ => undef if @_ % 2;
                my %flags = @_;
                my $pat = $spec{create}->($entry->{__VAL__},
                               {%default, %flags}, \@nonflags);
                if (exists $flags{-keep}) { $pat =~ s/\Q(?k:/(/g; }
                else { $pat =~ s/\Q(?k:/(?:/g; }
                return exists $flags {-i} ? qr /(?i:$pat)/ : qr/$pat/;
        };

        return 1;
}

sub generic_match {$_ [1] =~  /$_[0]/}
sub generic_subs  {$_ [1] =~ s/$_[0]/$_[2]/}

sub matches {
        my ($self, $str) = @_;
        my $entry = $self -> _decache;
        $entry -> {match} -> ($entry, $str);
}

sub subs {
        my ($self, $str, $newstr) = @_;
        my $entry = $self -> _decache;
        $entry -> {subs} -> ($entry, $str, $newstr);
        return $str;
}


package Regexp::Common::Entry;
# use Carp;

use overload
    q{""} => sub {
        my ($self) = @_;
        my $pat = $self->{create}->($self, $self->{flags}, $self->{args});
        if (exists $self->{flags}{-keep}) {
            $pat =~ s/\Q(?k:/(/g;
        }
        else {
            $pat =~ s/\Q(?k:/(?:/g;
        }
        if (exists $self->{flags}{-i})   { $pat = "(?i)$pat" }
        return $pat;
    };

sub _clone_with {
    my ($self, $args, $flags) = @_;
    bless { %$self, args=>$args, flags=>$flags }, ref $self;
}

1;

__END__

=pod

=head1 NAME

Regexp::Common - Provide commonly requested regular expressions

=head1 SYNOPSIS

 # STANDARD USAGE

 use Regexp::Common;

 while (<>) {
     /$RE{num}{real}/               and print q{a number};
     /$RE{quoted}/                  and print q{a ['"`] quoted string};
    m[$RE{delimited}{-delim=>'/'}]  and print q{a /.../ sequence};
     /$RE{balanced}{-parens=>'()'}/ and print q{balanced parentheses};
     /$RE{profanity}/               and print q{a #*@%-ing word};
 }


 # SUBROUTINE-BASED INTERFACE

 use Regexp::Common 'RE_ALL';

 while (<>) {
     $_ =~ RE_num_real()              and print q{a number};
     $_ =~ RE_quoted()                and print q{a ['"`] quoted string};
     $_ =~ RE_delimited(-delim=>'/')  and print q{a /.../ sequence};
     $_ =~ RE_balanced(-parens=>'()'} and print q{balanced parentheses};
     $_ =~ RE_profanity()             and print q{a #*@%-ing word};
 }


 # IN-LINE MATCHING...

 if ( $RE{num}{int}->matches($text) ) {...}


 # ...AND SUBSTITUTION

 my $cropped = $RE{ws}{crop}->subs($uncropped);


 # ROLL-YOUR-OWN PATTERNS

 use Regexp::Common 'pattern';

 pattern name   => ['name', 'mine'],
         create => '(?i:J[.]?\s+A[.]?\s+Perl-Hacker)',
         ;

 my $name_matcher = $RE{name}{mine};

 pattern name    => [ 'lineof', '-char=_' ],
         create  => sub {
                        my $flags = shift;
                        my $char = quotemeta $flags->{-char};
                        return '(?:^$char+$)';
                    },
         match   => sub {
                        my ($self, $str) = @_;
                        return $str !~ /[^$self->{flags}{-char}]/;
                    },
         subs   => sub {
                        my ($self, $str, $replacement) = @_;
                        $_[1] =~ s/^$self->{flags}{-char}+$//g;
                   },
         ;

 my $asterisks = $RE{lineof}{-char=>'*'};

 # DECIDING WHICH PATTERNS TO LOAD.

 use Regexp::Common qw /comment number/;  # Comment and number patterns.
 use Regexp::Common qw /no_defaults/;     # Don't load any patterns.
 use Regexp::Common qw /!delimited/;      # All, but delimited patterns.


=head1 DESCRIPTION

By default, this module exports a single hash (C<%RE>) that stores or generates
commonly needed regular expressions (see L<"List of available patterns">).

There is an alternative, subroutine-based syntax described in
L<"Subroutine-based interface">.


=head2 General syntax for requesting patterns

To access a particular pattern, C<%RE> is treated as a hierarchical hash of
hashes (of hashes...), with each successive key being an identifier. For
example, to access the pattern that matches real numbers, you
specify:

        $RE{num}{real}

and to access the pattern that matches integers:

        $RE{num}{int}

Deeper layers of the hash are used to specify I<flags>: arguments that
modify the resulting pattern in some way. The keys used to access these
layers are prefixed with a minus sign and may have a value; if a value
is given, it's done by using a multidimensional key.
For example, to access the pattern that
matches base-2 real numbers with embedded commas separating
groups of three digits (e.g. 10,101,110.110101101):

        $RE{num}{real}{-base => 2}{-sep => ','}{-group => 3}

Through the magic of Perl, these flag layers may be specified in any order
(and even interspersed through the identifier keys!)
so you could get the same pattern with:

        $RE{num}{real}{-sep => ','}{-group => 3}{-base => 2}

or:

        $RE{num}{-base => 2}{real}{-group => 3}{-sep => ','}

or even:

        $RE{-base => 2}{-group => 3}{-sep => ','}{num}{real}

etc.

Note, however, that the relative order of amongst the identifier keys
I<is> significant. That is:

        $RE{list}{set}

would not be the same as:

        $RE{set}{list}

=head2 Flag syntax

In versions prior to 2.113, flags could also be written as
C<{"-flag=value"}>. This no longer works, although C<{"-flag$;value"}>
still does. However, C<< {-flag => 'value'} >> is the preferred syntax.

=head2 Universal flags

Normally, flags are specific to a single pattern.
However, there is two flags that all patterns may specify.

=over 4

=item C<-keep>

By default, the patterns provided by C<%RE> contain no capturing
parentheses. However, if the C<-keep> flag is specified (it requires
no value) then any significant substrings that the pattern matches
are captured. For example:

        if ($str =~ $RE{num}{real}{-keep}) {
                $number   = $1;
                $whole    = $3;
                $decimals = $5;
        }

Special care is needed if a "kept" pattern is interpolated into a
larger regular expression, as the presence of other capturing
parentheses is likely to change the "number variables" into which significant
substrings are saved.

See also L<"Adding new regular expressions">, which describes how to create
new patterns with "optional" capturing brackets that respond to C<-keep>.

=item C<-i>

Some patterns or subpatterns only match lowercase or uppercase letters.
If one wants the do case insensitive matching, one option is to use
the C</i> regexp modifier, or the special sequence C<(?i)>. But if the
functional interface is used, one does not have this option. The
C<-i> switch solves this problem; by using it, the pattern will do
case insensitive matching.

=back

=head2 OO interface and inline matching/substitution

The patterns returned from C<%RE> are objects, so rather than writing:

        if ($str =~ /$RE{some}{pattern}/ ) {...}

you can write:

        if ( $RE{some}{pattern}->matches($str) ) {...}

For matching this would seem to have no great advantage apart from readability
(but see below).

For substitutions, it has other significant benefits. Frequently you want to
perform a substitution on a string without changing the original. Most people
use this:

        $changed = $original;
        $changed =~ s/$RE{some}{pattern}/$replacement/;

The more adept use:

        ($changed = $original) =~ s/$RE{some}{pattern}/$replacement/;

Regexp::Common allows you do write this:

        $changed = $RE{some}{pattern}->subs($original=>$replacement);

Apart from reducing precedence-angst, this approach has the added
advantages that the substitution behaviour can be optimized from the
regular expression, and the replacement string can be provided by
default (see L<"Adding new regular expressions">).

For example, in the implementation of this substitution:

        $cropped = $RE{ws}{crop}->subs($uncropped);

the default empty string is provided automatically, and the substitution is
optimized to use:

        $uncropped =~ s/^\s+//;
        $uncropped =~ s/\s+$//;

rather than:

        $uncropped =~ s/^\s+|\s+$//g;


=head2 Subroutine-based interface

The hash-based interface was chosen because it allows regexes to be
effortlessly interpolated, and because it also allows them to be
"curried". For example:

        my $num = $RE{num}{int};

        my $command    = $num->{-sep=>','}{-group=>3};
        my $duodecimal = $num->{-base=>12};


However, the use of tied hashes does make the access to Regexp::Common
patterns slower than it might otherwise be. In contexts where impatience
overrules laziness, Regexp::Common provides an additional
subroutine-based interface.

For each (sub-)entry in the C<%RE> hash (C<$RE{key1}{key2}{etc}>), there
is a corresponding exportable subroutine: C<RE_key1_key2_etc()>. The name of
each subroutine is the underscore-separated concatenation of the I<non-flag>
keys that locate the same pattern in C<%RE>. Flags are passed to the subroutine
in its argument list. Thus:

        use Regexp::Common qw( RE_ws_crop RE_num_real RE_profanity );

        $str =~ RE_ws_crop() and die "Surrounded by whitespace";

        $str =~ RE_num_real(-base=>8, -sep=>" ") or next;

        $offensive = RE_profanity(-keep);
        $str =~ s/$offensive/$bad{$1}++; "<expletive deleted>"/ge;

Note that, unlike the hash-based interface (which returns objects), these
subroutines return ordinary C<qr>'d regular expressions. Hence they do not
curry, nor do they provide the OO match and substitution inlining described
in the previous section.

It is also possible to export subroutines for all available patterns like so:

        use Regexp::Common 'RE_ALL';

Or you can export all subroutines with a common prefix of keys like so:

        use Regexp::Common 'RE_num_ALL';

which will export C<RE_num_int> and C<RE_num_real> (and if you have
create more patterns who have first key I<num>, those will be exported
as well). In general, I<RE_key1_..._keyn_ALL> will export all subroutines
whose pattern names have first keys I<key1> ... I<keyn>.


=head2 Adding new regular expressions

You can add your own regular expressions to the C<%RE> hash at run-time,
using the exportable C<pattern> subroutine. It expects a hash-like list of
key/value pairs that specify the behaviour of the pattern. The various
possible argument pairs are:

=over 4

=item C<name =E<gt> [ @list ]>

A required argument that specifies the name of the pattern, and any
flags it may take, via a reference to a list of strings. For example:

         pattern name => [qw( line of -char )],
                 # other args here
                 ;

This specifies an entry C<$RE{line}{of}>, which may take a C<-char> flag.

Flags may also be specified with a default value, which is then used whenever
the flag is specified without an explicit value (but not when the flag is
omitted). For example:

         pattern name => [qw( line of -char=_ )],
                 # default char is '_'
                 # other args here
                 ;


=item C<create =E<gt> $sub_ref_or_string>

A required argument that specifies either a string that is to be returned
as the pattern:

        pattern name    => [qw( line of underscores )],
                create  => q/(?:^_+$)/
                ;

or a reference to a subroutine that will be called to create the pattern:

        pattern name    => [qw( line of -char=_ )],
                create  => sub {
                                my ($self, $flags) = @_;
                                my $char = quotemeta $flags->{-char};
                                return '(?:^$char+$)';
                            },
                ;

If the subroutine version is used, the subroutine will be called with
three arguments: a reference to the pattern object itself, a reference
to a hash containing the flags and their values,
and a reference to an array containing the non-flag keys.

Whatever the subroutine returns is stringified as the pattern.

No matter how the pattern is created, it is immediately postprocessed to
include or exclude capturing parentheses (according to the value of the
C<-keep> flag). To specify such "optional" capturing parentheses within
the regular expression associated with C<create>, use the notation
C<(?k:...)>. Any parentheses of this type will be converted to C<(...)>
when the C<-keep> flag is specified, or C<(?:...)> when it is not.
It is a Regexp::Common convention that the outermost capturing parentheses
always capture the entire pattern, but this is not enforced.


=item C<match =E<gt> $sub_ref>

An optional argument that specifies a subroutine that is to be called when
the C<$RE{...}-E<gt>matches(...)> method of this pattern is invoked.

The subroutine should expect two arguments: a reference to the pattern object
itself, and the string to be matched against.

It should return the same types of values as a C<m/.../> does.

     pattern name    => [qw( line of -char )],
             create  => sub {...},
             match   => sub {
                             my ($self, $str) = @_;
                             $str !~ /[^$self->{flags}{-char}]/;
                        },
             ;


=item C<subs =E<gt> $sub_ref>

An optional argument that specifies a subroutine that is to be called when
the C<$RE{...}-E<gt>subs(...)> method of this pattern is invoked.

The subroutine should expect three arguments: a reference to the pattern object
itself, the string to be changed, and the value to be substituted into it.
The third argument may be C<undef>, indicating the default substitution is
required.

The subroutine should return the same types of values as an C<s/.../.../> does.

For example:

     pattern name    => [ 'lineof', '-char=_' ],
             create  => sub {...},
             subs    => sub {
                          my ($self, $str, $ignore_replacement) = @_;
                          $_[1] =~ s/^$self->{flags}{-char}+$//g;
                        },
             ;

Note that such a subroutine will almost always need to modify C<$_[1]> directly.


=item C<version =E<gt> $minimum_perl_version>

If this argument is given, it specifies the minimum version of perl required
to use the new pattern. Attempts to use the pattern with earlier versions of
perl will generate a fatal diagnostic.

=back

=head2 Loading specific sets of patterns.

By default, all the sets of patterns listed below are made available.
However, it is possible to indicate which sets of patterns should
be made available - the wanted sets should be given as arguments to
C<use>. Alternatively, it is also possible to indicate which sets of
patterns should not be made available - those sets will be given as
argument to the C<use> statement, but are preceded with an exclaimation
mark. The argument I<no_defaults> indicates none of the default patterns
should be made available. This is useful for instance if all you want
is the C<pattern()> subroutine.

Examples:

 use Regexp::Common qw /comment number/;  # Comment and number patterns.
 use Regexp::Common qw /no_defaults/;     # Don't load any patterns.
 use Regexp::Common qw /!delimited/;      # All, but delimited patterns.

It's also possible to load your own set of patterns. If you have a
module C<Regexp::Common::my_patterns> that makes patterns available,
you can have it made available with

 use Regexp::Common qw /my_patterns/;

Note that the default patterns will still be made available - only if
you use I<no_defaults>, or mention one of the default sets explicitly,
the non mentioned defaults aren't made available.

=head2 List of available patterns

The patterns listed below are currently available. Each set of patterns
has its own manual page describing the details. For each pattern set
named I<name>, the manual page I<Regexp::Common::name> describes the
details.

Currently available are:

=over 4

=item Regexp::Common::balanced

Provides regexes for strings with balanced parenthesized delimiters.

=item Regexp::Common::comment

Provides regexes for comments of various languages (43 languages
currently).

=item Regexp::Common::delimited

Provides regexes for delimited strings.

=item Regexp::Common::lingua

Provides regexes for palindromes.

=item Regexp::Common::list

Provides regexes for lists.

=item Regexp::Common::net

Provides regexes for IPv4, IPv6, and MAC addresses.

=item Regexp::Common::number

Provides regexes for numbers (integers and reals).

=item Regexp::Common::profanity

Provides regexes for profanity.

=item Regexp::Common::whitespace

Provides regexes for leading and trailing whitespace.

=item Regexp::Common::zip

Provides regexes for zip codes.

=back

=head2 Forthcoming patterns and features

Future releases of the module will also provide patterns for the following:

        * email addresses
        * HTML/XML tags
        * more numerical matchers,
        * mail headers (including multiline ones),
        * more URLS
        * telephone numbers of various countries
        * currency (universal 3 letter format, Latin-1, currency names)
        * dates
        * binary formats (e.g. UUencoded, MIMEd)

If you have other patterns or pattern generators that you think would be
generally useful, please send them to the maintainer -- preferably as source
code using the C<pattern> subroutine. Submissions that include a set of
tests will be especially welcome.


=head1 DIAGNOSTICS

=over 4

=item C<Can't export unknown subroutine %s>

The subroutine-based interface didn't recognize the requested subroutine.
Often caused by a spelling mistake or an incompletely specified name.


=item C<Can't create unknown regex: $RE{...}>

Regexp::Common doesn't have a generator for the requested pattern.
Often indicates a misspelt or missing parameter.

=item
C<Perl %f does not support the pattern $RE{...}.
You need Perl %f or later>

The requested pattern requires advanced regex features (e.g. recursion)
that not available in your version of Perl. Time to upgrade.

=item C<< pattern() requires argument: name => [ @list ] >>

Every user-defined pattern specification must have a name.

=item C<< pattern() requires argument: create => $sub_ref_or_string >>

Every user-defined pattern specification must provide a pattern creation
mechanism: either a pattern string or a reference to a subroutine that
returns the pattern string.

=item C<Base must be between 1 and 36>

The C<< $RE{num}{real}{-base=>'I<N>'} >> pattern uses the characters [0-9A-Z]
to represent the digits of various bases. Hence it only produces
regular expressions for bases up to hexatricensimal.

=item C<Must specify delimiter in $RE{delimited}>

The pattern has no default delimiter.
You need to write: C<< $RE{delimited}{-delim=>I<X>'} >> for some character I<X>

=back

=head1 ACKNOWLEDGEMENTS

Deepest thanks to the many people who have encouraged and contributed to this
project, especially: Elijah, Jarkko, Tom, Nat, Ed, and Vivek.

Further thanks go to: Alexandr Ciornii, Blair Zajac, Bob Stockdale,
Charles Thomas, Chris Vertonghen, the CPAN Testers, David Hand,
Fany, Geoffrey Leach, Hermann-Marcus Behrens, Jerome Quelin, Jim Cromie,
Lars Wilke, Linda Julien, Mike Arms, Mike Castle, Mikko, Murat Uenalan,
RafaE<235>l Garcia-Suarez, Ron Savage, Sam Vilain, Slaven Rezic, Smylers,
Tim Maher, and all the others I've forgotten.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.be>.

There are some POD issues when installing this module using a pre-5.6.0 perl;
some manual pages may not install, or may not install correctly using a perl
that is that old. You might consider upgrading your perl.

=head1 NOT A BUG

=over 4

=item *

The various patterns are not anchored. That is, a pattern like
C<< $RE {num} {int} >> will match against "abc4def", because a
substring of the subject matches. This is by design, and not a
bug. If you want the pattern to be anchored, use something like:

 my $integer = $RE {num} {int};
 $subj =~ /^$integer$/ and print "Matches!\n";

=back

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2017, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.
EOCommon
# 2}}}
$Regexp_Common_Contents{'Common/comment'} = <<'EOC';   # {{{2
package Regexp::Common::comment;

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common qw /pattern clean no_defaults/;

our $VERSION = '2017060201';

my @generic = (
    {languages => [qw /ABC Forth/],
     to_eol    => ['\\\\']},   # This is for just a *single* backslash.

    {languages => [qw /Ada Alan Eiffel lua/],
     to_eol    => ['--']},

    {languages => [qw /Advisor/],
     to_eol    => ['#|//']},

    {languages => [qw /Advsys CQL Lisp LOGO M MUMPS REBOL Scheme
                       SMITH zonefile/],
     to_eol    => [';']},

    {languages => ['Algol 60'],
     from_to   => [[qw /comment ;/]]},

    {languages => [qw {ALPACA B C C-- LPC PL/I}],
     from_to   => [[qw {/* */}]]},

    {languages => [qw /awk fvwm2 Icon m4 mutt Perl Python QML
                       R Ruby shell Tcl/],
     to_eol    => ['#']},

    {languages => [[BASIC => 'mvEnterprise']],
     to_eol    => ['[*!]|REM']},

    {languages => [qw /Befunge-98 Funge-98 Shelta/],
     id        => [';']},

    {languages => ['beta-Juliet', 'Crystal Report', 'Portia', 'Ubercode'],
     to_eol    => ['//']},

    {languages => ['BML'],
     from_to   => [['<?_c', '_c?>']],
    },

    {languages => [qw /C++/, 'C#', 'X++', qw /Cg ECMAScript FPL Java JavaScript/],
     to_eol    => ['//'],
     from_to   => [[qw {/* */}]]},

    {languages => [qw /CLU LaTeX slrn TeX/],
     to_eol    => ['%']},

    {languages => [qw /False/],
     from_to   => [[qw !{ }!]]},

    {languages => [qw /Fortran/],
     to_eol    => ['!']},

    {languages => [qw /Haifu/],
     id        => [',']},

    {languages => [qw /ILLGOL/],
     to_eol    => ['NB']},

    {languages => [qw /INTERCAL/],
     to_eol    => [q{(?:(?:PLEASE(?:\s+DO)?|DO)\s+)?(?:NOT|N'T)}]},

    {languages => [qw /J/],
     to_eol    => ['NB[.]']},

    {languages => [qw /JavaDoc/],
     from_to   => [[qw {/** */}]]},

    {languages => [qw /Nickle/],
     to_eol    => ['#'],
     from_to   => [[qw {/* */}]]},

    {languages => [qw /Oberon/],
     from_to   => [[qw /(* *)/]]},

    {languages => [[qw /Pascal Delphi/], [qw /Pascal Free/], [qw /Pascal GPC/]],
     to_eol    => ['//'],
     from_to   => [[qw !{ }!], [qw !(* *)!]]},

    {languages => [[qw /Pascal Workshop/]],
     id        => [qw /"/],
     from_to   => [[qw !{ }!], [qw !(* *)!], [qw !/* */!]]},

    {languages => [qw /PEARL/],
     to_eol    => ['!'],
     from_to   => [[qw {/* */}]]},

    {languages => [qw /PHP/],
     to_eol    => ['#', '//'],
     from_to   => [[qw {/* */}]]},

    {languages => [qw !PL/B!],
     to_eol    => ['[.;]']},

    {languages => [qw !PL/SQL!],
     to_eol    => ['--'],
     from_to   => [[qw {/* */}]]},

    {languages => [qw /Q-BAL/],
     to_eol    => ['`']},

    {languages => [qw /Smalltalk/],
     id        => ['"']},

    {languages => [qw /SQL/],
     to_eol    => ['-{2,}']},

    {languages => [qw /troff/],
     to_eol    => ['\\\"']},

    {languages => [qw /vi/],
     to_eol    => ['"']},

    {languages => [qw /*W/],
     from_to   => [[qw {|| !!}]]},

    {languages => [qw /ZZT-OOP/],
     to_eol    => ["'"]},
);

my @plain_or_nested = (
   [Caml         =>  undef,       "(*"  => "*)"],
   [Dylan        =>  "//",        "/*"  => "*/"],
   [Haskell      =>  "-{2,}",     "{-"  => "-}"],
   [Hugo         =>  "!(?!\\\\)", "!\\" => "\\!"],
   [SLIDE        =>  "#",         "(*"  => "*)"],
  ['Modula-2'    =>  undef,       "(*"  => "*)"],
  ['Modula-3'    =>  undef,       "(*"  => "*)"],
);

#
# Helper subs.
#

sub combine      {
    local $_ = join "|", @_;
    if (@_ > 1) {
        s/\(\?k:/(?:/g;
        $_ = "(?k:$_)";
    }
    $_
}

sub to_eol  ($)  {"(?k:(?k:$_[0])(?k:[^\\n]*)(?k:\\n))"}
sub id      ($)  {"(?k:(?k:$_[0])(?k:[^$_[0]]*)(?k:$_[0]))"}  # One char only!
sub from_to      {
    my ($begin, $end) = @_;

    my $qb  = quotemeta $begin;
    my $qe  = quotemeta $end;
    my $fe  = quotemeta substr $end   => 0, 1;
    my $te  = quotemeta substr $end   => 1;

    "(?k:(?k:$qb)(?k:(?:[^$fe]+|$fe(?!$te))*)(?k:$qe))";
}


my $count = 0;
sub nested {
    my ($begin, $end) = @_;

    $count ++;
    my $r = '(??{$Regexp::Common::comment ['. $count . ']})';

    my $qb  = quotemeta $begin;
    my $qe  = quotemeta $end;
    my $fb  = quotemeta substr $begin => 0, 1;
    my $fe  = quotemeta substr $end   => 0, 1;

    my $tb  = quotemeta substr $begin => 1;
    my $te  = quotemeta substr $end   => 1;

    use re 'eval';

    my $re;
    if ($fb eq $fe) {
        $re = qr /(?:$qb(?:(?>[^$fb]+)|$fb(?!$tb)(?!$te)|$r)*$qe)/;
    }
    else {
        local $"      =  "|";
        my   @clauses =  "(?>[^$fb$fe]+)";
        push @clauses => "$fb(?!$tb)" if length $tb;
        push @clauses => "$fe(?!$te)" if length $te;
        push @clauses =>  $r;
        $re           =   qr /(?:$qb(?:@clauses)*$qe)/;
    }

    $Regexp::Common::comment [$count] = qr/$re/;
}

#
# Process data.
#

foreach my $info (@plain_or_nested) {
    my ($language, $mark, $begin, $end) = @$info;
    pattern name    => [comment => $language],
            create  =>
                sub {my $re     = nested $begin => $end;
                     my $prefix = defined $mark ? $mark . "[^\n]*\n|" : "";
                     exists $_ [1] -> {-keep} ? qr /($prefix$re)/
                                              : qr  /$prefix$re/
                },
            ;
}


foreach my $group (@generic) {
    my $pattern = combine +(map {to_eol   $_} @{$group -> {to_eol}}),
                           (map {from_to @$_} @{$group -> {from_to}}),
                           (map {id       $_} @{$group -> {id}}),
                  ;
    foreach my $language  (@{$group -> {languages}}) {
        pattern name    => [comment => ref $language ? @$language : $language],
                create  => $pattern,
                ;
    }
}



#
# Other languages.
#

# http://www.pascal-central.com/docs/iso10206.txt
pattern name    => [qw /comment Pascal/],
        create  => '(?k:' . '(?k:[{]|[(][*])'
                          . '(?k:[^}*]*(?:[*](?![)])[^}*]*)*)'
                          . '(?k:[}]|[*][)])'
                          . ')'
        ;

# http://www.templetons.com/brad/alice/language/
pattern name    =>  [qw /comment Pascal Alice/],
        create  =>  '(?k:(?k:[{])(?k:[^}\n]*)(?k:[}]))'
        ;


# http://westein.arb-phys.uni-dortmund.de/~wb/a68s.txt
pattern name    => [qw (comment), 'Algol 68'],
        create  => q {(?k:(?:#[^#]*#)|}                           .
                   q {(?:\bco\b(?:[^c]+|\Bc|\bc(?!o\b))*\bco\b)|} .
                   q {(?:\bcomment\b(?:[^c]+|\Bc|\bc(?!omment\b))*\bcomment\b))}
        ;


# See rules 91 and 92 of ISO 8879 (SGML).
# Charles F. Goldfarb: "The SGML Handbook".
# Oxford: Oxford University Press. 1990. ISBN 0-19-853737-9.
# Ch. 10.3, pp 390.
pattern name    => [qw (comment HTML)],
        create  => q {(?k:(?k:<!)(?k:(?:--(?k:[^-]*(?:-[^-]+)*)--\s*)*)(?k:>))},
        ;


pattern name    => [qw /comment SQL MySQL/],
        create  => q {(?k:(?:#|-- )[^\n]*\n|} .
                   q {/\*(?:(?>[^*;"']+)|"[^"]*"|'[^']*'|\*(?!/))*(?:;|\*/))},
        ;

# Anything that isn't <>[]+-.,
# http://home.wxs.nl/~faase009/Ha_BF.html
pattern name    => [qw /comment Brainfuck/],
        create  => '(?k:[^<>\[\]+\-.,]+)'
        ;

# Squeak is a variant of Smalltalk-80.
# http://www.squeak.
# http://mucow.com/squeak-qref.html
pattern name    => [qw /comment Squeak/],
        create  => '(?k:(?k:")(?k:[^"]*(?:""[^"]*)*)(?k:"))'
        ;

#
# Scores of less than 5 or above 17....
# http://www.cliff.biffle.org/esoterica/beatnik.html
@Regexp::Common::comment::scores = (1,  3,  3,  2,  1,  4,  2,  4,  1,  8,
                                    5,  1,  3,  1,  1,  3, 10,  1,  1,  1,
                                    1,  4,  4,  8,  4, 10);
{
my ($s, $x);
pattern name    =>  [qw /comment Beatnik/],
        create  =>  sub {
            use re 'eval';
            my $re = qr {\b([A-Za-z]+)\b
                         (?(?{($s, $x) = (0, lc $^N);
                              $s += $Regexp::Common::comment::scores
                                    [ord (chop $x) - ord ('a')] while length $x;
                              $s  >= 5 && $s < 18})XXX|)}x;
            $re;
        },
        ;
}


# http://www.cray.com/craydoc/manuals/007-3692-005/html-007-3692-005/
#  (Goto table of contents/3.3 Source Form)
# Fortran, in fixed format. Comments start with a C, c or * in the first
# column, or a ! anywhere, but the sixth column. Then end with a newline.
pattern name    =>  [qw /comment Fortran fixed/],
        create  =>  '(?k:(?k:(?:^[Cc*]|(?<!^.....)!))(?k:[^\n]*)(?k:\n))'
        ;


# http://www.csis.ul.ie/cobol/Course/COBOLIntro.htm
# Traditionally, comments in COBOL were indicated with an asterisk in
# the seventh column. Modern compilers may be more lenient.
pattern name    =>  [qw /comment COBOL/],
        create  =>  '(?<=^......)(?k:(?k:[*])(?k:[^\n]*)(?k:\n))',
        ;

1;


__END__

=pod

=head1 NAME

Regexp::Common::comment -- provide regexes for comments.

=head1 SYNOPSIS

    use Regexp::Common qw /comment/;

    while (<>) {
        /$RE{comment}{C}/       and  print "Contains a C comment\n";
        /$RE{comment}{C++}/     and  print "Contains a C++ comment\n";
        /$RE{comment}{PHP}/     and  print "Contains a PHP comment\n";
        /$RE{comment}{Java}/    and  print "Contains a Java comment\n";
        /$RE{comment}{Perl}/    and  print "Contains a Perl comment\n";
        /$RE{comment}{awk}/     and  print "Contains an awk comment\n";
        /$RE{comment}{HTML}/    and  print "Contains an HTML comment\n";
    }

    use Regexp::Common qw /comment RE_comment_HTML/;

    while (<>) {
        $_ =~ RE_comment_HTML() and  print "Contains an HTML comment\n";
    }

=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

This modules gives you regular expressions for comments in various
languages.

=head2 THE LANGUAGES

Below, the comments of each of the languages are described.
The patterns are available as C<$RE{comment}{I<LANG>}>, foreach
language I<LANG>. Some languages have variants; it's described
at the individual languages how to get the patterns for the variants.
Unless mentioned otherwise,
C<{-keep}> sets C<$1>, C<$2>, C<$3> and C<$4> to the entire comment,
the opening marker, the content of the comment, and the closing marker
(for many languages, the latter is a newline) respectively.

=over 4

=item ABC

Comments in I<ABC> start with a backslash (C<\>), and last till
the end of the line.
See L<http://homepages.cwi.nl/%7Esteven/abc/>.

=item Ada

Comments in I<Ada> start with C<-->, and last till the end of the line.

=item Advisor

I<Advisor> is a language used by the HP product I<glance>. Comments for
this language start with either C<#> or C<//>, and last till the
end of the line.

=item Advsys

Comments for the I<Advsys> language start with C<;> and last till
the end of the line. See also L<http://www.wurb.com/if/devsys/12>.

=item Alan

I<Alan> comments start with C<-->, and last till the end of the line.
See also L<http://w1.132.telia.com/~u13207378/alan/manual/alanTOC.html>.

=item Algol 60

Comments in the I<Algol 60> language start with the keyword C<comment>,
and end with a C<;>. See L<http://www.masswerk.at/algol60/report.htm>.

=item Algol 68

In I<Algol 68>, comments are either delimited by C<#>, or by one of the
keywords C<co> or C<comment>. The keywords should not be part of another
word. See L<http://westein.arb-phys.uni-dortmund.de/~wb/a68s.txt>.
With C<{-keep}>, only C<$1> will be set, returning the entire comment.

=item ALPACA

The I<ALPACA> language has comments starting with C</*> and ending with C<*/>.

=item awk

The I<awk> programming language uses comments that start with C<#>
and end at the end of the line.

=item B

The I<B> language has comments starting with C</*> and ending with C<*/>.

=item BASIC

There are various forms of BASIC around. Currently, we only support the
variant supported by I<mvEnterprise>, whose pattern is available as
C<$RE{comment}{BASIC}{mvEnterprise}>. Comments in this language start with a
C<!>, a C<*> or the keyword C<REM>, and end till the end of the line. See
L<http://www.rainingdata.com/products/beta/docs/mve/50/ReferenceManual/Basic.pdf>.

=item Beatnik

The esotoric language I<Beatnik> only uses words consisting of letters.
Words are scored according to the rules of Scrabble. Words scoring less
than 5 points, or 18 points or more are considered comments (although
the compiler might mock at you if you score less than 5 points).
Regardless whether C<{-keep}>, C<$1> will be set, and set to the
entire comment. This pattern requires I<perl 5.8.0> or newer.

=item beta-Juliet

The I<beta-Juliet> programming language has comments that start with
C<//> and that continue till the end of the line. See also
L<http://www.catseye.mb.ca/esoteric/b-juliet/index.html>.

=item Befunge-98

The esotoric language I<Befunge-98> uses comments that start and end
with a C<;>. See L<http://www.catseye.mb.ca/esoteric/befunge/98/spec98.html>.

=item BML

I<BML>, or I<Better Markup Language> is an HTML templating language that
uses comments starting with C<< <?c_ >>, and ending with C<< c_?> >>.
See L<http://www.livejournal.com/doc/server/bml.index.html>.

=item Brainfuck

The minimal language I<Brainfuck> uses only eight characters,
C<E<lt>>, C<E<gt>>, C<[>, C<]>, C<+>, C<->, C<.> and C<,>.
Any other characters are considered comments. With C<{-keep}>,
C<$1> is set to the entire comment.

=item C

The I<C> language has comments starting with C</*> and ending with C<*/>.

=item C--

The I<C--> language has comments starting with C</*> and ending with C<*/>.
See L<http://cs.uas.arizona.edu/classes/453/programs/C--Spec.html>.

=item C++

The I<C++> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment.

=item C#

The I<C#> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment.
See L<http://msdn.microsoft.com/library/default.asp?url=/library/en-us/csspec/html/vclrfcsharpspec_C.asp>.

=item Caml

Comments in I<Caml> start with C<(*>, end with C<*)>, and can be nested.
See L<http://www.cs.caltech.edu/courses/cs134/cs134b/book.pdf> and
L<http://pauillac.inria.fr/caml/index-eng.html>.

=item Cg

The I<Cg> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment.
See L<http://developer.nvidia.com/attach/3722>.

=item CLU

In C<CLU>, a comment starts with a procent sign (C<%>), and ends with the
next newline. See L<ftp://ftp.lcs.mit.edu:/pub/pclu/CLU-syntax.ps> and
L<http://www.pmg.lcs.mit.edu/CLU.html>.

=item COBOL

Traditionally, comments in I<COBOL> are indicated by an asterisk in the
seventh column. This is what the pattern matches. Modern compiler may
more lenient though. See L<http://www.csis.ul.ie/cobol/Course/COBOLIntro.htm>,
and L<http://www.csis.ul.ie/cobol/default.htm>.

=item CQL

Comments in the chess query language (I<CQL>) start with a semi colon
(C<;>) and last till the end of the line. See L<http://www.rbnn.com/cql/>.

=item Crystal Report

The formula editor in I<Crystal Reports> uses comments that start
with C<//>, and end with the end of the line.

=item Dylan

There are two types of comments in I<Dylan>. They either start with
C<//>, or are nested comments, delimited with C</*> and C<*/>.
Under C<{-keep}>, only C<$1> will be set, returning the entire comment.
This pattern requires I<perl 5.6.0> or newer.

=item ECMAScript

The I<ECMAScript> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment. I<JavaScript> is Netscapes implementation
of I<ECMAScript>. See
L<http://www.ecma-international.org/publications/files/ecma-st/Ecma-262.pdf>,
and L<http://www.ecma-international.org/publications/standards/Ecma-262.htm>.

=item Eiffel

I<Eiffel> comments start with C<-->, and last till the end of the line.

=item False

In I<False>, comments start with C<{> and end with C<}>.
See L<http://wouter.fov120.com/false/false.txt>

=item FPL

The I<FPL> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment.

=item Forth

Comments in Forth start with C<\>, and end with the end of the line.
See also L<http://docs.sun.com/sb/doc/806-1377-10>.

=item Fortran

There are two forms of I<Fortran>. There's free form I<Fortran>, which
has comments that start with C<!>, and end at the end of the line.
The pattern for this is given by C<$RE{Fortran}>. Fixed form I<Fortran>,
which has been obsoleted, has comments that start with C<C>, C<c> or
C<*> in the first column, or with C<!> anywhere, but the sixth column.
The pattern for this are given by C<$RE{Fortran}{fixed}>.

See also L<http://www.cray.com/craydoc/manuals/007-3692-005/html-007-3692-005/>.

=item Funge-98

The esotoric language I<Funge-98> uses comments that start and end with
a C<;>.

=item fvwm2

Configuration files for I<fvwm2> have comments starting with a
C<#> and lasting the rest of the line.

=item Haifu

I<Haifu>, an esotoric language using haikus, has comments starting and
ending with a C<,>.
See L<http://www.dangermouse.net/esoteric/haifu.html>.

=item Haskell

There are two types of comments in I<Haskell>. They either start with
at least two dashes, or are nested comments, delimited with C<{-> and C<-}>.
Under C<{-keep}>, only C<$1> will be set, returning the entire comment.
This pattern requires I<perl 5.6.0> or newer.

=item HTML

In I<HTML>, comments only appear inside a I<comment declaration>.
A comment declaration starts with a C<E<lt>!>, and ends with a
C<E<gt>>. Inside this declaration, we have zero or more comments.
Comments starts with C<--> and end with C<-->, and are optionally
followed by whitespace. The pattern C<$RE{comment}{HTML}> recognizes
those comment declarations (and hence more than a comment).
Note that this is not the same as something that starts with
C<E<lt>!--> and ends with C<--E<gt>>, because the following will
be matched completely:

    <!--  First  Comment   --
      --> Second Comment <!--
      --  Third  Comment   -->

Do not be fooled by what your favourite browser thinks is an HTML
comment.

If C<{-keep}> is used, the following are returned:

=over 4

=item $1

captures the entire comment declaration.

=item $2

captures the MDO (markup declaration open), C<E<lt>!>.

=item $3

captures the content between the MDO and the MDC.

=item $4

captures the (last) comment, without the surrounding dashes.

=item $5

captures the MDC (markup declaration close), C<E<gt>>.

=back

=item Hugo

There are two types of comments in I<Hugo>. They either start with
C<!> (which cannot be followed by a C<\>), or are nested comments,
delimited with C<!\> and C<\!>.
Under C<{-keep}>, only C<$1> will be set, returning the entire comment.
This pattern requires I<perl 5.6.0> or newer.

=item Icon

I<Icon> has comments that start with C<#> and end at the next new line.
See L<http://www.toolsofcomputing.com/IconHandbook/IconHandbook.pdf>,
L<http://www.cs.arizona.edu/icon/index.htm>, and
L<http://burks.bton.ac.uk/burks/language/icon/index.htm>.

=item ILLGOL

The esotoric language I<ILLGOL> uses comments starting with I<NB> and lasting
till the end of the line.
See L<http://www.catseye.mb.ca/esoteric/illgol/index.html>.

=item INTERCAL

Comments in INTERCAL are single line comments. They start with one of
the keywords C<NOT> or C<N'T>, and can optionally be preceded by the
keywords C<DO> and C<PLEASE>. If both keywords are used, C<PLEASE>
precedes C<DO>. Keywords are separated by whitespace.

=item J

The language I<J> uses comments that start with C<NB.>, and that last till
the end of the line. See
L<http://www.jsoftware.com/books/help/primer/contents.htm>, and
L<http://www.jsoftware.com/>.

=item Java

The I<Java> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment.

=item JavaDoc

The I<Javadoc> documentation syntax is demarked with a subset of
ordinary Java comments to separate it from code.  Comments start with
C</**> end with C<*/>.  If C<{-keep}> is used, only C<$1> will be set,
and set to the entire comment. See
L<http://www.oracle.com/technetwork/java/javase/documentation/index-137868.html#format>.

=item JavaScript

The I<JavaScript> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment. I<JavaScript> is Netscapes implementation
of I<ECMAScript>.
See L<http://www.mozilla.org/js/language/E262-3.pdf>,
and L<http://www.mozilla.org/js/language/>.

=item LaTeX

The documentation language I<LaTeX> uses comments starting with C<%>
and ending at the end of the line.

=item Lisp

Comments in I<Lisp> start with a semi-colon (C<;>) and last till the
end of the line.

=item LPC

The I<LPC> language has comments starting with C</*> and ending with C<*/>.

=item LOGO

Comments for the language I<LOGO> start with C<;>, and last till the end
of the line.

=item lua

Comments for the I<lua> language start with C<-->, and last till the end
of the line. See also L<http://www.lua.org/manual/manual.html>.

=item M, MUMPS

In C<M> (aka C<MUMPS>), comments start with a semi-colon, and last
till the end of a line. The language specification requires the
semi-colon to be preceded by one or more I<linestart character>s.
Those characters default to a space, but that's configurable. This
requirement, of preceding the comment with linestart characters is
B<not> tested for. See
L<ftp://ftp.intersys.com/pub/openm/ism/ism64docs.zip>,
L<http://mtechnology.intersys.com/mproducts/openm/index.html>, and
L<http://mcenter.com/mtrc/index.html>.

=item m4

By default, the preprocessor language I<m4> uses single line comments,
that start with a C<#> and continue to the end of the line, including
the newline. The pattern C<$RE {comment} {m4}> matches such comments.
In I<m4>, it is possible to change the starting token though.
See L<http://wolfram.schneider.org/bsd/7thEdManVol2/m4/m4.pdf>,
L<http://www.cs.stir.ac.uk/~kjt/research/pdf/expl-m4.pdf>, and
L<http://www.gnu.org/software/m4/manual/>.

=item Modula-2

In C<Modula-2>, comments start with C<(*>, and end with C<*)>. Comments
may be nested. See L<http://www.modula2.org/>.

=item Modula-3

In C<Modula-3>, comments start with C<(*>, and end with C<*)>. Comments
may be nested. See L<http://www.m3.org/>.

=item mutt

Configuration files for I<mutt> have comments starting with a
C<#> and lasting the rest of the line.

=item Nickle

The I<Nickle> language has one line comments starting with C<#>
(like Perl), or multiline comments delimited by C</*> and C<*/>
(like C). Under C<-keep>, only C<$1> will be set. See also
L<http://www.nickle.org>.

=item Oberon

Comments in I<Oberon> start with C<(*> and end with C<*)>.
See L<http://www.oberon.ethz.ch/oreport.html>.

=item Pascal

There are many implementations of Pascal. This modules provides
pattern for comments of several implementations.

=over 4

=item C<$RE{comment}{Pascal}>

This is the pattern that recognizes comments according to the Pascal ISO
standard. This standard says that comments start with either C<{>, or
C<(*>, and end with C<}> or C<*)>. This means that C<{*)> and C<(*}>
are considered to be comments. Many Pascal applications don't allow this.
See L<http://www.pascal-central.com/docs/iso10206.txt>

=item C<$RE{comment}{Pascal}{Alice}>

The I<Alice Pascal> compiler accepts comments that start with C<{>
and end with C<}>. Comments are not allowed to contain newlines.
See L<http://www.templetons.com/brad/alice/language/>.

=item C<$RE{comment}{Pascal}{Delphi}>, C<$RE{comment}{Pascal}{Free}>
and C<$RE{comment}{Pascal}{GPC}>

The I<Delphi Pascal>, I<Free Pascal> and the I<Gnu Pascal Compiler>
implementations of Pascal all have comments that either start with
C<//> and last till the end of the line, are delimited with C<{>
and C<}> or are delimited with C<(*> and C<*)>. Patterns for those
comments are given by C<$RE{comment}{Pascal}{Delphi}>,
C<$RE{comment}{Pascal}{Free}> and C<$RE{comment}{Pascal}{GPC}>
respectively. These patterns only set C<$1> when C<{-keep}> is used,
which will then include the entire comment.

See L<http://info.borland.com/techpubs/delphi5/oplg/>,
L<http://www.freepascal.org/docs-html/ref/ref.html> and
L<http://www.gnu-pascal.de/gpc/>.

=item C<$RE{comment}{Pascal}{Workshop}>

The I<Workshop Pascal> compiler, from SUN Microsystems, allows comments
that are delimited with either C<{> and C<}>, delimited with
C<(*)> and C<*>), delimited with C</*>, and C<*/>, or starting
and ending with a double quote (C<">). When C<{-keep}> is used,
only C<$1> is set, and returns the entire comment.

See L<http://docs.sun.com/db/doc/802-5762>.

=back

=item PEARL

Comments in I<PEARL> start with a C<!> and last till the end of the
line, or start with C</*> and end with C<*/>. With C<{-keep}>,
C<$1> will be set to the entire comment.

=item PHP

Comments in I<PHP> start with either C<#> or C<//> and last till the
end of the line, or are delimited by C</*> and C<*/>. With C<{-keep}>,
C<$1> will be set to the entire comment.

=item PL/B

In I<PL/B>, comments start with either C<.> or C<;>, and end with the
next newline. See L<http://www.mmcctech.com/pl-b/plb-0010.htm>.

=item PL/I

The I<PL/I> language has comments starting with C</*> and ending with C<*/>.

=item PL/SQL

In I<PL/SQL>, comments either start with C<--> and run till the end
of the line, or start with C</*> and end with C<*/>.

=item Perl

I<Perl> uses comments that start with a C<#>, and continue till the end
of the line.

=item Portia

The I<Portia> programming language has comments that start with C<//>,
and last till the end of the line.

=item Python

I<Python> uses comments that start with a C<#>, and continue till the end
of the line.

=item Q-BAL

Comments in the I<Q-BAL> language start with C<`> (a backtick), and
continue till the end of the line.

=item QML

In C<QML>, comments start with C<#> and last till the end of the line.
See L<http://www.questionmark.com/uk/qml/overview.doc>.

=item R

The statistical language I<R> uses comments that start with a C<#> and
end with the following new line. See L<http://www.r-project.org/>.

=item REBOL

Comments for the I<REBOL> language start with C<;> and last till the
end of the line.

=item Ruby

Comments in I<Ruby> start with C<#> and last till the end of the time.

=item Scheme

I<Scheme> comments start with C<;>, and last till the end of the line.
See L<http://schemers.org/>.

=item shell

Comments in various I<shell>s start with a C<#> and end at the end of
the line.

=item Shelta

The esotoric language I<Shelta> uses comments that start and end with
a C<;>. See L<http://www.catseye.mb.ca/esoteric/shelta/index.html>.

=item SLIDE

The I<SLIDE> language has two forms of comments. First there is the
line comment, which starts with a C<#> and includes the rest of the
line (just like Perl). Second, there is the multiline, nested comment,
which are delimited by C<(*> and C<*)>. Under C{-keep}>, only
C<$1> is set, and is set to the entire comment. See
L<http://www.cs.berkeley.edu/~ug/slide/docs/slide/spec/spec_frame_intro.shtml>.

=item slrn

Configuration files for I<slrn> have comments starting with a
C<%> and lasting the rest of the line.

=item Smalltalk

I<Smalltalk> uses comments that start and end with a double quote, C<">.

=item SMITH

Comments in the I<SMITH> language start with C<;>, and last till the
end of the line.

=item Squeak

In the Smalltalk variant I<Squeak>, comments start and end with
C<">. Double quotes can appear inside comments by doubling them.

=item SQL

Standard I<SQL> uses comments starting with two or more dashes, and
ending at the end of the line.

I<MySQL> does not follow the standard. Instead, it allows comments
that start with a C<#> or C<-- > (that's two dashes and a space)
ending with the following newline, and comments starting with
C</*>, and ending with the next C<;> or C<*/> that isn't inside
single or double quotes. A pattern for this is returned by
C<$RE{comment}{SQL}{MySQL}>. With C<{-keep}>, only C<$1> will
be set, and it returns the entire comment.

=item Tcl

In I<Tcl>, comments start with C<#> and continue till the end of the line.

=item TeX

The documentation language I<TeX> uses comments starting with C<%>
and ending at the end of the line.

=item troff

The document formatting language I<troff> uses comments starting
with C<\">, and continuing till the end of the line.

=item Ubercode

The Windows programming language I<Ubercode> uses comments that start with
C<//> and continue to the end of the line. See L<http://www.ubercode.com>.

=item vi

In configuration files for the editor I<vi>, one can use comments
starting with C<">, and ending at the end of the line.

=item *W

In the language I<*W>, comments start with C<||>, and end with C<!!>.

=item zonefile

Comments in DNS I<zonefile>s start with C<;>, and continue till the
end of the line.

=item ZZT-OOP

The in-game language I<ZZT-OOP> uses comments that start with a C<'>
character, and end at the following newline. See
L<http://dave2.rocketjump.org/rad/zzthelp/lang.html>.

=back

=head1 REFERENCES

=over 4

=item B<[Go 90]>

Charles F. Goldfarb: I<The SGML Handbook>. Oxford: Oxford University
Press. B<1990>. ISBN 0-19-853737-9. Ch. 10.3, pp 390-391.

=back

=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.be>.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2017, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.

=cut
EOC
# 2}}}
$Regexp_Common_Contents{'Common/balanced'} = <<'EOB';   # {{{2
package Regexp::Common::balanced; {

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common qw /pattern clean no_defaults/;

our $VERSION = '2017060201';

my %closer = ( '{'=>'}', '('=>')', '['=>']', '<'=>'>' );
my %cache;

sub nested {
    my ($start, $finish) = @_;

    return $cache {$start} {$finish} if exists $cache {$start} {$finish};

    my @starts   = map {s/\\(.)/$1/g; $_} grep {length}
                        $start  =~ /([^|\\]+|\\.)+/gs;
    my @finishes = map {s/\\(.)/$1/g; $_} grep {length}
                        $finish =~ /([^|\\]+|\\.)+/gs;

    push @finishes => ($finishes [-1]) x (@starts - @finishes);

    my @re;
    local $" = "|";
    foreach my $begin (@starts) {
        my $end = shift @finishes;

        my $qb  = quotemeta $begin;
        my $qe  = quotemeta $end;
        my $fb  = quotemeta substr $begin => 0, 1;
        my $fe  = quotemeta substr $end   => 0, 1;

        my $tb  = quotemeta substr $begin => 1;
        my $te  = quotemeta substr $end   => 1;

        my $add;
        if ($fb eq $fe) {
            push @re =>
                   qq /(?:$qb(?:(?>[^$fb]+)|$fb(?!$tb)(?!$te)|(?-1))*$qe)/;
        }
        else {
            my   @clauses =  "(?>[^$fb$fe]+)";
            push @clauses => "$fb(?!$tb)" if length $tb;
            push @clauses => "$fe(?!$te)" if length $te;
            push @clauses => "(?-1)";
            push @re      =>  qq /(?:$qb(?:@clauses)*$qe)/;
        }
    }

    $cache {$start} {$finish} = qr /(@re)/;
}


pattern name    => [qw /balanced -parens=() -begin= -end=/],
        create  => sub {
            my $flag = $_[1];
            unless (defined $flag -> {-begin} && length $flag -> {-begin} &&
                    defined $flag -> {-end}   && length $flag -> {-end}) {
                my @open  = grep {index ($flag->{-parens}, $_) >= 0}
                             ('[','(','{','<');
                my @close = map {$closer {$_}} @open;
                $flag -> {-begin} = join "|" => @open;
                $flag -> {-end}   = join "|" => @close;
            }
            return nested @$flag {qw /-begin -end/};
        },
        ;

}

1;

__END__

=pod

=head1 NAME

Regexp::Common::balanced -- provide regexes for strings with balanced
parenthesized delimiters or arbitrary delimiters.

=head1 SYNOPSIS

    use Regexp::Common qw /balanced/;

    while (<>) {
        /$RE{balanced}{-parens=>'()'}/
                                   and print q{balanced parentheses\n};
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

=head2 C<$RE{balanced}{-parens}>

Returns a pattern that matches a string that starts with the nominated
opening parenthesis or bracket, contains characters and properly nested
parenthesized subsequences, and ends in the matching parenthesis.

More than one type of parenthesis can be specified:

        $RE{balanced}{-parens=>'(){}'}

in which case all specified parenthesis types must be correctly balanced within
the string.

Since version 2013030901, C<< $1 >> will always be set (to the entire
matched substring), regardless whether C<< {-keep} >> is used or not.

=head2 C<< $RE{balanced}{-begin => "begin"}{-end => "end"} >>

Returns a pattern that matches a string that is properly balanced
using the I<begin> and I<end> strings as start and end delimiters.
Multiple sets of begin and end strings can be given by separating
them by C<|>s (which can be escaped with a backslash).

    qr/$RE{balanced}{-begin => "do|if|case"}{-end => "done|fi|esac"}/

will match properly balanced strings that either start with I<do> and
end with I<done>, start with I<if> and end with I<fi>, or start with
I<case> and end with I<esac>.

If I<-end> contains less cases than I<-begin>, the last case of I<-end>
is repeated. If it contains more cases than I<-begin>, the extra cases
are ignored. If either of I<-begin> or I<-end> isn't given, or is empty,
I<< -begin => '(' >> and I<< -end => ')' >> are assumed.

Since version 2013030901, C<< $1 >> will always be set (to the entire
matched substring), regardless whether C<< {-keep} >> is used or not.

=head2 Note

Since version 2013030901 the pattern will make of the recursive construct
C<< (?-1) >>, instead of using the problematic C<< (??{ }) >> construct.
This fixes an problem that was introduced in the 5.17 development track.

=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.be>.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2017, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.

=cut
EOB
# 2}}}
$Regexp_Common_Contents{'Common/delimited'} = <<'EOD';   # {{{2
package Regexp::Common::delimited;

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common qw /pattern clean no_defaults/;

use charnames ':full';

our $VERSION = '2017060201';

sub gen_delimited {

    my ($dels, $escs, $cdels) = @_;
    # return '(?:\S*)' unless $dels =~ /\S/;
    if (defined $escs && length $escs) {
        $escs  .= substr  ($escs, -1) x (length ($dels) - length  ($escs));
    }
    if (defined $cdels && length $cdels) {
        $cdels .= substr ($cdels, -1) x (length ($dels) - length ($cdels));
    }
    else {
        $cdels = $dels;
    }

    my @pat = ();
    for (my $i = 0; $i < length $dels; $i ++) {
        my $del  = quotemeta substr  ($dels, $i, 1);
        my $cdel = quotemeta substr ($cdels, $i, 1);
        my $esc  = defined $escs && length ($escs)
                           ? quotemeta substr ($escs, $i, 1) : "";
        if ($cdel eq $esc) {
            push @pat =>
                "(?k:$del)(?k:[^$cdel]*(?:(?:$cdel$cdel)[^$cdel]*)*)(?k:$cdel)";
        }
        elsif (length $esc) {
            push @pat =>
                "(?k:$del)(?k:[^$esc$cdel]*(?:$esc.[^$esc$cdel]*)*)(?k:$cdel)";
        }
        else {
            push @pat => "(?k:$del)(?k:[^$cdel]*)(?k:$cdel)";
        }
    }
    my $pat = join '|', @pat;
    return "(?k:(?|$pat))";
}

sub _croak {
    require Carp;
    goto &Carp::croak;
}

pattern name    => [qw( delimited -delim= -esc=\\ -cdelim= )],
        create  => sub {my $flags = $_[1];
                        _croak 'Must specify delimiter in $RE{delimited}'
                              unless length $flags->{-delim};
                        return gen_delimited (@{$flags}{-delim, -esc, -cdelim});
                   },
        ;

pattern name    => [qw( quoted -esc=\\ )],
        create  => sub {my $flags = $_[1];
                        return gen_delimited (q{"'`}, $flags -> {-esc});
                   },
        ;


my @bracket_pairs;
if ($] >= 5.014) {
    #
    # List from http://xahlee.info/comp/unicode_matching_brackets.html
    #
    @bracket_pairs =
        map {ref $_ ? $_ :
                /!/ ? [(do {my $x = $_; $x =~ s/!/TOP/;    $x},
                        do {my $x = $_; $x =~ s/!/BOTTOM/; $x})]
                    : [(do {my $x = $_; $x =~ s/\?/LEFT/;  $x},
                        do {my $x = $_; $x =~ s/\?/RIGHT/; $x})]}
            "? PARENTHESIS",
            "? SQUARE BRACKET",
            "? CURLY BRACKET",
            "? DOUBLE QUOTATION MARK",
            "? SINGLE QUOTATION MARK",
            "SINGLE ?-POINTING ANGLE QUOTATION MARK",
            "?-POINTING DOUBLE ANGLE QUOTATION MARK",
            "FULLWIDTH ? PARENTHESIS",
            "FULLWIDTH ? SQUARE BRACKET",
            "FULLWIDTH ? CURLY BRACKET",
            "FULLWIDTH ? WHITE PARENTHESIS",
            "? WHITE PARENTHESIS",
            "? WHITE SQUARE BRACKET",
            "? WHITE CURLY BRACKET",
            "? CORNER BRACKET",
            "? ANGLE BRACKET",
            "? DOUBLE ANGLE BRACKET",
            "? BLACK LENTICULAR BRACKET",
            "? TORTOISE SHELL BRACKET",
            "? BLACK TORTOISE SHELL BRACKET",
            "? WHITE CORNER BRACKET",
            "? WHITE LENTICULAR BRACKET",
            "? WHITE TORTOISE SHELL BRACKET",
            "HALFWIDTH ? CORNER BRACKET",
            "MATHEMATICAL ? WHITE SQUARE BRACKET",
            "MATHEMATICAL ? ANGLE BRACKET",
            "MATHEMATICAL ? DOUBLE ANGLE BRACKET",
            "MATHEMATICAL ? FLATTENED PARENTHESIS",
            "MATHEMATICAL ? WHITE TORTOISE SHELL BRACKET",
            "? CEILING",
            "? FLOOR",
            "Z NOTATION ? IMAGE BRACKET",
            "Z NOTATION ? BINDING BRACKET",
            [   "HEAVY SINGLE TURNED COMMA QUOTATION MARK ORNAMENT",
                "HEAVY SINGLE " .   "COMMA QUOTATION MARK ORNAMENT", ],
            [   "HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT",
                "HEAVY DOUBLE " .   "COMMA QUOTATION MARK ORNAMENT", ],
            "MEDIUM ? PARENTHESIS ORNAMENT",
            "MEDIUM FLATTENED ? PARENTHESIS ORNAMENT",
            "MEDIUM ? CURLY BRACKET ORNAMENT",
            "MEDIUM ?-POINTING ANGLE BRACKET ORNAMENT",
            "HEAVY ?-POINTING ANGLE QUOTATION MARK ORNAMENT",
            "HEAVY ?-POINTING ANGLE BRACKET ORNAMENT",
            "LIGHT ? TORTOISE SHELL BRACKET ORNAMENT",
            "ORNATE ? PARENTHESIS",
            "! PARENTHESIS",
            "! SQUARE BRACKET",
            "! CURLY BRACKET",
            "! TORTOISE SHELL BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? CORNER BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? WHITE CORNER BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? TORTOISE SHELL BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? BLACK LENTICULAR BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? WHITE LENTICULAR BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? ANGLE BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? DOUBLE ANGLE BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? SQUARE BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? CURLY BRACKET",
            "?-POINTING ANGLE BRACKET",
            "? ANGLE BRACKET WITH DOT",
            "?-POINTING CURVED ANGLE BRACKET",
            "SMALL ? PARENTHESIS",
            "SMALL ? CURLY BRACKET",
            "SMALL ? TORTOISE SHELL BRACKET",
            "SUPERSCRIPT ? PARENTHESIS",
            "SUBSCRIPT ? PARENTHESIS",
            "? SQUARE BRACKET WITH UNDERBAR",
            [    "LEFT SQUARE BRACKET WITH TICK IN TOP CORNER",
                "RIGHT SQUARE BRACKET WITH TICK IN BOTTOM CORNER", ],
            [    "LEFT SQUARE BRACKET WITH TICK IN BOTTOM CORNER",
                "RIGHT SQUARE BRACKET WITH TICK IN TOP CORNER", ],
            "? SQUARE BRACKET WITH QUILL",
            "TOP ? HALF BRACKET",
            "BOTTOM ? HALF BRACKET",
            "? S-SHAPED BAG DELIMITER",
            [    "LEFT ARC LESS-THAN BRACKET",
                "RIGHT ARC GREATER-THAN BRACKET",  ],
            [    "DOUBLE LEFT ARC GREATER-THAN BRACKET",
                "DOUBLE RIGHT ARC LESS-THAN BRACKET",  ],
            "? SIDEWAYS U BRACKET",
            "? DOUBLE PARENTHESIS",
            "? WIGGLY FENCE",
            "? DOUBLE WIGGLY FENCE",
            "? LOW PARAPHRASE BRACKET",
            "? RAISED OMISSION BRACKET",
            "? SUBSTITUTION BRACKET",
            "? DOTTED SUBSTITUTION BRACKET",
            "? TRANSPOSITION BRACKET",
            [   "OGHAM FEATHER MARK",
                "OGHAM REVERSED FEATHER MARK",  ],
            [   "TIBETAN MARK GUG RTAGS GYON",
                "TIBETAN MARK GUG RTAGS GYAS",  ],
            [   "TIBETAN MARK ANG KHANG GYON",
                "TIBETAN MARK ANG KHANG GYAS",  ],
    ;

    #
    # Filter out unknown characters; this may run on an older version
    # of Perl with an old version of Unicode.
    #
    @bracket_pairs = grep {defined charnames::string_vianame ($$_ [0]) &&
                           defined charnames::string_vianame ($$_ [1])}
                     @bracket_pairs;

    if (@bracket_pairs) {
        my  $delims = join "" => map {charnames::string_vianame ($$_ [0])}
                                     @bracket_pairs;
        my $cdelims = join "" => map {charnames::string_vianame ($$_ [1])}
                                     @bracket_pairs;

        pattern name   => [qw (bquoted -esc=\\)],
                create => sub {my $flags = $_ [1];
                               return gen_delimited ($delims, $flags -> {-esc},
                                                    $cdelims);
                          },
                version => 5.014,
                ;
    }
}


#
# Return the Unicode names of the pairs of matching delimiters.
#
sub bracket_pairs {@bracket_pairs}

1;

__END__

=pod

=head1 NAME

Regexp::Common::delimited -- provides a regex for delimited strings

=head1 SYNOPSIS

    use Regexp::Common qw /delimited/;

    while (<>) {
        /$RE{delimited}{-delim=>'"'}/  and print 'a \" delimited string';
        /$RE{delimited}{-delim=>'/'}/  and print 'a \/ delimited string';
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

=head2 C<$RE{delimited}{-delim}{-cdelim}{-esc}>

Returns a pattern that matches a single-character-delimited substring,
with optional internal escaping of the delimiter.

When C<-delim => I<S>> is specified, each character in the sequence I<S> is
a possible delimiter. There is no default delimiter, so this flag must always
be specified.

By default, the closing delimiter is the same character as the opening
delimiter. If this is not wanted, for instance, if you want to match
a string with symmetric delimiters, you can specify the closing delimiter(s)
with C<-cdelim => I<S>>. Each character in I<S> is matched with the
corresponding character supplied with the C<-delim> option. If the C<-cdelim>
option has less characters than the C<-delim> option, the last character
is repeated as often as necessary. If the C<-cdelim> option has more
characters than the C<-delim> option, the extra characters are ignored.

If C<-esc => I<S>> is specified, each character in the sequence I<S> is
the delimiter for the corresponding character in the C<-delim=I<S>> list.
The default escape is backslash.

For example:

   $RE{delimited}{-delim=>'"'}               # match "a \" delimited string"
   $RE{delimited}{-delim=>'"'}{-esc=>'"'}    # match "a "" delimited string"
   $RE{delimited}{-delim=>'/'}               # match /a \/ delimited string/
   $RE{delimited}{-delim=>q{'"}}             # match "string" or 'string'
   $RE{delimited}{-delim=>"("}{-cdelim=>")"} # match (string)

Under C<-keep> (See L<Regexp::Common>):

=over 4

=item $1

captures the entire match

=item $2

captures the opening delimiter

=item $3

captures delimited portion of the string

=item $4

captures the closing delimiter

=back

=head2 $RE{quoted}{-esc}

A synonym for C<< $RE {delimited} {-delim => q {'"`}} {...} >>.

=head2 $RE {bquoted} {-esc}

This is a pattern which matches delimited strings, where the delimiters
are a set of matching brackets. Currently, this comes 85 pairs. This
includes the 60 pairs of bidirection paired brackets, as listed
in L<< http://www.unicode.org/Public/UNIDATA/BidiBrackets.txt >>.

The other 25 pairs are the quotation marks, the double quotation
marks, the single and double pointing quoation marks, the heavy
single and double commas, 4 pairs of top-bottom parenthesis and
brackets, 9 pairs of presentation form for vertical brackets,
and the low paraphrase, raised omission, substitution, double
substitution, and transposition brackets.

In a future update, pairs may be added (or deleted).

This pattern requires perl 5.14.0 or higher.

For a full list of bracket pairs, inspect the output of
C<< Regexp::Common::delimited::bracket_pair () >>, which returns
a list of two element arrays, each holding the Unicode names of
matching pair of delimiters.

The C<< {-esc => I<S> } >> works as in the C<< $RE {delimited} >> pattern.

If C<< {-keep} >> is given, the following things will be captured:

=over 4

=item $1

captures the entire match

=item $2

captures the opening delimiter

=item $3

captures delimited portion of the string

=item $4

captures the closing delimiter

=back

=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.be>.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2017, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.

=cut
EOD
# 2}}}
    my $problems        = 0;
    $HAVE_Rexexp_Common = 0;
    my $dir             = "";
    if ($opt_sdir) {
        ++$TEMP_OFF;
        $dir = "$opt_sdir/$TEMP_OFF";
        File::Path::rmtree($dir) if     is_dir($dir);
        File::Path::mkpath($dir) unless is_dir($dir);
    } else {
        # let File::Temp create a suitable temporary directory
        $dir = tempdir( CLEANUP => 1 );  # 1 = delete on exit
        $TEMP_INST{ $dir } = "Regexp::Common";
    }
    print "Using temp dir [$dir] to install Regexp::Common\n" if $opt_v;
    my $Regexp_dir        = "$dir/Regexp";
    my $Regexp_Common_dir = "$dir/Regexp/Common";
    mkdir $Regexp_dir       ;
    mkdir $Regexp_Common_dir;

    foreach my $module_file (keys %Regexp_Common_Contents) {
        my $OUT = open_file('>', "$dir/Regexp/${module_file}.pm", 1);
        if (defined $OUT) {
            print $OUT $Regexp_Common_Contents{$module_file};
            $OUT->close;
        } else {
            warn "Failed to install Regexp::${module_file}.pm\n";
            $problems = 1;
        }
    }

    push @INC, $dir;
    eval "use Regexp::Common qw /comment RE_comment_HTML balanced/";
    $HAVE_Rexexp_Common = 1 unless $problems;
} # 1}}}
sub Install_Algorithm_Diff {                 # {{{1
    # Installs Tye McQueen's Algorithm::Diff module, v1.1902, into a
    # temporary directory for the duration of this run.

my $Algorithm_Diff_Contents = <<'EOAlgDiff'; # {{{2
package Algorithm::Diff;
# Skip to first "=head" line for documentation.
use strict;

use integer;    # see below in _replaceNextLargerWith() for mod to make
                # if you don't use this
use vars qw( $VERSION @EXPORT_OK );
$VERSION = 1.19_02;
#          ^ ^^ ^^-- Incremented at will
#          | \+----- Incremented for non-trivial changes to features
#          \-------- Incremented for fundamental changes
require Exporter;
*import    = \&Exporter::import;
@EXPORT_OK = qw(
    prepare LCS LCSidx LCS_length
    diff sdiff compact_diff
    traverse_sequences traverse_balanced
);

# McIlroy-Hunt diff algorithm
# Adapted from the Smalltalk code of Mario I. Wolczko, <mario@wolczko.com>
# by Ned Konz, perl@bike-nomad.com
# Updates by Tye McQueen, http://perlmonks.org/?node=tye

# Create a hash that maps each element of $aCollection to the set of
# positions it occupies in $aCollection, restricted to the elements
# within the range of indexes specified by $start and $end.
# The fourth parameter is a subroutine reference that will be called to
# generate a string to use as a key.
# Additional parameters, if any, will be passed to this subroutine.
#
# my $hashRef = _withPositionsOfInInterval( \@array, $start, $end, $keyGen );

sub _withPositionsOfInInterval
{
    my $aCollection = shift;    # array ref
    my $start       = shift;
    my $end         = shift;
    my $keyGen      = shift;
    my %d;
    my $index;
    for ( $index = $start ; $index <= $end ; $index++ )
    {
        my $element = $aCollection->[$index];
        my $key = &$keyGen( $element, @_ );
        if ( exists( $d{$key} ) )
        {
            unshift ( @{ $d{$key} }, $index );
        }
        else
        {
            $d{$key} = [$index];
        }
    }
    return wantarray ? %d : \%d;
}

# Find the place at which aValue would normally be inserted into the
# array. If that place is already occupied by aValue, do nothing, and
# return undef. If the place does not exist (i.e., it is off the end of
# the array), add it to the end, otherwise replace the element at that
# point with aValue.  It is assumed that the array's values are numeric.
# This is where the bulk (75%) of the time is spent in this module, so
# try to make it fast!

sub _replaceNextLargerWith
{
    my ( $array, $aValue, $high ) = @_;
    $high ||= $#$array;

    # off the end?
    if ( $high == -1 || $aValue > $array->[-1] )
    {
        push ( @$array, $aValue );
        return $high + 1;
    }

    # binary search for insertion point...
    my $low = 0;
    my $index;
    my $found;
    while ( $low <= $high )
    {
        $index = ( $high + $low ) / 2;

        # $index = int(( $high + $low ) / 2);  # without 'use integer'
        $found = $array->[$index];

        if ( $aValue == $found )
        {
            return undef;
        }
        elsif ( $aValue > $found )
        {
            $low = $index + 1;
        }
        else
        {
            $high = $index - 1;
        }
    }

    # now insertion point is in $low.
    $array->[$low] = $aValue;    # overwrite next larger
    return $low;
}

# This method computes the longest common subsequence in $a and $b.

# Result is array or ref, whose contents is such that
#   $a->[ $i ] == $b->[ $result[ $i ] ]
# foreach $i in ( 0 .. $#result ) if $result[ $i ] is defined.

# An additional argument may be passed; this is a hash or key generating
# function that should return a string that uniquely identifies the given
# element.  It should be the case that if the key is the same, the elements
# will compare the same. If this parameter is undef or missing, the key
# will be the element as a string.

# By default, comparisons will use "eq" and elements will be turned into keys
# using the default stringizing operator '""'.

# Additional parameters, if any, will be passed to the key generation
# routine.

sub _longestCommonSubsequence
{
    my $a        = shift;    # array ref or hash ref
    my $b        = shift;    # array ref or hash ref
    my $counting = shift;    # scalar
    my $keyGen   = shift;    # code ref
    my $compare;             # code ref

    if ( ref($a) eq 'HASH' )
    {                        # prepared hash must be in $b
        my $tmp = $b;
        $b = $a;
        $a = $tmp;
    }

    # Check for bogus (non-ref) argument values
    if ( !ref($a) || !ref($b) )
    {
        my @callerInfo = caller(1);
        die 'error: must pass array or hash references to ' . $callerInfo[3];
    }

    # set up code refs
    # Note that these are optimized.
    if ( !defined($keyGen) )    # optimize for strings
    {
        $keyGen = sub { $_[0] };
        $compare = sub { my ( $a, $b ) = @_; $a eq $b };
    }
    else
    {
        $compare = sub {
            my $a = shift;
            my $b = shift;
            &$keyGen( $a, @_ ) eq &$keyGen( $b, @_ );
        };
    }

    my ( $aStart, $aFinish, $matchVector ) = ( 0, $#$a, [] );
    my ( $prunedCount, $bMatches ) = ( 0, {} );

    if ( ref($b) eq 'HASH' )    # was $bMatches prepared for us?
    {
        $bMatches = $b;
    }
    else
    {
        my ( $bStart, $bFinish ) = ( 0, $#$b );

        # First we prune off any common elements at the beginning
        while ( $aStart <= $aFinish
            and $bStart <= $bFinish
            and &$compare( $a->[$aStart], $b->[$bStart], @_ ) )
        {
            $matchVector->[ $aStart++ ] = $bStart++;
            $prunedCount++;
        }

        # now the end
        while ( $aStart <= $aFinish
            and $bStart <= $bFinish
            and &$compare( $a->[$aFinish], $b->[$bFinish], @_ ) )
        {
            $matchVector->[ $aFinish-- ] = $bFinish--;
            $prunedCount++;
        }

        # Now compute the equivalence classes of positions of elements
        $bMatches =
          _withPositionsOfInInterval( $b, $bStart, $bFinish, $keyGen, @_ );
    }
    my $thresh = [];
    my $links  = [];

    my ( $i, $ai, $j, $k );
    for ( $i = $aStart ; $i <= $aFinish ; $i++ )
    {
        $ai = &$keyGen( $a->[$i], @_ );
        if ( exists( $bMatches->{$ai} ) )
        {
            $k = 0;
            for $j ( @{ $bMatches->{$ai} } )
            {

                # optimization: most of the time this will be true
                if ( $k and $thresh->[$k] > $j and $thresh->[ $k - 1 ] < $j )
                {
                    $thresh->[$k] = $j;
                }
                else
                {
                    $k = _replaceNextLargerWith( $thresh, $j, $k );
                }

                # oddly, it's faster to always test this (CPU cache?).
                if ( defined($k) )
                {
                    $links->[$k] =
                      [ ( $k ? $links->[ $k - 1 ] : undef ), $i, $j ];
                }
            }
        }
    }

    if (@$thresh)
    {
        return $prunedCount + @$thresh if $counting;
        for ( my $link = $links->[$#$thresh] ; $link ; $link = $link->[0] )
        {
            $matchVector->[ $link->[1] ] = $link->[2];
        }
    }
    elsif ($counting)
    {
        return $prunedCount;
    }

    return wantarray ? @$matchVector : $matchVector;
}

sub traverse_sequences
{
    my $a                 = shift;          # array ref
    my $b                 = shift;          # array ref
    my $callbacks         = shift || {};
    my $keyGen            = shift;
    my $matchCallback     = $callbacks->{'MATCH'} || sub { };
    my $discardACallback  = $callbacks->{'DISCARD_A'} || sub { };
    my $finishedACallback = $callbacks->{'A_FINISHED'};
    my $discardBCallback  = $callbacks->{'DISCARD_B'} || sub { };
    my $finishedBCallback = $callbacks->{'B_FINISHED'};
    my $matchVector = _longestCommonSubsequence( $a, $b, 0, $keyGen, @_ );

    # Process all the lines in @$matchVector
    my $lastA = $#$a;
    my $lastB = $#$b;
    my $bi    = 0;
    my $ai;

    for ( $ai = 0 ; $ai <= $#$matchVector ; $ai++ )
    {
        my $bLine = $matchVector->[$ai];
        if ( defined($bLine) )    # matched
        {
            &$discardBCallback( $ai, $bi++, @_ ) while $bi < $bLine;
            &$matchCallback( $ai,    $bi++, @_ );
        }
        else
        {
            &$discardACallback( $ai, $bi, @_ );
        }
    }

    # The last entry (if any) processed was a match.
    # $ai and $bi point just past the last matching lines in their sequences.

    while ( $ai <= $lastA or $bi <= $lastB )
    {

        # last A?
        if ( $ai == $lastA + 1 and $bi <= $lastB )
        {
            if ( defined($finishedACallback) )
            {
                &$finishedACallback( $lastA, @_ );
                $finishedACallback = undef;
            }
            else
            {
                &$discardBCallback( $ai, $bi++, @_ ) while $bi <= $lastB;
            }
        }

        # last B?
        if ( $bi == $lastB + 1 and $ai <= $lastA )
        {
            if ( defined($finishedBCallback) )
            {
                &$finishedBCallback( $lastB, @_ );
                $finishedBCallback = undef;
            }
            else
            {
                &$discardACallback( $ai++, $bi, @_ ) while $ai <= $lastA;
            }
        }

        &$discardACallback( $ai++, $bi, @_ ) if $ai <= $lastA;
        &$discardBCallback( $ai, $bi++, @_ ) if $bi <= $lastB;
    }

    return 1;
}

sub traverse_balanced
{
    my $a                 = shift;              # array ref
    my $b                 = shift;              # array ref
    my $callbacks         = shift || {};
    my $keyGen            = shift;
    my $matchCallback     = $callbacks->{'MATCH'} || sub { };
    my $discardACallback  = $callbacks->{'DISCARD_A'} || sub { };
    my $discardBCallback  = $callbacks->{'DISCARD_B'} || sub { };
    my $changeCallback    = $callbacks->{'CHANGE'};
    my $matchVector = _longestCommonSubsequence( $a, $b, 0, $keyGen, @_ );

    # Process all the lines in match vector
    my $lastA = $#$a;
    my $lastB = $#$b;
    my $bi    = 0;
    my $ai    = 0;
    my $ma    = -1;
    my $mb;

    while (1)
    {

        # Find next match indices $ma and $mb
        do {
            $ma++;
        } while(
                $ma <= $#$matchVector
            &&  !defined $matchVector->[$ma]
        );

        last if $ma > $#$matchVector;    # end of matchVector?
        $mb = $matchVector->[$ma];

        # Proceed with discard a/b or change events until
        # next match
        while ( $ai < $ma || $bi < $mb )
        {

            if ( $ai < $ma && $bi < $mb )
            {

                # Change
                if ( defined $changeCallback )
                {
                    &$changeCallback( $ai++, $bi++, @_ );
                }
                else
                {
                    &$discardACallback( $ai++, $bi, @_ );
                    &$discardBCallback( $ai, $bi++, @_ );
                }
            }
            elsif ( $ai < $ma )
            {
                &$discardACallback( $ai++, $bi, @_ );
            }
            else
            {

                # $bi < $mb
                &$discardBCallback( $ai, $bi++, @_ );
            }
        }

        # Match
        &$matchCallback( $ai++, $bi++, @_ );
    }

    while ( $ai <= $lastA || $bi <= $lastB )
    {
        if ( $ai <= $lastA && $bi <= $lastB )
        {

            # Change
            if ( defined $changeCallback )
            {
                &$changeCallback( $ai++, $bi++, @_ );
            }
            else
            {
                &$discardACallback( $ai++, $bi, @_ );
                &$discardBCallback( $ai, $bi++, @_ );
            }
        }
        elsif ( $ai <= $lastA )
        {
            &$discardACallback( $ai++, $bi, @_ );
        }
        else
        {

            # $bi <= $lastB
            &$discardBCallback( $ai, $bi++, @_ );
        }
    }

    return 1;
}

sub prepare
{
    my $a       = shift;    # array ref
    my $keyGen  = shift;    # code ref

    # set up code ref
    $keyGen = sub { $_[0] } unless defined($keyGen);

    return scalar _withPositionsOfInInterval( $a, 0, $#$a, $keyGen, @_ );
}

sub LCS
{
    my $a = shift;                  # array ref
    my $b = shift;                  # array ref or hash ref
    my $matchVector = _longestCommonSubsequence( $a, $b, 0, @_ );
    my @retval;
    my $i;
    for ( $i = 0 ; $i <= $#$matchVector ; $i++ )
    {
        if ( defined( $matchVector->[$i] ) )
        {
            push ( @retval, $a->[$i] );
        }
    }
    return wantarray ? @retval : \@retval;
}

sub LCS_length
{
    my $a = shift;                          # array ref
    my $b = shift;                          # array ref or hash ref
    return _longestCommonSubsequence( $a, $b, 1, @_ );
}

sub LCSidx
{
    my $a= shift @_;
    my $b= shift @_;
    my $match= _longestCommonSubsequence( $a, $b, 0, @_ );
    my @am= grep defined $match->[$_], 0..$#$match;
    my @bm= @{$match}[@am];
    return \@am, \@bm;
}

sub compact_diff
{
    my $a= shift @_;
    my $b= shift @_;
    my( $am, $bm )= LCSidx( $a, $b, @_ );
    my @cdiff;
    my( $ai, $bi )= ( 0, 0 );
    push @cdiff, $ai, $bi;
    while( 1 ) {
        while(  @$am  &&  $ai == $am->[0]  &&  $bi == $bm->[0]  ) {
            shift @$am;
            shift @$bm;
            ++$ai, ++$bi;
        }
        push @cdiff, $ai, $bi;
        last   if  ! @$am;
        $ai = $am->[0];
        $bi = $bm->[0];
        push @cdiff, $ai, $bi;
    }
    push @cdiff, 0+@$a, 0+@$b
        if  $ai < @$a || $bi < @$b;
    return wantarray ? @cdiff : \@cdiff;
}

sub diff
{
    my $a      = shift;    # array ref
    my $b      = shift;    # array ref
    my $retval = [];
    my $hunk   = [];
    my $discard = sub {
        push @$hunk, [ '-', $_[0], $a->[ $_[0] ] ];
    };
    my $add = sub {
        push @$hunk, [ '+', $_[1], $b->[ $_[1] ] ];
    };
    my $match = sub {
        push @$retval, $hunk
            if 0 < @$hunk;
        $hunk = []
    };
    traverse_sequences( $a, $b,
        { MATCH => $match, DISCARD_A => $discard, DISCARD_B => $add }, @_ );
    &$match();
    return wantarray ? @$retval : $retval;
}

sub sdiff
{
    my $a      = shift;    # array ref
    my $b      = shift;    # array ref
    my $retval = [];
    my $discard = sub { push ( @$retval, [ '-', $a->[ $_[0] ], "" ] ) };
    my $add = sub { push ( @$retval, [ '+', "", $b->[ $_[1] ] ] ) };
    my $change = sub {
        push ( @$retval, [ 'c', $a->[ $_[0] ], $b->[ $_[1] ] ] );
    };
    my $match = sub {
        push ( @$retval, [ 'u', $a->[ $_[0] ], $b->[ $_[1] ] ] );
    };
    traverse_balanced(
        $a,
        $b,
        {
            MATCH     => $match,
            DISCARD_A => $discard,
            DISCARD_B => $add,
            CHANGE    => $change,
        },
        @_
    );
    return wantarray ? @$retval : $retval;
}

########################################
my $Root= __PACKAGE__;
package Algorithm::Diff::_impl;
use strict;

sub _Idx()  { 0 } # $me->[_Idx]: Ref to array of hunk indices
            # 1   # $me->[1]: Ref to first sequence
            # 2   # $me->[2]: Ref to second sequence
sub _End()  { 3 } # $me->[_End]: Diff between forward and reverse pos
sub _Same() { 4 } # $me->[_Same]: 1 if pos 1 contains unchanged items
sub _Base() { 5 } # $me->[_Base]: Added to range's min and max
sub _Pos()  { 6 } # $me->[_Pos]: Which hunk is currently selected
sub _Off()  { 7 } # $me->[_Off]: Offset into _Idx for current position
sub _Min() { -2 } # Added to _Off to get min instead of max+1

sub Die
{
    require Carp;
    Carp::confess( @_ );
}

sub _ChkPos
{
    my( $me )= @_;
    return   if  $me->[_Pos];
    my $meth= ( caller(1) )[3];
    Die( "Called $meth on 'reset' object" );
}

sub _ChkSeq
{
    my( $me, $seq )= @_;
    return $seq + $me->[_Off]
        if  1 == $seq  ||  2 == $seq;
    my $meth= ( caller(1) )[3];
    Die( "$meth: Invalid sequence number ($seq); must be 1 or 2" );
}

sub getObjPkg
{
    my( $us )= @_;
    return ref $us   if  ref $us;
    return $us . "::_obj";
}

sub new
{
    my( $us, $seq1, $seq2, $opts ) = @_;
    my @args;
    for( $opts->{keyGen} ) {
        push @args, $_   if  $_;
    }
    for( $opts->{keyGenArgs} ) {
        push @args, @$_   if  $_;
    }
    my $cdif= Algorithm::Diff::compact_diff( $seq1, $seq2, @args );
    my $same= 1;
    if(  0 == $cdif->[2]  &&  0 == $cdif->[3]  ) {
        $same= 0;
        splice @$cdif, 0, 2;
    }
    my @obj= ( $cdif, $seq1, $seq2 );
    $obj[_End] = (1+@$cdif)/2;
    $obj[_Same] = $same;
    $obj[_Base] = 0;
    my $me = bless \@obj, $us->getObjPkg();
    $me->Reset( 0 );
    return $me;
}

sub Reset
{
    my( $me, $pos )= @_;
    $pos= int( $pos || 0 );
    $pos += $me->[_End]
        if  $pos < 0;
    $pos= 0
        if  $pos < 0  ||  $me->[_End] <= $pos;
    $me->[_Pos]= $pos || !1;
    $me->[_Off]= 2*$pos - 1;
    return $me;
}

sub Base
{
    my( $me, $base )= @_;
    my $oldBase= $me->[_Base];
    $me->[_Base]= 0+$base   if  defined $base;
    return $oldBase;
}

sub Copy
{
    my( $me, $pos, $base )= @_;
    my @obj= @$me;
    my $you= bless \@obj, ref($me);
    $you->Reset( $pos )   if  defined $pos;
    $you->Base( $base );
    return $you;
}

sub Next {
    my( $me, $steps )= @_;
    $steps= 1   if  ! defined $steps;
    if( $steps ) {
        my $pos= $me->[_Pos];
        my $new= $pos + $steps;
        $new= 0   if  $pos  &&  $new < 0;
        $me->Reset( $new )
    }
    return $me->[_Pos];
}

sub Prev {
    my( $me, $steps )= @_;
    $steps= 1   if  ! defined $steps;
    my $pos= $me->Next(-$steps);
    $pos -= $me->[_End]   if  $pos;
    return $pos;
}

sub Diff {
    my( $me )= @_;
    $me->_ChkPos();
    return 0   if  $me->[_Same] == ( 1 & $me->[_Pos] );
    my $ret= 0;
    my $off= $me->[_Off];
    for my $seq ( 1, 2 ) {
        $ret |= $seq
            if  $me->[_Idx][ $off + $seq + _Min ]
            <   $me->[_Idx][ $off + $seq ];
    }
    return $ret;
}

sub Min {
    my( $me, $seq, $base )= @_;
    $me->_ChkPos();
    my $off= $me->_ChkSeq($seq);
    $base= $me->[_Base] if !defined $base;
    return $base + $me->[_Idx][ $off + _Min ];
}

sub Max {
    my( $me, $seq, $base )= @_;
    $me->_ChkPos();
    my $off= $me->_ChkSeq($seq);
    $base= $me->[_Base] if !defined $base;
    return $base + $me->[_Idx][ $off ] -1;
}

sub Range {
    my( $me, $seq, $base )= @_;
    $me->_ChkPos();
    my $off = $me->_ChkSeq($seq);
    if( !wantarray ) {
        return  $me->[_Idx][ $off ]
            -   $me->[_Idx][ $off + _Min ];
    }
    $base= $me->[_Base] if !defined $base;
    return  ( $base + $me->[_Idx][ $off + _Min ] )
        ..  ( $base + $me->[_Idx][ $off ] - 1 );
}

sub Items {
    my( $me, $seq )= @_;
    $me->_ChkPos();
    my $off = $me->_ChkSeq($seq);
    if( !wantarray ) {
        return  $me->[_Idx][ $off ]
            -   $me->[_Idx][ $off + _Min ];
    }
    return
        @{$me->[$seq]}[
                $me->[_Idx][ $off + _Min ]
            ..  ( $me->[_Idx][ $off ] - 1 )
        ];
}

sub Same {
    my( $me )= @_;
    $me->_ChkPos();
    return wantarray ? () : 0
        if  $me->[_Same] != ( 1 & $me->[_Pos] );
    return $me->Items(1);
}

my %getName;
BEGIN {
    %getName= (
        same => \&Same,
        diff => \&Diff,
        base => \&Base,
        min  => \&Min,
        max  => \&Max,
        range=> \&Range,
        items=> \&Items, # same thing
    );
}

sub Get
{
    my $me= shift @_;
    $me->_ChkPos();
    my @value;
    for my $arg (  @_  ) {
        for my $word (  split ' ', $arg  ) {
            my $meth;
            if(     $word !~ /^(-?\d+)?([a-zA-Z]+)([12])?$/
                ||  not  $meth= $getName{ lc $2 }
            ) {
                Die( $Root, ", Get: Invalid request ($word)" );
            }
            my( $base, $name, $seq )= ( $1, $2, $3 );
            push @value, scalar(
                4 == length($name)
                    ? $meth->( $me )
                    : $meth->( $me, $seq, $base )
            );
        }
    }
    if(  wantarray  ) {
        return @value;
    } elsif(  1 == @value  ) {
        return $value[0];
    }
    Die( 0+@value, " values requested from ",
        $Root, "'s Get in scalar context" );
}


my $Obj= getObjPkg($Root);
no strict 'refs';

for my $meth (  qw( new getObjPkg )  ) {
    *{$Root."::".$meth} = \&{$meth};
    *{$Obj ."::".$meth} = \&{$meth};
}
for my $meth (  qw(
    Next Prev Reset Copy Base Diff
    Same Items Range Min Max Get
    _ChkPos _ChkSeq
)  ) {
    *{$Obj."::".$meth} = \&{$meth};
}

1;
# This version released by Tye McQueen (http://perlmonks.org/?node=tye).
#
# =head1 LICENSE
#
# Parts Copyright (c) 2000-2004 Ned Konz.  All rights reserved.
# Parts by Tye McQueen.
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl.
#
# =head1 MAILING LIST
#
# Mark-Jason still maintains a mailing list.  To join a low-volume mailing
# list for announcements related to diff and Algorithm::Diff, send an
# empty mail message to mjd-perl-diff-request@plover.com.
# =head1 CREDITS
#
# Versions through 0.59 (and much of this documentation) were written by:
#
# Mark-Jason Dominus, mjd-perl-diff@plover.com
#
# This version borrows some documentation and routine names from
# Mark-Jason's, but Diff.pm's code was completely replaced.
#
# This code was adapted from the Smalltalk code of Mario Wolczko
# <mario@wolczko.com>, which is available at
# ftp://st.cs.uiuc.edu/pub/Smalltalk/MANCHESTER/manchester/4.0/diff.st
#
# C<sdiff> and C<traverse_balanced> were written by Mike Schilli
# <m@perlmeister.com>.
#
# The algorithm is that described in
# I<A Fast Algorithm for Computing Longest Common Subsequences>,
# CACM, vol.20, no.5, pp.350-353, May 1977, with a few
# minor improvements to improve the speed.
#
# Much work was done by Ned Konz (perl@bike-nomad.com).
#
# The OO interface and some other changes are by Tye McQueen.
#
EOAlgDiff
# 2}}}
    my $problems        = 0;
    $HAVE_Algorithm_Diff = 0;
    my $dir             = "";
    if ($opt_sdir) {
        ++$TEMP_OFF;
        $dir = "$opt_sdir/$TEMP_OFF";
        File::Path::rmtree($dir) if     is_dir($dir);
        File::Path::mkpath($dir) unless is_dir($dir);
    } else {
        # let File::Temp create a suitable temporary directory
        $dir = tempdir( CLEANUP => 1 );  # 1 = delete on exit
        $TEMP_INST{ $dir } = "Algorithm::Diff";
    }
    print "Using temp dir [$dir] to install Algorithm::Diff\n" if $opt_v;
    my $Algorithm_dir      = "$dir/Algorithm";
    my $Algorithm_Diff_dir = "$dir/Algorithm/Diff";
    mkdir $Algorithm_dir     ;
    mkdir $Algorithm_Diff_dir;

    my $OUT = open_file('>', "$dir/Algorithm/Diff.pm", 1);
    if (defined $OUT) {
        print $OUT $Algorithm_Diff_Contents;
        $OUT->close;
    } else {
        warn "Failed to install Algorithm/Diff.pm\n";
        $problems = 1;
    }

    push @INC, $dir;  # between this & Regexp::Common only need to do once
    eval "use Algorithm::Diff qw / sdiff /";
    $HAVE_Algorithm_Diff = 1 unless $problems;
} # 1}}}
__END__
mode values (stat $item)[2]
       Unix    Windows
file:  33188   33206
dir :  16832   16895
link:  33261   33206
pipe:   4544    null
