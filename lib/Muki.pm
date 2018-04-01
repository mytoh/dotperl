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
 


# __PACKAGE__->meta->make_immutable();
1;
