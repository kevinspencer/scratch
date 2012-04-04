#!/usr/bin/env perl

use POE qw(Wheel::Run);
use strict;
use warnings;

my $child_prog = "~/code/scratch/run-me.pl";

POE::Session->create(
    inline_states => {
        _start => \&do_start
    }
);

POE::Kernel->run();
exit();

sub do_start {
    my $child = POE::Wheel::Run->new(
        Program => [$child_prog],
        StdoutEvent => "handle_child_stdout",
        StderrEvent => "handle_child_stderr",
        CloseEvent  => "handle_child_close"
    );

    $_[KERNEL]->sig_child($child->PID(), "handle_child_close");

    $_[HEAP]{children_by_wid}{$child->ID()} = $child;
    $_[HEAP]{children_by_pid}{$child->ID()} = $child;

    print "started PID [" . $child->PID() . "] as WID [" . $child->ID() . "]", "\n";
}

sub handle_child_stderr {
    my ($line, $wid) = @_[ARG0, ARG1];

    my $child = $_[HEAP]{children_by_wid}{$wid};
    print "child [" . $child->PID() . "] STDERR: $line\n";
}
