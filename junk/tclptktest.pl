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

use Tcl::pTk;
use Tcl::pTk::Photo;
use Tcl::pTk::Image;

my sub main ($args) {
  my $mw = MainWindow->new;
  my $photo = $mw->Photo(-file => 'test.jpg', -format => 'jpeg');
  my $label = $mw->Label(-image => $photo);
  $label->pack;
  MainLoop;

}

main(\@ARGV);
