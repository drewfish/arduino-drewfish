/*
 * Copyright (c) 2013 Drew Folta.  All rights reserved.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE.txt file for terms.
 */

/**********************************************************************
 * TIMERS
 */

namespace drewfish {

    // support common Hz
    //      1000
    //          ps=64   -> ocr=249      TIMER0 TIMER1 TIMER2
    //      100
    //          ps=256  -> ocr=624      TIMER1
    //      10
    //          ps=256  -> ocr=6249     TIMER1
    //      1
    //          ps=1024 -> ocr=15624    TIMER1

    // hz = F_CPU / (prescaler * (ocr + 1))
    // ocr = ( F_CPU / (prescaler * hz) ) - 1


    #define TIMER1_HANDLER() ISR(TIMER1_COMPA_vect) 

    #define TIMER1_OFF() \
        if (1) { \
            TCCR1A = 0; \
            TCCR1B = 0; \
            TCNT1  = 0; \
            OCR1A  = 0; \
            TIMSK1 = 0; \
        } else {}

    // ocr=249 prescalar=64 (CS12=0 CS11=1 CS10=1)
    #define TIMER1_1000HZ() \
        if (1) { \
            TCCR1A = 0; \
            TCCR1B = 0; \
            TCNT1  = 0; \
            OCR1A  = 249; \
            TCCR1B |= (1 << WGM12); \
            TCCR1B |= (1 << CS11) | (1 << CS10); \
            TIMSK1 |= (1 << OCIE1A); \
        } else {}

    // ocr=624 prescalar=256 (CS12=1 CS11=0 CS10=0)
    #define TIMER1_100HZ() \
        if (1) { \
            TCCR1A = 0; \
            TCCR1B = 0; \
            TCNT1  = 0; \
            OCR1A  = 624; \
            TCCR1B |= (1 << WGM12); \
            TCCR1B |= (1 << CS12); \
            TIMSK1 |= (1 << OCIE1A); \
        } else {}

    // ocr=6249 prescalar=256 (CS12=1 CS11=0 CS10=0)
    #define TIMER1_10HZ() \
        if (1) { \
            TCCR1A = 0; \
            TCCR1B = 0; \
            TCNT1  = 0; \
            OCR1A  = 6249; \
            TCCR1B |= (1 << WGM12); \
            TCCR1B |= (1 << CS12); \
            TIMSK1 |= (1 << OCIE1A); \
        } else {}

    // ocr=15624 prescalar=1024 (CS12=1 CS11=0 CS10=1)
    #define TIMER1_1HZ() \
        if (1) { \
            TCCR1A = 0; \
            TCCR1B = 0; \
            TCNT1  = 0; \
            OCR1A  = 15624; \
            TCCR1B |= (1 << WGM12); \
            TCCR1B |= (1 << CS12) | (1 << CS10); \
            TIMSK1 |= (1 << OCIE1A); \
        } else {}


    // TIMER0 --  OCR < 256
    //      TCCR0A |= (1 << WGM01)
    //      off  -- 
    //      1    -- CS00
    //      8    -- CS01
    //      64   -- CS01 & CS00
    //      256  -- CS02
    //      1024 -- CS02 & CS00
    //
    // TIMER1 -- OCR < 65536
    //      TCCR1B |= (1 << WGM12)
    //      off  -- 
    //      1    -- CS10
    //      8    -- CS11
    //      64   -- CS11 & CS10
    //      256  -- CS12
    //      1024 -- CS12 & CS10
    //
    // TIMER2 -- OCR < 256
    //      TCCR2A |= (1 << WGM21)
    //      off  -- 
    //      1    -- CS20
    //      8    -- CS21
    //      32   -- CS21 & CS20
    //      64   -- CS22

};

