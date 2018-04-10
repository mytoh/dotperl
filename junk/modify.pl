#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;


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
