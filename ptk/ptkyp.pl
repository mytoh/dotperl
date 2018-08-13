#!/usr/bin/env perl

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Local::App::Ptkyp;
use Tk;
my $mw = MainWindow->new;
my $app = Local::App::Ptkyp->new(master => $mw);
$app->run;
