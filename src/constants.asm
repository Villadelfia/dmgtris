; DMGTRIS
; Copyright (C) 2023 - Randy Thiemann <randy.thiemann@gmail.com>

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.


IF !DEF(CONSTANTS_ASM)
DEF CONSTANTS_ASM EQU 1

CHARMAP " ", 1
CHARMAP "0", 66
CHARMAP "1", 67
CHARMAP "2", 68
CHARMAP "3", 69
CHARMAP "4", 70
CHARMAP "5", 71
CHARMAP "6", 72
CHARMAP "7", 73
CHARMAP "8", 74
CHARMAP "9", 75
CHARMAP "A", 76
CHARMAP "B", 77
CHARMAP "C", 78
CHARMAP "D", 79
CHARMAP "E", 80
CHARMAP "F", 81
CHARMAP "G", 82
CHARMAP "H", 83
CHARMAP "I", 84
CHARMAP "J", 85
CHARMAP "K", 86
CHARMAP "L", 87
CHARMAP "M", 88
CHARMAP "N", 89
CHARMAP "O", 90
CHARMAP "P", 91
CHARMAP "Q", 92
CHARMAP "R", 93
CHARMAP "S", 94
CHARMAP "T", 95
CHARMAP "U", 96
CHARMAP "V", 97
CHARMAP "W", 98
CHARMAP "X", 99
CHARMAP "Y", 100
CHARMAP "Z", 101
CHARMAP "!", 102
CHARMAP "?", 103
CHARMAP "[", 129
CHARMAP "]", 130
CHARMAP "/", 128
CHARMAP "-", 127
CHARMAP "#", 126
CHARMAP ".", 216
CHARMAP ":", 222


SECTION "Static Data", ROMX, BANK[1]
sLeady::     db "  READY?  "
sGo::        db "    GO    "
sPause::
    db "P A U S E "
    db " P A U S E"
sOption0::
    db "NORM"
    db " INV"
sOption1::
    db "TGM1"
    db "TGM2"
    db "TGM3"
    db "HELL"
    db " NES"
sOption2::
    db "ARS1"
    db "ARS2"
    db " NES"
sOption3::
    db "FIRM"
    db "SNIC"
    db "HARD"
    db "LOCK"
    db "NONE"
sOption4::
    db "DMGT"
    db "TGM1"
    db "TGM3"
    db "DEAT"
    db "SHIR"
    db "CHIL"
sOption5::
    db "  NO"
    db " YES"
sDisabled::
    db "----"

sEasterM0:: db $C4, $C6, $C8, $CA, $CC
sEasterM1:: db $C5, $C7, $C9, $CB, $CD
sEasterC0:: db $CE, $D0, $C8, $CA, $CC, $72, $74, $76, $78, $7A, $D6, $D7
sEasterC1:: db $CF, $D1, $C9, $CB, $CD, $73, $75, $77, $79, $7B, $01, $01
sEasterA0:: db $D2, $D4, $C8, $CA, $CC, $72, $74, $76, $78, $7A, $D6, $D7
sEasterA1:: db $D3, $D5, $C9, $CB, $CD, $73, $75, $77, $79, $7B, $01, $01
sEasterS0:: db $F6, $F8, $C8, $CA, $CC
sEasterS1:: db $F7, $F9, $C9, $CB, $CD

sPieceXOffsets::    ; How to draw each piece. X-offsets of the sprites.
    db 0, 8, 16, 24 ; I
    db 0, 8, 8, 16  ; Z
    db 0, 8, 8, 16  ; S
    db 0, 8, 16, 16 ; J
    db 0, 0, 8, 16  ; L
    db 8, 8, 16, 16 ; O
    db 0, 8, 8, 16  ; T

sPieceYOffsets::    ; How to draw each piece. Y-offsets of the sprites.
    db 0, 0, 0, 0   ; I
    db 0, 0, 7, 7   ; Z
    db 7, 7, 0, 0   ; S
    db 0, 0, 0, 7   ; J
    db 7, 0, 0, 0   ; L
    db 0, 7, 0, 7   ; O
    db 0, 0, 7, 0   ; T

