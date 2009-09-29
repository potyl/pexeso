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


	my $progress = create_progess($stage->get_width/2, $stage->get_height/2);
	$stage->add($progress);


	my $middle = Clutter::Rectangle->new(Clutter::Color->new(0, 0, 0xff, 0xff));
	$middle->set_size(2, 2);
	$middle->set_anchor_point_from_gravity('center');
#	$middle->set_position(($stage->get_width - $middle->get_width)/2, ($stage->get_height - $middle->get_height)/2);
	$middle->set_position($stage->get_width/2, $stage->get_height/2);
	$stage->add($middle);

	my $angle = 0;
	$stage->signal_connect('button-release-event', sub {
		$angle = ($angle + 15) % 360;
		$progress->set_rotation('z-axis', $angle, 0, ($progress->get_width/2 + 50), 0);
	});

	$stage->show_all();
	Clutter->main();
	return 0;
}


sub create_progess {
	my ($x, $y) = @_;

	my $bar = Clutter::Rectangle->new(
		Clutter::Color->new(0xFF, 0x00, 0x00, 0xFF)
	);
	$bar->set_size(10, 30);
	$bar->set_anchor_point_from_gravity('center');
	$bar->set_position($x, $y - ($bar->get_height/2 + 10));

	return $bar;
}
