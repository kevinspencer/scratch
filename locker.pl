#!/usr/bin/env perl

use DBIx::Locker;
use strict;
use warnings;

my @conn   = ('dbi:SQLite:dbname=locks.db', undef, undef, {});
my $locker = DBIx::Locker->new( { dbi_args => \@conn, table => 'locks' } );
my $lock;
eval { $lock = $locker->lock('Fish Pants') };
die $@, "\n" if ($@);
