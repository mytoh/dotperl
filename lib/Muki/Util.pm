
package Muki::Util;

use utf8;
use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use strict;
use warnings;
use strictures 2;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing script_run>;
use re 'strict';
use List::AllUtils qw<reduce>;

use Exporter 'import';
our @EXPORT_OK = qw<pipeline compose>;

sub pipeline (@fns) {
  my $sub = sub ($param) {
    reduce {
      my $result = $a;
      my $fn = $b;
      $fn->($result);
    } $param, @fns;
  };
  $sub;
}

sub compose (@fns) {
  my $sub = sub ($param) {
    reduce {
      my $result = $a;
      my $fn = $b;
      $fn->($result);
    } $param, reverse @fns;
  };
  $sub;
}

!!1;
