#!/usr/bin/env perl

package Person {
  use Moo;
  use Types::Standard qw<:all>;

  has name => (
    is => 'rw',
    isa => Str,
   );

  has age => (
    is => 'rw',
    isa =>  Int,
   );
  
  1;
    
};

use strict;
use feature ":5.28";
  
my $person = Person->new(name => 'test', age => 9);
say $person->name;
say $person->age;
