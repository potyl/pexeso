#!/usr/bin/perl

=head1 NAME

Clutter::Ex::Progress - A progress pacifier.

=head1 SYNOPSIS

	my $card = Clutter::Ex::Progress->new();

=head1 DESCRIPTION

Show a progress pacifier.

=head1 METHODS

The following methods are available:

=cut

package Clutter::Ex::Progress;

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Clutter;
use Math::Trig qw(:pi);

use Glib::Object::Subclass 'Clutter::Group';

=head2 new

Creates a new card with the two given faces. The card is placed so that the back
of the card is shown.

Usage:

	my $card = Clutter::Ex::PexesoCard->new({
		front => $front_actor,
		back  => $back_actor,
	});

=cut

sub new {
	my $class = shift;


	my $self = Glib::Object::new($class);

	$self->create_actors(0, 0);

	return $self;
}


sub create_actors {
	my $self = shift;
	my ($x, $y) = @_;

	my $gap = 20;

	my @actors;
	my $actors = 12;
	$self->{angle_step} = 360/$actors;

	my $size_step = 0.025;
	my $size = 0.8;
	my @rgba = (0.3, 0.3, 0.3, 0.5);
	foreach my $i (0 .. $actors - 1) {

		# Grow the bars and change their transparency
		$size += $size_step;
		$rgba[3] -= 0.0125;

		my $actor = create_actor($size, @rgba);

		$self->{gravity} ||= $actor->get_height/2 + $gap;
		$actor->set_anchor_point_from_gravity('center');
		$actor->set_position($x, $y - $self->{gravity});

		$actor->{angle} = $i * $self->{angle_step};
		$actor->set_rotation('z-axis', $actor->{angle}, 0, $self->{gravity}, 0);
		push @actors, $actor;
		$self->add($actor);
	}

	$self->{actors} = \@actors;
}


sub pulse_animation_once {
	my $self = shift;

	# Animate a single frames
	my $timeline = Clutter::Timeline->new(2000 / @{ $self->{actors} });
	my $alpha = Clutter::Alpha->new($timeline, 'linear');

	my ($angle_start) = $self->get_rotation('z-axis');
	$angle_start = clamp_degrees($angle_start);
	my $angle_end = clamp_degrees($angle_start + $self->{angle_step});

	my $rotation = Clutter::Behaviour::Rotate->new($alpha, 'z-axis', 'cw', $angle_start, $angle_end);
	$rotation->set_center(0, 0, 0);
	$rotation->apply($self);

	$timeline->start();
	$self->{rotation} = $rotation;
}


sub pulse_animation_start {
	my $self = shift;
	my $timeline = Clutter::Timeline->new(2000);
	my $alpha = Clutter::Alpha->new($timeline, 'linear');

	my $rotation = Clutter::Behaviour::Rotate->new($alpha, 'z-axis', 'cw', 0, 360);
	$rotation->set_center(0, 0, 0);
	$rotation->apply($self);

	$timeline->set_loop(TRUE);
	$timeline->start();
	$self->{rotation} = $rotation;
}


sub pulse_animation_stop {
	my $self = shift;
	my $rotation = delete $self->{rotation};
	$rotation->get_alpha->get_timeline->stop() if $rotation;
}


sub create_actor {
	my ($size, @rgba) = @_;
	my ($w, $h) = (25, 25);
	my $actor = Clutter::CairoTexture->new($w, $h);
	my $cr = $actor->create_context();
	$cr->set_source_rgba(@rgba);
	$cr->arc(
		$w/2, $h/2,
		$w/4 * $size, # Radius
		0, pi2 # radians (start, end)
	);
	$cr->fill();

	# Surrounding box
	if (FALSE) {
		$cr->set_source_rgba(0, 0, 0, 1.0);
		$cr->rectangle(0, 0, $w, $h);
		$cr->stroke();
	}

	return $actor;
}


sub clamp_degrees {
	my ($angle) = @_;
	$angle -= 360 while ($angle > 360);
	return $angle;
}


# A true value
1;
