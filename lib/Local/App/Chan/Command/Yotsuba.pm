package Local::App::Chan::Command::Yotsuba;

use Local::App::Chan -command;
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
use Furl::HTTP;
use Net::DNS::Lite;
use Cache::LRU;
use File::Spec::Functions qw<catfile>;
use JSON::MaybeUTF8 qw(:v1);
use File::Slurper qw<read_text>;
use Term::ANSIColor qw<colored>;
use Regexp::Common qw<URI>;
use Type::Params qw<compile>;
use Types::Standard -types, 'slurpy';
use Type::Utils -all;
use Types::URI -all;
use Local::Chan::Types -types;
use Return::Type;
use Const::Fast;
use URI;
no autovivification;

my sub get_directories :ReturnType(ArrayRef) () {
  my @files = path('.')->children;
  [ map { $_->stringify } grep { $_->is_dir } @files ];
}

my sub is_number :ReturnType(Bool) ($x) {
  state $c = compile(Str);
  $c->(@_);
  state $re = qr{\A\d+\z};
  $x =~ $re;
}

my sub thread_directories :ReturnType(ArrayRef) ($dirs) {
  state $c = compile(ArrayRef[Str]);
  $c->(@_);
  [ grep { is_number($_) } $dirs->@* ]
}

my sub parse_images :ReturnType(ArrayRef[Image]) ( $board, $json ) {
  state $c = compile(Board, HashRef);
  $c->(@_);
  my @images = map {
    my $url = URI->new("https://i.4cdn.org");
    $url->path_segments( $board, $_->{'tim'} . $_->{'ext'} );
    +{ filename => $_->{'tim'} . $_->{'ext'}, url => $url }
  }
    grep { exists $_->{'filename'} } $json->{'posts'}->@*;
  \@images;
}

my sub find_non_existent_images :ReturnType(ArrayRef[Image]) ( $thread, $image ) {
  state $c = compile(Thread, ArrayRef[Image]);
  $c->(@_);
  [ grep { !-f catfile( $thread, $_->{'filename'} ) } $image->@* ];
}

my sub fetch_thread_data :ReturnType(Maybe[HashRef]) ( $ua, $board, $thread ) {
  state $c = compile(FurlHttp, Board, Thread);
  $c->(@_);
  my $url = URI->new("https://a.4cdn.org");
  $url->path_segments( $board, 'thread', "${thread}.json" );

  my ( $minor_version, $status, $message, $headers, $content ) =
    $ua->request( method => 'GET', url => $url->as_string );
  if ( $status == 200 ) {
    my $data = decode_json_text($content);
    $data;
  } else {
    undef;
  }
}

my sub download_file ( $ua, $thread, $image ) {
  state $c = compile(FurlHttp, Thread, Image);
  $c->(@_);
  my $output_file = catfile( $thread, $image->{'filename'} );

  my $fh = path($output_file)->openw_raw;

  $ua->request(
    method     => 'GET',
    url        => $image->{'url'},
    write_file => $fh
   );
}

my sub get_single ( $ua, $board, $thread ) {
  state $c = compile(FurlHttp, Board, Thread);
  $c->(@_);
  my $thread_data = fetch_thread_data( $ua, $board, $thread );

  if (defined $thread_data) {

    say $thread;
    my $images =
      find_non_existent_images( $thread,
                                parse_images( $board, $thread_data ) );
    if ( $images->@* ) {
      say 'Downloading ' . $board . ': ' . $thread;
      foreach my $image ( $images->@* ) {
        download_file( $ua, $thread, $image );
      }
      say 'Downleaded '
        . colored( ['blue'], scalar( $images->@* ) )
        . ' files';
    }
  } else {
    undef;
  }
}

my sub get_all ( $ua, $board ) {
  state $c = compile(FurlHttp, Board);
  $c->(@_);
  my $dirs = thread_directories( get_directories() );
  foreach my $thread ( reverse $dirs->@* ) {
    get_single( $ua, $board, $thread );
  }
}

my sub forever : prototype(&;$) ( $sub, $sleep ) {
  state $c = compile(CodeRef, Num);
  $c->(@_);
  while (1) {
    $sub->();
    sleep $sleep;
  }
}

my sub get ( $opt, $args ) {
  state $c = compile(Object, ArrayRef);
  $c->(@_);
  my $sleep_second = 60 * 5;
  my $ua           = Furl::HTTP->new(
    agent     => 'Mozilla/5.0',
    inet_aton => \&Net::DNS::Lite::inet_aton
   );
  if ( $opt->all ) {
    my $board = $args->[0];
    if ( $opt->repeat ) {
      forever { get_all( $ua, $board ); } $sleep_second;
    } else {
      get_all( $ua, $board );
    }
  } else {
    my $board  = $args->[0];
    my $thread = $args->[1];
    path($thread)->mkpath;
    if ( $opt->repeat ) {
      forever { get_single( $ua, $board, $thread ); } $sleep_second;
    } else {
      get_single( $ua, $board, $thread );
    }
  }
}

sub abstract {
  "Yotsuba";
}

sub description { "4chan script" }

sub opt_spec {
  (
    [ 'all|a',    "process all directories in current directory" ],
    [ 'repeat|r', "repeat download forever" ],
    +{
      getopt_conf =>
      [ "posix_default", "no_ignore_case", "bundling", "auto_help" ]
    }
   );
}

sub validate_args ($self, $opt, $args) {

  if ( defined $args->[0] ) {
    unless ( $args->[0] =~ /$RE{URI}{HTTP}{-scheme => '(https|http)'}/
             || $args->[0] =~ /\A\w+\z/ ) {
      $self->usage_error('First argument should be Board Name or URL');
    }
  } else {
    $self->usage_error("Specify Board Name");
  }

  if ( defined $args->[1] ) {
    $self->usage_error("Thread should be Number")
      unless is_number $args->[1];
  }
}

sub usage_desc {
  'yotsuba %o <board> <thread>';
}

sub execute ($self, $opt, $args) {

  local $Net::DNS::Lite::CACHE = Cache::LRU->new( size => 256, );

  get( $opt, $args );
}

!!1;
