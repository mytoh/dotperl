
package Local::App::Ptiv;

use Moo;
use MooX::LvalueAttribute;
use MooX::XSConstructor;
use MooX::HandlesVia;

use v5.28;
use utf8;
use strictures 2;
use experimental qw<signatures re_strict refaliasing declared_refs script_run alpha_assertions regex_sets const_attr>;
use autodie ':all';
use utf8::all;
use open qw<:std :encoding(UTF-8)>;
use re 'strict';
use Acme::LookOfDisapproval qw<ಠ_ಠ>;

use Tk;
use Tk::JPEG;
use Tk::PNG;
use File::MimeInfo;
use Imager;
use MIME::Base64;
use Image::Info qw<image_type>;
use File::Find::Rule::LibMagic qw<find>;
use List::AllUtils qw<first_index>;
use Path::Tiny;
use DDP;

no indirect 'fatal';
no bareword::filehandles;
no autovivification;

has master => ( is => 'ro',
                reuired => 1);

has target_file => (is => 'rw',
                    default => sub { "." });

has current_file => (is => 'rw',
                     init_arg => undef,
                     predicate => 1,
                     lvalue => 1);
has imager => (is => 'rw',
               init_arg => undef,
               predicate => 1,
               lvalue => 1);
has imager_scaled => (is => 'rw',
                      init_arg => undef,
                      predicate => 1,
                      lvalue => 1);
has scaled_height => (is => 'rw',
                      init_arg => undef,
                      predicate => 1,
                      lvalue => 1);
has scaled_width => (is => 'rw',
                     init_arg => undef,
                     predicate => 1,
                     lvalue => 1);
has photo_widget => (is => 'rw',
                     init_arg => undef,
                     predicate => 1,
                     lvalue => 1);
has photo_label => (is => 'rw',
                    init_arg => undef,
                    predicate => 1,
                    lvalue => 1);
has file_list => (is => 'rw',
                  init_arg => undef,
                  predicate => 1,
                  lvalue => 1);
has current_file_index => (is => 'rw',
                           init_arg => undef,
                           predicate => 1,
                           lvalue => 1,
                           default => sub { 0; });

sub detect_type ($self, $file)  {
  my $type = image_type($file)->{'file_type'};
  lc $type;
}

# [[https://www.perlmonks.org/bare/?node_id=537705][Re: Tk sizing a pic to fit a window]]
sub open_file($self, $file) {
  $self->current_file($file);
  my $imager = $self->imager // Imager->new;
  $self->photo_widget->blank;
  my $type = $self->detect_type($file);

  $self->scaled_height($self->photo_label->reqheight);
  $self->scaled_width($self->photo_label->reqwidth);

  $imager->read(file => $file, type => $type);
  $self->imager_scaled($imager->scale(xpixels => $self->scaled_width,
                                      ypixels => $self->scaled_height,
                                      type => 'min'
                                     ) or die $imager->errstr) ;
  #Tk needs base64 encoded image files
  my $data;
  $self->imager_scaled->write(data => \$data, type => $type)
    or die $self->imager_scaled->errstr;
  my $encoded_data = encode_base64( $data );

  $imager = undef;
  $self->photo_widget($self->new_photo(-data => $encoded_data));
  $self->photo_label->configure(-image => $self->photo_widget);
  $self->photo_label->pack(-expand => 1, -fill => 'both');
}

sub new_photo($self, %args) {
  $self->master->Photo(%args);
}

sub fit_image_to_window ($self, $dh, $dw) {
  my $file = $self->current_file;
  my $imager = $self->imager;
  my $type = $self->detect_type($file);

  say $dh, $dw;
  my $scaled = $imager->scale(xpixels => $dw,
                              ypixels => $dh,
                              type => 'min'
                             ) or die $imager->errstr;
  #Tk needs base64 encoded image files
  my $data;
  $scaled->write(data => \$data, type => $type)
    or die $scaled->errstr;
  my $encoded_data = encode_base64( $data );

  $self->photo_widget->blank;
  $self->photo_widget->put($encoded_data);
  $self->photo_label->configure(-image => $self->photo_widget,
                                -width => $dw,
                                -height => $dh,
                                -anchor => 'center');
}

sub fit_image_to_scaled ($self) {
  my $file = $self->current_file;
  my $imager = $self->imager;
  my $type = $self->detect_type($file);
  say $self->scaled_height;

  #Tk needs base64 encoded image files
  my $data;
  $self->imager_scaled->write(data => \$data, type => $type)
    or die $self->imager_scaled->errstr;
  my $encoded_data = encode_base64( $data );

  $self->photo_widget->blank;
  # need new Photo widget to show image correctly
  $self->photo_widget($self->new_photo(-data => $encoded_data));
  $self->photo_label->configure(-image => $self->photo_widget,
                                -width => $self->scaled_width,
                                -height => $self->scaled_height
                                -anchor => 'center');
}

sub toggle_fullscreen ($self) {
  my $mw = $self->master;
  if ($mw->attributes('-fullscreen')) {
    $mw->attributes(-fullscreen => 0);
    $self->fit_image_to_scaled();
  } else {
    $mw->attributes(-fullscreen => 1);
    $self->fit_image_to_window($mw->screenheight,
                               $mw->screenwidth);
  }
}

sub find_image_files ($self, $dir) {
  [ find( file => mime => 'image/*',
          in => $dir,
          maxdepth => 1) ];
}

sub create_image_list ($self, $file_list, $file ) {
  my $i = first_index {$file eq $_} $file_list->@*;
  delete $file_list->[$i];
  push $file_list->@*, $file;
  [grep { defined $_ } $file_list->@*];
}

sub create_directory_image_list ($self) {
  my $file_list = $self->find_image_files(path($self->target_file)->absolute);
  [grep { defined $_ } $file_list->@*];
}

sub next_image ($self) {
  if ($self->current_file_index == $self->file_list->$#*) {
    $self->current_file_index = 0;
    $self->open_file($self->file_list->[$self->current_file_index]);
  } else {
    $self->current_file_index($self->current_file_index + 1);
    $self->open_file($self->file_list->[$self->current_file_index]);
  }
}


sub prev_image ($self) {
  if ($self->current_file_index == 0) {
    $self->current_file_index = $self->file_list->$#*;
    $self->open_file($self->file_list->[$self->current_file_index]);
  } else {
    $self->current_file_index($self->current_file_index - 1);
    $self->open_file($self->file_list->[$self->current_file_index]);
  }
}

sub BUILD ($self, $args) {

  $self->master->configure(-background => 'black',
                           -height => 400, -width => 400);
  my $mw = $self->master;
  $mw->bind('<q>', ['destroy', $mw]);
  $mw->bind('<f>', sub {$self->toggle_fullscreen()});
  $mw->bind('<n>', sub {$self->next_image});
  $mw->bind('<p>', sub {$self->prev_image});
  $mw->bind('<space>', sub {$self->next_image});

  $self->imager(Imager->new);
  $self->photo_widget($mw->Photo(-file => ''));
  $self->photo_label($mw->Label(-height => 400, -width => 400,
                                -image => $self->photo_widget,
                                -background => 'black',
                                -anchor => 'center'));

  $self->target_file(path($self->target_file)->absolute);
  my $file = $self->target_file();

  if (-d $file) {
    $self->file_list($self->create_directory_image_list());
    $self->open_file($self->file_list->[0]);
  } elsif (-f $file) {
    $self->file_list($self->create_image_list($self->find_image_files(path($self->target_file)->parent),
                                              $self->target_file));
    $self->open_file($file);
  }
}

sub run ($self) {
  MainLoop();
}

!!1;
