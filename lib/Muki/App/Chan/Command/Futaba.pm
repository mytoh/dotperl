package Muki::App::Chan::Command::Futaba;

use Muki::App::Chan -command;
use utf8;
use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use strictures 2;
use autodie ':all';
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing script_run>;
use re 'strict';
use Getopt::Long::Descriptive qw<describe_options>;
use File::Glob qw<:bsd_glob>;
use File::Spec::Functions qw<catfile>;
use File::Basename::Extra qw<basename>;
use Path::Tiny qw<path>;
use Term::ANSIColor qw<colored>;
use URI;
use DDP;
use List::AllUtils qw<first uniq any>;
use Const::Fast qw<const>;
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
use Furl::HTTP;
use Net::DNS::Lite;
use Cache::LRU;
use Regexp::Common qw<URI>;
# use XML::LibXML::jQuery;
use WWW::Mechanize;
no autovivification;

const my $BOARD_SERVERS => { l => 'dat',
                             k => 'cgi',
                             7 => 'zip',
                             16 => 'dat',
                             40 => 'may',
                             p => 'zip',
                             u => 'cgi',
                             b => [qw<may jun dec>]};

my sub get_directories () {
  my @files = bsd_glob(qw<*>);
  [grep { -d $_ } reverse @files];
}

my sub is_number ($x) {
  state $re = qr{\A\d+\z};
  $x =~ $re;
}

my sub thread_directories ($dirs) {
  [ grep {is_number($_)} $dirs->@* ] 
}

my sub download_file ($ua, $thread, $link) {
  my $output_file = catfile($thread, basename($link));
  my $fh = path($output_file)->openw_raw or die $!;
  $ua->request(
    method => 'GET',
    url => $link,
    write_file => $fh,
   );
  close $fh;
}

my sub fetch_b_thread ($ua, $server, $board, $thread) {
  my $url = "https://${server}.2chan.net/${board}/res/${thread}.htm";
  my ($minor_version, $status, $message, $headers, $content) = $ua->request(method => 'GET' , url => $url );
  if ($status == 200 ) {
    !!1;
  } else {
    !!0;
  }
}

my sub uri_base_name ($url) {
  my $uri = URI->new($url);
  my @segs = $uri->path_segments;
  $segs[$#segs];
}

my sub find_non_existent_images ( $thread, $image_links ) {
  [ grep { ! -f catfile( $thread, uri_base_name($_) ) } $image_links->@* ]; 
}

my sub find_b_server ($ua, $thread) {
  first { fetch_b_thread($ua, $_, 'b', $thread)} $BOARD_SERVERS->{b}->@*;
}

my sub scrape_image_list ($mech, $server, $board, $url) {
  $mech->get($url);
  if ($mech->success) {
    my @uris = $mech->find_all_links(tag => "a", url_regex => qr{$board/src});
    my @images = uniq map { $_->url_abs->as_string } @uris;
    \@images;
  } else {
    undef;
  }

}

my sub select_server ($ua,$board, $thread) {
  if ($board eq 'b') {
    find_b_server($ua, $thread);
  } else {
    $BOARD_SERVERS->{$board};
  }
}

my sub get_single ($ua, $mech, $board, $thread ) {
  my $server = select_server($ua,$board, $thread);
  if ($server) {
    my $image_links = scrape_image_list($mech, $server, $board, "https://${server}.2chan.net/${board}/res/${thread}.htm");
    if ($image_links) {
      say $thread;
      my $fetch_list = find_non_existent_images($thread, $image_links);
      if ( $fetch_list->@*) {
        say 'Downloading ' . $board . ': ' . $thread;
        foreach my $image ( $fetch_list->@* ) {
          download_file($ua, $thread, $image );
        }
        say 'Downloaded ' . colored(['blue'], scalar( $fetch_list->@* ))  . ' files';
      }
    }
  }

}

my sub get_all ($ua, $mech, $board) {
  my $dirs = thread_directories( get_directories() );
  foreach my $thread ( $dirs->@* ) {
    get_single($ua, $mech, $board, $thread );
  }
}

my sub forever :prototype(&;$) ( $sub, $sleep ) {
  while (1) {
    $sub->();
    sleep $sleep;
  }
}

my sub get ( $opt, $args ) {
  my $sleep_second = 60 * 5;
  my $ua = Furl::HTTP->new(agent => 'Mozilla/5.0',
                           inet_aton => \&Net::DNS::Lite::inet_aton);
  my $mech = WWW::Mechanize->new();
  $mech->agent_alias('Windows Mozilla');
  if ( $opt->all ) {
    my $board = $args->[0];
    if ( $opt->repeat ) {
      forever { get_all($ua, $mech, $board); } $sleep_second;
    } else {
      get_all($ua, $mech, $board);
    }
  } else {
    my $board  = $args->[0];
    my $thread = $args->[1];
    if ( $opt->repeat ) {
      forever { get_single($ua, $mech, $board, $thread ); } $sleep_second;
    } else {
      get_single($ua, $mech, $board, $thread );
    }
  }
}

sub abstract { 
  "Futaba" 
}

sub description { "futaba script" }

sub opt_spec {
  (
    [ 'all|a',    "process all directories in current directory" ],
    [ 'repeat|r', "repeat download forever" ],
    +{
      getopt_conf => [ "posix_default", 
                       "no_ignore_case",
                       "bundling",
                       "auto_help" ]
    }
   );
}

sub validate_args ($self, $opt, $args) {

  if (defined $args->[0]) {
    unless ( $args->[0] =~ /$RE{URI}{HTTP}{-scheme => '(https|http)'}/ || $args->[0] =~ /\A\w+\z/ ) {
      $self->usage_error('First argument should be Board Name or URL');
    }
  } else {
    $self->usage_error("Specify Board Name");
  }

  if (defined $args->[1]) {
    $self->usage_error("Thread should be Number") unless is_number $args->[1];
  }
}

sub usage_desc {
  'yotsuba %o <board> <thread>';
}



sub execute ($self, $opt, $args) {
  
  $Net::DNS::Lite::CACHE = Cache::LRU->new( size => 256, );

  get( $opt, $args );
}

!!1;
