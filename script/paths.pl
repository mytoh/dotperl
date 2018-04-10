#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature ":5.28";
use warnings qw<FATAL utf8>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;
use re 'strict';

say for split /:/, $ENV{PATH}
