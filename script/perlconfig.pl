#!/usr/bin/env perl

use utf8;
use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use strictures 2;
use autodie ':all';
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing script_run>;
use re 'strict';
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
no autovivification;
use Config;
use DDP;
use English;

$OUTPUT_AUTOFLUSH = 1;

my sub match_config ( $query, $key, $value ) {
    my $regexp = qr{\Q$query\E};
    if ( $key =~ $regexp ) {
        !!1;
    }
    elsif ($value) {
        $value =~ $regexp;
    }
    else {
        !!0;
    }
}

my sub main ($args) {
    my $query = $args->[0];
    if ($query) {
        foreach my $key ( keys %Config ) {
            if ( match_config( $query, $key, $Config{$key} ) ) {
                print "$key: ";
                p $Config{$key};
            }
        }
    }
    else {
        foreach my $key ( keys %Config ) {
            print "$key: ";
            p $Config{$key};
        }
    }
}

# use Encode qw<decode encode>;
@ARGV = map { decode_utf8($_) } @ARGV;
main( \@ARGV );
