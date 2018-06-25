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
use Type::Utils -all;
use Types::Standard -all;
no indirect 'fatal';
no bareword::filehandles;
no autovivification;

my sub main ($x) {
  match_on_type $x => (
    HashRef[ArrayRef] ,=> sub {
      say "HashRef[ArrayRef]";
    },
    HashRef[Num] ,=> sub {
      say "HashRef[Num]";
    },
    HashRef ,=> sub {
      say "HashRef";
},
    Undef ,=> sub {
      say "Undef";
    },
    Any ,=> sub {
      say "Any: $_";
},
   );
}

# main({});
# main({a => 1, b => 1});
# main({a => [qw<a b c>]});
# main(0);
# main('');
# main('nsaeuht');
# main([qw<a b c>]);
# main(undef);


# my sub loop ($x) {
# match_on_type $x => (
#   Num ,=> sub { say "num"},
#   ArrayRef ,=> sub {loop(1)},
# )
# }


# loop([1]);
