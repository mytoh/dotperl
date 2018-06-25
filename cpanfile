requires 'App::Cmd';
requires 'Archive::Extract';
requires 'Archive::Rar::Passthrough';
requires 'Cache::LRU';
requires 'Carp::Always';
requires 'Config::PL';
requires 'Const::Fast';
requires 'Cwd::utf8';
requires 'DDP';
requires 'Desktop::Notify';
requires 'File::Basename::Extra';
requires 'File::Find::Rule';
requires 'File::Find::Rule::LibMagic';
requires 'File::Glob';
requires 'File::MimeInfo';
requires 'File::Slurper';
requires 'File::Spec::Functions';
requires 'File::XDG';
requires 'File::chdir';
requires 'Furl::HTTP';
requires 'Getopt::Long::Descriptive';
requires 'IPC::System::Simple';
requires 'Image::JpegTran';
requires 'Imager';
requires 'JSON::MaybeUTF8';
requires 'List::AllUtils';
requires 'List::Flatten::XS';
requires 'Net::DNS::Lite';
requires 'Path::Tiny';
requires 'File::Copy::Recursive::Reduced'; # for FindBin::libs
requires 'FindBin::libs';
requires 'Project::Libs';
requires 'Regexp::Common';
requires 'Term::ANSIColor';
requires 'Time::Date';
requires 'Time::HiRes';
requires 'URI';
requires 'Unicode::UTF8';
requires 'Web::Query::LibXML';
requires 'autovivification';
requires 'strictures';
requires 'XML::LibXML::jQuery';
requires 'Web::Query';
requires 'WWW::Mechanize';
requires 'utf8::all';
requires 'Exporter::Shiny';
requires 'Unix::PID';
requires 'Type::Tiny';
requires 'Type::Tiny::XS';
requires 'Return::Type';
requires 'Types::URI';
requires 'IO::Socket::PortState';
requires 'Acme::LookOfDisapproval';
requires 'Proc::Daemon';

{
  requires 'EV';
  requires 'Net::DNS::Native';
  requires 'IO::Socket::Socks';
  requires 'IO::Socket::SSL';
  requires 'Mojolicious';
}

{
  requires 'Tk';
  # requires 'Tk::More';
}
