#!/usr/bin/perl

use strict;
use warnings;

use HTTP::Request::Common qw(POST);
use JSON;
use Try::Tiny;
use Amazon::MWS::Client;

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

my $messages = '';
my $i = 1;
my $r = bizowie_api_call();
for my $row (@{ $r->{response}{report_data}{rows} })
{
    my ($sku, $qty) = @$row;
    $qty = $qty + 0;
    next unless $sku;
    $messages .= qq|
        <Message>
            <MessageID>$i</MessageID>
            <OperationType>Update</OperationType>
            <Inventory>
                <SKU>$sku</SKU>
                <Quantity>$qty</Quantity>
            </Inventory>
        </Message>
    |;

    $i++;
}

my $content = qq|
<AmazonEnvelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="amzn-envelope.xsd">
    <Header>
        <DocumentVersion>1.01</DocumentVersion>
        <MerchantIdentifier>My_Seller_ID</MerchantIdentifier>
    </Header>
    <MessageType>Inventory</MessageType>
    $messages
</AmazonEnvelope>
|;

my $r = $amz->SubmitFeed(
    FeedType    => '_POST_INVENTORY_AVAILABILITY_DATA_',
    FeedContent => $content,
);

sub bizowie_call
{
    my $id   = shift;
    my $bzua = LWP::UserAgent->new;
    my $request = {
        api_key        => 'x',
        secret_key     => 'x',
        # report save from Quantity & Demand export
        report_save_id => 100,
    };

    my $q = $bzua->request(POST("https://sitename.mybizowie.com/bz/apiv2/call/System/report_save/get_report_data",
        Content => encode_json($request),
    ));

    my $o;
    {
        local $SIG{__DIE__} = sub { };
        try {
            $o = decode_json($q->decoded_content);
        } catch {
            $o = { unprocessed => 1 };

             warn $q->as_string;
        };
    }     

    return $o;
}
