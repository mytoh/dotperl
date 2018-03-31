#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use warnings qw<FATAL utf8>;
use feature ":5.28";
use feature qw<refaliasing declared_refs>;
use experimental qw<signatures re_strict refaliasing script_run>;
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';

use ExtUtils::Installed;

my sub print_modules ($args) {
  my $cpan = $args->[0] // '';
  my $ext = ExtUtils::Installed->new;
  my @modules = $ext->modules();
  if ($cpan eq 'cpanfile') {
    for my $module (@modules) {
      say "requires '$module';" ;
    }
  } else {
    for my $module (@modules) {
      say  "$module";
    }
  }
}

print_modules(\@ARGV);
