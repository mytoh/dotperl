#!/usr/bin/env perl
# https://www.perlmonks.org/?node_id=390782

use v5.28;
use utf8;
use strictures 2;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use experimental qw<signatures re_strict refaliasing declared_refs
                    script_run alpha_assertions regex_sets const_attr>;
use re 'strict';
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
use Tk;
use Tk::HList;
use Tk::Frame;
use Tk::NoteBook;
use Tk::Wm;
use Tk::Menu;
use Mojo::UserAgent;
use List::AllUtils qw<first_index natatime>;
use Proc::Daemon;

my $COLUMNS = [qw<Name
                  Genre
                  Description
                  Message
                  Viewer
                  Contact>];

my sub replace_chars($text) {
  my $result = $text =~ s/&lt\;/</gr
    =~ s/&gt\;/>/gr
    =~ s/&quot\;/\"/gr
    =~ s/&amp\;/&/gr
    =~ s/&\#034\;/\"/gr
    =~ s/&\#039\;/\'/gr;
}

my sub channel_to_obj ($list) {
  # yp channel list definition
  # https://github.com/kumaryu/peercaststation/blob/3b7251c7f3e9ec6378a527bbe80822d51f585fe4/PeerCastStation/PeerCastStation.PCP/PCPYellowPageClient.cs
  +{
    name         => $list->[0],
    channel_id   => $list->[1],
    tracker      => $list->[2],
    contact_url  => $list->[3],
    genre        => $list->[4],
    description  => $list->[5],
    listeners    => $list->[6],
    relays       => $list->[7],
    bitrate      => $list->[8],
    content_type => $list->[9],
    artist       => $list->[10],
    album        => $list->[11],
    track_title  => $list->[12],
    track_url    => $list->[13],
    uptime       => $list->[15],
    comment      => $list->[17],
  };
}

my sub get_channels($ua, $urls) {
  [map {
    my $url = $_;
    my $res = $ua->get($url)->result;
    if ($res->is_success) {
      my @lines = split /<>0\n/, $res->body;
      map { my $channel_infos = [split /<>/, $_];
            channel_to_obj($channel_infos)
          }
        @lines;
    } else {
      ()
    }
  }
   $urls->@*];
}

my sub create_headers($hlist, $columns) {
  foreach my $i (keys $columns->@*) {
    $hlist->header('create', $i,
                   -text => $columns->[$i],
                   -relief => 'flat',
                   -headerbackground => '#555555',
                   -borderwidth => 1);
  }
}

my sub add_row($hlist, $row, $channel) {
  state $column_name_index = first_index { $_ eq 'Name' } $COLUMNS->@*;
  state $column_genre_index = first_index { $_ eq 'Genre' } $COLUMNS->@*;
  state $column_description_index = first_index { $_ eq 'Description' } $COLUMNS->@*;
  $hlist->add($row, -data => $channel);
  $hlist->itemCreate($row, $column_name_index,
                     -text => decode_utf8($channel->{'name'}));
  $hlist->itemCreate($row, $column_genre_index,
                     -text => decode_utf8($channel->{'genre'}));
  $hlist->itemCreate($row, $column_description_index,
                     -text => replace_chars(decode_utf8($channel->{'description'})));
}


my sub play_channel ($hlist, $logger, $selected_entry) {
  # remove dotted line
  $hlist->anchorClear();

  my $data = $hlist->info('data', $selected_entry);

  if ($data->{'contact_url'} =~ m{www\.twitch\.tv}) {
    my $url = $data->{'contact_url'};
    my $daemon = Proc::Daemon->new(
      exec_command => "mpv --force-window=immediate $url",
     );
    my $pid = $daemon->Init();
    say "Player started with PID $pid";
  } else {
    my $daemon = Proc::Daemon->new(
      exec_command => sprintf("mpv --force-window=immediate --no-ytdl http://peca2.koti:7144/stream/%s.%s?tip=%s",
                              $data->{'channel_id'}, lc $data->{'content_type'}, $data->{'tracker'})
     );
    my $pid = $daemon->Init();
    $logger->(sprintf("playing %s (PID: %s)",
                      decode_utf8($data->{'name'} ), $pid ));
  }
}


