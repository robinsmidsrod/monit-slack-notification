#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
use Email::Simple;

# Get the Slack incoming-webhooks URL using a SaltStack pillar value
my $url = '{{ salt.pillar.get("slack:agent:monit:url") }}';
my $server = qx(hostname -f);
chomp $server;
my $tz = qx(date +%Z);
chomp $tz;

my $message = do { local $/; <>; };
#print STDERR $message;
my $email = Email::Simple->new($message);

my $payload = { username => "Monit ($server)" };

if ( $email->body ) {
    $payload->{'text'} .= $email->body . "\n\nTimezone: $tz";
}

my $json = encode_json($payload);

my @cmd = ("curl", "-X", "POST", "-s", "--data-urlencode", "payload=$json", "$url");
#print STDERR join(" ", @cmd), "\n";
system(@cmd);


