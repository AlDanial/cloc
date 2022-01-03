#!/usr/bin/env perl
#
# TODO wonderbird: Before creating the pull request, delete this file.
#
# Collection of X++ tests.
#
# These tests are used during development of the X++ language definition.
# This file makes it easy to run a subset of tests for TDDing the feature.
#
use warnings;
use strict;
use Test::More;
use Cwd;
my @Tests = (
                {
                    'name' => 'X++',
                    'ref'  => './tests/outputs/xplusplus.xpo.yaml',
                    'args' => './tests/inputs/xplusplus.xpo',
                },
            );

my $Verbose = 1;

my $results  = 'results.yaml';
my $work_dir = getcwd;
my $cloc     = "$work_dir/cloc";
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
