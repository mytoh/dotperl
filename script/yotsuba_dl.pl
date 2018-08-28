#!/usr/bin/env perl

use v5.28;
use utf8;
use autodie ':all';
use strictures 2;
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict>;
use re 'strict';

use File::chdir;
use File::Spec::Functions qw<catdir>;
use Time::HiRes qw<sleep>;
use IPC::System::Simple qw<systemx>;
use PerlX::Define;

my sub yotsuba ($dir) {
  my @children = qw<huone kuvat sivusto 4chan>;
  local $CWD = catdir( <~>, @children, $dir );
  # systemx( 'yotsuba.pl', '--all', $dir );
  systemx( 'chan.pl', 'yotsuba', '--all', $dir );
}

my sub main ($dirs) {
  while (1) {
    foreach my $dir ( $dirs->@* ) {
      say $dir;
      yotsuba $dir;
    }
    say "sleeping...";
    sleep 300;
  }
}

define TARGETS = [qw<trash w wg g>];
main(TARGETS);
