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
    jp IncrementLevel
    jp EventLoopPostHandler

    ; Start level down?
:   ldh a, [hDownState]
    cp a, 1
    jr nz, :+
    jp DecrementLevel
:   jp EventLoopPostHandler


DecrementLevel:
    ; Decrement
    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    ld bc, -12
    add hl, bc
    ld a, l
    ldh [hStartSpeed], a
    ld a, h
    ldh [hStartSpeed+1], a
    jp CheckLevelRange

IncrementLevel:
    ; Increment
    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    ld bc, 12
    add hl, bc
    ld a, l
    ldh [hStartSpeed], a
    ld a, h
    ldh [hStartSpeed+1], a
    jp CheckLevelRange


CheckLevelRange:
    ; At end?
    ld bc, sSpeedCurveEnd
    ldh a, [hStartSpeed]
    cp a, c
    jr nz, .notatend
    ldh a, [hStartSpeed+1]
    cp a, b
    jr nz, .notatend
    ld hl, sSpeedCurve
    ld a, l
    ldh [hStartSpeed], a
    ld a, h
    ldh [hStartSpeed+1], a

.notatend
    ld bc, sSpeedCurve-12
    ldh a, [hStartSpeed]
    cp a, c
    jr nz, .notatstart
    ldh a, [hStartSpeed+1]
    cp a, b
    jr nz, .notatstart
    ld hl, sSpeedCurveEnd-12
    ld a, l
    ldh [hStartSpeed], a
    ld a, h
    ldh [hStartSpeed+1], a

.notatstart
    jp EventLoopPostHandler


TitleVBlankHandler::
    ; Draw level.
    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    ld a, [hl]
    swap a
    and a, $0F
    ld b, a
    ld a, TILE_0
    add a, b
    ld hl, TITLE_LEVEL+2
    ld [hl], a

    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    ld a, [hl]
    and a, $0F
    ld b, a
    ld a, TILE_0
    add a, b
    ld hl, TITLE_LEVEL+3
    ld [hl], a

    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    inc hl
    ld a, [hl]
    swap a
    and a, $0F
    ld b, a
    ld a, TILE_0
    add a, b
    ld hl, TITLE_LEVEL+0
    ld [hl], a

    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    inc hl
    ld a, [hl]
    and a, $0F
    ld b, a
    ld a, TILE_0
    add a, b
    ld hl, TITLE_LEVEL+1
    ld [hl], a

    ; Draw A/B
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
