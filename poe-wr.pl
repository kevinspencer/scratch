#!/usr/bin/env perl

use POE qw(Wheel::Run);
use strict;
use warnings;

my $child_prog = "/Users/kevin/code/scratch/run-me.sh";

POE::Session->create(
    inline_states => {
        _start => \&do_start,
        got_child_stdout => \&handle_child_stdout,
        got_child_stderr => \&handle_child_stderr,
        got_child_close  => \&handle_child_close,
    }
);

POE::Kernel->run();
exit();

sub do_start {
    my $child = POE::Wheel::Run->new(
        Program => [$child_prog],
        StdoutEvent => "got_child_stdout",
        StderrEvent => "got_child_stderr",
        CloseEvent  => "got_child_close"
    );

    $_[KERNEL]->sig_child($child->PID(), "handle_child_signal");

    $_[HEAP]{children_by_wid}{$child->ID()} = $child;
    $_[HEAP]{children_by_pid}{$child->ID()} = $child;

    print "started PID [" . $child->PID() . "] as WID [" . $child->ID() . "]", "\n";
}

sub handle_child_stdout {
    my ($kernel, $heap, $line, $wid) = @_[KERNEL, HEAP, ARG0, ARG1];

    my $child = $heap->{children_by_wid}{$wid};
    print "child [" . $child->PID() . "] STDOUT: $line\n";
}

sub handle_child_stderr {
    my ($kernel, $heap, $line, $wid) = @_[KERNEL, HEAP, ARG0, ARG1];

    my $child = $heap->{children_by_wid}{$wid};
    print "child [" . $child->PID() . "] STDERR: $line\n";
}

sub handle_child_signal {
    my ($kernel, $heap, $foo, $pid, $status) = @_[KERNEL, HEAP, ARG0, ARG1, ARG2];

    print "$foo\n$pid\n$status\n";
    my $child = delete $heap->{children_by_pid}{$pid};
    return unless defined ($child);
    delete $heap->{children_by_wid}{$child->ID()};
}

sub handle_child_close {
    my ($kernel, $heap, $wid) = @_[KERNEL, HEAP, ARG0];
    
    my $child = delete $heap->{children_by_wid}{$wid};
    print "pid [" . $child->PID() . "] saying cheerio\n";
    delete $heap->{children_by_pid}{$child->PID()};
}