; Speed curve data is defined as follows:
; N blocks of:
;   dw BCD_START_LEVEL, START_LEVEL, BCD_NEXT_100_LEVEL_BREAKPOINT
;   db GRID_CELLS_PER_MOVE_ON_OVERFLOW, INCREMENT_PER_FRAME
;   db NORMAL_ARE, LINE_ARE, DAS, LOCK_DELAY, CLEAR_DELAY
;
; Followed by one single:
;   dw $FFFF

sTGM1SpeedCurve::
    dw $0000, 0, $0100
    db 1, 4
    db 30, 30, 16, 30, 41

    dw $0030, 30, $0100
    db 1, 6
    db 30, 30, 16, 30, 41

    dw $0035, 35, $0100
    db 1, 8
    db 30, 30, 16, 30, 41

    dw $0040, 40, $0100
    db 1, 10
    db 30, 30, 16, 30, 41

    dw $0050, 50, $0100
    db 1, 12
    db 30, 30, 16, 30, 41

    dw $0060, 60, $0100
    db 1, 16
    db 30, 30, 16, 30, 41

    dw $0070, 70, $0100
    db 1, 32
    db 30, 30, 16, 30, 41

    dw $0080, 80, $0100
    db 1, 48
    db 30, 30, 16, 30, 41

    dw $0090, 90, $0100
    db 1, 64
    db 30, 30, 16, 30, 41

    dw $0100, 100, $0200
    db 1, 80
    db 30, 30, 16, 30, 41

    dw $0120, 120, $0200
    db 1, 96
    db 30, 30, 16, 30, 41

    dw $0140, 140, $0200
    db 1, 112
    db 30, 30, 16, 30, 41

    dw $0160, 160, $0200
    db 1, 128
    db 30, 30, 16, 30, 41

    dw $0170, 170, $0200
    db 1, 144
    db 30, 30, 16, 30, 41

    dw $0200, 200, $0300
    db 1, 4
    db 30, 30, 16, 30, 41

    dw $0220, 220, $0300
    db 1, 32
    db 30, 30, 16, 30, 41

    dw $0230, 230, $0300
    db 1, 64
    db 30, 30, 16, 30, 41

    dw $0233, 233, $0300
    db 1, 96
    db 30, 30, 16, 30, 41

    dw $0236, 236, $0300
    db 1, 128
    db 30, 30, 16, 30, 41

    dw $0239, 239, $0300
    db 1, 160
    db 30, 30, 16, 30, 41

    dw $0243, 243, $0300
    db 1, 192
    db 30, 30, 16, 30, 41

    dw $0247, 239, $0300
    db 1, 224
    db 30, 30, 16, 30, 41

    dw $0251, 251, $0300
    db 1, $FF
    db 30, 30, 16, 30, 41

    dw $0300, 300, $0400
    db 2, $FF
    db 30, 30, 16, 30, 41

    dw $0330, 330, $0400
    db 3, $FF
    db 30, 30, 16, 30, 41

    dw $0360, 360, $0400
    db 4, $FF
    db 30, 30, 16, 30, 41

    dw $0400, 400, $0500
    db 5, $FF
    db 30, 30, 16, 30, 41

    dw $0420, 420, $0500
    db 4, $FF
    db 30, 30, 16, 30, 41

    dw $0450, 450, $0500
    db 3, $FF
    db 30, 30, 16, 30, 41

    dw $0500, 500, $0600
    db 20, $FF
    db 30, 30, 16, 30, 41

sTGM1SpeedCurveEnd::
    dw $FFFF


