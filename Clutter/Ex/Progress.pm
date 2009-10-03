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

	my @bars;
	my $bars = 12;
	$self->{angle_step} = 360/$bars;

	my ($actor_on, $actor_off);
	foreach my $i (0 .. $bars - 1) {

		my $bar;
		if ($i < 3) {
			# Dot on
			if ($actor_on) {
				$bar = Clutter::Clone->new($actor_on);
			}
			else {
				my @rgba = (1, 0, 0, 0.5);
				$actor_on = create_bar(TRUE, @rgba);
				$bar = $actor_on;
			}
		}
		else {
			# Dot off
			if ($actor_off) {
				$bar = Clutter::Clone->new($actor_off);
			}
			else {
				my @rgba = (0, 0, 1, 0.5);
				$actor_off = create_bar(FALSE, @rgba);
				$bar = $actor_off;
			}
		}

		$self->{gravity} ||= $bar->get_height/2 + $gap;

		$bar->set_anchor_point_from_gravity('center');
		$bar->set_position($x, $y - $self->{gravity});

		$bar->{angle} = $i * $self->{angle_step};
		$bar->set_rotation('z-axis', $bar->{angle}, 0, $self->{gravity}, 0);
		push @bars, $bar;
		$self->add($bar);
	}

	$self->{bars} = \@bars;
	$self->{i} = 0;
}


sub pulse {
	my $self = shift;
	foreach my $bar (@{ $self->{bars} }) {
		$bar->{angle} += $self->{angle_step};
		$bar->set_rotation('z-axis', $bar->{angle}, 0, $self->{gravity}, 0);
	}
}


sub create_bar {
	my ($kind, @rgba) = @_;

	my ($w, $h) = (25, 25);
	if ($kind) {
#		($w, $h) = map { $_ * 1.5 } ($w, $h);
	}

	my $actor = Clutter::CairoTexture->new($w, $h);
	my $cr = $actor->create_context();
	$cr->set_source_rgba(@rgba);
	$cr->arc(
		$w/2, $h/2,
		$w/4, # Radius
		0, pi2 # radians (start, end)
	);
	$cr->fill();

	return $actor;
}



# A true value
1;
