#!/usr/bin/env perl

use 5.20.0;
use strict;
use utf8;
use warnings;

use feature qw{ signatures };
no warnings qw{ experimental::signatures };

main();

sub main () {
    my $clothing = 'socks';
    give_to_dobby($clothing);
}

sub give_to_dobby ($clothes) {
    print "You have given dobby clothes: $clothes\n";
}
