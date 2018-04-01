#!/usr/bin/env perl

use utf8;
use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use strictures 2;
use autodie ':all';
use open qw<:std :encoding(UTF-8)>;
use experimental
  qw<signatures re_strict refaliasing script_run alpha_assertions>;
use re 'strict';
use utf8::all;
use IPC::System::Simple qw<systemx>;
use File::Basename qw<dirname>;
no autovivification;

my sub open_file($file) {
    systemx( qw<feh -Z -F -B black>, dirname($file) );
}

my sub open_directory ($dir) {
    systemx( qw<feh -Z -F -B black>, $dir );
}

my sub main ($args) {
    my $file = $args->[0];

    if ( -d $file ) {
        open_directory($file);
    }
    else {
        open_file($file);
    }
}

main( \@ARGV );