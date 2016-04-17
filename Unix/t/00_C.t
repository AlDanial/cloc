#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
my @Tests = (   {
                    'name' => 'C simple',
                    'args' => '../tests/inputs/C-Ansi.c',
                    'ref'  => '../tests/outputs/00_C.yaml',
                },
            );

my $Verbose = 1;

my $results = 'results.yaml';
my $Run = "../cloc --yaml --out $results ";
foreach my $t (@Tests) {
    print  $Run . $t->{'args'} if $Verbose;
    system($Run . $t->{'args'});
    ok(-e $results, $t->{'name'} . " created output");
    my %ref  = load_yaml($t->{'ref'});
    my %this = load_yaml($results);
    is_deeply(\%ref, \%this, $t->{'name'} . " results match");
}
done_testing();

sub load_yaml {
    my ($file, ) = @_;
    my %result = ();
    open IN, $file or return %result;
    my $section = undef;
    while (<IN>) {
        next if /^\s*#/ or /^--/;
        if (/^(\w+)\s*:\s*$/) {
            $section = $1;
            next;
        }
        next unless defined $section;
        next if $section eq 'header';
        chomp;
        s/\s+//g;
        my ($K, $V) = split(':');
        $result{$section}{$K} = $V;
    }
    close IN;
    return %result
}
