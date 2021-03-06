package Local::Peercast::Channel;

use strictures 2;
use true;

use Mu;
use namespace::clean;

ro [qw< name
        channel_id
        tracker
        contact_url
        genre
        description
        listeners
        relays
        bitrate
        content_type
        artist
        album
        track_title
        track_url
        uptime
        comment
        yp>];