sCHILSpeedCurve::
    dw $0000, 0, $0100
    db 1, 5
    db 10, 10, 16, 25, 17

    dw $0100, 100, $0200
    db 1, 6
    db 10, 10, 16, 25, 17

    dw $0200, 200, $0300
    db 1, 7
    db 10, 10, 16, 25, 17

    dw $0300, 300, $0400
    db 1, 8
    db 10, 10, 16, 25, 17

    dw $0400, 400, $0500
    db 1, 9
    db 10, 10, 16, 25, 17

    dw $0500, 500, $0600
    db 1, 11
    db 10, 10, 16, 25, 17

    dw $0600, 600, $0700
    db 1, 14
    db 10, 10, 16, 25, 17

    dw $0700, 700, $0800
    db 1, 20
    db 10, 10, 16, 25, 17

    dw $0800, 800, $0900
    db 1, 32
    db 10, 10, 16, 25, 17

    dw $0900, 900, $1000
    db 1, 43
    db 10, 10, 16, 25, 17

    dw $1000, 1000, $1100
    db 1, 51
    db 10, 10, 16, 25, 17

    dw $1300, 1300, $1400
    db 1, 64
    db 10, 10, 16, 25, 17

    dw $1600, 1600, $1700
    db 1, 85
    db 10, 10, 16, 25, 17

    dw $1900, 1900, $2000
    db 1, 128
    db 10, 10, 16, 25, 17

    dw $2900, 2900, $3000
    db 1, $FF
    db 10, 10, 16, 25, 17

    dw $3333, 3333, $3400
    db 2, $FF
    db 10, 10, 12, 25, 17

    dw $4444, 4444, $4500
    db 3, $FF
    db 10, 10, 12, 25, 17

    dw $5555, 5555, $5600
    db 4, $FF
    db 10, 10, 12, 25, 17

    dw $6666, 6666, $6700
    db 5, $FF
    db 10, 10, 12, 25, 17

    dw $7777, 7777, $7800
    db 20, $FF
    db 10, 10, 8, 25, 17

    dw $8888, 8888, $8900
    db 20, $FF
    db 10, 10, 6, 18, 17

    dw $9999, 9999, $9999
    db 20, $FF
    db 5, 5, 6, 14, 10

sCHILSpeedCurveEnd::
    dw $FFFF