my sub create_channels_list($hlist, $urls) {

  my $ua = Mojo::UserAgent->new;
  $ua->transactor->name("Mozilla/5.0");
  my $channels = get_channels($ua, $urls);
  foreach my $i (keys $channels->@*) {
    add_row($hlist, $i,
            $channels->[$i]);
  }
}

my sub menu_channel_update ($hlist, $urls) {
  $hlist->delete('all');
  create_channels_list($hlist, $urls);
}

my sub make_log_sub ($var) {
  sub ($message) {
    $var->$* = $message;
  }
}


my sub main() {
  my $yp_urls = ['http://bayonet.ddo.jp/sp/index.txt',
                 'http://temp.orz.hm/yp/index.txt',
                 'http://games.himitsukichi.com/hktv/index.txt',
                 'http://peercast.takami98.net/turf-page/index.txt',
                 'http://oekakiyp.appspot.com/index.txt',
                 'http://eventyp.xrea.jp/index.txt',
                 'http://peercast.takami98.net/message-yp/index.txt',
                 'http://gerogugu.web.fc2.com/tjyp/index.txt',];
  my $status_text = '';
  my $logger = make_log_sub(\$status_text);

  my $mw = MainWindow->new(-foreground => 'white',
                           -background => 'black',);
  # $top->overrideredirect('true');


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
  my $page_favorites = $notebook->add("favorites", -label => 'Favorites');

  my $hlist = $page_all->Scrolled("HList",
                                  -font => '{Noto Sans} 10',
                                  -relief => 'flat',
                                  -foreground => 'white',
                                  -background => 'black',
                                  -header => 'true',
                                  -columns => scalar($COLUMNS->@*),
                                  -scrollbars => 'osoe',
                                  # -width => 70,
                                  # hide black border around HList when it's active
                                  -highlightthickness => 0,
                                  -selectborderwidth => 0,
                                  -selectbackground => 'SeaGreen3',);
  $hlist->configure(-command => [\&play_channel, $hlist, $logger]);
  $hlist->Subwidget('corner')->configure(-background => 'black');
  $hlist->Subwidget('yscrollbar')->configure(-background => 'black',
                                             -activerelief => 'flat',
                                             -relief => 'flat',
                                             -borderwidth => 0,
                                             -elementborderwidth => 0);
  $hlist->Subwidget('xscrollbar')->configure(-background => 'black',
                                             -activerelief => 'flat',
                                             -relief => 'flat',
                                             -borderwidth => 0,
                                             -elementborderwidth => 0);

  # remove dotte line from selected item
  # [[https://stackoverflow.com/questions/12466585/how-do-i-remove-the-dotted-line-of-the-selection-in-a-tkhlist][perl - How do I remove the dotted line of the selection in a Tk::HList? - Stack Overflow]]
  $hlist->configure(
    -browsecmd => [ sub{ $_[0]->anchorClear(); }, $hlist],
   );


  # menu
  my $menubar = $mw->Menu(-type => 'menubar', -tearoff => 0,
                          -foreground => 'white',
                          -background => 'black',);
  $mw->configure( -menu => $menubar );

  my $menu_file = $mw->Menu(-type => 'normal', -tearoff => 0);
  $menubar->add('cascade', -label => 'File', -menu => $menu_file);
  $menu_file->add('command', -label => 'Exit', -underline => 0, -command => \&exit );

  my $menu_channel = $mw->Menu(-type => 'normal', -tearoff => 0);
  $menubar->add('cascade', -label => 'Channel', -menu => $menu_channel);
  $menu_channel->add('command', -label => 'Update',  -command => [\&menu_channel_update, $hlist, $yp_urls]);
  # $menu_file->separator;

  # create hlist
  create_headers($hlist, $COLUMNS);
  create_channels_list($hlist, $yp_urls);

  # statusbar
  my $statusbar = $mw->Label(-borderwidth => 1, -relief => 'sunken', -anchor => 'w',
                             -font => 'Verdana',
                             -textvariable => \$status_text,
                             -background => 'black',
                             -foreground => 'white');

  $page_all->pack(-expand => 'true', -fill => 'both');
  $notebook->pack(-expand => 'true', -fill => 'both');
  $frame->pack(-expand => 'true', -fill => 'both');
  $hlist->pack(-expand => 'true', -fill => 'both');
  $statusbar->pack(-side => 'bottom', -fill => 'x');

  MainLoop();
}

main();
