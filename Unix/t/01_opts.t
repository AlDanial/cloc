#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
use File::Copy "cp";
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
                {
                    'name' => '--not-match-d (github issue #114 T1)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file issues/114',
                    'ref'  => '../tests/outputs/issues/114/T1.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T2)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --not-match-d bar issues/114',
                    'ref'  => '../tests/outputs/issues/114/T2.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T3)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --not-match-d bee issues/114',
                    'ref'  => '../tests/outputs/issues/114/T3.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T4)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --not-match-d bar/bee issues/114',
                    'ref'  => '../tests/outputs/issues/114/T4.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T5)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --fullpath --not-match-d   bar issues/114',
                    'ref'  => '../tests/outputs/issues/114/T5.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T6)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --fullpath --not-match-d ./bar issues/114',
                    'ref'  => '../tests/outputs/issues/114/T6.yaml',
                },
                {
                    'name' => '--not-match-d (github issue #114 T7)',
                    'cd'   => '../tests/inputs',
                    'args' => '--by-file --fullpath --not-match-d bar/bee issues/114',
                    'ref'  => '../tests/outputs/issues/114/T7.yaml',
                },
                {
                    'name' => 'git submodule handling (github issue #131 T1)',
                    'cd'   => '../tests/inputs',
                    'args' => 'issues/131',
                    'ref'  => '../tests/outputs/issues/131/T1.yaml',
                },
                {
                    'name' => 'git submodule handling (github issue #131 T2)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git issues/131',
                    'ref'  => '../tests/outputs/issues/131/T2.yaml',
                },
                {
                    'name' => 'all files (github issue #132 T1)',
                    'cd'   => '../tests/inputs',
                    'args' => 'issues/132',
                    'ref'  => '../tests/outputs/issues/132/T1.yaml',
                },
                {
                    'name' => '--vcs git issues/132 (github issue #132 T2)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git issues/132',
                    'ref'  => '../tests/outputs/issues/132/T2.yaml',
                },
                {
                    'name' => '--vcs-git --exclude-dir ignore_dir (github issue #132 T3)',
                    'cd'   => '../tests/inputs/issues/132',
                    'args' => '--vcs git --exclude-dir ignore_dir .',
                    'ref'  => '../tests/outputs/issues/132/T3.yaml',
                },
                {
                    'name' => '--vcs git --fullpath --not-match-d issues/132/ignore_dir (github issue #132 T4)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git --fullpath --not-match-d issues/132/ignore_dir issues/132',
                    'ref'  => '../tests/outputs/issues/132/T4.yaml',
                },
                {
                    'name' => '--vcs git --match-f C-Ansi (github issue #132 T5)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git --match-f C-Ansi issues/132',
                    'ref'  => '../tests/outputs/issues/132/T5.yaml',
                },
                {
                    'name' => '--vcs git --match-f "\.c$" (github issue #132 T6)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs git --match-f "\.c$" issues/132',
                    'ref'  => '../tests/outputs/issues/132/T6.yaml',
                },
                {
                    'name' => '--vcs "find X" (github issue #147)',
                    'cd'   => '../tests/inputs',
                    'args' => '--vcs "find foo_bar"',
                    'ref'  => '../tests/outputs/issues/147/T1.yaml',
                },
                {
                    'name' => '--read-lang-def w/remove_between_general (github issue #166)',
                    'cd'   => '../tests/inputs/issues/166',
                    'args' => '--read-lang-def X fake.thy',
                    'ref'  => '../tests/outputs/issues/166/fake.thy.yaml',
                },
                {
                    'name' => '--read-lang-def w/triple_extension',
                    'cd'   => '../tests/inputs',
                    'args' => '--read-lang-def triple_lang_def.txt custom.triple.extension.js',
                    'ref'  => '../tests/outputs/custom.triple.extension.js.yaml',
                },
                {
                    'name' => 'Forth balanced parentheses #1 (github issue #183)',
                    'cd'   => '../tests/inputs/issues/183',
                    'args' => 'file.fth',
                    'ref'  => '../tests/outputs/issues/183/file.fth.yaml',
                },
                {
                    'name' => 'Forth balanced parentheses #2 (github issue #183)',
                    'cd'   => '../tests/inputs/issues/183',
                    'args' => 'eval1957.SACunidir.fr',
                    'ref'  => '../tests/outputs/issues/183/eval1957.SACunidir.fr.yaml',
                },
            );

# Create test input for issue #132 which needs data not in the git repo.
# Silently fail if file/dir already exists.
mkdir "../tests/inputs/issues/132/ignore_git";
cp    "../tests/inputs/hi.py", "../tests/inputs/issues/132/ignore_git/";

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

sub load_yaml {                             # {{{1
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
} # 1}}}