sTGM3SpeedCurve::
    dw $0000, 0, $0100
    db 1, 4
    db 27, 27, 16, 30, 40

    dw $0030, 30, $0100
    db 1, 6
    db 27, 27, 16, 30, 40

    dw $0035, 35, $0100
    db 1, 8
    db 27, 27, 16, 30, 40

    dw $0040, 40, $0100
    db 1, 10
    db 27, 27, 16, 30, 40

    dw $0050, 50, $0100
    db 1, 12
    db 27, 27, 16, 30, 40

    dw $0060, 60, $0100
    db 1, 16
    db 27, 27, 16, 30, 40

    dw $0070, 70, $0100
    db 1, 32
    db 27, 27, 16, 30, 40

    dw $0080, 80, $0100
    db 1, 48
    db 27, 27, 16, 30, 40

    dw $0090, 90, $0100
    db 1, 64
    db 27, 27, 16, 30, 40

    dw $0100, 100, $0200
    db 1, 80
    db 27, 27, 16, 30, 40

    dw $0120, 120, $0200
    db 1, 96
    db 27, 27, 16, 30, 40

    dw $0140, 140, $0200
    db 1, 112
    db 27, 27, 16, 30, 40

    dw $0160, 160, $0200
    db 1, 128
    db 27, 27, 16, 30, 40

    dw $0170, 170, $0200
    db 1, 144
    db 27, 27, 16, 30, 40

    dw $0200, 200, $0300
    db 1, 4
    db 27, 27, 16, 30, 40

    dw $0220, 220, $0300
    db 1, 32
    db 27, 27, 16, 30, 40

    dw $0230, 230, $0300
    db 1, 64
    db 27, 27, 16, 30, 40

    dw $0233, 233, $0300
    db 1, 96
    db 27, 27, 16, 30, 40

    dw $0236, 236, $0300
    db 1, 128
    db 27, 27, 16, 30, 40

    dw $0239, 239, $0300
    db 1, 160
    db 27, 27, 16, 30, 40

    dw $0243, 243, $0300
    db 1, 192
    db 27, 27, 16, 30, 40

    dw $0247, 239, $0300
    db 1, 224
    db 27, 27, 16, 30, 40

    dw $0251, 251, $0300
    db 1, $FF
    db 27, 27, 16, 30, 40

    dw $0300, 300, $0400
    db 2, $FF
    db 27, 27, 16, 30, 40

    dw $0330, 330, $0400
    db 3, $FF
    db 27, 27, 16, 30, 40

    dw $0360, 360, $0400
    db 4, $FF
    db 27, 27, 16, 30, 40

    dw $0400, 400, $0500
    db 5, $FF
    db 27, 27, 16, 30, 40

    dw $0420, 420, $0500
    db 4, $FF
    db 27, 27, 16, 30, 40

    dw $0450, 450, $0500
    db 3, $FF
    db 27, 27, 16, 30, 40

    dw $0500, 500, $0600
    db 20, $FF
    db 27, 27, 10, 30, 25

    dw $0600, 600, $0700
    db 20, $FF
    db 27, 18, 10, 30, 16

    dw $0700, 700, $0800
    db 20, $FF
    db 18, 14, 10, 30, 12

    dw $0800, 800, $0900
    db 20, $FF
    db 14, 8, 10, 30, 6

    dw $0900, 900, $1000
    db 20, $FF
    db 14, 8, 8, 17, 6

    dw $1000, 1000, $1100
    db 20, $FF
    db 8, 8, 8, 17, 6

    dw $1100, 1000, $1200
    db 20, $FF
    db 7, 7, 8, 15, 6

    dw $1200, 1000, $1300
    db 20, $FF
    db 6, 6, 8, 15, 6

sTGM3SpeedCurveEnd::
    dw $FFFF

sDEATSpeedCurve::
    dw $0000, 0, $0100
    db 20, $FF
    db 18, 14, 12, 30, 12

    dw $0100, 0, $0200
    db 20, $FF
    db 14, 8, 12, 26, 6

    dw $0200, 0, $0300
    db 20, $FF
    db 14, 8, 11, 22, 6

    dw $0300, 0, $0400
    db 20, $FF
    db 8, 8, 10, 18, 6

    dw $0400, 0, $0500
    db 20, $FF
    db 7, 7, 8, 15, 5

    dw $0500, 0, $0600
    db 20, $FF
    db 6, 6, 8, 15, 4

sDEATSpeedCurveEnd::
    dw $FFFF

sSHIRSpeedCurve::
    dw $0000, 0, $0100
    db 20, $FF
    db 12, 8, 10, 18, 6

    dw $0100, 100, $0200
    db 20, $FF
    db 12, 7, 8, 18, 5

    dw $0200, 200, $0300
    db 20, $FF
    db 12, 6, 8, 17, 4

    dw $0300, 300, $0400
    db 20, $FF
    db 6, 6, 8, 15, 4

    dw $0500, 500, $0600
    db 20, $FF
    db 6, 5, 6, 13, 3

    dw $1100, 1100, $1200
    db 20, $FF
    db 6, 5, 6, 10, 3

    dw $1200, 1200, $1300
    db 20, $FF
    db 6, 5, 6, 8, 3

sSHIRSpeedCurveEnd::
    dw $FFFF

