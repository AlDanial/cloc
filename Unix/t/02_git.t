#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
use File::Copy "cp";
use Cwd;
my @Tests = (
                {
                    'name' => 'direct count git hash 1',
                    'args' => 'd9b672643d',
                    'ref'  => '../tests/outputs/git_tests/d9b672643d.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                {
                    'name' => 'direct count git hash 2',
                    'args' => 'f647093e8be3',
                    'ref'  => '../tests/outputs/git_tests/f647093e8be3.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                {
                    'name' => 'tar file f647093e8',
                    'args' => '../../tests/inputs/git_tests/contents_f647093e8.tar.gz',
                    'ref'  => '../tests/outputs/git_tests/contents_f647093e8.tar.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                {
                    'name' => 'diff f647093e8 to tar file f647093e8',
                    'args' => '--git --diff f647093e8 ../../tests/inputs/git_tests/contents_f647093e8.tar.gz',
                    'ref'  => '../tests/outputs/git_tests/diff_contents_f647093e8.tar.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                {
                    'name' => 'diff f15bf042b f647093e8b',
                    'args' => '--git --diff f15bf042b f647093e8b',
                    'ref'  => '../tests/outputs/git_tests/diff_f15bf042b_f647093e8b.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                {
                    'name' => 'diff commit with only deleted file',
                    'args' => '--strip-str-comments --git --diff 04179b6 ae0d26e',
                    'ref'  => '../tests/outputs/git_tests/04179b6_ae0d26e.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                {
                    'name' => 'diff commit with only added file',
                    'args' => '--strip-str-comments --git --diff f15bf04 d9b6726',
                    'ref'  => '../tests/outputs/git_tests/f15bf04_d9b6726.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                # cannot use HEAD~1 HEAD as the diff is not deterministic
                {
                    'name' => 'count and diff part I',
                    'args' => '--strip-str-comments  --git --count-and-diff 3b359b4904 f647093e8be',
                    'ref'  => '../tests/outputs/git_tests/count_and_diff.yaml.HEAD',
                    'cd'   => 'cloc_submodule_test',
                    'results'  => 'results.yaml.f647093e8be',
                },

                {
                    'name' => 'count and diff part II',
                    'args' => '--strip-str-comments  --git --count-and-diff 3b359b4904 f647093e8be',
                    'ref'  => '../tests/outputs/git_tests/count_and_diff.yaml.HEAD~1',
                    'cd'   => 'cloc_submodule_test',
                    'results'  => 'results.yaml.3b359b4904',
                },

                {
                    'name' => 'count and diff part III',
                    'args' => '--strip-str-comments  --git --count-and-diff 3b359b4904 f647093e8be',
                    'ref'  => '../tests/outputs/git_tests/count_and_diff.yaml.diff.HEAD~1.HEAD',
                    'cd'   => 'cloc_submodule_test',
                    'results'  => 'results.yaml.diff.3b359b4904.f647093e8be',
                },

                {
                    'name' => 'file size filter with --vcs, #599',
                    'args' => '--vcs=git --max-file-size 0.0001 .',
                    'ref'  => '../tests/outputs/issues/599/results.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                {
                    'name' => '--git-diff-{rel,all} with --exclude-list-file, #735',
                    'args' => '--exclude-list-file ../../tests/inputs/issues/735/excludes.txt --git --diff f15bf042b f647093e8b',
                    'ref'  => '../tests/outputs/issues/735/results.yaml',
                    'cd'   => 'cloc_submodule_test',
                },

                {
                    'name' => '--vcs=git from non-git directory, #772',
                    'args' => '--vcs=git cloc_submodule_test',
                    'ref'  => '../tests/outputs/issues/772/results.yaml',
                    'cd'   => '.',
                },

            );

my $Verbose = 0;

if (!-d 'cloc_submodule_test') {
    print "-" x 79, "\n";
    print "Directory 'cloc_submodule_test' is not found; git tests skipped.\n";
    print "To enable the tests, create the directory with\n";
    print "    git clone https://github.com/AlDanial/cloc_submodule_test.git\n";
    ok( 0, "git tests");
    print "-" x 79, "\n";
} else {
    my $results  = 'results.yaml';
    my $work_dir = getcwd;
    my $cloc     = "$work_dir/../cloc";   # all-purpose version
#   my $cloc     = "$work_dir/cloc";      # Unix-tuned version
    my $Run = "$cloc --quiet --yaml --out $results ";
    foreach my $t (@Tests) {
        chdir($t->{'cd'}) if defined $t->{'cd'};
        print  $Run . $t->{'args'} if $Verbose;
        system($Run . $t->{'args'});
        my %this = ();
        if (defined $t->{'results'}) {
            ok(-e $t->{'results'}, $t->{'name'} . " created output");
            %this = load_yaml($t->{'results'});
        } else {
            ok(-e $results       , $t->{'name'} . " created output");
            %this = load_yaml($results);
        }
        unlink $results;
        chdir($work_dir) if defined $t->{'cd'};
        my %ref  = load_yaml($t->{'ref'});

        is_deeply(\%ref, \%this, $t->{'name'} . " results match");
    }
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
        $result{$section}{$K} = $V;
    }
    close IN;
    return %result
} # 1}}}
