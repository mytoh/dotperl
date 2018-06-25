#!/usr/bin/env perl

# github:deepanprabhu/duckduckgo-images-api

use v5.28;
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use Acme::LookOfDisapproval qw<ಠ_ಠ>;
use Mojo::UserAgent;
use Mojo::URL;
use Time::HiRes qw ( sleep );
use File::Basename::Extra qw<basename>;

my sub extract_vqd ($keyword, $ua) {
  my $url = Mojo::URL->new('https://duckduckgo.com/');
  $url->query(q => $keyword);
  my $body = $ua->get($url)->result->body;
  my ($vqd )= ($body =~ /vqd='(\d+)'/);
  $vqd;
}

my sub download_file($ua, $url) {
  my $file = basename($url);
  if (! -f $file) {
    $ua->get($url)
      ->result
      ->content
      ->asset
      ->move_to($file);
  }
}

my sub main ($args) {
  my $keyword = $args->[0];
  my $ua = Mojo::UserAgent->new;
  my $vqd = extract_vqd($keyword, $ua);
  my $base_url = 'https://duckduckgo.com';
  my $url = Mojo::URL->new($base_url);
  $url->path('i.js');
  $url->query(l => 'wt-wt',
              o => 'json',
              q => $keyword,
              vqd => $vqd,
              f => ',,,',
              p => 1,
# kp => -2
);
  my $headers = {
    dnt => '1',
    'accept-encoding' => 'gzip, deflate, sdch, br',
    'x-requested-with' => 'XMLHttpRequest',
    'accept-language' => 'en-GB,en-US;q=0.8,en;q=0.6,ms;q=0.4',
    'user-agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36',
    accept => 'application/json, text/javascript, */*; q=0.01',
    referer => 'https://duckduckgo.com/',
    authority => 'duckduckgo.com',
  };

  while (1) {
    say "URL: $url";
    my $json = $ua->get($url => $headers)->result->json;
    foreach my $result ($json->{'results'}->@*) {
      download_file($ua, $result->{'image'});
    }
    sleep(5);

    my $next = $json->{'next'};
    if ($next) {
      $url = Mojo::URL->new($base_url . '/' . $next . "&vqd=$vqd");
    } else {
      last;
    }
  }
}

main(\@ARGV);
