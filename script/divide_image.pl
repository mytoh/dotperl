#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Imager;
use open ':std', ':encoding(UTF-8)';
use feature ":5.28";
use experimental qw<signatures>;


my sub half_image ($img, $part) {
  $img->crop($part => $img->getwidth() / 2 );
}

my sub main($file) {
  my $img = Imager->new;

  $img->read(file => $file) or die $img->errstr;

  my $right_part = half_image $img, 'right';
  my $left_part  = half_image $img, 'left';

  $left_part->write(file => 'left_part.jpg', jpegquality => 100) or dir $left_part->errstr;
  $right_part->write(file => 'right_part.jpg', jpegquality => 100) or dir $right_part->errstr;
}

main($ARGV[0]);
