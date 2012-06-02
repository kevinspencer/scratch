#!/usr/bin/env perl
#
# for use where user defined Perl regex substitutions are allowed
#

use Data::Dumper;
use Safe;
use strict;
use warnings;

$Data::Dumper::Indent = 1;

my $user_regex_file = shift;

# Any malformed regex will cause a compilation failure so we must check
# the validity by eval.  But doing that is a security risk because the users
# could place anything in the file.  Each regex will be evaluated inside a
# Safe container with a minimal set of allowable Perl code just to be safe.
#

my $sandbox = Safe->new();
open(my $fh, '<', $user_regex_file) || die "Could not open $user_regex_file - $!\n";
# ensure any unsafe code in the regex file is rejected
# see perldoc Opcode for what :base_core and :base_orig allow...
$sandbox->permit_only(qw(:base_core :base_orig));
my @substitutions;
while(<$fh>) {
    chomp;
    my $regex = $_;
    $_ = '';
    $sandbox->reval($regex);
    # did that compile?
    if ($@) {
        # nope
        die "Invalid regex found - $@\n";
    }
    push(@substitutions, eval("sub { $regex }" ));
}
close($fh);
print Dumper \@substitutions;
