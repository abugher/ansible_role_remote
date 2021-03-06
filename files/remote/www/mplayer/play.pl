#!/usr/bin/perl -W

use strict;
use warnings;

use CGI;
use File::Spec;
use URI::Encode;
use Time::HiRes qw( usleep );


my $uri         = URI::Encode->new( { encode_reserved => 1 } );
my $q           = CGI->new();

my $file        = $q->param('file');
my @fileset     = $q->multi_param('fileset');

# microseconds
my $napTime     = 300000;

sub issue_command {
  my $command = $_[0];

  my $control_file_name = '/mplayer.control';

  open( my $control_file_handle, '>', $control_file_name ) 
    or die "Failed to open control file ( '${control_file_name}' ) for writing:  '$!'";
  print $control_file_handle "${command}\n";
  close $control_file_handle;
  usleep( $napTime );
}


if( defined( $file ) ) {
  $file = File::Spec->rel2abs( 
    $uri->decode( $file ),
    '/'
  );
  $file =~ /^\/storage\/bittorrent\/content\// or die "Invalid file path: ${file}";
} else {
  for my $f ( keys( @fileset ) ) {
    $fileset[$f] = File::Spec->rel2abs( 
      $uri->decode( $fileset[$f] ),
      '/' 
    );
    $fileset[$f] =~ /^\/storage\/bittorrent\/content\// or die "Invalid file path: $fileset[$f]";
  }
}

my $append = 'append-play';
if( defined( $file ) ) {
  $file =~ s/'/\\'/;
  if( "${file}" =~ /^\/storage\/bittorrent\/content\/radio\.m3u$/  ) {
    issue_command( "loadlist \"${file}\" ${append}" );
  } else {
    issue_command( "loadfile \"${file}\" ${append}" );
  }
} else {
  for my $f ( sort( @fileset ) ) {
    $f =~ s/'/\\'/;
    if( "${f}" =~ /^\/storage\/bittorrent\/content\/radio\.m3u$/  ) {
      issue_command( "loadlist \"${f}\" ${append}" );
    } else {
      issue_command( "loadfile \"${f}\" ${append}" );
    }
    $append = 'append';
  }
}

usleep( $napTime );
# mplayer:
#issue_command( "vo_fullscreen 1" );

#mpv
issue_command( "set fullscreen yes" );

print( "Content-type:text/html\n\n" );
print( "<meta http-equiv=refresh content='.1;/remote.pl'>\n" );
