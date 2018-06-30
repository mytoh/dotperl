
# https://www.perlmonks.org/?node_id=390782

package Local::App::Ptkyp;

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
use Tk;
use Types::Standard -all;

use Local::App::Ptkyp::View::ChannelList;

use namespace::clean;

has master => (is => 'ro',
               required => 1);

has frames => (is => 'rw',
               isa => ArrayRef,
               default => sub { [] }
              );

sub BUILD($self, $args) {

  my $frame_channel_list = Local::App::Ptkyp::View::ChannelList->new(
    master =>  $self->master,
   );
  push $self->frames->@*, $frame_channel_list;
}

sub run($self) {
  MainLoop();
}


!!1;
