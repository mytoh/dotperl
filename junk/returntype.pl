#!/usr/bin/env perl

use v5.28;
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use Acme::LookOfDisapproval qw<ಠ_ಠ>;
use Return::Type;
use Types::Standard -types;

my sub foo :ReturnType(Str) {
  return $_[0];
}

foo("1");
