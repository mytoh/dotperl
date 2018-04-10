#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;

use File::HomeDir;
use File::Spec::Functions;

my @children = qw(huone kuvat sivusto);
say catdir(File::HomeDir->my_home, @children, 'wg');
