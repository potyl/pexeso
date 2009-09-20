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


	my $self = Glib::Object::new($class);
	my ($front, $back) = @$args{qw(front back)};
	$self->{front} = $front;
	$self->{back} = $back;
	$self->{is_showing_face} = TRUE;

	# Set the gravity of the card faces to be in the center
	foreach my $face ($front, $back) {
		$face->set_anchor_point_from_gravity('center');
		$face->set_position($face->get_width/2, $face->get_height/2);
	}

	# Flip the back card as it has to be facing the opposite direction
	$back->set_rotation('y-axis', 180, 0, 0, 0);

	$self->add($front, $back);

	# A pexeso card starts with showing its back
	$self->set_rotation('y-axis', 180, $self->get_width/2, 0, 0);

	return $self;
}


sub flip {
	my $self = shift;

	# Normally a flip would go from (0 -> 180) or (180 -> 0). But since the flip
	# is done in an animation flipping before a current animation is over will
	# flicker the image to the original state. What this code here is doing is
	# preserving the current angle and to resume start the flip animation from
	# there.
	#
	# If the image is already rotated (in between a flip) then keep the
	# current angle and resume the new rotation from that point
	my $direction;
	my ($angle_start) = $self->get_rotation('y-axis');
	my $angle_end;
	if ($self->{is_showing_face}) {
		$angle_end = 0;
		$direction = 'ccw';
	}
	else {
		$angle_end = 180;
		$direction = 'cw';
	}
	$self->{is_showing_face} = ! $self->{is_showing_face};

	my $timeline = Clutter::Timeline->new(300);
	my $alpha = Clutter::Alpha->new($timeline, 'linear');
	my $rotation = Clutter::Behaviour::Rotate->new($alpha, 'y-axis', $direction, $angle_start, $angle_end);
	$rotation->set_center($self->get_width() / 2, 0, 0);
	$rotation->apply($self);
	$timeline->start();
	$timeline->signal_connect(completed => sub {
		delete $self->{rotation};
	});

	# Keep a handle to the behaviour otherwise it wont be applied
	$self->{rotation} = $rotation;
}


sub fade {
	my $self = shift;

	my $timeline = Clutter::Timeline->new(300);
	my $alpha = Clutter::Alpha->new($timeline, 'linear');
	my ($start, $end) = (1.0, 0.0);

	# Shrink the card
	my $zoom = Clutter::Behaviour::Scale->new($alpha, $start, $start, $end, $end);
#	$zoom->apply($self);
	$zoom->apply($self->{front});
	$zoom->apply($self->{back});

	# And spin it
	my $rotation = Clutter::Behaviour::Rotate->new($alpha, 'z-axis', 'cw', 0, 360);
	$rotation->set_center($self->get_width() / 2, $self->get_height() / 2, 0);
	$rotation->apply($self);

	# And make it transparent
	my $transparent = Clutter::Behaviour::Opacity->new($alpha, 255, 0);
	$transparent->apply($self);


	# Start the timeline and once it is over hide the card
	$timeline->start();
	$timeline->signal_connect(completed => sub {
		$self->hide();
		delete $self->{zoom};
		delete $self->{rotation};
		delete $self->{transparent};
	});

	# Keep a handle to the behaviours otherwise they wont be applied
	$self->{zoom} = $zoom;
	$self->{rotation} = $rotation;
	$self->{transparent} = $transparent;
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
