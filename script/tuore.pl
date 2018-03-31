#!/usr/bin/env perl

use utf8;
use feature ":5.28";
use feature qw<refaliasing  declared_refs>;
use strictures 2;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing script_run>;
use re 'strict';
use Cwd::utf8 qw<getcwd>;
use File::Spec::Functions qw<catfile>;
use File::Basename::Extra qw<basename dirname>;
use DDP;
use Term::ANSIColor;
use List::Flatten::XS qw<flatten>;
use Config::PL;
no autovivification;

my sub create_spec_to_links ($cwd, $dest, $spec) {
  my @keys = keys $spec->%*;
  my $theme = $keys[0];
  my $files = $spec->{$theme};
  [ map  +{ old => catfile($cwd, $theme, $_), new => catfile($dest, $_) }  $files->@* ];
}

my sub create_link_list ($cwd, $dest, $file_specs) {
  my $list = [ map { create_spec_to_links($cwd, $dest, $_) }  $file_specs->@* ];
  my $flattened = flatten($list, 1);
  $flattened;
}

my sub create_links ($list) {
  foreach my $file ($list->@*) {
    my $old = $file->{'old'};
    my $new = $file->{'new'};
    if ( -f $new) {
      say "File " . $new . " exists!";
    } elsif ( -l $new || ! -e $new) {
      say 'Linking ' . $new . ' to ' . $old;
      symlink($old, $new);
    }
  }
}

my sub command_list ($args) {
  my $conf_file = $args->[1];
  my $dest = $args->[2] // $ENV{HOME};
  my $cwd = getcwd();
  my $conf = config_do( catfile($cwd, $conf_file));

  foreach my $link (create_link_list($cwd, $dest, $conf->{'files'})->@*) {
    say colored(['green'], $link->{'new'}) .  " => " .  colored(['yellow'], $link->{'old'});
  }
}

my sub command_link($args) {
  my $conf_file = $args->[1];
  my $dest = $args->[2] // $ENV{HOME};
  my $cwd = getcwd();
  my $conf = config_do( catfile($cwd, $conf_file));

  create_links(create_link_list($cwd, $dest, $conf->{'files'}));
}

my sub command_help() {
  say "Usega:";
  say "$0 list <config_file>";
  say "$0 link <config_file> [<dest_dir>]";
}

my sub main ($args) {
  my $command = $args->[0];
  
  if ($command eq 'list') {
    command_list($args);
  } elsif ($command eq 'link') {
    command_link($args);
  } else {
    command_help();
  }
}

main(\@ARGV);
