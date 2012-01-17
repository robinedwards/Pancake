package Pancake::Config;
use Moose;
use Moose::Util::TypeConstraints;
use IO::Dir;
use Config::JFDI;
use Data::Dump 'pp';
use namespace::autoclean;

subtype 'ReadableConfigDir',
    as 'Str',
    where { -d $_ && -r $_ },
    message { "$_ is not a readable directory, please set config directory via env PANCAKE_CONFIG_DIR" };

has plugin_config_dir => ( is => 'ro', isa => 'ReadableConfigDir', required => 1);
has plugin_config     => ( is => 'ro', isa => 'HashRef', lazy_build => 1);

sub _build_plugin_config {
    my ($self) = @_;

    my $config = {};

    my $dir = IO::Dir->new($self->plugin_config_dir)
        or die "Couldn't open directory ". $self->plugin_config_dir;

    while (my $config_file = $dir->read) {
        next if $config_file =~ /^\./;

        my $hash = Config::JFDI->open($self->plugin_config_dir."/$config_file");
        $config->{$config_file} = $hash;

        say STDERR "Loaded $config_file: ".pp($hash);
    }

    return $config;
}

__PACKAGE__->meta->make_immutable;

1;
