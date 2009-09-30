#!/usr/bin/perl

=head1 NAME

progress.pl - experiment with a progress pacifier

=head1 SYNOPSIS

progress.pl

=head1 DESCRIPTION

This sample script tries create a progress pacifier.

=cut

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Clutter::Ex::PexesoCard;
use Clutter qw(-init);


exit main();


sub main {

	my $stage = Clutter::Stage->get_default();
	$stage->set_size(300, 300);
	my ($middle_x, $middle_y) = ($stage->get_width/2, $stage->get_height/2);

	# Create a progress bar
	my $progress = create_progess($middle_x, $middle_y);
	$stage->add($progress);

	# A point in the middle of the screen as a reference
	my $middle = Clutter::Rectangle->new(Clutter::Color->new(0, 0, 0xff, 0xff));
	$middle->set_size(2, 2);
	$middle->set_anchor_point_from_gravity('center');
	$middle->set_position($middle_x, $middle_y);
	$stage->add($middle);


	my $angle = 0;
	$stage->signal_connect('button-release-event', sub {
		$angle = ($angle + 15) % 360;
		my $y = $progress->get_height/2 + 10;
		$progress->set_rotation('z-axis', $angle, 0, $y, 0);
	});

	$stage->show_all();
	Clutter->main();
	return 0;
}


sub create_progess {
	my ($x, $y) = @_;

	my $gap = 8;

	my @bars;
	my $group = Clutter::Group->new();
	my $bars = 12;
	my $angle = 360/$bars;
	foreach my $i (0 .. $bars - 1) {
		my $bar = Clutter::Rectangle->new(
			Clutter::Color->new(0xFF, 0x00, 0x00, 0xFF)
		);
		$bar->set_size(4, 12);
		my $gravity = $bar->get_height/2 + $gap;

		$bar->set_anchor_point_from_gravity('center');
		$bar->set_position($x, $y - $gravity);

		$bar->set_rotation('z-axis', $i * $angle, 0, $gravity, 0);

		push @bars, $bar;
		$group->add($bar);
	}


	return $group;
}
