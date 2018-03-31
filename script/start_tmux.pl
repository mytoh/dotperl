#!/usr/bin/env perl

use utf8;
use autodie ':all';
use feature ":5.28";
use strictures 2;
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict>;
use re 'strict';
use IPC::System::Simple qw<systemx>;

my sub tmux_command ($command, @args) {
  systemx('tmux', $command, @args);
}

my sub tmux_new_session (@args) {
  tmux_command('new-session', @args);
}

my sub tmux_split_window (@args) {
  tmux_command('split-window', @args);
}

my sub tmux_set_window_option (@args) {
  tmux_command('set-window-option', @args);
}

my sub session_main () {
  tmux_new_session(qw<-s main -n main -d>);
}

my sub session_daemon () {
  tmux_new_session(qw<-s daemon -n yotsuba -d yotsuba_dl.pl>);
  tmux_set_window_option(qw<-q -t daemon:yotsuba remain-on-exit on>);
}

my sub session_stats () {
  tmux_new_session(qw<-s stats -n top -d top>);
  tmux_set_window_option(qw<-q -t stats:top remain-on-exit on>);
  tmux_split_window(qw<-h -t stats:top.0 -d systat -ifstat>);
  tmux_split_window(qw<-v -t stats:top.1 -d systat -ip>);
}

my sub attach_main () {
  tmux_command(qw<-2 attach -t main>);
}

my sub main () {
  session_main();
  session_daemon();
  session_stats();
  attach_main();
}

main();
