#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature qw(say);
use experimental qw(signatures);

use DDP;

my sub cat ($cat) { 
    say "The cat is $cat";
    }

my sub dog ($names) {
  # say Dumper $names;
   p  $names;
  p  map {$_ * $_ } @{$names};
}

my sub nondestrsubst ($str) {
  my $subed = $str =~ s/old/new/r;
  $subed
}

my sub postderef ($ref) {
  p $ref-@*;
}

my sub defined_or () {
  my $test = 'default';
  my $none = undef ;

  $none // $test;
}


my @array = (1, 2, 3, 4, 5);

# cat( 'Buster' );

# dog(\@array);

# say nondestrsubst('satnoeuhsn,old,snthoeukf');

# postderef(\@array);

p defined_or();
