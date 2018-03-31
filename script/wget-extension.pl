#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use warnings qw<FATAL utf8>;
use feature ":5.28";
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict>;
use re 'strict';
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
use URI;
use Path::Tiny qw<path>;
use File::chdir;

#  [[https://www.youtube.com/watch?v=oWRBjLy8B-I][Wget Batch Download From Website - Linux CLI - YouTube]] :google:download:wget:

my sub url_basename ($url) {
  my $uri = URI->new($url);
  my @seg = $uri->path_segments;
  my $file = $seg[-1];
  my $dir = $seg[-2];
  $file ? $file : $dir;
}

my sub main ($args) {
  my $extensions = $args->[0];
  my $url = $args->[1];
  if (!defined $url ) {
    say "Download all files with specific extension on a webpage";
    say "Usage: $0 <file_extension> <url>";
    say "Example:\n$0 mp4 http://example.com/files/";
    say "$0 mp3,ogg,wma http://samples.com/files/";
    say "Google: http://lmgtfy.com/?q=intitle%3Aindex.of+mp3+-html+-htm+-php+-asp+-txt+-pls+madonna";
  } else {
    my $outputdir= url_basename($url);
    say decode_utf8($outputdir);
    path($outputdir)->mkpath;
    local $CWD = $outputdir;
    system(qx<wget -r -l1 -H -t1 -nd -N -np -A $extensions -erobots=off $url>);
  }
}

main(\@ARGV);
