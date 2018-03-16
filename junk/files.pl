#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature qw(say switch signatures);
use experimental qw(smartmatch signatures);

use File::HomeDir;
use File::Spec::Functions;

my @children = qw(huone kuvat sivusto);
say catdir(File::HomeDir->my_home, @children, 'wg');
