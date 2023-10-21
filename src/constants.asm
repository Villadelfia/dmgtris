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
CHARMAP "|", 126
CHARMAP "#", 125


SECTION "Static Data", ROM0
sLeady::     db "  READY?  "
sGo::        db "    GO    "
sGameOver::  db "GAME OVER!"
sGameOver2:: db " RETRY[A] "
sGameOver3:: db " QUIT [B] "
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

sSpeedCurve::         ; Speed curve of the game.
    dw $0000          ; Level 0000
    db 1, 64          ; 1G every 16 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0015          ; Level 0015
    db 1, 15          ; 1G every 15 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0030          ; Level 0030
    db 1, 14          ; 1G every 14 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0040          ; Level 0040
    db 1, 13          ; 1G every 13 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0050          ; Level 0050
    db 1, 12          ; 1G every 12 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0060          ; Level 0060
    db 1, 11          ; 1G every 11 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0070          ; Level 0070
    db 1, 10          ; 1G every 10 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0080          ; Level 0080
    db 1, 9           ; 1G every 9 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0090          ; Level 0090
    db 1, 8           ; 1G every 8 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0100          ; Level 0100
    db 1, 7           ; 1G every 7 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0150          ; Level 0150
    db 1, 6           ; 1G every 6 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0200          ; Level 0200
    db 1, 5           ; 1G every 5 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0225          ; Level 0225
    db 1, 4           ; 1G every 4 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0250          ; Level 0250
    db 1, 3           ; 1G every 3 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0275          ; Level 0275
    db 1, 2           ; 1G every 2 frames
    db 25, 14, 30, 40 ; ARE, DAS, LOCK, LINECLEAR

    dw $0300          ; Level 0300
    db 1, 1           ; 1G
    db 25, 14, 30, 32 ; ARE, DAS, LOCK, LINECLEAR

    dw $0350          ; Level 0350
    db 2, 1           ; 2G
    db 25, 14, 30, 32 ; ARE, DAS, LOCK, LINECLEAR

    dw $0400          ; Level 0400
    db 3, 1           ; 3G
    db 25, 14, 30, 32 ; ARE, DAS, LOCK, LINECLEAR

    dw $0450          ; Level 0450
    db 4, 1           ; 4G
    db 25, 14, 30, 32 ; ARE, DAS, LOCK, LINECLEAR

    dw $0475          ; Level 0475
    db 5, 1           ; 5G
    db 25, 14, 30, 32 ; ARE, DAS, LOCK, LINECLEAR

    dw $0500          ; Level 0500
    db 20, 1          ; 20G
    db 25, 14, 30, 24 ; ARE, DAS, LOCK, LINECLEAR

    dw $0600          ; Level 0600
    db 20, 1          ; 20G
    db 25, 8, 30, 24  ; ARE, DAS, LOCK, LINECLEAR

    dw $0700          ; Level 0700
    db 20, 1          ; 20G
    db 20, 8, 30, 24  ; ARE, DAS, LOCK, LINECLEAR

    dw $0900          ; Level 0900
    db 20, 1          ; 20G
    db 16, 6, 25, 16  ; ARE, DAS, LOCK, LINECLEAR

    dw $1100          ; Level 1100
    db 20, 1          ; 20G
    db 12, 6, 25, 16  ; ARE, DAS, LOCK, LINECLEAR

    dw $1200          ; Level 1200
    db 20, 1          ; 20G
    db 12, 6, 25, 8   ; ARE, DAS, LOCK, LINECLEAR

    dw $1300          ; Level 1300
    db 20, 1          ; 20G
    db 10, 6, 20, 7   ; ARE, DAS, LOCK, LINECLEAR

    dw $1400          ; Level 1400
    db 20, 1          ; 20G
    db 10, 6, 18, 6   ; ARE, DAS, LOCK, LINECLEAR

    dw $1500          ; Level 1500
    db 20, 1          ; 20G
    db 8, 4, 16, 5    ; ARE, DAS, LOCK, LINECLEAR

    dw $1600          ; Level 1600
    db 20, 1          ; 20G
    db 8, 4, 14, 4    ; ARE, DAS, LOCK, LINECLEAR

    dw $1700          ; Level 1700
    db 20, 1          ; 20G
    db 6, 4, 12, 3    ; ARE, DAS, LOCK, LINECLEAR

    dw $1800          ; Level 1800
    db 20, 1          ; 20G
    db 6, 4, 10, 3    ; ARE, DAS, LOCK, LINECLEAR

    dw $1900          ; Level 1900
    db 20, 1          ; 20G
    db 4, 4, 8, 3     ; ARE, DAS, LOCK, LINECLEAR

    dw $2000          ; Level 2000
    db 20, 1          ; 20G
    db 4, 3, 8, 3     ; ARE, DAS, LOCK, LINECLEAR

    dw $2500          ; Level 2500
    db 20, 1          ; 20G
    db 2, 1, 8, 2     ; ARE, DAS, LOCK, LINECLEAR

    dw $3000          ; Level 3000
    db 20, 1          ; 20G
    db 1, 1, 8, 1     ; ARE, DAS, LOCK, LINECLEAR

    dw $4000          ; Level 4000
    db 20, 1          ; 20G
    db 1, 1, 6, 1     ; ARE, DAS, LOCK, LINECLEAR

    dw $5000          ; Level 5000
    db 20, 1          ; 20G
    db 1, 1, 4, 1     ; ARE, DAS, LOCK, LINECLEAR

    dw $6666          ; Level 6666
    db 20, 1          ; 20G
    db 1, 1, 2, 1     ; ARE, DAS, LOCK, LINECLEAR

    dw $9999          ; Level 9999
    db 20, 1          ; 20G
    db 1, 1, 1, 1     ; ARE, DAS, LOCK, LINECLEAR

    dw $FFFF          ; End.


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


ENDC
