#!/usr/bin/env perl

use v5.28;
use feature qw<refaliasing  declared_refs>;
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing script_run alpha_assertions>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use Unix::PID;
no indirect 'fatal';
no bareword::filehandles;
no autovivification;

my sub main ($args) {
  my $command = $args->[0];
  my $pid = Unix::PID->new;
  my @pids = $pid->get_pidof($command);
  say join(' ', @pids);
}

main(\@ARGV);
