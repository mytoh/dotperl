#!/usr/bin/env perl

use utf8;
use feature ":5.28";
use strictures 2;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;
use re 'strict';
use Config::PL;
use Cwd::utf8 qw<getcwd>;
use File::Spec::Functions qw<catfile>;
use Const::Fast qw<const>;
use File::Basename qw<basename>;
use File::Basename::Extra qw<basename_suffix>;
use IPC::System::Simple qw<systemx>;
use File::XDG;
use DDP;
no autovivification;

# ranger's rifle like file opener
my $xdg = File::XDG->new(name => 'nagasa');
const my $CONFIG_FILE => $xdg->config_home->file('config.pl')->stringify;

my sub run_program ($command, $file) {
  systemx($command, $file);
}

my sub remove_first_char ($string) {
  substr $string, 1;
}

my sub main ($config_file, $args) {
  my $file = $args->[0];
  my $cwd = getcwd();
  my $config = config_do( $config_file);
  my $ext = remove_first_char(basename_suffix($file));
  
  run_program($config->{$ext}, $file);
  
}

main($CONFIG_FILE, \@ARGV);
