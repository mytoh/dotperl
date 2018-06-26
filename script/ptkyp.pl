#!/usr/bin/env perl

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Local::Ptkyp;
use Tk;
my $mw = MainWindow->new;
my $app = Local::Ptkyp->new(master => $mw);
$app->run;
