package Muki;

use feature ':5.28';
use strict;
use warnings;
# use Mouse;
# use Moxie;
use Ref::Util qw<is_plain_arrayref>;
use experimental qw<signatures re_strict>;

# extends 'Moxie::Object';


sub new {
    my ( $class ) = @_;

    return bless {}, $class;
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


# __PACKAGE__->meta->make_immutable();
1;
