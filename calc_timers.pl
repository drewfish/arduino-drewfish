#!/usr/bin/env perl


use strict;
use warnings;
use Data::Dumper;
use POSIX;


# interrupt frequency (Hz) = F_CPU / (prescaler * (ocr + 1))
# ocr = ( F_CPU / (prescaler * desired interrupt frequency) ) - 1

my $F_CPU = 16_000_000;
my @PRESCALARS = (
    [ 1, 8, 64, 256, 1024 ],
    [ 1, 8, 64, 256, 1024 ],
    [ 1, 8, 32, 64 ]
);
my @WIDTHS = ( 256, 65536, 256 );



sub ocr {
    my $ps = shift;
    my $hz = shift;
    return ( $F_CPU / ($ps * $hz) ) - 1;
}


sub hz {
    my $ps = shift;
    my $ocr = shift;
    return $F_CPU / ($ps * ($ocr + 1));
}


sub main {
    my $targethz = shift;
    unless ($targethz) {
        print "USAGE:  $0 {desired-hz}\n";
        exit 1;
    }

    my @exacts;
    my @almosts;
    foreach my $timer ( 0 .. 2 ) {
        my $width = $WIDTHS[$timer];
        foreach my $prescalar ( @{$PRESCALARS[$timer]} ) {
            my $ocr = ocr($prescalar, $targethz);
            next if $ocr >= $width;

            if ($ocr eq POSIX::floor($ocr)) {
                push @exacts, { timer => $timer, prescalar => $prescalar, ocr => $ocr };
            }
            else {
                push @almosts, { timer => $timer, prescalar => $prescalar, ocr => $ocr };
            }
        }
    }

    if (@exacts) {
        print "EXACT MATCHES\n";
        foreach my $exact ( @exacts ) {
            my $timer = $exact->{'timer'};
            my $prescalar = $exact->{'prescalar'};
            my $ocr = $exact->{'ocr'};
            print "    timer $timer -- prescalar $prescalar -- ocr $ocr\n";
        }
    }

    print "\n" if @exacts and @almosts;

    if (@almosts) {
        print "APPROXIMATES\n";
        foreach my $almost ( @almosts ) {
            my $timer = $almost->{'timer'};
            my $prescalar = $almost->{'prescalar'};
            my $ocr = $almost->{'ocr'};
            print "    timer $timer -- prescalar $prescalar\n";
            my $min_ocr = POSIX::floor($ocr);
            my $max_ocr = POSIX::ceil($ocr);
            my $min_hz = hz($prescalar, $min_ocr);
            my $max_hz = hz($prescalar, $max_ocr);
            print "        ocr $min_ocr -- $min_hz hz -- diff +", ($min_hz - $targethz), " hz\n";
            print "        ocr $max_ocr -- $max_hz hz -- diff -", ($targethz - $max_hz), " hz\n";
            
        }
    }
    

}
main(@ARGV);


