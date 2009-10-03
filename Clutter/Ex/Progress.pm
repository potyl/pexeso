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

# Duration of the animation
my $TIME = 2_000;


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

	$self->{actors} = 12;
	$self->{angle_step} = 360 / $self->{actors};
	$self->create_actors();

	return $self;
}


sub create_actors {
	my $self = shift;
	my ($x, $y) = (0, 0);

	my $gap = 20;

	my $size_step = 0.025;
	my $size = 0.8;
	my @rgba = (0.3, 0.3, 0.3, 0.5);
	foreach my $i (0 .. $self->{actors} - 1) {

		# Grow the bars and change their transparency
		$size += $size_step;
		$rgba[3] -= 0.0125;

		my $actor = create_actor($size, @rgba);

		my $gravity = $actor->get_height/2 + $gap;
		$actor->set_anchor_point_from_gravity('center');
		$actor->set_position($x, $y - $gravity);

		$actor->{angle} = $i * $self->{angle_step};
		$actor->set_rotation('z-axis', $actor->{angle}, 0, $gravity, 0);

		$self->add($actor);
	}
}


sub pulse_animation_once {
	my $self = shift;

	return if $self->{animation};
	$self->{once_iter} ||= 0;

	my $angle = ++$self->{once_iter} * $self->{angle_step};
	$self->{once_iter} = 0 if $self->{once_iter} == $self->{actors};

	my $animation = $self->create_animation($angle);
	my $timeline = $animation->get_alpha->get_timeline;
	$timeline->signal_connect(completed => sub {
		delete $self->{animation};
	});

	$timeline->start();
	$self->{animation} = $animation;
}


sub pulse_animation_start {
	my $self = shift;

	return if $self->{animation};

	my $animation = $self->create_animation(360);
	my $timeline = $animation->get_alpha->get_timeline;
	$timeline->set_loop(TRUE);
	$timeline->start();
	$self->{animation} = $animation;
}


sub pulse_animation_stop {
	my $self = shift;

	my $animation = $self->{animation} or return;
	my $timeline = $animation->get_alpha->get_timeline;

	# Stop the animation as soon as the loop is over
	$timeline->set_loop(FALSE);
	$timeline->signal_connect(completed => sub {
		delete $self->{animation};
		# If we want to continue with a pulse_animation_once then resume from
		# the start.
		delete $self->{once_iter};
	});
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


sub create_animation {
	my $self = shift;
	my ($angle_end) = @_;

	my ($angle_start) = $self->get_rotation('z-axis');
	$angle_start = clamp_degrees($angle_start);
	$angle_start = 0 if $angle_start == 360;

	my $time = ($angle_end - $angle_start) * $TIME / 360;

	my $timeline = Clutter::Timeline->new($time);
	my $alpha = Clutter::Alpha->new($timeline, 'linear');

	my $rotation = Clutter::Behaviour::Rotate->new($alpha, 'z-axis', 'cw', $angle_start, $angle_end);
	$rotation->set_center(0, 0, 0);
	$rotation->apply($self);

	return $rotation;
}

# A true value
1;
