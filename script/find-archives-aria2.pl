#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use File::Find::Rule;
use feature ":5.28";
use experimental qw<signatures>;

my sub find_files ($dir) {
  my @files = File::Find::Rule->file()
    ->name( '*.zip', '*.rar')
    ->in($dir);
}

my sub delete_files ($files) {
  for my $f ($files->@*) {
    my $fa = $f . ".aria2";
    say "Deleting file $f";
    unlink $f or warn "Could not delete $f";
    say "Deleted file $f";
    say "Deleting aria2 file $fa";
    unlink $fa or warn "Could not delete $fa";
    say "Deleted aria2 file $fa";
  }
}

my sub main ($dir) {
  my @files = find_files($dir);

  my @files_with_aria2 = grep { -e $_ . ".aria2" } @files;

  # delete_files(\@files_with_aria2);
  
}

main($ARGV[0]);
