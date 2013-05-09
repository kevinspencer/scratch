#!/usr/bin/env perl
#
# so i don't forget how to do ssl servers...
#
use Data::Dumper;
use File::HomeDir;
use File::Spec;
use IO::Socket::SSL;
use Scalar::Util qw(blessed);
use strict;
use warnings;

$Data::Dumper::Indent = 1;

my $keyfile  = File::Spec->catfile(File::HomeDir->my_home(), 'key.pem');
my $certfile = File::Spec->catfile(File::HomeDir->my_home(), 'key.pem');

if (! -e $keyfile) { die "$keyfile doesn't exist\n"; }
if (! -e $certfile) { die "$keyfile doesn't exist\n"; }

#
# SSL NOTE:
#
# When supporting SSL, the initial socket must be opened as an INET
# socket.  You then accept(), fork(), and *then* perform the SSL handshake.
# If successful, the $client object will be reblessed from an IO::Socket
# object to an IO::Socket::SSL object.
#
# See:
#
# http://www.cpanforum.com/threads/433
#
# http://search.cpan.org/src/SULLR/IO-Socket-SSL-1.07/t/startssl.t
#

my $SERVER = IO::Socket::INET->new(
    Proto     => 'tcp',
    LocalPort => 9100,
    Listen    => 128,
    Reuse     => 1
);

if (! $SERVER) { die "Could not setup server listening on port 9100 - $!\n"; }

while(1) {
    while (my $client = $SERVER->accept()) {
        $client->autoflush(1);
        IO::Socket::SSL->start_SSL(
            $client,
            SSL_version   => 'SSLv3',
            SSL_key_file  => $keyfile,
            SSL_cert_file => $certfile,
            SSL_use_cert  => 1,
            SSL_server    => 1
        ) || do {
            die $SSL_ERROR, "\n"; # $SSL_ERROR exported from IO::Socket::SSL
        };
        print "Got connection\n";
    }
}
