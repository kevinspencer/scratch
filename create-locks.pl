#!/usr/bin/env perl

use DBI;
use strict;
use warnings;

my @conn = ('dbi:SQLite:dbname=locks.db', undef, undef, {});
my $dbh  = DBI->connect(@conn);
$dbh->do('CREATE TABLE locks (
    id INTEGER PRIMARY KEY,
    lockstring varchar(128) UNIQUE,
    created varchar(14) NOT NULL,
    expires varchar(14) NOT NULL,
    locked_by varchar(1024)
  )'
);
