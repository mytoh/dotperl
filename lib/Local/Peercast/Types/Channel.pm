package Local::Peercast::Types::Channel;

use Type::Library
  -base,
  -declare => qw<Channel>;
use Type::Utils -all;
use Types::Standard -types, 'slurpy';
use Types::URI -all;
use Types::Common::Numeric -types;
use v5.28;
use strict;
use warnings;
use true;

class_type Channel, {class => 'Local::Peercast::Channel' };
