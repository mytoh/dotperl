#!/usr/bin/env perl

##  https://github.com/yayugu/net-radio-archive

use feature ":5.28";
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use WWW::Mechanize;
use JSON::MaybeUTF8 qw<:v1>;
use Data::Dumper;
use List::Util qw<first>;
use IPC::System::Simple qw<systemx>;
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
use DDP;
no indirect 'fatal';
no bareword::filehandles;
no autovivification;

my sub get_api($url) {
  my $mech = WWW::Mechanize->new();
  $mech->agent_alias('Windows Mozilla');
  $mech->add_header('X-Requested-With' => 'XMLHttpRequest');
  $mech->add_header('Origin' => 'http://hibiki-radio.jp');
  $mech->get($url);
  decode_json_text($mech->content);
}

my sub get_list ($page) {
  get_api("https://vcms-api.hibiki-radio.jp/api/v1/programs?limit=8&page=${page}");
}

my sub search_program($access_id, $list) {
  first { $_->{'access_id'} eq $access_id} $list->@*;
}

my sub get_playlist_url($video_id) {
  my $res = get_api("https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=${video_id}");
  p $res;
  $res->{'playlist_url'};
}

my sub get_program_info($access_id){
  my $res = get_api("https://vcms-api.hibiki-radio.jp/api/v1/programs/${access_id}");
  $res;
}

my sub main ($args) {
  my $list = get_list(5);
  my $program = get_program_info('minorhythm');
  my $episode_name = decode_utf8($program->{'latest_episode_name'});
  my $video_id = $program->{'episode'}{'video'}{'id'};
  my $playlist_url = get_playlist_url($video_id);
  my $filename = "${episode_name}.mp4";
  if (! -f $filename) {
    systemx('ffmpeg', '-y', '-i', "$playlist_url", '-vcodec', 'copy', '-acodec', 'copy', '-bsf:a', 'aac_adtstoasc', $filename)
  } else {
    say "File: ${filename} exists!";
  }
}

main(\@ARGV);
