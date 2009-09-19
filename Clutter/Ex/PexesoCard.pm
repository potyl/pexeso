#!/usr/bin/perl

=head1 NAME

Clutter::Ex::PexesoCard - A card is an actor with two faces.

=head1 SYNOPSIS

	my $card = Clutter::Ex::PexesoCard->new({
		front => $front_actor,
		back  => $back_actor,
	});

=head1 DESCRIPTION

Representation of a card. A card consists for two actors: back face and front
face that act together as a single entity. A card can be flipped to show the
front face or the back face.

=cut

package Clutter::Ex::PexesoCard;

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Clutter;
use Carp;

use Glib::Object::Subclass 'Clutter::Group';


sub new {
	my $class = shift;
	my ($args) = @_;
	croak "Usage: ", __PACKAGE__, "->new(hashref)" unless ref $args eq 'HASH';

	my ($front, $back) = @$args{qw(front back)};
	my $self = Glib::Object::new($class);
	$self->{front} = $front;
	$self->{back} = $back;

	# Flip the back card as it has to be facing the opposite direction
	$back->set_rotation('y-axis', 180, $back->get_width/2, 0, 0);

	$self->add($front, $back);

	return $self;
}


sub show_face {
	my $self = shift;
	$self->_flip('cw');
}


sub show_back {
	my $self = shift;
	$self->_flip('ccw');
}


sub _flip {
	my $self = shift;
	my ($direction) = @_;

	my @angles = $direction eq 'cw' ? (0, 180) : (180, 0);

	my $timeline = Clutter::Timeline->new(1000);
	my $alpha = Clutter::Alpha->new($timeline, 'linear');
	my $behaviour = Clutter::Behaviour::Rotate->new($alpha, 'y-axis', $direction, @angles);
	$behaviour->set_center($self->get_width() / 2, 0, 0);
	$behaviour->apply($self);
	$timeline->start();

	$self->{behaviour} = $behaviour;
}


# Turns backface culling (hide the back side of an actor) on and calls the super
# paint to draw the cards.
sub PAINT {
	my $self = shift;

	# Enable backface culling in order to animate the cards properly
	my $culling = Clutter::Cogl->get_backface_culling_enabled();
	Clutter::Cogl->set_backface_culling_enabled(TRUE);

	# Draw the card properly
	$self->SUPER::PAINT(@_);

	# Restore backface culling to its previous state
	Clutter::Cogl->set_backface_culling_enabled($culling);
}


# Return a true value
1;
