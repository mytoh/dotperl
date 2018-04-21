#!/usr/bin/env perl

use v5.28;
use strict;
use warnings;
use utf8;
use warnings qw<FATAL utf8>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict>;
use re 'strict';
use Module::CoreList;

my sub core_modules () {
  Module::CoreList->find_modules(qr/.*/);
}

my sub module_is_core ($module) {
  if (Module::CoreList->is_core($module)) {
    say 'Module ' . $module . ' is core.';
  } else {
    say 'Module ' . $module . ' is NOT core.';
  }
}

my sub main ($args) {
  if($args->[0]) {
    module_is_core($args->[0])
  } else {
    say for core_modules();
  }
}

main(\@ARGV);
