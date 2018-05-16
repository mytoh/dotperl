#!/usr/bin/env perl

use strict;
use warnings;
use v5.28;

# github.com/Dual-Life/experimental

BEGIN { eval { require feature } };

say for sort keys %feature::feature;
