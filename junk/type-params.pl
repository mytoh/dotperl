#!/usr/bin/env perl

use feature ":5.28";
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use Type::Params qw<compile>;
use Types::Standard qw<Str Num ArrayRef HashRef>;
no indirect 'fatal';
no bareword::filehandles;
no autovivification;


my sub test($str, $num, $ar, $hr) {
  state $c = compile(Str, Num, ArrayRef, HashRef);
  $c->($str, $num, $ar, $hr);
  say "pass";
}

my sub num($n) {
  state $c = compile(Num);
  $c->($n);
  say "pass";
}

num(1);
num("1");
test("test", 1, [1,2], {a => 1, b => 2});
test(1, [1,2], {a => 1, b => 2}, "test");
