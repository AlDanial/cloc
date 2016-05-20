#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
my @Tests = (   {
                    'name' => 'exclude dir 1 (github issue #82)',
                    'args' => '--exclude-dir cc ../tests/inputs/dd',
                    'ref'  => '../tests/outputs/exclude_dir_1.yaml',
                },

            );

my $Verbose = 0;

my $results = 'results.yaml';
my $Run = "../cloc --quiet --yaml --out $results ";
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
    if (!-r $file) {
        warn "File not found: $file\n"; 
        return %result;
    }
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
