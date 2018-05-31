#!/usr/bin/env perl

use v5.28;
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use Acme::LookOfDisapproval qw<ಠ_ಠ>;
use List::SomeUtils qw<apply>;
no indirect 'fatal';
no bareword::filehandles;
no autovivification;


my @list = (1 .. 4);
my @mult = apply { $_ *= 2 } @list;
print "\@list = @list\n";
print "\@mult = @mult\n";
__END__
@list = 1 2 3 4
@mult = 2 4 6 8
