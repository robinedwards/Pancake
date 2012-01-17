use strict;
use warnings;
use Test::More 'no_plan';
use Pancake::Service;

{
    my $service = Pancake::Service->new(
        plugin_config_dir => 'test_data/plugin_config/'
    );

    isa_ok $service, 'Pancake::Service';
}

{
    my $app = Pancake::Service->new(
        plugin_config_dir => 'test_data/plugin_config/'
    )->to_psgi_app;

    is ref($app), 'CODE';
}

ok(1);
