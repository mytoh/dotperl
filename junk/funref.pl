#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;


my $myfunc = sub ($n) { $n + 1 };

my sub mysub ($n) {
  $n + 1;
}

my sub testref ($func) {
  &$func(41);
}

say 'closure';
say testref($myfunc);
say 'subroutine';
say testref(\&mysub);
