#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use warnings qw<FATAL utf8>;
use autodie ':all';
use feature ":5.28";
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict>;
use re 'strict';
use List::Util qw<uniq>;

my sub list_env ($env) {
  if ($ENV{$env}) {
    my @envs = split /:/, $ENV{$env};
    [ uniq(@envs) ];
  } else {
    !!0;
  }
}

my sub find_segment ($seg, $list) {
  grep {$_ eq $seg } $list->@*;
}

my sub join_with_colon ($list) {
  join ':', $list->@*;
}

my sub main ($args) {
  my $segment = $args->[0];
  my $env_name = $args->[1];
  my $env_list =  list_env($env_name);
  
  if (! $env_list) {
    print $segment;
  } elsif (find_segment($segment, $env_list)) {
    my $joined_env = join_with_colon($env_list);
    print $joined_env;
  } else {
    unshift $env_list->@*, $segment;
    my $joined_env = join_with_colon($env_list);
    print $joined_env;
  }
}

main(\@ARGV);
