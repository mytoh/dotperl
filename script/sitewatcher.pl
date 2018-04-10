#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature ":5.28";
use warnings qw<FATAL utf8>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing declared_refs 
                    script_run alpha_assertions regex_sets const_attr>;
use re 'strict';
use File::Fetch;
use Time::HiRes qw<sleep>;
use Time::Date;
use Desktop::Notify;

my sub fetch ($uri) {
  $File::Fetch::WARN = 0;
  my $ff = File::Fetch->new(uri => $uri);
  my $res;
  $ff->fetch(to => \$res );
  
  if ($res ) {
    !!1;
  } else {
    !!0;
  }

}

my sub notify ($uri) {
    
  # Open a connection to the notification daemon
  my $notify = Desktop::Notify->new();

  my $now = Time::Date->now;
    
  # Create a notification to display
  my $notification = $notify->create(summary => 'SiteWatcher',
                                     body => "$uri access SUCCESS\n$now");
    
  # Display the notification
  $notification->show();
    
  # Close the notification later
  # $notification->close();
}

my sub watch ($uri) {
  while (1) {
    my $res = fetch($uri);
    my $wait = 60 * 5;
    if ($res) {
      last;
    } else {
      sleep $wait;
    }
  }
}

my sub main ($args) {
  my $uri = $args->[0];
  say "Watching $uri";
  watch($uri);
  notify($uri);
}

main(\@ARGV);
