use strict;
use warnings;
use Test::More tests => 3;
use_ok 'Pancake::Config';
use Data::Dumper;

my $cfg = Pancake::Config->new(plugin_config_dir => './test_data/plugin_config');
isa_ok $cfg, 'Pancake::Config';
can_ok $cfg, 'plugin_config';
