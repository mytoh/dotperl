
package types;

use Type::Library
  -base,
  -declare => qw<Test >;
use Type::Utils -all;
use Types::Standard -types, 'slurpy';
use Types::URI -all;
use Types::Common::Numeric -types;
use v5.28;
use strict;
use warnings;


declare Test,
  as Dict[filename => Str, slurpy Any] &
  Dict[url => Str, slurpy Any];

!!1;
