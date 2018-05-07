#!/usr/bin/env perl

use v5.28;
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use IO::Socket::PortState qw<check_ports>;
use Time::HiRes qw<sleep>;
use IO::Handle;
use IPC::System::Simple qw<systemx>;
use Cwd::utf8;
use Proc::Daemon;
use DDP;
no indirect 'fatal';
no bareword::filehandles;
no autovivification;

my sub check_ports ($check) {
  my $res = check_ports('localhost', 1, $check);

  if ($res->{'tcp'}->{55051}->{'open'}) {
    !!1;
  } else {
    !!0;
  }
}

my sub wait_port_open ($hash) {
  say "Checking...";
  my $is_open = check_ports($hash);
  if (! $is_open) {
    sleep(1);
    __SUB__->($hash);
  } else {
    sleep(2);
  }
}

my sub start_server ($cwd, $url, $sport, $pport) {
  say "Starting server with url ${url}";
  my $daemon = Proc::Daemon->new(
    work_dir => $cwd,
    exec_command => "sp-sc-auth ${url} ${sport} ${pport}",
   );
  my $pid = $daemon->Init();
  say "Daemon started with PID $pid";
  $daemon;
}

my sub kill_server ($daemon) {
  say "Killing server";
  # $daemon->Kill_Daemon(); # didn't work
  systemx("killall", "-9", "sp-sc-auth");
}

my sub start_player ($port) {
  systemx('mpv', '--no-ytdl' ,"http://localhost:${port}");
}

my sub find_url($name, $defs) {
  $defs->{$name};
}

my sub cmd_play ($name, $defs) {
  my $url = find_url($name, $defs);
  if ($url) {
  my $server_port = '55050';
  my $player_port = '55051';
  my %porthash =  (
    tcp => {
      $player_port => {
        name => 'sop',
      },
    },
   );
  my $dir = getcwd;
  my $daemon = start_server($dir, $url, $server_port, $player_port);
  STDOUT->autoflush;
  wait_port_open(\%porthash);
  start_player($player_port);
  kill_server($daemon);
} else {
  say "Can't find channel: ${name}";
}
}

my sub cmd_list ($defs) {
  say for sort keys $defs->%*;
}

my sub main ($args) {
  my $url_definitions = +{
    bbcearth           => 'sop://broker.sopcast.com:3912/148257',
    natsci             => 'sop://broker.sopcast.com:3912/256243',
    natgeo             => 'sop://broker.sopcast.com:3912/148248',
    natsci             => 'sop://broker.sopcast.com:3912/256243',
    discovery          => 'sop://broker.sopcast.com:3912/256241',
    acasa              => "sop://broker.sopcast.com:3912/149256",
    acasagolda         => "sop://broker.sopcast.com:3912/253471",
    acasatv            => "sop://broker.sopcast.com:3912/149256",
    antena1a           => "sop://broker.sopcast.com:3912/149257",
    antena1b           => "sop://broker.sopcast.com:3912/151301",
    antena1c           => "sop://broker.sopcast.com:3912/148083",
    antenastars        => "sop://broker.sopcast.com:3912/148255",
    antena3            => "sop://broker.sopcast.com:3912/148084",
    axn                => "sop://broker.sopcast.com:3912/253035",
    axnblack           => "sop://broker.sopcast.com:3912/149261",
    axnwhite           => "sop://broker.sopcast.com:3912/149262",
    b1                 => "sop://broker.sopcast.com:3912/148087",
    boomerang          => "sop://broker.sopcast.com:3912/149264",
    cartoonnetwork     => "sop://broker.sopcast.com:3912/148254",
    digiworld          => "sop://broker.sopcast.com:3912/148260",
    digisport1a        => "sop://broker.sopcast.com:3912/148886",
    digisport1b        => "sop://broker.sopcast.com:3912/173020",
    digisport2c        => "sop://broker.sopcast.com:3912/263242",
    discoverychannel   => "sop://broker.sopcast.com:3912/256241",
    discoveryscience   => "sop://broker.sopcast.com:3912/256243",
    disneychannel      => "sop://broker.sopcast.com:3912/253031",
    disneyjunior       => "sop://broker.sopcast.com:3912/256239",
    diva               => "sop://broker.sopcast.com:3912/253034/123456",
    divauniversal      => "sop://broker.sopcast.com:3912/253034",
    ducktv             => "sop://broker.sopcast.com:3912/148259",
    etnotv             => "sop://broker.sopcast.com:3912/173116",
    euforia            => "sop://broker.sopcast.com:3912/253473",
    eurosport1         => "sop://broker.sopcast.com:3912/263056",
    filmbox            => "sop://broker.sopcast.com:3912/148981",
    filmcafe           => "sop://broker.sopcast.com:3912/256238",
    hbohd              => "sop://51.15.38.157:3912/260710",
    idx                => "sop://broker.sopcast.com:3912/256244",
    kanald             => "sop://broker.sopcast.com:3912/149258",
    minimax            => "sop://broker.sopcast.com:3912/148263",
    natgeowild         => "sop://broker.sopcast.com:3912/253037",
    nationalgeographic => "sop://broker.sopcast.com:3912/148248",
    nationaltv         => "sop://broker.sopcast.com:3912/253030",
    nickelodeon        => "sop://broker.sopcast.com:3912/253472",
    paramount          => "sop://broker.sopcast.com:3912/253033",
    primatv            => "sop://broker.sopcast.com:3912/148086",
    procinema          => "sop://broker.sopcast.com:3912/148249",
    protva             => "sop://broker.sopcast.com:3912/149252",
    protvb             => "sop://broker.sopcast.com:3912/151380",
    realitateatv       => "sop://broker.sopcast.com:3912/253036",
    romaniatv          => "sop://broker.sopcast.com:3912/148258",
    sportro            => "sop://broker.sopcast.com:3912/178547",
    tlc                => "sop://broker.sopcast.com:3912/148256",
    traveltv           => "sop://broker.sopcast.com:3912/148885",
    tv1000             => "sop://broker.sopcast.com:3912/256337/123456",
    tvpaprika          => "sop://broker.sopcast.com:3912/148881",
    tv1000             => "sop://broker.sopcast.com:3912/256337",
    tvr1               => "sop://broker.sopcast.com:3912/148085",
    tvr2               => "sop://broker.sopcast.com:3912/173286",
    viasathistory      => "sop://broker.sopcast.com:3912/151300",
    zutv               => "sop://broker.sopcast.com:3912/148252",
  };
  my $command = $args->[0];
  if ($command eq 'play') {
    cmd_play($args->[1], $url_definitions);
  } elsif ($command eq 'list') {
    cmd_list($url_definitions);
  }
}

main(\@ARGV);
