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

use Glib::Object::Subclass 'Clutter::Group';


sub new {
	my $class = shift;
	my ($args) = @_;
	croak "Usage: ", __PACKAGE__, "->new(hashref)" unless ref $args eq 'HASH';

	my ($front, $back) = @$args{qw(front back)};
	my $self = Glib::Object::new($class);
	$self->{front} = $front;
	$self->{back} = $back;

	# Flip the back card, this assumes that backface culling is enabled
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

# Return a true value
1;
