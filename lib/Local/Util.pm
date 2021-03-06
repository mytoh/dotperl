
package Local::Util;

use v5.28;
use utf8;
use strict;
use warnings;
use strictures 2;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;
use re 'strict';
use List::AllUtils qw<reduce>;
use Ref::Util qw<is_plain_arrayref>;

use Exporter::Shiny qw<pipeline compose>;

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
sub map :prototype($&$) ($sub, $list)  {
  if (is_plain_arrayref($list)) {
    my @arr = $list->@*;
    my @res = map { $sub->($_) } @arr;
    \@res;
  } else {
    undef;
  }  
}

# [[https://stackoverflow.com/questions/5166662/perl-what-is-the-easiest-way-to-flatten-a-multidimensional-array][list - Perl: What is the easiest way to flatten a multidimensional array? - Stack Overflow]]
sub flatten :prototype($$) ($list)  {
  map(sub ($x) { $x->@*}, $list);
}

sub flatten_all :prototype($$) ($list)  {
  map { is_plain_arrayref($_) ? __SUB__->($_) : $_ } $list->@*;
}  

!!1;
