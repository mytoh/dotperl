#!/usr/bin/env perl

use utf8;
use strictures 2;
use File::chdir;
use File::MimeInfo;
use Archive::Extract;
use Archive::Rar::Passthrough;
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
use open qw<:std :encoding(UTF-8)>;
use feature ":5.28";
use experimental qw<signatures re_strict>;
use re 'strict';


my sub extract_file ($file, $todir) {
  my $ae = Archive::Extract->new(archive => $file);
  my $ok = $ae->extract(to => $todir);
  $ok;
}


my sub extract_rar_file ($file, $todir) {
  my $rar = Archive::Rar::Passthrough->new();
  my $errorcode = $rar->run(
                            command => 'e',
                            archive => $file,
                            path => $todir, # optional
                           );
  $errorcode;
}

my sub get_file_extension ($file) {
  my $fm = File::MimeInfo->new();
  my $type = $fm->mimetype($file);
  my $ext = $fm->extensions($type);
  $ext;
}

my $extraction_table = +{
                         zip => \&extract_file,
                         rar => \&extract_rar_file,
                         default => \&extract_file,
                        };

my sub main ($args) {
  my $file = $args->[0];
  my $ext = get_file_extension($file);
  
  my $todir = $args->[1] // $CWD;
  
  my $sub = exists $extraction_table->{$ext} ? $extraction_table->{$ext} : $extraction_table->{'default'};
  
  say "Extracting $file to $todir";
  $sub->($file, $todir);
}

@ARGV = map { decode_utf8($_) } @ARGV;
main(\@ARGV);
