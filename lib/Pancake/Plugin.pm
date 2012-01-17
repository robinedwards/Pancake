package Pancake::Plugin;
use Moose;
use JSON;
use namespace::autoclean;

has name => (is => 'ro', isa => 'Str', required => 1);

sub json_view { shift; JSON->new->pretty(1)->canonical(1)->encode(@_) }

__PACKAGE__->meta->make_immutable;

1;
