#!/usr/bin/env perl

package Myapp {
  use Moo;
  # use strictures 2;
  use v5.28;
  use experimental qw<signatures>;
  # use namespace::clean;
  use Tk;
  use Tk::NoteBook;

  has master => (
    is => 'ro',
   );

  sub run ($self) {
    my $mw = $self->master;
    my $frame = $mw->Frame(-foreground => 'white',
                           -background => 'black',
                           -relief => 'flat',);
    my $notebook = $frame->NoteBook(-font => '{Noto Sans} 10',
                                    -foreground => 'white',
                                    -background => '#555555',
                                    -backpagecolor => 'black',
                                    -inactivebackground => 'black',
                                    -relief => 'flat',
                                   );
    my $page_all = $notebook->add("all", -label => 'All');
    $page_all->pack(-expand => 'true', -fill => 'both');
    $notebook->pack(-expand => 'true', -fill => 'both');
    $frame->pack(-expand => 'true', -fill => 'both');

    MainLoop;
  }


  !!1;
}


  package main;

use v5.28;
use utf8;
# use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use Acme::LookOfDisapproval qw<ಠ_ಠ>;
no indirect 'fatal';
no bareword::filehandles;
no autovivification;

use Myapp;
use Tk;
my $mw = MainWindow->new;
my $app = Myapp->new(master => $mw);
$app->run;
