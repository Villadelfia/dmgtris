INCLUDE "globals.asm"
INCLUDE "memcpy.asm"
INCLUDE "hardwarectl.asm"
INCLUDE "interrupts.asm"
INCLUDE "res/tiles.inc"
INCLUDE "res/gameplay_map.inc"

SECTION "Code Entry Point", ROM0
MainEntryPoint::
    ; Turn off LCD during initialization.
    call DisableLCD
    call DisableAudio

    ; We use a single set of tiles for the entire game, so we copy it at the start.
    ld de, Tiles
    ld hl, $9000
    ld bc, TilesEnd - Tiles
    call UnsafeMemCopy

    ; The tilemap is just for testing for now.
    ld de, GameplayTilemap
    ld hl, $9800
    ld bc, GameplayTilemapEnd - GameplayTilemap
    call UnsafeMemCopy

    ld a, PALETTE_REGULAR
    call SetBGPalette

    call InitializeVariables
    call InitializeLCDCInterrupt

    ; And turn it back on before we start.
    call EnableLCD

    ; Make sure the first game loop starts just like all the future ones.
    wait_vblank
    wait_vblank_end


GameLoop::
    call GetInput
    call HandleTimers

    ld bc, 20*10
    ld hl, wField
:   ld a, [wFill]
    ld [hl+], a
    dec bc
    ld a, b
    or a, c
    jp nz, :-

    ld a, [wFill]
    inc a
    ld [wFill], a

    ; Handle gameplay here
    ; TODO




GameLoopEnd:
    wait_vblank
    call BlitField
    jp GameLoop



; *****************************************************************************
; *                                                                           *
; *  Functions                                                                *
; *                                                                           *
; *****************************************************************************
SECTION "Functions", ROM0
InitializeVariables:
    xor a, a
    ld [wLCDCCtr], a
    ret


BlitField:
    ; The first 16 rows can be blitted without checking for vram access.
    ld de, wField
    DEF row = 0
    REPT 16
        ld hl, FIELD_ROW_1+(32*row)
        REPT 10
            ld a, [de]
            ld [hl+], a
            inc de
        ENDR
        DEF row += 1
    ENDR

    ; The last 4 rows need some care.
    REPT 4
        ld hl, FIELD_ROW_1+(32*row)
        REPT 2
:           ldh a, [rSTAT]
            and STATF_LCD
            cp STATF_HBL
            jr z, :-
:           ldh a, [rSTAT]
            and STATF_LCD
            cp STATF_HBL
            jr nz, :-
            REPT 5
                ld a, [de]
                ld [hl+], a
                inc de
            ENDR
        ENDR
        DEF row += 1
    ENDR
    ret

GetInput:
    ret

HandleTimers:
    ld a, [wEvenFrame]
    inc a
    and 1
    ld [wEvenFrame], a
    ret
