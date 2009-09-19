#!/usr/bin/perl

=head1 NAME

card.pl - test how to make a two face card

=head1 SYNOPSIS

card.pl

=head1 DESCRIPTION

This sample script tries to take a two face card.

=cut

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Clutter::Ex::PexesoCard;
use Clutter qw(-threads-init -init);


exit main();


sub main {

	my @files = qw(daxim.jpg icon.png);


	my $stage = Clutter::Stage->get_default();
	$stage->set_size(300, 300);


	my $card1 = new_card($stage, @files);
	$card1->set_position(($stage->get_width - $card1->{front}->get_width) / 2, 40);

	my $card2 = new_card($stage, @files);

	$stage->signal_connect('button-release-event', sub {
		foreach my $card ($card1, $card2) {
			$card->flip();
		}
	});

	$stage->show_all();
	Clutter->main();
	return 0;
}


sub new_card {
	my ($stage, $front, $back) = @_;

	my $card = Clutter::Ex::PexesoCard->new({
		front => Clutter::Texture->new($front),
		back  => Clutter::Texture->new($back),
	});
	$stage->add($card);

	return $card;
}
