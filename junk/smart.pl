#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature ":5.28";
use warnings qw<FATAL utf8>;
use autodie ':all';
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict>;
use re 'strict';
use Smart::Args::TypeTiny;
use Types::Standard qw<Str slurpy>;
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
# use Encode qw<decode encode>;
@ARGV = map { decode_utf8($_) } @ARGV;



my sub test (@args) {
  args_pos my $args => slurpy Str;
  say for $args->@*;
}

test(@ARGV);
