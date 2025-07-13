#!/usr/bin/env perl
use warnings;
use strict;

my $a = 43;
=over
this is not code
=cut
print $a, "\n";

my $b = 44;
=pod
also not code
=cut
print $b, "\n";

my $c = 45;
=head3
more docs
=cut
print $c, "\n";

__DATA__

This is yet more non-code
