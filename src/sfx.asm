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


IF !DEF(SFX_ASM)
DEF SFX_ASM EQU 1


DEF REG_NR10_CH1_SWEEP EQU $10
DEF REG_NR11_CH1_LENDT EQU $11
DEF REG_NR12_CH1_VOLEV EQU $12
DEF REG_NR13_CH1_FRQLO EQU $13
DEF REG_NR14_CH1_FRQHI EQU $14
DEF REG_NR21_CH2_LENDT EQU $16
DEF REG_NR22_CH2_VOLEV EQU $17
DEF REG_NR23_CH2_FRQLO EQU $18
DEF REG_NR24_CH2_FRQHI EQU $19
DEF REG_NR30_CH3_DACEN EQU $1A
DEF REG_NR31_CH3_LENGT EQU $1B
DEF REG_NR32_CH3_VOLUM EQU $1C
DEF REG_NR33_CH3_FRQLO EQU $1D
DEF REG_NR34_CH3_FRQHI EQU $1E
DEF REG_NR41_CH4_LENGT EQU $20
DEF REG_NR42_CH4_VOLEV EQU $21
DEF REG_NR43_CH4_FQRND EQU $22
DEF REG_NR44_CH4_CNTRL EQU $23
DEF REG_NR50_MVOLVINPN EQU $24
DEF REG_NR51_MASTERPAN EQU $25
DEF REG_NR52_MASTERCTL EQU $26
DEF REG_WAVE_PATTERN_0 EQU $30
DEF REG_WAVE_PATTERN_1 EQU $31
DEF REG_WAVE_PATTERN_2 EQU $32
DEF REG_WAVE_PATTERN_3 EQU $33
DEF REG_WAVE_PATTERN_4 EQU $34
DEF REG_WAVE_PATTERN_5 EQU $35
DEF REG_WAVE_PATTERN_6 EQU $36
DEF REG_WAVE_PATTERN_7 EQU $37
DEF REG_WAVE_PATTERN_8 EQU $38
DEF REG_WAVE_PATTERN_9 EQU $39
DEF REG_WAVE_PATTERN_A EQU $3A
DEF REG_WAVE_PATTERN_B EQU $3B
DEF REG_WAVE_PATTERN_C EQU $3C
DEF REG_WAVE_PATTERN_D EQU $3D
DEF REG_WAVE_PATTERN_E EQU $3E
DEF REG_WAVE_PATTERN_F EQU $3F


INCLUDE "globals.asm"
INCLUDE "res/sfx_data.inc"
INCLUDE "res/music_data.inc"


SECTION "High SFX Variables", HRAM
hPlayhead:: ds 2
hPlayQueue:: ds 4
hNoisePlayhead:: ds 2


SECTION "SFX Functions", ROM0
SFXInit::
    ; Audio on, volume on, and enable all channels.
    ld a, $80
    ldh [rNR52], a
    ld a, $FF
    ldh [rNR51], a
    ld a, $77
    ldh [rNR50], a

    ld a, $FF
    ldh [hPlayQueue], a
    ldh [hPlayQueue+1], a
    ldh [hPlayQueue+2], a
    ldh [hPlayQueue+3], a
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ldh [hNoisePlayhead], a
    ldh [hNoisePlayhead+1], a
    ret


SFXPopQueue:
    ; Pop the head of the queue into A, the tail of the queue will be set to $FF.
    ldh a, [hPlayQueue]
    ld b, a
    ldh a, [hPlayQueue+1]
    ldh [hPlayQueue], a
    ldh a, [hPlayQueue+2]
    ldh [hPlayQueue+1], a
    ldh a, [hPlayQueue+3]
    ldh [hPlayQueue+2], a
    ld a, $FF
    ldh [hPlayQueue+3], a
    ld a, b
    ret


SFXPushQueue:
    ; Push A onto the tail of the queue, the head of the queue will be pushed off.
    ld b, a
    ldh a, [hPlayQueue+1]
    ldh [hPlayQueue], a
    ldh a, [hPlayQueue+2]
    ldh [hPlayQueue+1], a
    ldh a, [hPlayQueue+3]
    ldh [hPlayQueue+2], a
    ld a, b
    ldh [hPlayQueue+3], a
    ret


SFXProcessQueue:
    ; Clear the playhead.
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a

    ldh a, [hPlayQueue]
    cp a, MUSIC_MENU
    jr nz, :+
    call SFXEnqueue
    ret


    ; Try 4 times to pop a sound effect off the queue.
:   call SFXPopQueue
    cp a, $FF
    jr nz, :+
    call SFXPopQueue
    cp a, $FF
    jr nz, :+
    call SFXPopQueue
    cp a, $FF
    jr nz, :+
    call SFXPopQueue
    cp a, $FF
    ret z

    ; If we got a valid sound effect, then play it.
    call SFXEnqueue
    ret


SFXTriggerNoise::
    cp a, SFX_LINE_CLEAR
    jr nz, :+
    ld a, LOW(sSFXLineClear)
    ldh [hNoisePlayhead], a
    ld a, HIGH(sSFXLineClear)
    ldh [hNoisePlayhead+1], a
    ret

:   cp a, SFX_LAND
    jr nz, :+
    ld a, LOW(sSFXLand)
    ldh [hNoisePlayhead], a
    ld a, HIGH(sSFXLand)
    ldh [hNoisePlayhead+1], a
    ret

:   cp a, SFX_LOCK
    ret nz
    ld a, LOW(sSFXLock)
    ldh [hNoisePlayhead], a
    ld a, HIGH(sSFXLock)
    ldh [hNoisePlayhead+1], a
    ret


    ; Attempt to play the sound effect in A. Will enqueue the sound effect if the play routine is currently busy.
