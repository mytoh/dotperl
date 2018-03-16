#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use DDP;

 use FindBin;
 use lib "$FindBin::Bin/../lib";
use Muki::Hash::Util;

use feature qw(say signatures);
use experimental qw(signatures);


my $h = Muki:Hash::Util->new;

my $hash = { a => 1, b => 2};

p $h->get($hash, 'a');

p $h->assoc($hash, 'c', 3);
