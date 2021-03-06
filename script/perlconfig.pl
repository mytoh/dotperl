#!/usr/bin/env perl

use v5.28;
use utf8;
use strictures 2;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;
use re 'strict';
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

main( \@ARGV );
