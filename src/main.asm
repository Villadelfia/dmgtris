INCLUDE "globals.asm"
INCLUDE "memory.asm"
INCLUDE "interrupts.asm"
INCLUDE "sprites.asm"
INCLUDE "rng.asm"
INCLUDE "input.asm"
INCLUDE "time.asm"
INCLUDE "score.asm"
INCLUDE "level.asm"
INCLUDE "field.asm"
INCLUDE "res/tiles.inc"
INCLUDE "res/gameplay_map.inc"

SECTION "Code Entry Point", ROM0
Main::
    ; Turn off LCD during initialization.
    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Save some power and turn off the audio.
    xor a, a
    ldh [rNR52], a

    ; We use a single set of tiles for the entire game, so we copy it at the start.
    ld de, Tiles
    ld hl, _VRAM
    ld bc, TilesEnd - Tiles
    call UnsafeMemCopy

    ; Also to the second bank of tile data.
    ld de, Tiles
    ld hl, _VRAM + $800
    ld bc, TilesEnd - Tiles
    call UnsafeMemCopy

    ; Make sure both sprites and bg use the same tile data.
    ldh a, [rLCDC]
    or LCDCF_BLK01
    ldh [rLCDC], a

    ; The tilemap is just for testing for now.
    ld de, GameplayTilemap
    ld hl, $9800
    ld bc, GameplayTilemapEnd - GameplayTilemap
    call UnsafeMemCopy

    ; Clear OAM.
    call ClearOAM
    call CopyOAMHandler
    call SetNumberSpritePositions

    ; Set up the palettes.
    ld a, PALETTE_REGULAR
    set_bg_palette
    set_obj0_palette
    ld a, PALETTE_LIGHTER_1
    set_obj1_palette

    ; Get the timer going. It's used for RNG.
    xor a, a
    ldh [rTMA], a
    ld a, TACF_262KHZ | TACF_START

    ; Zero out the ram where needed.
    call InitializeVariables

    ; Set up the interrupt handlers.
    call InitializeLCDCInterrupt

    ; And turn the LCD back on before we start.
    ldh a, [rLCDC]
    or LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh [rLCDC], a

    ; Make sure the first game loop starts just like all the future ones.
    wait_vblank
    wait_vblank_end

    ; TEMP: Set up the game.
    call StartNewGame


GameLoop::
    call GetInput
    call HandleTimers

    ; Handle gameplay here
    ; TODO

    ldh a, [hCtr]
    inc a
    and a, $1F
    ldh [hCtr], a

    jr nz, :+
    call GetNextPiece

:   ld a, [wNextPiece]
    call ApplyNext

    ld a, [wNextPiece]
    call ApplyHold

    ld hl, wSPRScore1
    ld de, wScore
    call ApplyNumbers

    ld hl, wSPRCLevel1
    ld de, wCLevel
    call ApplyNumbers

    ld hl, wSPRNLevel1
    ld de, wNLevel
    call ApplyNumbers

GameLoopEnd:
    wait_vblank
    call hOAMDMA
    call BlitField
    jp GameLoop



; *****************************************************************************
; *                                                                           *
; *  Functions                                                                *
; *                                                                           *
; *****************************************************************************
SECTION "Functions", ROM0
InitializeVariables:
    call TimeInit
    call IntrInit
    call InputInit
    call ScoreInit
    call LevelInit
    call FieldInit
    ret
