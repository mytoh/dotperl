#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use warnings qw<FATAL utf8>;
use autodie ':all';
use feature ":5.28";
use feature 'switch';
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict smartmatch>;
use re 'strict';
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
# use Encode qw<decode encode>;
@ARGV = map { decode_utf8($_) } @ARGV;


given ('a') {
  whereso($_ eq 'c') { say 'matched ' . $_}
  whereso($_ eq 'b') { say 'matched ' . $_}
  whereso($_ eq 'a') { say 'matched ' . $_}
}


given ('a') {
  whereis(qr/a/) { say 'matched ' . $_ . ' with regex'}
}


given ('a') {
  whereis(qr/notmatch/) {}
  {
  say 'nothing matched';
}
}
