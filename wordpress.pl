#!/usr/bin/env perl
# Copyright 2018-2024 Kevin Spencer <kevin@kevinspencer.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both the
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#
################################################################################

use Data::Dumper;
use Encode;
use WordPress::XMLRPC;
use utf8;
use strict;
use warnings;

$Data::Dumper::Indent = 1;

my $wp_user = $ENV{WP_USER} or die "No wp username found\n";
my $wp_pass = $ENV{WP_PASS} or die "No wp password found\n";

my $o = WordPress::XMLRPC->new({
  username => $wp_user,
  password => $wp_pass,
  proxy => 'https://kevinspencer.org/posts/xmlrpc.php'
});

my $authors = $o->getAuthors();

print Dumper $authors;
