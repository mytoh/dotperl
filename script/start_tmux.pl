#!/usr/bin/env perl

use v5.28;
use utf8;
use autodie ':all';
use strictures 2;
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict>;
use re 'strict';
use IPC::System::Simple qw<systemx>;

my sub tmux_command ($command, @args) {
  systemx('tmux', $command, @args);
}

my sub tmux_new_session (%options) {
  my @args = (exists $options{'session'} ? ('-s', $options{'session'}) : (),
              exists $options{'window'} ? ('-n', $options{'window'}) : (),
              exists $options{'attach'} ? () : '-d',
              exists $options{'command'} ? $options{'command'}->@* : (),
             );
  tmux_command('new-session', @args);
}

my sub tmux_split_window (@args) {
  tmux_command('split-window', @args);
}

my sub tmux_set_window_option (@args) {
  tmux_command('set-window-option', @args);
}

my sub session_main () {
  tmux_new_session(session => 'main',
                   window  => 'main',);
}

my sub session_daemon () {
  tmux_new_session(session => 'daemon',
                   window  => 'yotsuba',
                   command => [qw<yotsuba_dl.pl>]);
  tmux_set_window_option(qw<-q -t daemon:yotsuba remain-on-exit on>);
}

my sub session_stats () {
  tmux_new_session(session => 'stats',
                   window  => 'top',
                   command => [qw<top>]);
  tmux_set_window_option(qw<-q -t stats:top remain-on-exit on>);
  tmux_split_window(qw<-h -t stats:top.0 -d systat -ifstat>);
  tmux_split_window(qw<-v -t stats:top.1 -d systat -ip>);
}

my sub session_remote () {
  tmux_new_session(session => 'remote',
                   window  => 'remote',);
}

my sub attach_main () {
  tmux_command(qw<-2 attach -t main>);
}

my sub main () {
  session_main();
  session_daemon();
  session_stats();
  session_remote();
  attach_main();
}

main();
