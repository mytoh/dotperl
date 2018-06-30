package Local::Ptkyp::View::ChannelList;

use Moo;
use Moo;
use MooX::LvalueAttribute;
use MooX::XSConstructor;
use MooX::HandlesVia;

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
use Package::Alias
  PC => 'Local::Peercast::Channel';
use Types::Standard -all;
use Local::Peercast::Types::Channel -all;

use namespace::clean;

has master => (is => 'ro',
               required => 1);

has config => (is => 'rw',
               default => sub {
                 +{
                   yp_urls => [['sp',         'http://bayonet.ddo.jp/sp/index.txt'],
                               ['yp',         'http://temp.orz.hm/yp/index.txt'],
                               ['hktv',       'http://games.himitsukichi.com/hktv/index.txt'],
                               ['turf',       'http://peercast.takami98.net/turf-page/index.txt'],
                               ['oekaki',     'http://oekakiyp.appspot.com/index.txt'],
                               ['eventyp',    'http://eventyp.xrea.jp/index.txt'],
                               ['messageyp',  'http://peercast.takami98.net/message-yp/index.txt'],
                               ['tjyp',       'http://gerogugu.web.fc2.com/tjyp/index.txt']],
                   header_columns => [qw<Name
                                         Genre
                                         Description
                                         Message
                                         Viewer
                                         Contact>],
                 }
               });

has channels => (is => 'rw',
                 isa => ArrayRef[Channel],
                 handlesvia => 'Array',
                );

has ua => (is => 'rw',
           default => sub {
             Mojo::UserAgent->new;
           });

sub BUILD ($self, $args){

  my $mw = $self->master;

  my $status_text = '';
  my $logger = $self->make_log_sub(\$status_text);
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
                                  -columns => scalar($self->config->{'header_columns'}->@*),
                                  -scrollbars => 'osoe',
                                  # -width => 70,
                                  # hide black border around HList when it's active
                                  -highlightthickness => 0,
                                  -selectborderwidth => 0,
                                  -selectbackground => 'SeaGreen3',);
  $hlist->configure(-command => sub ($entry){$self->play_channel($hlist, $logger, $entry)});
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

  $self->create_menus($hlist);

  # create hlist
  $self->create_headers($hlist, $self->config->{'header_columns'});
  $self->create_channels_list($hlist,
                              $self->config->{'yp_urls'},
                              $self->config->{'header_columns'});

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

}

sub create_menus($self, $hlist) {

  # menu
  my $mw = $self->master;
  my $menubar = $mw->Menu(-type => 'menubar', -tearoff => 0,
                          -foreground => 'white',
                          -background => 'black',);
  $mw->configure( -menu => $menubar );
  my $menu_file = $mw->Menu(-type => 'normal', -tearoff => 0);
  $menubar->add('cascade', -label => 'File', -menu => $menu_file);
  $menu_file->add('command', -label => 'Exit', -underline => 0,
                  -command => \&exit );

  my $menu_channel = $mw->Menu(-type => 'normal', -tearoff => 0);
  $menubar->add('cascade', -label => 'Channel', -menu => $menu_channel);
  $menu_channel->add('command', -label => 'Update',
                     -command => sub {$self->menu_channel_update($hlist,
                                                                 $self->config->{'yp_urls'},
                                                                 $self->config->{'header_columns'})} );
  # $menu_file->separator;
}

sub replace_chars($self, $text) {
  my $result = $text =~ s/&lt\;/</gr
    =~ s/&gt\;/>/gr
    =~ s/&quot\;/\"/gr
    =~ s/&amp\;/&/gr
    =~ s/&\#034\;/\"/gr
    =~ s/&\#039\;/\'/gr;
}

sub channel_to_obj ($self, $list) {
  # yp channel list definition
  # https://github.com/kumaryu/peercaststation/blob/3b7251c7f3e9ec6378a527bbe80822d51f585fe4/PeerCastStation/PeerCastStation.PCP/PCPYellowPageClient.cs
  PC->new(name         => $list->[0],
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
         );
}

sub get_channels($self, $urls) {
  [map {
    my $url = $_->[1];
    my $res = $self->ua->get($url)->result;
    if ($res->is_success) {
      my @lines = split /<>0\n/, $res->body;
      map { my $channel_infos = [split /<>/, $_];
            $self->channel_to_obj($channel_infos);
          }
        @lines;
    } else {
      ()
    }
  }
   $urls->@*];
}

sub create_headers($self, $hlist, $columns) {
  foreach my $i (keys $columns->@*) {
    $hlist->header('create', $i,
                   -text => $columns->[$i],
                   -relief => 'flat',
                   -headerbackground => '#555555',
                   -borderwidth => 1);
  }
}

sub add_row($self, $hlist, $row, $channel, $columns) {
  state $column_name_index = first_index { $_ eq 'Name' } $columns->@*;
  state $column_genre_index = first_index { $_ eq 'Genre' } $columns->@*;
  state $column_description_index = first_index { $_ eq 'Description' } $columns->@*;
  $hlist->add($row, -data => $channel);
  $hlist->itemCreate($row, $column_name_index,
                     -text => decode_utf8($channel->name));
  $hlist->itemCreate($row, $column_genre_index,
                     -text => decode_utf8($channel->genre));
  $hlist->itemCreate($row, $column_description_index,
                     -text => $self->replace_chars(decode_utf8($channel->description)));
}


sub play_channel ($self, $hlist, $logger, $selected_entry) {
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
                              $data->channel_id, lc $data->content_type, $data->tracker)
     );
    my $pid = $daemon->Init();
    $logger->(sprintf("playing %s (PID: %s)",
                      decode_utf8($data->name ), $pid ));
  }
}


sub create_channels_list($self, $hlist, $urls, $columns) {

  $self->ua->transactor->name("Mozilla/5.0");
  $self->channels($self->get_channels($urls));
  foreach my $i (keys $self->channels->@*) {
    $self->add_row($hlist, $i,
                   $self->channels->[$i],
                   $columns);
  }
}

sub menu_channel_update ($self, $hlist, $urls, $columns) {
  $hlist->delete('all');
  $self->create_channels_list($hlist, $urls, $columns);
}

sub make_log_sub ($self, $var) {
  sub ($message) {
    $var->$* = $message;
  }
}

!!1;
