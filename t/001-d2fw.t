# perl
use strict;
use warnings;
use Carp;
use File::Basename;
use File::Temp qw( tempdir );
use Test::More qw( no_plan );
use Tie::File;
use lib qw( ./lib );
use Text::FixedWidth::Helper qw( d2fw );

my ($input, $output, $produced, $base, $tdir);

{
    $input = "./t/testlib/01-sample.txt";
    $base = basename($input);
    $tdir = tempdir( CLEANUP => 1 );
    $output = "$tdir/$base.transformed";
    $produced = d2fw( $input, $output );
    ok( ( -f $produced ), "Output file produced" );

    my @lines;
    tie @lines, 'Tie::File', $produced
        or croak "Unable to tie to $produced";
    like( $lines[0], qr/^(?:1234567890)+/,
        "Got index line" );
    like( $lines[1], qr/^[\s|]+$/, "Got a spacer line" );
    like( $lines[2],
        qr/^Sylvester\s{6}JGomez\s{10}M789294592Rochester\s{11}NY14618$/,
        "Got expected fixed-width line" );
    untie @lines or croak "Cannot untie from $produced";
}

{
    $input = "./foobar";
    $base = basename($input);
    $tdir = tempdir( CLEANUP => 1 );
    $output = "$tdir/$base.transformed";
    eval {
        $produced = d2fw( $input, $output );
    };
    like( $@, qr/Could not locate input file $input/, "Got expected death message: input not found" );
}

{
    $input = "./t/testlib/01-sample.txt";
    $base = basename($input);
    $tdir = tempdir( CLEANUP => 1 );
    $produced = d2fw( $input );
    ok( ( -f $produced ), "Output file produced" );
    is( $produced, "$input.out",
        "Output file name defaulted to expected value" );

    my @lines;
    tie @lines, 'Tie::File', $produced
        or croak "Unable to tie to $produced";
    like( $lines[0], qr/^(?:1234567890)+/,
        "Got index line" );
    like( $lines[1], qr/^[\s|]+$/, "Got a spacer line" );
    like( $lines[2],
        qr/^Sylvester\s{6}JGomez\s{10}M789294592Rochester\s{11}NY14618$/,
        "Got expected fixed-width line" );
    untie @lines or croak "Cannot untie from $produced";
    unlink $produced;
}

{
    $input = "./t/testlib/03-toolong.txt";
    $base = basename($input);
    $tdir = tempdir( CLEANUP => 1 );
    $output = "$tdir/$base.transformed";
    eval {
        $produced = d2fw( $input, $output );
    };
    like( $@,
        qr/Text::FixedWidth::Helper restricts records to 1000 characters/,
        "Got expected death message: template too long" );
}

__END__
12345678901234567890123456789012345678901234567890123456789012345678
|              ||              |         |                   | |    
Sylvester      JGomez          M789294592Rochester           NY14618
Arthur         XFridrikkson    M783891590Oakland             CA94601
Kasimir        EKristemanaczewsN389182992Buffalo             NY14214
