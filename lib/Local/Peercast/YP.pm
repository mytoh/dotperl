
package Local::Peercast::YP;

use Mu;
use v5.28;
use strictures 2;
use experimental qw<signatures>;
use Mojo::UserAgent;
use Unicode::UTF8 qw<decode_utf8 encode_utf8>;
use Package::Alias
  Channel => 'Local::Peercast::Channel';
use namespace::clean;

ro [qw<name url>];

sub modify_channel_description ($self, $text){
  my $result = $text =~ s/&lt\;/</gr
    =~ s/&gt\;/>/gr
    =~ s/&quot\;/\"/gr
    =~ s/&amp\;/&/gr
    =~ s/&\#034\;/\"/gr
    =~ s/&\#039\;/\'/gr;
  $result;
}

sub _channel_to_object ($self, $list) {
  # yp channel list definition
  # https://github.com/kumaryu/peercaststation/blob/3b7251c7f3e9ec6378a527bbe80822d51f585fe4/PeerCastStation/PeerCastStation.PCP/PCPYellowPageClient.cs
  my $genre = $list->[4];
  my $desc = $list->[5];
  my $comment  = $list->[17];
  Channel->new(name         => decode_utf8($list->[0]),
               channel_id   => $list->[1],
               tracker      => $list->[2],
               contact_url  => $list->[3],
               genre        => $genre ? decode_utf8($genre) : $genre,
               description  => $desc ? $self->modify_channel_description(decode_utf8($desc)) : $desc,
               listeners    => $list->[6],
               relays       => $list->[7],
               bitrate      => $list->[8],
               content_type => $list->[9],
               artist       => $list->[10],
               album        => $list->[11],
               track_title  => $list->[12],
               track_url    => $list->[13],
               uptime       => $list->[15],
               comment      => $comment ? decode_utf8($comment) : $comment,
              );
}

sub get_channel ($self) {
  my $url = $self->url;
  my @out = ();
  state $ua = Mojo::UserAgent->new;

  $ua->get_p($url)
    ->then( sub ($tx){
              my $res = $tx->result;
              if ($res->is_success) {
                my @lines = split /<>0\n/, $res->body;
                @out = map { my $channel_infos = [split /<>/, $_];
                             $self->_channel_to_object($channel_infos);
                           }
                  @lines;
              } else {
                @out = ();
              }
            }
           )->wait;
  \@out;
}

!!1;
