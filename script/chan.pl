#!/usr/bin/env perl

use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use utf8;
use strict;
use warnings;
use experimental qw<signatures re_strict refaliasing script_run alpha_assertions>;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
use Project::Libs;
use Muki::App::Chan;
no autovivification;

Muki::App::Chan->run;









