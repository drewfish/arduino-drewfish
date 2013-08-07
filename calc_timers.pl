#!/usr/bin/env perl
#
# Copyright (c) 2013 Drew Folta.  All rights reserved.
# Copyrights licensed under the MIT License.
# See the accompanying LICENSE.txt file for terms.
#
#
# interrupt frequency (Hz) = F_CPU / (prescaler * (ocr + 1))
# ocr = ( F_CPU / (prescaler * desired interrupt frequency) ) - 1
#


use strict;
use warnings;
use POSIX;


my $F_CPU = 16_000_000;
my @PRESCALARS = (
    [ 1, 8, 64, 256, 1024 ],
    [ 1, 8, 64, 256, 1024 ],
    [ 1, 8, 32, 64 ]
);
my @MAX_OCRS = ( 256, 65536, 256 );


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
        my $max_ocr = $MAX_OCRS[$timer];
        foreach my $prescalar ( @{$PRESCALARS[$timer]} ) {
            my $ocr = ocr($prescalar, $targethz);
            next if $ocr >= $max_ocr;

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
            my $a_ocr = POSIX::floor($ocr);
            my $b_ocr = POSIX::ceil($ocr);
            if ($a_ocr >= 0) {
                my $a_hz = hz($prescalar, $a_ocr);
                print "        ocr $a_ocr -- $a_hz hz -- diff +", ($a_hz - $targethz), " hz\n";
            }
            if ($b_ocr >= 0) {
                my $b_hz = hz($prescalar, $b_ocr);
                print "        ocr $b_ocr -- $b_hz hz -- diff -", ($targethz - $b_hz), " hz\n";
            }
        }
    }
    

}
main(@ARGV);


