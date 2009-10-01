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

	my $gap = 8;

	my @bars;
	my $bars = 12;
	$self->{angle} = 360/$bars;
	foreach my $i (0 .. $bars - 1) {
		my $bar = Clutter::CairoTexture->new(4, 12);
		my $cr = $bar->create_context();
		if ($i < 3) {
			$cr->set_source_rgba(1, 0, 0, 0.5);
		}
		else {
			$cr->set_source_rgba(0, 0, 1, 0.5);
		}
		$cr->arc(2, 6, 2, 0, pi2);
		$cr->fill();

		my $gravity = $bar->get_height/2 + $gap;

		$bar->set_anchor_point_from_gravity('center');
		$bar->set_position($x, $y - $gravity);

		$bar->set_rotation('z-axis', $i * $self->{angle}, 0, $gravity, 0);

		push @bars, $bar;
		$self->add($bar);
	}

	$self->{bars} = \@bars;
	$self->{i} = 0;
}


sub pulse {
	my $self = shift;
	$self->{i} = $self->{i} + 1;
	if ($self->{i} == @{ $self->{bars} }) {
		$self->{i} = 0;
	}
	$self->set_rotation('z-axis', $self->{i} * $self->{angle}, 0, 0, 0);
}


# A true value
1;
