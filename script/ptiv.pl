#!/usr/bin/env perl

use v5.28;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Local::App::Ptiv;
use Tk;
my $mw = MainWindow->new;
my $target = $ARGV[0] ? $ARGV[0] : ".";
my $app = Local::App::Ptiv->new(master => $mw,
                                target_file => $target);
$app->run;
