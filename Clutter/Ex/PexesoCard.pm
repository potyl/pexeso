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
	$self->{is_showing_face} = TRUE;

	# Flip the back card as it has to be facing the opposite direction
	$back->set_rotation('y-axis', 180, $back->get_width/2, 0, 0);

	$self->add($front, $back);

	# A pexeso card starts with showing its back
	$self->set_rotation('y-axis', 180, $self->get_width/2, 0, 0);;

	return $self;
}


sub show_face {
	my $self = shift;
	$self->_animation_flip('cw');
	$self->{is_showing_face} = TRUE;
}


sub show_back {
	my $self = shift;
	$self->_animation_flip('ccw');
	$self->{is_showing_face} = FALSE;
}


sub flip {
	my $self = shift;

	if ($self->{is_showing_face}) {
		$self->show_back();
	}
	else {
		$self->show_face();
	}
}


sub _animation_flip {
	my $self = shift;
	my ($direction) = @_;

	# Normally a flip would go from (0 -> 180) or (180 -> 0). But since the flip
	# is done in an animation flipping before a current animation is over will
	# flicker the image to the original state. What this code here is doing is
	# preserving the current angle and to resume start the flip animation from
	# there.
	#
	# If the image is already rotated (in between a flip) then keep the
	# current angle and resume the new rotation from that point
	my @angles;
	if ($direction eq 'cw') {
		my ($angle) = $self->get_rotation('y-axis');
		@angles = ($angle, 180);
	}
	else {
		my ($angle) = ($self->get_rotation('y-axis'));
		@angles = ($angle, 0);
	}

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
