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
my @TIMERS = (
    {
        name => 0,
        maxOCR => 255,
        prescalars => [ 1, 8, 64, 256, 1024 ]
    },
    {
        name => 1,
        maxOCR => 65535,
        prescalars => [ 1, 8, 64, 256, 1024 ]
    },
    {
        name => 2,
        maxOCR => 255,
        prescalars => [ 1, 8, 32, 64 ]
    }
);


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
    foreach my $timer ( @TIMERS ) {
        foreach my $ps ( @{$timer->{'prescalars'}} ) {
            my $ocr = ocr($ps, $targethz);
            next if $ocr > $timer->{'maxOCR'};
            if ($ocr eq POSIX::floor($ocr)) {
                push @exacts, { timer => $timer->{'name'}, ps => $ps, ocr => $ocr };
            }
            else {
                push @almosts, { timer => $timer->{'name'}, ps => $ps, ocr => $ocr };
            }
        }
    }

    if (@exacts) {
        print "EXACT MATCHES\n";
        foreach my $exact ( @exacts ) {
            my $timer = $exact->{'timer'};
            my $ps = $exact->{'ps'};
            my $ocr = $exact->{'ocr'};
            print "    timer $timer -- prescalar $ps -- ocr $ocr\n";
        }
    }

    print "\n" if @exacts and @almosts;

    if (@almosts) {
        print "APPROXIMATES\n";
        foreach my $almost ( @almosts ) {
            my $timer = $almost->{'timer'};
            my $ps = $almost->{'ps'};
            my $ocr = $almost->{'ocr'};
            print "    timer $timer -- prescalar $ps\n";
            my $a_ocr = POSIX::floor($ocr);
            my $b_ocr = POSIX::ceil($ocr);
            if ($a_ocr >= 0) {
                my $a_hz = hz($ps, $a_ocr);
                print "        ocr $a_ocr -- $a_hz hz -- diff +", ($a_hz - $targethz), " hz\n";
            }
            if ($b_ocr >= 0) {
                my $b_hz = hz($ps, $b_ocr);
                print "        ocr $b_ocr -- $b_hz hz -- diff -", ($targethz - $b_hz), " hz\n";
            }
        }
    }
}
main(@ARGV);


