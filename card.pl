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

my $text = Clutter::Text->new("Mono 28", "Hello world");
$stage->add($text);
$text->set_anchor_point_from_gravity('center');
$text->set_position(
	($stage->get_width - $text->get_width/2),
	($stage->get_height - $text->get_height/2),
);
#text->set_rotation('y-axis', -30, 0, 0, 0);

	my $direction = 0;
	
	$stage->signal_connect('button-release-event', sub {
		foreach my $card ($card1, $card2) {
#			$card->flip();
		}
#		$card1->flip();
	#	$card2->fade();
		
		my ($angle) = $text->get_rotation('y-axis');
		$direction = ! $direction;
		if ($direction == 0) { $angle = 180; }
		else { $angle = 270; }
		
		
		$text->animate('ease-out-elastic', 500, 
			"scale-x", $direction ? 2 : 0.5,
			"scale-y", $direction ? 2 : 0.5,
			'rotation-angle-y', 180,
		);
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
