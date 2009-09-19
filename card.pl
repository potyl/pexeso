#!/usr/bin/perl

=head1 NAME

card.pl - test how to make a two face card

=head1 SYNOPSIS

card.pl

=head1 DESCRIPTION

This sample script tries to ake a two face card.

=cut

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Clutter qw(-threads-init -init);

exit main();


sub main {

	my $stage = Clutter::Stage->get_default();
	$stage->set_size(300, 300);

	my $back = Clutter::Texture->new('icon.png');
	$back->set_name('back');
	$back->set_reactive(TRUE);

	my $front = Clutter::Texture->new('daxim.jpg');
	$front->set_name('front');
	$front->set_reactive(TRUE);


	my $card = Clutter::Group->new();
	$card->add($front, $back);
#	$front->set_position(0, $back->get_height + 10);
#	$front->set_position(0, $back->get_height/2);

	$card->set_position(($stage->get_width - $front->get_width) / 2, 40);

	$card->set_reactive(TRUE);
	my $behaviour;
	$card->signal_connect('button-release-event', sub {
		print "Card\n";
		$behaviour = rotate($card, 'cw', 0, 90, sub {
			$front->raise_top();
			$behaviour = rotate($card, 'cw', 90, 180);
		});
	});

	$stage->signal_connect('button-release-event', sub {
		print "Card back\n";
		$behaviour = rotate($card, 'ccw', 180, 90, sub {
			$front->lower_bottom();
			$behaviour = rotate($card, 'ccw', 90, 0);
		});
	});

	$stage->add($card);
	$stage->show_all();
	Clutter->main();
	return 0;
}


sub rotate {
	my ($actor, $direction, $start, $end, $action) = @_;
	my $timeline = Clutter::Timeline->new(300);
	my $alpha = Clutter::Alpha->new($timeline, 'linear');
	my $behaviour = Clutter::Behaviour::Rotate->new($alpha, 'y-axis', $direction, $start, $end);
	$behaviour->set_center($actor->get_width() / 2, 0, 0);
	$behaviour->apply($actor);
	$timeline->start();
	$timeline->signal_connect(completed => $action) if $action;

	return $behaviour;
}
