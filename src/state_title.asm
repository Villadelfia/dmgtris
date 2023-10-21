IF !DEF(STATE_TITLE_ASM)
DEF STATE_TITLE_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Title Functions", ROM0
SwitchToTitle::
    ; Turn the screen off if it's on.
    ldh a, [rLCDC]
    and LCDCF_ON
    jr z, :+ ; Screen is already off.
    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Load the gameplay tilemap.
:   ld de, TitleScreenTilemap
    ld hl, $9800
    ld bc, TitleScreenTilemapEnd - TitleScreenTilemap
    call UnsafeMemCopy

    ; Clear OAM.
    call ClearOAM
    call SetNumberSpritePositions

    ; Set up the palettes.
    ld a, PALETTE_INVERTED
    set_bg_palette
    set_obj0_palette
    set_obj1_palette

    ; Install the event loop handlers.
    ld a, 0
    ldh [hGameState], a

    ; And turn the LCD back on before we start.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BLK01
    ldh [rLCDC], a

    ; Make sure the first game loop starts just like all the future ones.
    wait_vblank
    wait_vblank_end
    ret


TitleEventLoopHandler::
    ; Start game?
    ldh a, [hStartState]
    ld b, a
    ldh a, [hAState]
    ld c, a
    ldh a, [hBState]
    or a, b
    or a, c
    cp a, 1
    jr nz, :+
    call SwitchToGameplay
    jp EventLoopPostHandler

    ; Toggle A/B?
:   ldh a, [hLeftState]
    ld b, a
    ldh a, [hRightState]
    or a, b
    cp a, 1
    jr nz, :+
    ldh a, [hSwapAB]
    cpl
    ldh [hSwapAB], a
    jp EventLoopPostHandler

    ; Start level up?
:   ldh a, [hUpState]
    cp a, 1
    jr nz, :+
    ; TODO
    jp EventLoopPostHandler

    ; Start level down?
:   ldh a, [hDownState]
    cp a, 1
    jr nz, :+
    ; TODO
:    jp EventLoopPostHandler


TitleVBlankHandler::
    ldh a, [hSwapAB]
    cp a, 0
    jr nz, :+
    ld hl, TITLE_A
    ld a, TILE_A
    ld [hl+], a
    inc hl
    inc a
    ld [hl], a
    wait_vblank_end
    jp EventLoop

:   ld hl, TITLE_A
    ld a, TILE_B
    ld [hl+], a
    inc hl
    dec a
    ld [hl], a
    wait_vblank_end
    jp EventLoop


ENDC
