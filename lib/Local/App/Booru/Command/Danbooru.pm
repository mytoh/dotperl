package Local::App::Booru::Command::Danbooru;

use Local::App::Booru -command;
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
use Const::Fast qw<const>;
use Furl::HTTP;
use Net::DNS::Lite;
use Cache::LRU;
use LWP::UserAgent;
use JSON::MaybeUTF8 qw(:v1);
use Type::Params qw<compile>;
use Types::Standard -types;
use Local::Booru::Types -types;
use Return::Type;
no autovivification;

my sub format_tags :ReturnType(ArrayRef) ($tags) {
  state $c = compile(ArrayRef[Str]);
  $c->(@_);
  if ( scalar $tags->@* > 1 ) {
    join " ", $tags->@*;
  } else {
    $tags->[0];
  }
}

my sub is_get_successed :ReturnType(Bool) ($res) {
  state $c = compile(HttpResponse);
  $c->(@_);
  if ( $res->is_success && $res->content eq "[]" ) {
    !!0;
  } elsif ( $res->is_success ) {
    !!1;
  } else {
    !!0;
  }
}

my sub get_posts :ReturnType(Maybe[HashRef]) ( $page, $tags ) {
  state $c = compile(Num, ArrayRef[Str]);
  $c->(@_);
  my $ua = LWP::UserAgent->new;
  $ua->agent("Mozilla/5.0");

  my $formatted_tags = format_tags($tags);
  my $limit          = 100;

  my $url = URI->new("https://danbooru.donmai.us/posts.json");
  $url->query_form(
    tags  => $formatted_tags,
    limit => $limit,
    page  => $page
   );

  my $req = HTTP::Request->new( GET => $url );

  my $res = $ua->request($req);

  if ( is_get_successed($res) ) {
    say "Getting page ${page}";
    decode_json_text( $res->content );
  } else {
    undef;
  }
}

my sub download_post ( $ua, $post ) {
  state $c = compile(FurlHttp, HashRef);
  $c->(@_);
  if ( defined $post->{'large_file_url'} ) {
    my $output_file =
      $post->{'id'} . '-' . basename( $post->{'large_file_url'} );
    if ( !-f $output_file ) {
      my $fh  = path($output_file)->openw_raw;
      my $url = URI->new_abs( $post->{'large_file_url'},
                              'https://danbooru.donmai.us' );
      $ua->request(
        method     => 'GET',
        url        => $url,
        write_file => $fh
       );
    }
  }
}

my sub download_posts ($posts) {
  state $c = compile(ArrayRef[HashRef]);
  $c->(@_);
  my $ua = Furl::HTTP->new(
    agent     => 'Mozilla/5.0',
    inet_aton => \&Net::DNS::Lite::inet_aton
   );
  foreach my $post ( $posts->@* ) {
    download_post( $ua, $post );
  }
}

my sub start_loop ( $page, $tags ) {
  state $c = compile(Num, ArrayRef[Str]);
  $c->(@_);
  my $posts = get_posts( $page, $tags );
  if (defined $posts) {
    download_posts($posts);
    __SUB__->( $page + 1, $tags );
  } else {
    say "End";
  }
}

sub abstract { "Danbooru" }

sub description { "Get images from danbooru" }

sub opt_spec {
  (
    [
      'page|p=i',
      "page number which start downloading from",
      {
        default => 1 }
     ],
    +{
      getopt_conf =>
      [ "posix_default", "no_ignore_case", "bundling", "auto_help" ]
    }
   );
}

sub validate_args ($self, $opt, $args) {

  # no args allowed but options!
  # $self->usage_error("No args allowed") if @$args;
}

sub execute ($self, $opt, $tags) {
  say join ', ', $tags->@*;
  start_loop( $opt->page, $tags );
}

!!1;
