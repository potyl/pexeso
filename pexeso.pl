#!/usr/bin/perl

=head1 NAME

pexeso.pl - Play the pexeso game

=head1 SYNOPSIS

pexeso.pl [columns rows]

Where I<columns> is the number of columns to use and I<rows> the number or rows.

=head1 DESCRIPTION

This sample script allows you to play the pexeso game.

=cut

use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Gtk2;
use Clutter qw(-threads-init -init);
use Data::Dumper;
use AnyEvent::HTTP;
use XML::LibXML;
use URI;
use Carp 'carp';
use List::Util 'shuffle';
use base 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors qw(columns rows stage urls actors x y parallel animation_1);


my $ICON_WIDTH = 80;
my $ICON_HEIGHT = 80;


exit main();


sub main {
	my ($columns, $rows) = @ARGV;
	$columns ||= 8;
	$rows ||= 4;
	
	my $pexeso = __PACKAGE__->new({
		columns  => $columns,
		rows     => $rows,
		actors   => [],
		parallel => 5,
	});
	
	$pexeso->construct_game();

	return 0;
}


sub construct_game {
	my $pexeso = shift;
	
	# The main clutter stage
	my $stage = Clutter::Stage->get_default();
	$pexeso->stage($stage);
	$stage->set_size(
		$pexeso->columns * $ICON_WIDTH,
		$pexeso->rows * $ICON_HEIGHT,
	);

	$stage->show_all();
	
	$pexeso->download_icon_list();
	Clutter->main();
}


sub download_icon_list {
	my $pexeso = shift;
	
	my $uri = URI->new('http://hexten.net/cpan-faces/');
	
	# Asyncrhonous download the list of icons available
	http_request(
		GET     => $uri,
		timeout => 10,
		sub {$pexeso->parse_icon_list($uri, @_)},
	);
}


sub parse_icon_list {
	my $pexeso = shift;
	my ($base_uri, $content, $headers) = @_;
	
	if ($headers->{Status} != 200) {
		$pexeso->quit("Failed to download $base_uri: $headers->{Reason} (Status: $headers->{Status})");
		return;
	}
	
	
	# Find all icon candidates
	my $parser = XML::LibXML->new();
	my $doc = $parser->parse_html_string($content);
	my @icons;
	foreach my $node ($doc->findnodes('//div[@class="icon"]/a/img[@src]')) {
		my $src = $node->getAttribute('src');
		my $uri = URI->new_abs($src, $base_uri);
		push @icons, $uri;
	}
	
	# Find how many icons should be downloaded
	my $max = $pexeso->columns * $pexeso->rows;
	if ($max > @icons) {
		$pexeso->rows(int(@icons/$pexeso->columns));
		$max = $pexeso->columns * $pexeso->rows;
	}
	$max = int($max/2);
	
	# Pick the icons to download
	my @picked;
	for (1 .. $max) {
		push @picked, $icons[rand @icons];
	}
	$pexeso->urls(\@picked);
	
	# Start to download the icons
	for (1 .. $pexeso->parallel) {
		$pexeso->download_next_icon();
	}
}


sub download_next_icon {
	my $pexeso = shift;

	if (my $url = pop @{ $pexeso->urls }) {
		# Asyncrhonous download the list of icons available
		http_request(
			GET     => $url,
			timeout => 10,
			sub {$pexeso->parse_icon($url, @_)},
		);
		return;
	}
	
	# No more icons to download
	$pexeso->parallel($pexeso->parallel - 1);
	
	# Build the board if this is the last parallel worker
	if (! $pexeso->parallel) {
		$pexeso->build_board();
	}
}


sub parse_icon {
	my $pexeso = shift;
	my ($url, $content, $headers) = @_;

	if ($headers->{Status} != 200) {
		$pexeso->quit("Failed to download $url: $headers->{Reason} (Status: $headers->{Status})");
		return;
	}

	my ($mime) = split(/\s*;/, $headers->{'content-type'}, 1);
	if ($mime !~ m,^(image/\S+),) {
		$pexeso->quit("Document $url is not an image (Mime: $mime)");
		return;
	}

	my $loader = Gtk2::Gdk::PixbufLoader->new_with_mime_type($mime);
	$loader->write($content);
	$loader->close;
	my $pixbuf = $loader->get_pixbuf;

	# Transform the Pixbuf into a Clutter::Texture
	my $texture = Clutter::Texture->new();
	$texture->set_from_rgb_data(
		$pixbuf->get_pixels,
		$pixbuf->get_has_alpha,
		$pixbuf->get_width,
		$pixbuf->get_height,
		$pixbuf->get_rowstride,
		($pixbuf->get_has_alpha ? 4 : 3),
		[]
	);
	
	my $count = push @{ $pexeso->actors }, $texture;
	$pexeso->download_next_icon();
}


sub build_board {
	my $pexeso = shift;

	my @actors = @{ delete $pexeso->{actors} };
	
	my $stage = $pexeso->stage;

	# Collect the cards to show. For each original card generate a matching
	# card (clone) in order to get a pair.
	my @cards;
	foreach my $actor (@actors) {
		my $clone = Clutter::Clone->new($actor);

		# Cards will match if they have the same name
		my $i = @cards;
		foreach my $card ($actor, $clone) {
			$stage->add($card);
			$card->set_name("$i");
			$card->set_reactive(TRUE);
			$card->signal_connect('button-release-event', sub {
				print "Card ", $card->get_name, "\n";
				
				my $timeline = Clutter::Timeline->new(250);
				my $alpha = Clutter::Alpha->new($timeline, 'linear');
				my $behaviour = Clutter::Behaviour::Rotate->new($alpha, 'y-axis', 'cw', 0, 180);
				$behaviour->set_center($card->get_width() / 2, 0, 0);
				$behaviour->apply($card);
				$timeline->start();
				$pexeso->animation_1($behaviour);
			});
			push @cards, $card;
		}
	}
	
	# Shuffle and place the cards in the board
	@cards = shuffle @cards;

	my ($x, $y) = (0, 0);
	for (my $row = 0; $row < $pexeso->rows; ++$row) {
		for (my $column = 0; $column < $pexeso->columns; ++$column) {
			my $card = pop @cards;
			$card->set_position($column * $ICON_WIDTH, $row * $ICON_HEIGHT);
			$card->show();
		}
	}
}


sub quit {
	my $pexeso = shift;
	carp @_ if @_;
	Clutter->main_quit();
}
