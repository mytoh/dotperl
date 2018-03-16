#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature qw(say signatures);
use experimental qw(signatures);


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
