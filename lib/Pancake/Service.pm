package Pancake::Service;
use Moose;
use MooseX::NonMoose;
extends 'Web::Simple::Application';
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Plack::Builder;
use Pancake::Config;
use Pancake::DispatchTable;
use namespace::autoclean;

class_type 'Pancake::Config';
class_type 'Pancake::DispatchTable';

has service_config => (
    is => 'ro',
    isa => 'Pancake::Config',
    lazy_build => 1
);

has plugin_config_dir => (
    is => 'ro',
    isa => 'Str',
    default => sub { $ENV{PANCAKE_CONFIG_DIR} || './pancake_config' }
);

sub _build_service_config {
    Pancake::Config->new(plugin_config_dir => shift->plugin_config_dir )
}

has dispatch_table => (
    is => 'ro',
    isa => 'Pancake::DispatchTable',
    handles => ['dispatch_request'],
    lazy_build => 1,
);

sub _build_dispatch_table {
    Pancake::DispatchTable->new(
        plugin_config => shift->service_config->plugin_config
    )
}

sub _error_catcher {
    my $app = shift;

    return sub {
        my $env = shift;
        try {
            return $app->($env);
        } catch {
            print STDERR "500 ERROR: $_\n";
            my ($error) = split /\n/, $_;
            return [500, [], [$error] ];
        };
    };
}

sub to_psgi_app {
    my $self = ref($_[0]) ? $_[0] : $_[0]->new;
    $self->dispatch_table->table; # force load
    my $app = $self->_dispatcher->to_app;
    builder { enable \&_error_catcher; $app; }
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

__PACKAGE__->run_if_script;
