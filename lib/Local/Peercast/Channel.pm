package Local::Peercast::Channel;

use Moo;
use strictures 2;
use namespace::clean;

has name         => (is => 'ro',);
has channel_id   => (is => 'ro',);
has tracker      => (is => 'ro',);
has contact_url  => (is => 'ro',);
has genre        => (is => 'ro',);
has description  => (is => 'ro',);
has listeners    => (is => 'ro',);
has relays       => (is => 'ro',);
has bitrate      => (is => 'ro',);
has content_type => (is => 'ro',);
has artist       => (is => 'ro',);
has album        => (is => 'ro',);
has track_title  => (is => 'ro',);
has track_url    => (is => 'ro',);
has uptime       => (is => 'ro',);
has comment      => (is => 'ro',);

!!1;
