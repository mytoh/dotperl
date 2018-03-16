#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature qw(say signatures);
use experimental qw(signatures);


my sub test (%hash) {
 $hash{a} = 'modified';
 %hash;
}

my %myhash = ('a' => 'original');

my %mod = test(%myhash);

say 'original';
say $myhash{a};

say 'modified';
say $mod{a};