sDMGTSpeedCurve::       ; Speed curve of the game.
    dw $0000, 0, $0100  ; Level 0000
    db 1, 16
    db 25, 15, 14, 30, 40

    dw $0015, 15, $0100 ; Level 0015
    db 1, 17
    db 25, 15, 14, 30, 40

    dw $0030, 30, $0100 ; Level 0030
    db 1, 18
    db 25, 15, 14, 30, 40

    dw $0040, 40, $0100 ; Level 0040
    db 1, 20
    db 25, 15, 14, 30, 40

    dw $0050, 50, $0100 ; Level 0050
    db 1, 21
    db 25, 15, 14, 30, 40

    dw $0060, 60, $0100 ; Level 0060
    db 1, 23
    db 25, 15, 14, 30, 40

    dw $0070, 70, $0100 ; Level 0070
    db 1, 26
    db 25, 15, 14, 30, 40

    dw $0080, 80, $0100 ; Level 0080
    db 1, 28
    db 25, 15, 14, 30, 40

    dw $0090, 90, $0100 ; Level 0090
    db 1, 32
    db 25, 15, 14, 30, 40

    dw $0100, 100, $0200 ; Level 0100
    db 1, 37
    db 25, 15, 14, 30, 40

    dw $0150, 150, $0200 ; Level 0150
    db 1, 43
    db 25, 15, 14, 30, 40

    dw $0200, 200, $0300 ; Level 0200
    db 1, 51
    db 25, 15, 14, 30, 40

    dw $0225, 225, $0300 ; Level 0225
    db 1, 64
    db 25, 15, 14, 30, 40

    dw $0250, 250, $0300 ; Level 0250
    db 1, 85
    db 25, 15, 14, 30, 40

    dw $0275, 275, $0300 ; Level 0275
    db 1, 128
    db 25, 15, 14, 30, 40

    dw $0300, 300, $0400 ; Level 0300
    db 1, $FF
    db 25, 7, 14, 30, 32

    dw $0350, 350, $0350 ; Level 0350
    db 2, $FF
    db 25, 7, 14, 30, 32

    dw $0400, 400, $0400 ; Level 0400
    db 3, $FF
    db 25, 7, 14, 30, 32

    dw $0450, 450, $0500 ; Level 0450
    db 4, $FF
    db 25, 7, 14, 30, 32

    dw $0475, 475, $0500 ; Level 0475
    db 5, $FF
    db 25, 7, 14, 30, 32

    dw $0500, 500, $0600 ; Level 0500
    db 20, $FF
    db 25, 6, 14, 30, 24

    dw $0600, 600, $0700 ; Level 0600
    db 20, $FF
    db 25, 6, 8, 30, 24

    dw $0700, 700, $0800 ; Level 0700
    db 20, $FF
    db 20, 6, 8, 30, 24

    dw $0900, 900, $1000 ; Level 0900
    db 20, $FF
    db 16, 4, 6, 25, 16

    dw $1100, 1100, $1200 ; Level 1100
    db 20, $FF
    db 12, 4, 6, 25, 16

    dw $1200, 1200, $1300 ; Level 1200
    db 20, $FF
    db 12, 4, 6, 25, 8

    dw $1300, 1300, $1400 ; Level 1300
    db 20, $FF
    db 10, 4, 6, 20, 7

    dw $1400, 1400, $1500 ; Level 1400
    db 20, $FF
    db 10, 4, 6, 18, 6

    dw $1500, 1500, $1600 ; Level 1500
    db 20, $FF
    db 8, 4, 4, 16, 5

    dw $1600, 1600, $1700 ; Level 1600
    db 20, $FF
    db 8, 4, 4, 14, 4

    dw $1700, 1700, $1800 ; Level 1700
    db 20, $FF
    db 6, 4, 4, 12, 3

    dw $1800, 1800, $1900 ; Level 1800
    db 20, $FF
    db 6, 4, 4, 10, 3

    dw $1900, 1900, $2000 ; Level 1900
    db 20, $FF
    db 4, 4, 4, 8, 3

    dw $2000, 2000, $2100 ; Level 2000
    db 20, $FF
    db 4, 4, 3, 8, 3

    dw $2500, 2500, $2600 ; Level 2500
    db 20, $FF
    db 2, 2, 1, 8, 2

    dw $3000, 3000, $3100 ; Level 3000
    db 20, $FF
    db 1, 1, 1, 8, 1

    dw $4000, 4000, $4100 ; Level 4000
    db 20, $FF
    db 1, 1, 1, 6, 1

    dw $5000, 5000, $5100 ; Level 5000
    db 20, $FF
    db 1, 1, 1, 4, 1

    dw $6666, 6666, $6700 ; Level 6666
    db 20, $FF
    db 1, 1, 1, 2, 1

    dw $9999, 9999, $9999 ; Level 9999
    db 20, $FF
    db 1, 1, 1, 1, 1

