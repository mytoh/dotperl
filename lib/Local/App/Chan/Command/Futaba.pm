package Local::App::Chan::Command::Futaba;

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
use Getopt::Long::Descriptive qw<describe_options>;
use File::Glob qw<:bsd_glob>;
use File::Spec::Functions qw<catfile>;
use File::Basename::Extra qw<basename>;
use Path::Tiny qw<path>;
use Term::ANSIColor qw<colored>;
use URI;
use List::AllUtils qw<first uniq any>;
use List::UtilsBy qw<uniq_by>;
use Const::Fast qw<const>;
use Furl::HTTP;
use Net::DNS::Lite;
use Cache::LRU;
use Regexp::Common qw<URI>;
use Type::Params qw<compile>;
use Type::Utils -all;
use Types::Standard -types;
use Types::URI -types;
use Local::Chan::Types -types;
use Local::Chan::Util qw<download_file forever>;
use Return::Type;
use Mojo::UserAgent;
use DDP;
no autovivification;

my $BoardDefinitions = declare BoardDefinitions =>
  as Map[Str, union([Str, ArrayRef])];

const my $BOARD_SERVERS =>
  $BoardDefinitions->(+{
  l  => 'dat',
  k  => 'cgi',
  7  => 'zip',
  16 => 'dat',
  40 => 'may',
  p  => 'zip',
  u  => 'cgi',
  b  => [qw<may jun dec>]
}
);

my sub get_directories :ReturnType(ArrayRef[Str]) () {
  my @files = path('.')->children;
  [
    map  { $_->stringify }
    grep { $_->is_dir } reverse @files
   ];
}

my sub is_number :ReturnType(Bool) ($x) {
  state $re = qr{\A\d+\z};
  $x =~ $re;
}

my sub thread_directories :ReturnType(ArrayRef[ThreadId]) ($dirs) {
  state $c = compile(ArrayRef[ThreadId]); $c->(@_);
  [ grep { is_number($_) } $dirs->@* ]
}

my sub fetch_b_thread :ReturnType(Bool) ( $obj, $server ) {
  state $c = compile(HashRef, Server); $c->(@_);
  my ( $board, $thread ) = $obj->@{qw<board thread>};
  my $url = "https://${server}.2chan.net/${board}/res/${thread}.htm";
  my $res = $obj->{'mojo'}->get( $url )->result;
  if ($res->is_success) {
    !!1;
  } else {
    !!0;
  }
}

my sub uri_base_name :ReturnType(Str) ($uri) {
  state $c = compile(Uri); $c->(@_);
  my @segs = $uri->path_segments;
  $segs[$#segs];
}

my sub find_non_existent_images :ReturnType(ArrayRef[Uri]) ( $thread, $image_links ) {
  state $c = compile(ThreadId, ArrayRef[Uri]); $c->(@_);
  [ grep { !-f catfile( $thread, uri_base_name($_) ) } $image_links->@* ];
}

my sub find_b_server :ReturnType(Server) ($obj) {
  state $c = compile(HashRef); $c->(@_);
  $obj->{'board'} = 'b';
  first { fetch_b_thread( $obj, $_ ) } $BOARD_SERVERS->{b}->@*;
}

my sub scrape_image_list :ReturnType(Maybe[ArrayRef[Uri]]) ($obj) {
  state $c = compile(HashRef); $c->(@_);
  my ( $mojo, $server, $board, $thread ) = $obj->@{qw<mojo server board thread>};
  my $base_url = "https://${server}.2chan.net";
  my $url = "${base_url}/${board}/res/${thread}.htm";
  my $res = $mojo->get($url)->result;
  if ( $res->is_success ) {
    my $query = qq{a[href*="${board}/src"]};
    my $links = $res->dom->find($query)->map('text')->uniq->to_array;
    my @uris = map { $_ ? URI->new_abs($_, "${base_url}/${board}/src/") : () } $links->@*;
    \@uris;
  } else {
    undef;
  }
}

my sub select_server :ReturnType(Server) ($obj) {
  state $c = compile(HashRef); $c->(@_);
  my $board = $obj->{'board'};
  if ( $board eq 'b' ) {
    find_b_server($obj);
  } else {
    $BOARD_SERVERS->{$board};
  }
}

my sub get_single ($obj) {
  state $c = compile(HashRef); $c->(@_);
  my ( $ua, $thread, $board ) = $obj->@{qw<ua thread board>};
  $obj->{'server'} = select_server($obj);
  if ( $obj->{'server'} ) {
    my $image_links = scrape_image_list($obj);
    if (defined $image_links) {
      say $thread;
      my $fetch_list = find_non_existent_images( $thread, $image_links );
      if ( $fetch_list->@* ) {
        say 'Downloading ' . $board . ': ' . $thread;
        foreach my $uri ( $fetch_list->@* ) {
          my $filename = catfile( $thread, uri_base_name($uri) );
          download_file( $ua, $uri, $filename);
        }
        say 'Downloaded '
          . colored( ['blue'], scalar( $fetch_list->@* ) )
          . ' files';
      }
    }
  }

}

my sub get_all ($obj) {
  state $c = compile(HashRef); $c->(@_);
  my $dirs = thread_directories( get_directories() );
  foreach my $thread ( $dirs->@* ) {
    $obj->{'thread'} = $thread;
    get_single($obj);
  }
}

my sub get ( $opt, $args ) {
  my $sleep_second = 60 * 5;
  my $ua           = Furl::HTTP->new(
    agent     => 'Mozilla/5.0',
    inet_aton => \&Net::DNS::Lite::inet_aton
   );
  my $mojo = Mojo::UserAgent->new;
  my $obj = +{
    ua   => $ua,
    mojo => $mojo,
  };
  if ( $opt->all ) {
    $obj->{'board'} = $args->[0];
    if ( $opt->repeat ) {
      forever { get_all($obj); } $sleep_second;
    } else {
      get_all($obj);
    }
  } else {
    $obj->@{qw<board thread>}  = $args->@[0, 1];
    path($obj->{'thread'})->mkpath;
    if ( $opt->repeat ) {
      forever { get_single($obj); } $sleep_second;
    } else {
      get_single($obj);
    }
  }
}

sub abstract {
  "Futaba";
}

sub description { "futaba script" }

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
