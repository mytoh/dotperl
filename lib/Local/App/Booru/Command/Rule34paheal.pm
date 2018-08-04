
package Local::App::Booru::Command::Rule34paheal;

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
use Net::DNS::Lite;
use Cache::LRU;
use Mojo::UserAgent;
use JSON::MaybeUTF8 qw(:v1);
use Type::Params qw<compile>;
use Types::Standard -types;
use Local::Booru::Types -types;
use Return::Type;
no autovivification;

my sub format_tags :ReturnType(Str) ($tags) {
  state $c = compile(ArrayRef[Str]); &{$c};
  if ( scalar $tags->@* > 1 ) {
    join "%20", $tags->@*;
  } else {
    $tags->[0];
  }
}

my sub is_get_successed :ReturnType(Bool) ($res) {
  state $c = compile(MojoMessageResponse); &{$c};
  if ( $res->is_success && $res->body eq "[]" ) {
    !!0;
  } elsif ( $res->is_success ) {
    !!1;
  } else {
    !!0;
  }
}

my sub get_posts :ReturnType(Maybe[ArrayRef[Str]]) ($ua, $page, $tags ) {
  state $c = compile(MojoUserAgent, Num, ArrayRef[Str]); &{$c};

  my $formatted_tags = format_tags($tags);
  my $limit          = 100;

  my $url = URI->new("https://rule34.paheal.net/post/list/" . $formatted_tags . "/" . $page);

  say $url;
  my $res = $ua->get($url->as_string)->result;
  if ( is_get_successed($res) ) {
    say "Getting page ${page}";
    my @links = $res->dom
      ->find('section#imagelist div a')
      ->grep(sub {$_->text eq "Image Only"})
      ->map(attr => 'href')
      ->each;
    \@links;
  } else {
    undef;
  }
}

my sub download_post ( $ua, $link ) {
  state $c = compile(MojoUserAgent, Str); &{$c};
  if ( defined $link ) {
    my $output_file = basename($link);
    if ( !-f $output_file ) {
      $ua->get($link)
        ->result
        ->content
        ->asset
        ->move_to($output_file);
    }
  }
}

my sub download_posts ($ua, $links) {
  state $c = compile(MojoUserAgent, ArrayRef[Str]); &{$c};
  foreach my $post ( $links->@* ) {
    download_post( $ua, $post );
  }
}

my sub start_loop ($ua, $page, $tags ) {
  state $c = compile(MojoUserAgent, Num, ArrayRef[Str]); &{$c};
  my $links = get_posts($ua, $page, $tags );
  if (defined $links) {
    download_posts($ua, $links);
    __SUB__->($ua, $page + 1, $tags);
  } else {
    say "End";
  }
}

sub abstract { "Rule34.xxx" }

sub description { "Get images from rule34.xxx" }

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
  my $ua = Mojo::UserAgent->new;
  $ua->transactor->name("Mozilla/5.0");

  my $page = $opt->page;
  start_loop($ua, $page, $tags );
}

!!1;
