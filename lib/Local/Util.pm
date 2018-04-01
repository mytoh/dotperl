
package Local::Util;

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
use Ref::Util qw<is_plain_arrayref>;

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

# [[http://pppurple.hatenablog.com/entry/2016/05/28/230722][高階関数perl（higher order perl） - abcdefg.....]]
sub map :prototype($&$) ($self, $sub, $list)  {
  if (is_plain_arrayref($list)) {
    my @arr = $list->@*;
    my @res = map { $sub->($_) } @arr;
    \@res;
  } else {
    undef;
  }  
}

# [[https://stackoverflow.com/questions/5166662/perl-what-is-the-easiest-way-to-flatten-a-multidimensional-array][list - Perl: What is the easiest way to flatten a multidimensional array? - Stack Overflow]]
sub flatten :prototype($$) ($self, $list)  {
  $self->map(sub ($x) { $x->@*}, $list);
}

sub flatten_all :prototype($$) ($self, $list)  {
  map { is_plain_arrayref($_) ? $self->flatten_all($_) : $_ } $list->@*;
}  

!!1;
