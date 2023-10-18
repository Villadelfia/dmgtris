IF !DEF(MAIN_ASM)
DEF MAIN_ASM EQU 1


INCLUDE "globals.asm"
INCLUDE "res/tiles.inc"
INCLUDE "res/gameplay_map.inc"


SECTION "Globals", WRAM0
wStateEventHandler:: ds 2
wStateVBlankHandler:: ds 2


SECTION "Stack", WRAM0
wStack:
    ds STACK_SIZE
wStackEnd:


SECTION "Code Entry Point", ROM0
Main::
    ; Turn off LCD during initialization.
    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Stack
    ld sp, wStackEnd

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

    ; Clear OAM.
    call ClearOAM
    call CopyOAMHandler

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
    call TimeInit
    call IntrInit
    call InputInit
    call ScoreInit
    call LevelInit
    call FieldInit
    call SFXInit

    ; Set up the interrupt handlers.
    call InitializeLCDCInterrupt

    ; Switch to gameplay state.
    call SwitchToGameplay


EventLoop::
    ; Play the sound effect, if any.
    call SFXPlay

    ; Wrangle inputs and timers at the start of every frame.
    call GetInput
    call HandleTimers

    ; Call the current state's event handler.
    ld a, [wStateEventHandler]
    ld l, a
    ld a, [wStateEventHandler + 1]
    ld h, a
    jp hl
EventLoopPostHandler::

    ; Wait for vblank and update OAM.
    wait_vblank
    call hOAMDMA

    ; Call the current state's vblank handler.
    ld a, [wStateVBlankHandler]
    ld l, a
    ld a, [wStateVBlankHandler + 1]
    ld h, a
    jp hl
EventLoopPostVBlankHandler::

    ; Jump back to the start of the event loop.
    jr EventLoop


ENDC
