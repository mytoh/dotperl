package Local::Chan::Util;

use v5.28;
use utf8;
use strictures 2;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;
use re 'strict';
use File::Glob qw<:bsd_glob>;
use Path::Tiny qw<path>;
use File::Spec::Functions qw<catfile>;
use Type::Params qw<compile>;
use Types::Standard -types, 'slurpy';
use Types::URI -all;
use Local::Chan::Types -types;
use Return::Type;
no autovivification;

use Exporter::Shiny qw<download_file
                       forever>;

sub download_file ( $ua, $url, $file ) {
  state $c = compile(FurlHttp, Uri, Str); $c->(@_);

  my $fh = path($file)->openw_raw;

  $ua->request(
    method     => 'GET',
    url        => $url,
    write_file => $fh
   );
}

sub forever : prototype(&;$) ( $sub, $sleep ) {
  state $c = compile(CodeRef, Num); $c->(@_);
  while (1) {
    $sub->();
    sleep $sleep;
  }
}

!!1;
