#!/usr/bin/perl -w

=head1 NAME 

our_wrapper.pl - a wrapper calling provided algorithms

=head1 SYNOPSIS

our_wrapper.pl --program 'text' 
 --inputfiles file1.xml,file2.xml
 --varfiles varInfo1.xml,varInfo2.xml
 --zfiles zfile1.xml,zfile2.xml
 --variables variable1,variable2
 --bbox west,south,east,north
 --starttime YYYY-MM-DDTHH:MI:SSZ
 --endtime YYYY-MM-DDTHH:MI:SSZ
 [--comparison comparison_type]
 [--dateline-method stitch]
 [--debug [0-3]]
 [--time-axis]
 [--output-type (filelist|ncfile)]
 [--units units1,units2,units-cfg.xml]
 
=head1 DESCRIPTION

time_code.pl simplifies and regularizes the calling arguments for
 provided algorithims. 
=over

=item --program

Filename (no directory, ideally) of algorithm executable, plus any fixed
arguments as necessary. E.g., "kmeans.pl -k 3"

=item --inputfiles

Comma separated list of input XML G6 Manifest files. 
There is typically only file for most 1-variable-at-a-time services
(like area averager), but it may be two files for some comparisons.

=item --varfiles

Comma separated list of input XML files with informatino about the data fields.
There is typically only file for most 1-variable-at-a-time services
(like area averager), but it may be two files for some comparisons.

=item --variables

Comma separated list of variables
There is typically only one for most 1-variable-at-a-time services
(like area averager), but it may be two for some comparisons.

=item --bbox

Comma-separated west,south,east,north boundaries.
Typically, the algorithm is expected to subset within these boundaries.

=item --outfile

Output XML manifest file listing the file(s) created by the algorithm.

=item --zfiles

Comma separated list of input XML zslice files, showing what z level the user
has selected.

=item --starttime

Start time in format YYYY-MM-DDTHH:MM:SSZ.

=item --endtime

End time in format YYYY-MM-DDTHH:MM:SSZ.

=item --comparison

Word or phrase describing the comparison type, 
e.g., "minus", "divided by", "regressed against"

=item --debug

Debug level, 0-3.

=item --output-file-root

Root for the filename of the output data file.

=item --session-dir

Session directory. Default is '.'.

=item --time-axis

Whether the output data has a time axis. This is true for someting and time-axis.
If unset, assumes no time axis.
This is what controls whether Something::Visualizer::TimeTics is invoked.

=item --output-type

If assigned the value 'filelist', the wrapper treats the output file argument as the 
name of the file that lists all the output files

=item --units units1.xml,units2.xml,units-cfg.xml

This argument tells the wrapper and/or algorithm to do units conversion, taking
a comma-separated list of destination units: 
the first one (or two for comparison) is the user
input, the last one is the units conversion configuration file.

=cut

# $Id: our_wrapper.pl,v 1.16 2015/04/16 22:15:42 cls Exp $
# -@@@ GSdd4

use strict;
use Getopt::Long;
use Something::Algorithm::Wrapper;

use vars qw($program $comparison $bbox
    $inputfiles $outfile $zfiles $varfiles $units
    $variables $starttime $endtime
    $mintimesteps $outputfileroot
    $sessiondir
    $comparison
    $name
    $debug
    $dateline
    $time_axis
    $output_type
    $shapefile
    $group
    $jobs
);

GetOptions(
    "program=s"            => \$program,
    "name=s"               => \$name,
    "starttime=s"          => \$starttime,
    "endtime=s"            => \$endtime,
    "bbox=s"               => \$bbox,
    "inputfiles=s"         => \$inputfiles,
    "outfile=s"            => \$outfile,
    "varfiles=s"           => \$varfiles,
    "zfiles=s"             => \$zfiles,
    "variables=s"          => \$variables,
    "minimum-time-steps=i" => \$mintimesteps,
    "output-file-root=s"   => \$outputfileroot,
    "session-dir=s"        => \$sessiondir,
    "comparison=s"         => \$comparison,
    "dateline=s"           => \$dateline,
    "debug=i"              => \$debug,
    "time-axis"            => \$time_axis,
    "output-type=s"        => \$output_type,
    "units=s"              => \$units,
    "group=s"              => \$group,
    "shapefile|S=s"        => \$shapefile,
    "jobs=i"               => \$jobs
);
my %args = (
    'program'          => $program,
    'name'             => $name,
    'time-axis'        => $time_axis,
    'dateline'         => $dateline,
    'starttime'        => $starttime,
    'endtime'          => $endtime,
    'bbox'             => $bbox,
    'outfile'          => $outfile,
    'output-file-root' => $outputfileroot,
    'debug'            => $debug,
    'varfiles'         => $varfiles,
    'variables'        => $variables,
    'inputfiles'       => $inputfiles,
    'session-dir'      => $sessiondir,
    'zfiles'           => $zfiles,
    'output-type'      => $output_type,
    'units'            => $units,
    'group'            => $group,
    'shapefile'        => $shapefile,
    'jobs'             => $jobs
);

if ($comparison) {
    $args{'comparison'}         = $comparison;
    $args{'minimum-time-steps'} = $mintimesteps;
}
my $outnc = Something::Algorithm::Wrapper::run(%args);
exit( !( -s $outnc ) );