SFXEnqueue::
    ; If the playhead isn't null, then we're already playing something.
    ld b, a
    ldh a, [hPlayhead]
    ld l, a
    ldh a, [hPlayhead+1]
    ld h, a
    or a, l
    jr z, :+
    ld a, b
    call SFXPushQueue
    ret

    ; Menu music
:   ld a, b
    cp a, MUSIC_MENU
    jr nz, :+
    ldh [hPlayQueue], a
    ld a, LOW(sMusicMenu)
    ldh [hPlayhead], a
    ld a, HIGH(sMusicMenu)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret


    ; Piece jingles.
:   ld a, b
    cp a, PIECE_I
    jr nz, :+
    ld a, LOW(sSFXPieceI)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceI)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_I | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSI)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSI)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_S
    jr nz, :+
    ld a, LOW(sSFXPieceS)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceS)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_S | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSS)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSS)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_Z
    jr nz, :+
    ld a, LOW(sSFXPieceZ)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceZ)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_Z | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSZ)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSZ)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_J
    jr nz, :+
    ld a, LOW(sSFXPieceJ)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceJ)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_J | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSJ)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSJ)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_L
    jr nz, :+
    ld a, LOW(sSFXPieceL)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceL)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_L | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSL)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSL)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_O
    jr nz, :+
    ld a, LOW(sSFXPieceO)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceO)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_O | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSO)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSO)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_T
    jr nz, :+
    ld a, LOW(sSFXPieceT)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceT)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   ld a, b
    cp a, PIECE_T | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRST)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRST)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret


    ; IRS
:   cp a, SFX_IHS
    jr nz, :+
    ld a, LOW(sSFXIHS)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXIHS)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   cp a, SFX_IHS | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXIHSIRS)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXIHSIRS)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret


    ; Leveling
:   cp a, SFX_LEVELLOCK
    jr nz, :+
    ld a, LOW(sSFXLevelLock)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXLevelLock)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   cp a, SFX_LEVELUP
    jr nz, :+
    ld a, LOW(sSFXLevelUp)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXLevelUp)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret


    ; Other
:   cp a, SFX_RANKUP
    jr nz, :+
    ld a, LOW(sSFXRankUp)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXRankUp)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret

:   cp a, SFX_READYGO
    ret nz
    ld a, LOW(sSFXReadyGo)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXReadyGo)
    ldh [hPlayhead+1], a
    call SFXPlay
    ret


SFXKill::
    ; Kill all sound without pops.
    ld a, %00111111
    ldh [rNR11], a
    ldh [rNR21], a
    ld a, $FF
    ldh [rNR31], a
    ;ldh [rNR41], a
    ld a, %01000000
    ldh [rNR14], a
    ldh [rNR24], a
    ldh [rNR34], a
    ;ldh [rNR44], a

    ; Clear the queue.
    ld a, $FF
    ldh [hPlayQueue], a
    ldh [hPlayQueue+1], a
    ldh [hPlayQueue+2], a
    ldh [hPlayQueue+3], a
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ret


SFXPlayNoise::
    ; Get the noise playhead.
    ldh a, [hNoisePlayhead]
    ld l, a
    ldh a, [hNoisePlayhead+1]
    ld h, a
    or a, l

    ; Bail if it's null
    ret z

    ld b, BANK("SFX Data")
    rst RSTSwitchBank

    ; Get the register to write to
.noisereg
    ld a, [hl]
    inc hl

    ; If it's $FE, then we're done.
    cp a, $FE
    jr nz, :+
    rst RSTRestoreBank
    xor a, a
    ldh [hNoisePlayhead], a
    ldh [hNoisePlayhead+1], a
    ret

    ; If it's $FF, then we're done for this frame.
:   cp a, $FF
    jr z, .savenoiseplayhead

    ; Otherwise, put the register in C.
    ld c, a

    ; Get the value to write.
    ld a, [hl]
    inc hl

    ; Write it and loop.
    ldh [$ff00+c], a
    jr .noisereg

    ; Save the playhead position.
.savenoiseplayhead
    ld a, l
    ldh [hNoisePlayhead], a
    ld a, h
    ldh [hNoisePlayhead+1], a
    rst RSTRestoreBank
    ret


    ; This play routine must be called every frame.
SFXPlay::
    ; Bank to correct bank.
    ldh a, [hPlayQueue]
    cp a, MUSIC_MENU
    jr nz, :+
    ld b, BANK("Music Data")
    rst RSTSwitchBank
    jr .play
:   ld b, BANK("SFX Data")
    rst RSTSwitchBank

    ; Load the playhead position into HL.
.play
    ldh a, [hPlayhead]
    ld l, a
    ldh a, [hPlayhead+1]
    ld h, a

    ; Nothing to do if it's a null ptr.
    or a, l
    jr nz, .getRegister
    rst RSTRestoreBank
    ret

    ; Otherwise, get the register to write to.
.getRegister
    ld a, [hl]
    inc hl

    ; If it's $FE, then we're done. Check if there's more for us in the queue.
    cp a, $FE
    jr nz, :+
    rst RSTRestoreBank
    call SFXProcessQueue
    ret

    ; If it's $FF, then we're done for this frame.
:   cp a, $FF
    jr z, .savePlayhead

    ; Otherwise, put the register in C.
    ld c, a

    ; Get the value to write.
    ld a, [hl]
    inc hl

    ; Write it and loop.
    ldh [$ff00+c], a
    jr .getRegister

    ; Save the playhead position.
.savePlayhead
    ld a, l
    ldh [hPlayhead], a
    ld a, h
    ldh [hPlayhead+1], a
    rst RSTRestoreBank
    ret


ENDC