sDMGTSpeedCurveEnd::
    dw $FFFF              ; End.



sPieceFastRotationStates::
    ; I
    db 14, 1, 1, 1
    db 2, 14, 14, 14
    db 14, 1, 1, 1
    db 2, 14, 14, 14

    ; Z
    db 14, 1, 14, 1
    db 2, 13, 1, 13
    db 14, 1, 14, 1
    db 2, 13, 1, 13

    ; S
    db 15, 1, 12, 1
    db 0, 14, 1, 14
    db 15, 1, 12, 1
    db 0, 14, 1, 14

    ; J
    db 14, 1, 1, 14
    db 1, 1, 13, 14
    db 14, 14, 1, 1
    db 1, 14, 13, 1

    ; L
    db 14, 1, 1, 12
    db 1, 14, 14, 1
    db 16, 12, 1, 1
    db 0, 1, 14, 14

    ; O
    db 15, 1, 13, 1
    db 15, 1, 13, 1
    db 15, 1, 13, 1
    db 15, 1, 13, 1

    ; T
    db 14, 1, 1, 13
    db 1, 14, 1, 13
    db 15, 13, 1, 1
    db 1, 13, 1, 14

sPieceRotationStates:: ; How each piece is rotated.
    ; I
    db %0000
    db %1111
    db %0000
    db %0000

    db %0010
    db %0010
    db %0010
    db %0010

    db %0000
    db %1111
    db %0000
    db %0000

    db %0010
    db %0010
    db %0010
    db %0010

    ; Z
    db %0000
    db %1100
    db %0110
    db %0000

    db %0010
    db %0110
    db %0100
    db %0000

    db %0000
    db %1100
    db %0110
    db %0000

    db %0010
    db %0110
    db %0100
    db %0000

    ; S
    db %0000
    db %0110
    db %1100
    db %0000

    db %1000
    db %1100
    db %0100
    db %0000

    db %0000
    db %0110
    db %1100
    db %0000

    db %1000
    db %1100
    db %0100
    db %0000

    ; J
    db %0000
    db %1110
    db %0010
    db %0000

    db %0110
    db %0100
    db %0100
    db %0000

    db %0000
    db %1000
    db %1110
    db %0000

    db %0100
    db %0100
    db %1100
    db %0000

    ; L
    db %0000
    db %1110
    db %1000
    db %0000

    db %0100
    db %0100
    db %0110
    db %0000

    db %0000
    db %0010
    db %1110
    db %0000

    db %1100
    db %0100
    db %0100
    db %0000

    ; O
    db %0000
    db %0110
    db %0110
    db %0000

    db %0000
    db %0110
    db %0110
    db %0000

    db %0000
    db %0110
    db %0110
    db %0000

    db %0000
    db %0110
    db %0110
    db %0000

    ; T
    db %0000
    db %1110
    db %0100
    db %0000

    db %0100
    db %0110
    db %0100
    db %0000

    db %0000
    db %0100
    db %1110
    db %0000

    db %0100
    db %1100
    db %0100
    db %0000

sTGM3Bag::
    db 0, 0, 0, 0, 0
    db 1, 1, 1, 1, 1
    db 2, 2, 2, 2, 2
    db 3, 3, 3, 3, 3
    db 4, 4, 4, 4, 4
    db 5, 5, 5, 5, 5
    db 6, 6, 6, 6, 6

sTGM3Droughts::
    db 0, 0, 0, 0, 0, 0, 0


ENDC
