#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use DDP;
use Scalar::Util qw(reftype);
use feature qw(say signatures);
use experimental qw(signatures);

my @array = (1, 2, 3, 4, 5);

my sub func ($ref) {
  $ref;
}

my $stuff = {
    blank => "",
    null => "\0",
    undefined => undef,
    zed => 0,
    zero => '0',
};


my %testhash = (
    blank => "",
    null => "\0",
    undefined => undef,
    zed => 0,
    zero => '0',
);


say  reftype(%{$stuff});
p $stuff;
say reftype(%testhash);
p %testhash;

p func(\@ARGV);
