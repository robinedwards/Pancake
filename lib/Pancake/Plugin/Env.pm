package Pancake::Plugin::Env;
use Moose;
extends 'Pancake::Plugin';
use Plack::Request;
use namespace::autoclean;

has '+name' => (default => 'env');

sub dispatch_request {
    my ($plugin) = @_;

    '/plugins' => sub {
        [   200,
            ['Content-Type' => 'application/json'],
            [ $plugin->json_view($_[0]->service_config->plugin_config) ] 
        ]
    },
}


__PACKAGE__->meta->make_immutable;

1;
