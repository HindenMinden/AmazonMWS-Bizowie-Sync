#!/usr/bin/perl

use strict;
use warnings;
use Amazon::MWS::Client;
use Data::Dumper;

my ($feed_submission_id) = @ARGV;

my $mws_marketplace_id  = 'x',
my $mws_merchant_id     = 'x',
my $mws_secret_key      = 'x';
my $mws_access_key      = 'x';

my $amz = Amazon::MWS::Client->new(
    access_key_id  => $mws_access_key,
    secret_key     => $mws_secret_key,
    merchant_id    => $mws_merchant_id,
    marketplace_id => $mws_access_key,
);

my $r = $amz->GetFeedSubmissionResult(FeedSubmissionId => $feed_submission_id);
warn Dumper $r;
