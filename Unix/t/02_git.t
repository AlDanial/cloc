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

#               {
#                   'name' => 'diff f15bf042b f647093e8b',
#                   'args' => '--git --diff f15bf042b f647093e8b',
#                   'ref'  => '../tests/outputs/git_tests/diff_f15bf042b_f647093e8b.yaml',
#                   'cd'   => 'cloc_submodule_test',
#               },

                {
                    'name' => 'count and diff part I',
                    'args' => '--strip-str-comments  --git --count-and-diff HEAD~1 HEAD',
                    'ref'  => '../tests/outputs/git_tests/count_and_diff.yaml.HEAD',
                    'cd'   => 'cloc_submodule_test',
                    'results'  => 'results.yaml.HEAD',
                },

                {
                    'name' => 'count and diff part II',
                    'args' => '--strip-str-comments  --git --count-and-diff HEAD~1 HEAD',
                    'ref'  => '../tests/outputs/git_tests/count_and_diff.yaml.HEAD~1',
                    'cd'   => 'cloc_submodule_test',
                    'results'  => 'results.yaml.HEAD~1',
                },

                {
                    'name' => 'count and diff part III',
                    'args' => '--strip-str-comments  --git --count-and-diff HEAD~1 HEAD',
                    'ref'  => '../tests/outputs/git_tests/count_and_diff.yaml.diff.HEAD~1.HEAD',
                    'cd'   => 'cloc_submodule_test',
                    'results'  => 'results.yaml.diff.HEAD~1.HEAD',
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
