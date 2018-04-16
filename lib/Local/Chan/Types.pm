package Local::Chan::Types;

use Type::Library 
  -base,
  -declare => qw<Board Thread>;
use Type::Utils -all;
use Types::Standard -types;
use strict;
use warnings;
 
declare Thread, 
  as Str;

declare Board, 
  as Str;
 
# declare "AllCaps",
#    as "Str",
#    where { uc($_) eq $_ },
#    inline_as { my $varname = $_[1]; "uc($varname) eq $varname" };
 
# coerce "AllCaps",
#    from "Str", via { uc($_) };

!!1;
