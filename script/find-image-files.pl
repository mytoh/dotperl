#!/usr/bin/env perl

use v5.28;
use utf8;
use strictures 2;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict>;
use re 'strict';
use utf8::all;
use File::Find::Rule::LibMagic qw<find>;

my sub find_image_files ($dir) {
    [ find( file => mime => 'image/*', in => $dir ) ];
}

my sub main ($args) {
    my $dir   = $args->[0];
    my $files = find_image_files $dir;
    for my $file ( $files->@* ) {
        say $file;
    }
}

main( \@ARGV );
