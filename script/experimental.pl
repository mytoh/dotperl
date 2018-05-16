#!/usr/bin/env perl

use strict;
use warnings;
use v5.28;

# github.com/Dual-Life/experimental

say "experimental::";
say for sort
  map { s/experimental::/  /r }
  grep { /^experimental::/ }
  keys %warnings::Offsets;
