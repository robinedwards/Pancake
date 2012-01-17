package Pancake::DispatchTable;
use Moose;
use Try::Tiny;
use Data::Dump 'pp';
use namespace::autoclean;

has table => (is => 'rw', isa => 'HashRef', lazy_build => 1);
has plugin_config => (is => 'ro', isa => 'HashRef', required => 1);

sub _build_table {
    my ($self) = @_;

    my $table = {};

    while (my ($name, $config) = each %{$self->plugin_config}) {

        die "Error no module specified in plugin config '$name'" 
            unless defined $config->{module};

        {
            local $@;
            eval "require $config->{module}";
            die "Error loading module $config->{module} for '$name': $@" if $@;
        }

        my $plugin;
        try { $plugin = $config->{module}->new($config) }
        catch {
            die "Error instantiating plugin for '$name' v"
                . " with config ".pp($config). "\n$_";
        };

        my $mount = '/'.$plugin->name.'/...';

        die "Mount point collision '$mount', please check your config"
            if (exists $table->{$mount});

        $table->{$mount} = sub { $plugin->dispatch_request(@_) } ;
    }

    return $table
}

sub dispatch_request { %{shift->table} }

__PACKAGE__->meta->make_immutable;

1;
