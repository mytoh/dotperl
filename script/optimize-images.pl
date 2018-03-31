#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use warnings qw<FATAL utf8>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing script_run>;
use re 'strict';
use Image::JpegTran;
use File::Temp qw< tempfile tempdir >;
use File::Copy qw<move>;
use File::Spec::Functions qw<catfile>;
use File::Basename::Extra qw<basename basename_suffix>;
use File::Find::Rule::LibMagic qw<find>;
no autovivification;
no indirect;


my sub find_image_files ($dir) {
  [ find( file => mime => 'image/jpeg*', in => $dir ) ];
}

my sub optimize_jpeg ($temp_dir, $fullpath) {
  my $file = basename($fullpath);
  my $temp_path = catfile($temp_dir, $file);
  jpegtran $fullpath, $temp_path, trim => 0, perfect => 1, optimize => 1;

  # if (-e $temp_path ) {
 
  # } else {
  # }
}

my sub optimize_png($fullpath) {
  system("optipng", $fullpath);
}

my sub main ($args) {
  my $dir = $args->[0];
  my $image_files = find_image_files($dir);
  my $temp_dir = tempdir( 'optimize_images_pl_XXXXX',
                          TMPDIR => 1);
  foreach my $file ($image_files->@*) {
    say $file;
    # say basename($file);
    optimize_jpeg($temp_dir, $file);
  }
}

main(\@ARGV);
