#!/usr/bin/env perl

use feature ":5.28";
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(utf-8)>;
use re 'strict';
no indirect 'fatal';
no bareword::filehandles;
no autovivification;

use WWW::Mechanize::Firefox;
my $mech = WWW::Mechanize::Firefox->new();
$mech->get('http://google.com');

$mech->eval_in_page('alert("Hello Firefox")');
my $png = $mech->content_as_png();

