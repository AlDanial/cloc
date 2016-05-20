#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
use Cwd;
my @Tests = (
                {
                    'name' => '--exclude-dir 1 (baseline for github issue #82)',
                    'args' => '--exclude-dir cc ../tests/inputs/dd',
                    'ref'  => '../tests/outputs/exclude_dir_1.yaml',
                },
                {
                    'name' => '--exclude-dir 2 (github issue #82)',
                    'cd'   => '../tests/inputs/dd',
                    'args' => '--exclude-dir cc *',
                    'ref'  => '../tests/outputs/exclude_dir_1.yaml',
                },
                {
                    'name' => '--not-match-d',
                    'cd'   => '../tests/inputs/dd',
                    'args' => '--not-match-d cc *',
                    'ref'  => '../tests/outputs/exclude_dir_1.yaml',
                },
            );

my $Verbose = 0;

my $results = 'results.yaml';
my $work_dir = getcwd;
my $cloc    = "$work_dir/../cloc";
my $Run = "$cloc --quiet --yaml --out $results ";
foreach my $t (@Tests) {
    chdir($t->{'cd'}) if defined $t->{'cd'};
    print  $Run . $t->{'args'} if $Verbose;
    system($Run . $t->{'args'});
    ok(-e $results, $t->{'name'} . " created output");
    my %this = load_yaml($results);
    unlink $results;
    chdir($work_dir) if defined $t->{'cd'};
    my %ref  = load_yaml($t->{'ref'});
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
