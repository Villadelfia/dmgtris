IF !DEF(MAIN_ASM)
DEF MAIN_ASM EQU 1


INCLUDE "globals.asm"
INCLUDE "res/tiles.inc"
INCLUDE "res/gameplay_map.inc"


SECTION "Globals", WRAM0
wStateEventHandler:: ds 2
wStateVBlankHandler:: ds 2


SECTION "Stack", WRAM0
wStack::
    ds STACK_SIZE
wStackEnd::


SECTION "Code Entry Point", ROM0
Main::
    ; Turn off LCD during initialization.
    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Set up stack
    ld sp, wStackEnd

    ; We use a single set of tiles for the entire game, so we copy it at the start.
    ld de, Tiles
    ld hl, _VRAM
    ld bc, TilesEnd - Tiles
    call UnsafeMemCopy

    ; Make sure both sprites and bg use the same tile data.
    ldh a, [rLCDC]
    or LCDCF_BLK01
    ldh [rLCDC], a

    ; Clear OAM.
    call ClearOAM
    call CopyOAMHandler

    ; Zero out the ram where needed.
    call TimeInit
    call IntrInit
    call InputInit
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

    ; Wait for vblank.
:   ldh a, [rLY]
    cp a, 144
    jr nz, :-

    ; Do OAM DMA.
    call hOAMDMA

    ; Call the current state's vblank handler.
    ld a, [wStateVBlankHandler]
    ld l, a
    ld a, [wStateVBlankHandler + 1]
    ld h, a
    jp hl

    ; The VBlank Handler is expected to end with jp EventLoop.


ENDC
