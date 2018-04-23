package Local::App::Chan::Command::Infinity;

use Local::App::Chan -command;
use v5.28;
use feature qw<refaliasing  declared_refs>;
use utf8;
use strictures 2;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing script_run>;
use re 'strict';
use File::Glob qw<:bsd_glob>;
use Path::Tiny qw<path>;
use Furl::HTTP;
use Net::DNS::Lite;
use Cache::LRU;
use File::Spec::Functions qw<catfile>;
use File::Slurper qw<read_text>;
use Term::ANSIColor qw<colored>;
use Regexp::Common qw<URI>;
use List::Flatten::XS qw<flatten>;
use Const::Fast qw<const>;
use Carp::Always;
use List::AllUtils qw<uniq>;
use WWW::Mechanize;
use URI::Split qw<uri_split>;
use List::UtilsBy qw<uniq_by>;
use File::Basename::Extra qw<basename>;
use Type::Params qw<compile>;
use Types::Standard qw<-types slurpy>;
use Local::Chan::Types qw<Board Thread>;
use Return::Type;
use IO::Handle;
use DDP;
no autovivification;

const my $HOST => '8ch.net';
const my $BASE_URL => "https://${HOST}";
const my $BASE_MEDIA_URL => "https://media.${HOST}";

my sub get_directories :ReturnType(ArrayRef) () {
  my @files = path('.')->children;
  [ map { $_->stringify } grep { $_->is_dir } @files ];
}

my sub is_number :ReturnType(Bool) ($x) {
  state $re = qr{\A\d+\z};
  $x =~ $re;
}

my sub thread_directories :ReturnType(ArrayRef) ($dirs) {
  state $c = compile(ArrayRef);
  $c->(@_);
  [ grep { is_number($_) } $dirs->@* ]
}

my sub make_url :ReturnType(Object) ($base, @segments) {
  state $c = compile(Str, slurpy ArrayRef[Str]);
  $c->(@_);
  my $url = URI->new($base);
  $url->path_segments(@segments);
  $url;
}

my sub find_non_existent_images :ReturnType(ArrayRef) ( $thread, $uris) {
  state $c = compile(Thread, ArrayRef[Object]);
  $c->(@_);
  [ grep { 
    !-f catfile( $thread, basename($_->url_abs->path)) ;
  }
    $uris->@* ];
}

my sub fetch_thread_data :ReturnType(Maybe[ArrayRef]) ( $mech, $board, $thread ) {
  state $c = compile(Object, Board, Thread);
  $c->(@_);
  my $url = make_url($BASE_URL, $board, 'res', "${thread}.html" );
  $mech->agent_alias('Windows Mozilla');
  $mech->get($url);
  if ($mech->success) {
    my $re_url = qr[media\.8ch\.net/((${board}/src)|file_store)] ;
    my @uris = $mech->find_all_links( tag => 'a', 
                                      url_regex => $re_url);
    my @image_uris = uniq_by { $_->url_abs->as_string } @uris;
    \@image_uris;
  } else {
    undef
  }
}

my sub download_file ( $ua, $thread, $uri) {
  state $c = compile(Object, Thread, Object);
  $c->(@_);
  my $output_file = catfile( $thread, basename($uri->url_abs->path));
  my $fh = path($output_file)->openw_raw;
  $fh->autoflush;
  $ua->request(
    method     => 'GET',
    url        => $uri->url_abs->as_string,
    write_file => $fh
   );

  close $fh;
}

my sub get_single ( $ua, $board, $thread ) {
  state $c = compile(Object, Board, Thread);
  $c->(@_);
  my $mech = WWW::Mechanize->new();
  my $uris = fetch_thread_data( $mech, $board, $thread );
  if ($uris->@*) {
    say $thread;
    my $images = find_non_existent_images( $thread, $uris);
    if ( $images->@* ) {
      say 'Downloading ' . $board . ': ' . $thread;
      foreach my $image ( $images->@* ) {
        download_file( $ua, $thread, $image );
      }
      say 'Downleaded '
        . colored( ['blue'], scalar( $images->@* ) )
        . ' files';
    }
  }
}

my sub get_all ( $ua, $board ) {
  state $c = compile(Object, Board);
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
  "Infinity";
}

sub description { "8chan script" }

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
  'infinity %o <board> <thread>';
}

sub execute ($self, $opt, $args) {

  local $Net::DNS::Lite::CACHE = Cache::LRU->new( size => 256, );

  get( $opt, $args );
}

!!1;
