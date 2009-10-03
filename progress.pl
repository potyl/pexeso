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

use FindBin;
use lib "$FindBin::Bin";

use Glib qw(TRUE FALSE);
use Clutter::Ex::Progress;
use Clutter qw(-init);


exit main();


sub main {

	my $stage = Clutter::Stage->get_default();
	$stage->set_size(300, 300);
	my ($middle_x, $middle_y) = ($stage->get_width/2, $stage->get_height/2);

	# Create a progress bar
	my $progress = Clutter::Ex::Progress->new();
	$progress->set_position($middle_x, $middle_y);
	$stage->add($progress);

	# A point in the middle of the screen as a reference
	my $middle = Clutter::Rectangle->new(Clutter::Color->new(0, 0, 0xff, 0xff));
	$middle->set_size(2, 2);
	$middle->set_anchor_point_from_gravity('center');
	$middle->set_position($middle_x, $middle_y);
	$stage->add($middle);

	$stage->signal_connect('button-release-event', sub {
		$progress->pulse_animation();
	});

	$stage->show_all();
	Clutter->main();
	return 0;
}
