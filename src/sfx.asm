IF !DEF(SFX_ASM)
DEF SFX_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Sound Effect Data", ROM0
sSFXNextPieceI::
    db $02, $F0, $07, $F0, $01, $BF, $01, $BF, $02, $F0, $03, $AC, $04, $85, $06, $7F, $06, $7F, $07, $80, $08, $14, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $ED, $04, $85,
    db $06, $7F, $06, $7F, $07, $80, $08, $2D, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $27, $04, $86, $06, $7F, $06, $7F, $07, $80, $08, $44, $09, $87, $FF, $FF, $01, $BF,
    db $01, $BF, $02, $F0, $03, $AC, $04, $85, $06, $7F, $06, $7F, $07, $80, $08, $14, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $ED, $04, $85, $06, $7F, $06, $7F, $07, $80,
    db $08, $2D, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $27, $04, $86, $06, $7F, $06, $7F, $07, $80, $08, $44, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $5B,
    db $04, $86, $06, $7F, $06, $7F, $07, $80, $08, $59, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $AC, $04, $85, $06, $7F, $06, $7F, $07, $80, $08, $14, $09, $87, $FF, $FF,
    db $01, $BF, $01, $BF, $02, $F0, $03, $27, $04, $86, $06, $7F, $06, $7F, $07, $80, $08, $44, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $72, $04, $86, $06, $7F, $06, $7F,
    db $07, $80, $08, $62, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $D6, $04, $86, $06, $7F, $06, $7F, $07, $80, $08, $8A, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0,
    db $03, $14, $04, $87, $06, $7F, $06, $7F, $07, $80, $08, $A2, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $39, $04, $87, $06, $7F, $06, $7F, $07, $80, $08, $B1, $09, $87,
    db $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $4F, $04, $87, $06, $7F, $06, $7F, $07, $80, $08, $BA, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $F0, $03, $62, $04, $87, $06, $7F,
    db $06, $7F, $07, $80, $08, $C1, $09, $87, $FF, $FF, $07, $F0, $01, $BF, $01, $BF, $02, $D0, $03, $6B, $04, $87, $06, $BF, $06, $BF, $07, $D0, $08, $39, $09, $87, $FF, $FF, $01, $BF,
    db $01, $BF, $02, $D0, $03, $6B, $04, $87, $06, $BF, $06, $BF, $07, $D0, $08, $39, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $D0, $03, $6B, $04, $87, $06, $BF, $06, $BF, $07, $D0,
    db $08, $39, $09, $87, $FF, $FF, $FF, $FF, $FF, $FF, $01, $BF, $01, $BF, $02, $10, $03, $6B, $04, $87, $06, $BF, $06, $BF, $07, $10, $08, $39, $09, $87, $FF, $FF, $01, $BF, $01, $BF,
    db $02, $10, $03, $6B, $04, $87, $06, $BF, $06, $BF, $07, $10, $08, $39, $09, $87, $FF, $FF, $01, $BF, $01, $BF, $02, $10, $03, $6B, $04, $87, $06, $BF, $06, $BF, $07, $10, $08, $39,
    db $09, $87, $FF, $FF, $FF, $FF, $01, $BF, $01, $BF, $02, $00, $03, $6B, $04, $87, $06, $BF, $06, $BF, $07, $00, $08, $39, $09, $87, $FF, $FF, $FF, $FF, $02, $08, $03, $6B, $04, $87,
    db $07, $08, $08, $39, $09, $87, $FE


SECTION "SFX Variables", HRAM
hPlayhead:: ds 2


SECTION "SFX Functions", ROM0
SFXInit::
    ; Audio on, volume on, and enable all channels.
    ld a, $80
    ldh [rNR52], a
    ld a, $FF
    ldh [rNR51], a
    ld a, $77
    ldh [rNR50], a

    ;xor a, a
    ;ldh [hPlayhead], a
    ;ldh [hPlayhead+1], a

    ld a, LOW(sSFXNextPieceI)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXNextPieceI)
    ldh [hPlayhead+1], a
    ret


SFXPlay::
    ; Load the playhead position into HL.
    ldh a, [hPlayhead]
    ld l, a
    ldh a, [hPlayhead+1]
    ld h, a

    ; Nothing to do if it's a null ptr.
    or a, l
    ret z

    ; Otherwise, get the register to write to.
.getRegister
    ld a, [hl]
    inc hl

    ; If it's $FE, then we're done.
    cp a, $FE
    jr nz, :+
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ret

    ; If it's $FF, then we're done for this frame.
:   cp a, $FF
    jr z, .savePlayhead

    ; Otherwise, put the register in C.
    add a, $10
    ld c, a

    ; Get the value to write.
    ld a, [hl]
    inc hl

    ; Write it and loop.
    ldh [$ff00+c], a
    jr .getRegister

.savePlayhead
    ld a, l
    ldh [hPlayhead], a
    ld a, h
    ldh [hPlayhead+1], a
    ret


ENDC
