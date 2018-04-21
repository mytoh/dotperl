#!/usr/bin/env perl

use v5.28;
use utf8;
use strict;
use warnings;
use warnings qw<FATAL utf8>;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;
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
