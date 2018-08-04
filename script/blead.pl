#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature qw<say>;
use autodie ':all';
use open qw<:std :encoding(UTF-8)>;
use File::pushd qw<pushd>;
use File::Path qw<remove_tree make_path>;
use HTTP::Tiny;

my sub command_install {
  if ( ! -d "$ENV{HOME}/.blead/git/perl") {
    my $dir = "$ENV{HOME}/.blead/git/perl";
    my $dest_path = "$ENV{HOME}/.blead/perls/blead";
    my $git_args = [qw<clone --depth 1 git://perl5.git.perl.org/perl >];
    push @{$git_args}, $dir;
    system "git", @{$git_args};
    {
      my $cache_dir = pushd($dir);
      system 'sh', 'Configure', '-de', "-Dprefix=$dest_path", '-Dusedevel', '-Duseshrplib', '-Uversiononly', '-Dcc=clang-devel',
        "-A'eval:scriptdir=$ENV{HOME}/.blead/perls/blead/bin'" ;
      system 'make';
      system 'make', 'install';
    }
  }
}

my sub command_init {
  say "set -f path=($ENV{HOME}/.blead/perls/blead/bin $ENV{HOME}/.blead/bin \${path});";
}

my sub command_install_cpanm {
  make_path("$ENV{HOME}/.blead/bin");
  my $file = "$ENV{HOME}/.blead/bin/cpanm";
  my $response = HTTP::Tiny->new
    ->mirror("http://cpanmin.us/", $file);
  chmod 0755, $file;
}

my sub command_clean {
  my $cache_path = "$ENV{HOME}/.blead/git/perl";
  if ( -d $cache_path) {
    say 'Cleaning cache paths';
    say "Removing $cache_path";
    remove_tree $cache_path;
  }
}

my sub main {
  my ($args) = @_;
  if ($args->[0] eq 'install') {
    command_install();
  } elsif ($args->[0] eq 'clean') {
    command_clean();
  } elsif ($args->[0] eq 'init') {
    command_init();
  } elsif ($args->[0] eq 'install-cpanm') {
    command_install_cpanm();
  }
}

main(\@ARGV);
