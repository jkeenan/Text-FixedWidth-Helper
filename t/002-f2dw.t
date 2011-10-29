# perl
use strict;
use warnings;
use Carp;
use Cwd;
use File::Basename;
use File::Temp qw( tempdir );
use IO::CaptureOutput qw( capture );
use Test::More qw( no_plan );
use Tie::File;
use lib qw( ./lib );
use Text::FixedWidth::Helper qw( fw2d );

my ($input, $output, $produced, $base, $tdir);
my $cwd = cwd();

{
    $input = "$cwd/t/testlib/02-sample.txt";
    $base = basename($input);
    $tdir = tempdir( CLEANUP => 1 );
    $output = "$tdir/$base.transformed";
    $produced = fw2d( $input, $output );
    ok( ( -f $produced ), "Output file produced" );

    my @lines;
    tie @lines, 'Tie::File', $produced
        or croak "Unable to tie to $produced";
    like( $lines[0], qr/^fname\|Sylvester$/,
        "Got expected first line" );
    like( $lines[6], qr/^zip\|14618$/,
        "Got expected last line in first block" );
    like( $lines[7], qr/^/,
        "Got expected empty line between blocks" );
    untie @lines or croak "Cannot untie from $produced";
}

