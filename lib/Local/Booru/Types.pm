
package Local::Booru::Types;

use Type::Library 
  -base,
  -declare => qw<Board 
                 Thread 
                 Server 
                 Image
                 MechLink 
                 Mech 
                 Furl 
                 FurlHttp
                HttpResponse>;
use Type::Utils -all;
use Types::Standard -types, 'slurpy';
use Types::URI -all;
use v5.28;
use strict;
use warnings;
 
declare Thread, 
  as Str;

declare Board, 
  as Str;

declare Server, 
  as Str;

declare Image,
  as Dict[filename => Str,
          url => Uri,
          slurpy Any];

class_type MechLink, {class => 'WWW::Mechanize::Link' };

class_type Mech, {class => 'WWW::Mechanize' };

class_type Furl;

class_type FurlHttp, {class => 'Furl::HTTP'};

class_type HttpResponse, { class => 'HTTP::Response' };
 
# declare "AllCaps",
#    as "Str",
#    where { uc($_) eq $_ },
#    inline_as { my $varname = $_[1]; "uc($varname) eq $varname" };
 
# coerce "AllCaps",
#    from "Str", via { uc($_) };

!!1;
