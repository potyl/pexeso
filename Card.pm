#!/usr/bin/perl

=head1 NAME

Card - A card is an actor with two faces.

=head1 SYNOPSIS

	my $card = Card->new({
		front => $front_actor,
		back  => $back_actor,
	});

=head1 DESCRIPTION

This sample script tries to ake a two face card.

=cut

package Card;

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Clutter;
use Carp;

use Glib::Object::Subclass 'Clutter::Group',
	properties => [
		Glib::ParamSpec->object(
			'front',
			'Front face actor',
			'The actor that will be shown in the front face',
			'Clutter::Actor',
			[ qw(readable writable) ],
		),
		Glib::ParamSpec->object(
			'back',
			'Back face actor',
			'The actor that will be shown in the back face',
			'Clutter::Actor',
			[ qw(readable writable) ],
		),
	];


sub new {
	my $class = shift;
	my ($args) = @_;
	croak "Usage: ", __PACKAGE__, "->new(hashref)" unless ref $args eq 'HASH';

	my ($front, $back) = @$args{qw(front back)};
	my $self = Glib::Object::new($class =>
		front => $front,
		back  => $back,
	);

	# Flip the back card
	$back->set_rotation('y-axis', 180, $back->get_width/2, 0, 0);

	$self->add($front, $back);
	#$front->set_position(0, $back->get_height/2);

	return $self;
}


sub show_face {
	my $self = shift;
	my $behaviour;

	$self->{behaviour} = rotate($self, 'cw', 0, 180);

	$self->{behaviour} = rotate($self, 'cw', 0, 90, sub {
		$self->{front}->raise_top();
		$self->{behaviour} = rotate($self, 'cw', 90, 180);
	}) if 0;
}


sub show_back {
	my $self = shift;

	$self->{behaviour} = rotate($self, 'ccw', 180, 0);

	$self->{behaviour} = rotate($self, 'ccw', 180, 90, sub {
		$self->{front}->lower_bottom();
		$self->{behaviour} = rotate($self, 'ccw', 90, 0);
	}) if 0;
}


sub rotate {
	my ($actor, $direction, $start, $end, $action) = @_;
	my $timeline = Clutter::Timeline->new(1000);
	my $alpha = Clutter::Alpha->new($timeline, 'linear');
	my $behaviour = Clutter::Behaviour::Rotate->new($alpha, 'y-axis', $direction, $start, $end);
	$behaviour->set_center($actor->get_width() / 2, 0, 0);
	$behaviour->apply($actor);
	$timeline->start();
	$timeline->signal_connect(completed => $action) if $action;

	return $behaviour;
}

# Return a true value
1;
