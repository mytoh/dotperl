#!/usr/bin/env perl

use strict;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Local::App::Chan;

Local::App::Chan->run;
