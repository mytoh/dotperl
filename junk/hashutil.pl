#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use DDP;

 use FindBin;
 use lib "$FindBin::Bin/../lib";
use Muki::Hash::Util;

use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;


my $h = Muki:Hash::Util->new;

my $hash = { a => 1, b => 2};

p $h->get($hash, 'a');

p $h->assoc($hash, 'c', 3);
