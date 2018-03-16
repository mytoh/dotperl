#!/usr/bin/env perl

use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use utf8;
use strictures 2;
use autodie ':all';
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing script_run>;
use re 'strict';
use Getopt::Long::Descriptive qw<describe_options>;
use File::Glob qw<:bsd_glob>;
use Path::Tiny qw<path>;
use Furl::HTTP;
use Net::DNS::Lite;
use Cache::LRU;
use File::Spec::Functions qw<catfile>;
use JSON::MaybeUTF8 qw(:v1);
use File::Slurper qw<read_text>;
use Term::ANSIColor qw<colored>;
use DDP;
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
no autovivification;

# use Encode qw<decode encode>;
@ARGV = map {decode_utf8($_)} @ARGV;

my sub get_directories () {
    my @files = path('.')->children;
    [ map { $_->stringify } grep { $_->is_dir } @files ];
}

my sub is_number ($x) {
    state $re = qr{\A\d+\z};
    $x =~ $re;
}

my sub thread_directories ($dirs) {
    [ grep {is_number($_)} $dirs->@* ]
}

my sub parse_images ( $board, $json ) {
    my @images = map +{
        dest => $_->{tim} . $_->{ext},
        url  => "https://i.4cdn.org/$board/$_->{tim}" . $_->{ext}
      },
      grep { exists $_->{filename} } $json->{posts}->@*;
    \@images;
}

my sub find_non_existent_images ( $thread, $image_data ) {
    [ grep { !-f catfile( $thread, $_->{dest} ) } $image_data->@* ];
}

my sub fetch_thread_data ( $ua, $board, $thread ) {
    my $url = "https://a.4cdn.org/${board}/thread/${thread}.json";
    my ( $minor_version, $status, $message, $headers, $content ) =
      $ua->request( method => 'GET', url => $url );
    if ( $status == 200 ) {
        my $data = decode_json_text($content);
        $data;
    }
    else {
        !!0;
    }
}

my sub download_file ( $ua, $thread, $image_data ) {
    my $output_file = catfile( $thread, $image_data->{dest} );

    my $fh = path($output_file)->openw_raw;

    $ua->request(
        method     => 'GET',
        url        => $image_data->{url},
        write_file => $fh
    );

    close $fh;
}

my sub get_single ( $ua, $board, $thread ) {
    my $thread_data = fetch_thread_data( $ua, $board, $thread );
    if ($thread_data) {
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
    }
}

my sub get_all ( $ua, $board ) {
    my $dirs = thread_directories( get_directories() );
    foreach my $thread ( reverse $dirs->@* ) {
        get_single( $ua, $board, $thread );
    }
}

my sub forever : prototype(&;$) ( $sub, $sleep ) {
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
        }
        else {
            get_all( $ua, $board );
        }
    }
    else {
        my $board  = $args->[0];
        my $thread = $args->[1];
        path($thread)->mkpath;
        if ( $opt->repeat ) {
            forever { get_single( $ua, $board, $thread ); } $sleep_second;
        }
        else {
            get_single( $ua, $board, $thread );
        }
    }
}

my sub main ($args) {
    $Net::DNS::Lite::CACHE = Cache::LRU->new( size => 256, );
    my $usage_desc = 'yotsuba %o <board> <thread>';
    my $opt_spec   = [
        [ 'all|a',    "process all directories in current directory" ],
        [ 'repeat|r', "repeat download forever" ],
        [
            'help',
            'print usage message and exit',
            {
                shortcircuit => 1
            }
        ],
    ];

    my ( $opt, $usage ) = describe_options(
        $usage_desc,
        $opt_spec->@*,
        +{
            getopt_conf =>
              [ "posix_default", "no_ignore_case", "bundling", "auto_help" ]
        }
    );

    if ( $opt->help ) {
        print( $usage->text );
    }
    else {
        get( $opt, $args );
    }
}

main( \@ARGV );
