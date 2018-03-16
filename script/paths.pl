#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use warnings qw<FATAL utf8>;
use autodie ':all';
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing script_run>;
use re 'strict';
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
# use Encode qw<decode encode>;
@ARGV = map { decode_utf8($_) } @ARGV;

say for split /:/, $ENV{PATH}
