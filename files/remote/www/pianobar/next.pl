#!/usr/bin/perl -W

use strict;
use warnings;

system( 'echo "n" > /pianobar.control' );

print( "Content-type:text/html\n\n" );
print << 'EOF';
<html>
  <body>
    Command issued.
  </body>
</html>
EOF
