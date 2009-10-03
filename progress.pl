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
#	$progress->set_position($middle_x, $middle_y);
	$progress->set_position(100, 100);
	$stage->add($progress);

	$stage->signal_connect('button-release-event', sub {
		my ($actor, $event) = @_;
		if ($event->button == 1) {
			$progress->pulse_animation_start();
		}
		elsif ($event->button == 2) {
			$progress->pulse_animation_stop();
		}
		else {
			$progress->pulse_animation_step();
		}
	});

	$stage->show_all();
	$progress->hide();
	Clutter->main();
	return 0;
}
