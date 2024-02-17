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


INCLUDE "globals.asm"
INCLUDE "res/sfx_data.inc"
INCLUDE "res/music_data_0.inc"
INCLUDE "res/music_data_1.inc"
INCLUDE "res/music_data_2.inc"
INCLUDE "res/music_data_3.inc"


SECTION "High SFX Variables", HRAM
hPlayhead:: ds 2
hCurrentlyPlaying:: ds 1
hPlayQueue:: ds 4
hNoisePlayhead:: ds 2


SECTION "SFX Variables", WRAM0
wCurrentBank:: ds 1
wBankSwitchTarget:: ds 1
wPlayHeadTarget:: ds 2
wLoadedAinB:: ds 1


SECTION "SFX Functions", ROM0
    ; Audio on, volume on, and enable all channels.
    ; Zeroes out all playheads and the queue.
SFXInit::
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
    ldh [hCurrentlyPlaying], a
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ldh [hNoisePlayhead], a
    ldh [hNoisePlayhead+1], a
    ld [wCurrentBank], a
    ld [wBankSwitchTarget], a
    ld [wPlayHeadTarget], a
    ld [wPlayHeadTarget+1], a
    ret


    ; Pop the head of the queue into A, the tail of the queue will be set to $FF.
SFXPopQueue:
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


    ; Push A onto the tail of the queue, the head of the queue will be pushed off.
SFXPushQueue:
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


    ; Process the queue, if there's more to play, it will do so.
SFXProcessQueue:
    ; Clear the playhead.
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ld a, $FF
    ldh [hCurrentlyPlaying], a

    ; Music will just repeat.
    ldh a, [hPlayQueue]
    cp a, MUSIC_MENU
    jr nz, :+
    jr SFXEnqueue

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
:   jr SFXEnqueue


    ; Noise effects use their own playhead that can play at the same time as the normal queue.
SFXTriggerNoise::
    cp a, SFX_LOCK
    jr nz, :+
    ld a, LOW(sSFXLock)
    ldh [hNoisePlayhead], a
    ld a, HIGH(sSFXLock)
    ldh [hNoisePlayhead+1], a
    ret

    ; Other noise stops when the staff roll is going.
:   ld b, a
    ldh a, [hCurrentlyPlaying]
    cp a, MUSIC_ROLL
    ret z
    ld a, b

    cp a, SFX_LINE_CLEAR
    jr nz, :+
    ld a, LOW(sSFXLineClear)
    ldh [hNoisePlayhead], a
    ld a, HIGH(sSFXLineClear)
    ldh [hNoisePlayhead+1], a
    ret

:   cp a, SFX_LAND
    ret nz
    ld a, LOW(sSFXLand)
    ldh [hNoisePlayhead], a
    ld a, HIGH(sSFXLand)
    ldh [hNoisePlayhead+1], a
    ret


    ; Attempt to play the sound effect in A. Will enqueue the sound effect if the play routine is currently busy.
SFXEnqueue::
    ; If we're playing the grade up sound, or the ROLL music, it has absolute prio.
    ld b, a
    ldh a, [hCurrentlyPlaying]
    cp a, SFX_RANKUP
    ret z
    cp a, SFX_RANKGM
    ret z
    cp a, MUSIC_ROLL
    ret z

    ; If the playhead isn't null, then we're already playing something.
    ldh a, [hPlayhead]
    ld l, a
    ldh a, [hPlayhead+1]
    ld h, a
    or a, l
    jr z, .findsfx
    ld a, b
    jp SFXPushQueue

.findsfx
    ld a, b
    ldh [hCurrentlyPlaying], a
    ld a, BANK_SFX
    ld [wCurrentBank], a

    ; Menu music
    ld a, b
    cp a, MUSIC_MENU
    jr nz, :+
    ldh [hPlayQueue], a
    ld a, LOW(sMusicMenu)
    ldh [hPlayhead], a
    ld a, HIGH(sMusicMenu)
    ldh [hPlayhead+1], a
    ld a, BANK_MUSIC_0
    ld [wCurrentBank], a
    jp SFXPlay

    ; Piece jingles.
:   ld a, [wRotModeState]
    cp a, ROT_MODE_BARS ; Are we using the Better Arika Rotation System?
    ld a, b
    jr nz, .dont ; No, don't convert the jingles
.convertpiece
    ; Is the jingle combined with the IRS sound?
    bit 7, a
    jr z, .noirs
.yesirs
    cp a, 87 ; Is the SFX to play in the IRS piece range?
    jr nc, .dont ; No, it's not a piece sfx
    ld d, a
    and a, $80
    ld c, a
    ld a, d
    and a, $7f
    cp a, 7 ; Is the SFX to play in the piece range?
    jr nc, .dont ; No, it's not a piece sfx
    ld hl, sSEGAtoBARSpiececonversion ; If we're using BARS, the piece jingles will be wrong, so we have to convert the piece ids
    ld d, 0
    ld e, a
    add hl, de
    ld a, [hl]
    or a, c
    ld c, b
    ld b, a ; (Insert Troll Face)
    ld a, 1
    ld [wLoadedAinB], a
    ld a, b
    jr .did
.noirs
    cp a, 7 ; Is the SFX to play in the piece range?
    jr nc, .dont ; No, it's not a piece sfx
    ld hl, sSEGAtoBARSpiececonversion ; If we're using BARS, the piece jingles will be wrong, so we have to convert the piece ids
    ld d, 0
    ld e, a
    add hl, de
    ld a, [hl]
    ld c, b
    ld b, a ; (Insert Troll Face)
    ld a, 1
    ld [wLoadedAinB], a
    ld a, b
    jr .did
.dont
    ld b, a
    ld a, 0
    ld [wLoadedAinB], a
    ld a, b
.did
    cp a, PIECE_I
    jr nz, :+
    ld a, LOW(sSFXPieceI)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceI)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_I | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSI)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSI)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_S
    jr nz, :+
    ld a, LOW(sSFXPieceS)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceS)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_S | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSS)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSS)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_Z
    jr nz, :+
    ld a, LOW(sSFXPieceZ)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceZ)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_Z | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSZ)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSZ)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_J
    jr nz, :+
    ld a, LOW(sSFXPieceJ)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceJ)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_J | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSJ)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSJ)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_L
    jr nz, :+
    ld a, LOW(sSFXPieceL)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceL)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_L | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSL)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSL)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_O
    jr nz, :+
    ld a, LOW(sSFXPieceO)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceO)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_O | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRSO)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRSO)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_T
    jr nz, :+
    ld a, LOW(sSFXPieceT)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceT)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   ld a, b
    cp a, PIECE_T | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXPieceIRST)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXPieceIRST)
    ldh [hPlayhead+1], a
    jp SFXPlay

    ; IHS
:   ld b, a
    ld a, [wRotModeState]
    cp a, ROT_MODE_BARS ; Are we using the Better Arika Rotation System?
    jr nz, .no ; No
.yes
    ld a, b
    ; We previously loaded the converted piece jingle into B, but we saved the original value in C.
    ld b, a
    ld a, [wLoadedAinB] ; Or did we?
    cp a, 1
    jr nz, .no ; No, we didn't
    ld b, c; Restore it
.no
    ld a, b
    cp a, SFX_IHS
    jr nz, :+
    ld a, LOW(sSFXIHS)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXIHS)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   cp a, SFX_IHS | SFX_IRS
    jr nz, :+
    ld a, LOW(sSFXIHSIRS)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXIHSIRS)
    ldh [hPlayhead+1], a
    jp SFXPlay

    ; Leveling
:   cp a, SFX_LEVELLOCK
    jr nz, :+
    ld a, LOW(sSFXLevelLock)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXLevelLock)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   cp a, SFX_LEVELUP
    jr nz, :+
    ld a, LOW(sSFXLevelUp)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXLevelUp)
    ldh [hPlayhead+1], a
    jp SFXPlay

    ; Other
:   cp a, SFX_RANKUP
    jr nz, :+
    ld a, LOW(sSFXRankUp)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXRankUp)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   cp a, SFX_RANKGM
    jr nz, :+
    ld a, LOW(sSFXRankGM)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXRankGM)
    ldh [hPlayhead+1], a
    jp SFXPlay

:   cp a, SFX_READYGO
    ret nz
    ld a, LOW(sSFXReadyGo)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXReadyGo)
    ldh [hPlayhead+1], a
    jr SFXPlay

    ; Kill the non-noise sound and clear the queue.
SFXKill::
    ; If we're playing the grade up sound, it has absolute prio and cannot be killed.
    ld b, a
    ldh a, [hCurrentlyPlaying]
    cp a, SFX_RANKUP
    ret z
    cp a, SFX_RANKGM
    ret z
    cp a, SFX_LEVELLOCK
    ret z
    cp a, SFX_LEVELUP
    ret z
    cp a, MUSIC_ROLL
    ret z

    ; Kill all sound without pops.
    ld a, %00111111
    ldh [rNR11], a
    ldh [rNR21], a
    ld a, $FF
    ldh [rNR31], a
    ld a, %01000000
    ldh [rNR14], a
    ldh [rNR24], a
    ldh [rNR34], a

    ; Clear the queue.
    ld a, $FF
    ldh [hPlayQueue], a
    ldh [hPlayQueue+1], a
    ldh [hPlayQueue+2], a
    ldh [hPlayQueue+3], a
    ldh [hCurrentlyPlaying], a
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ret


    ; Play routine for the noise channel.
    ; Must be called every frame.
SFXPlayNoise::
    ; Get the noise playhead.
    ldh a, [hNoisePlayhead]
    ld l, a
    ldh a, [hNoisePlayhead+1]
    ld h, a
    or a, l

    ; Bail if it's null
    ret z

    ; Bank to sound effects.
    ld b, BANK_SFX
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
    jp RSTRestoreBank


    ; Play routine for the regular sfx channels.
    ; Must be called every frame.
SFXPlay::
    ; Bank to correct bank.
    ld a, [wCurrentBank]
    ld b, a
    rst RSTSwitchBank

    ; Load the playhead position into HL.
.play
    ldh a, [hPlayhead]
    ld l, a
    ldh a, [hPlayhead+1]
    ld h, a

    ; Nothing to do if it's a null ptr.
    or a, l
    jp z, RSTRestoreBank

    ; Otherwise, get the register to write to.
.getRegister
    ld a, [hl+]

    ; If it's END_OF_SONG (or END_OF_SFX), then we're done. Check if there's more for us in the queue.
.checkEndOfSong
    cp a, END_OF_SONG
    jr nz, .checkEndOfSample
    rst RSTRestoreBank
    ldh a, [hCurrentlyPlaying]
    cp a, MUSIC_ROLL
    jp nz, SFXProcessQueue
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ret

    ; If it's END_OF_SAMPLE, then we're done for this frame.
.checkEndOfSample
    cp a, END_OF_SAMPLE
    jr z, .savePlayhead

    ; If it's CHANGE_BANK, ready a bank switch.
.checkChangeBank
    cp a, CHANGE_BANK
    jr nz, .checkChangePlayHead

    ; What bank?
    ld a, [hl+]
    ld [wBankSwitchTarget], a

    ; Loop
    jr .getRegister

    ; If it's CHANGE_PLAYHEAD, change the playhead and apply the bank switch.
.checkChangePlayHead
    cp a, CHANGE_PLAYHEAD
    jr nz, .applyRegister

    ; Get the new playhead position.
    ld a, [hl+]
    ldh [hPlayhead], a
    ld a, [hl]
    ldh [hPlayhead+1], a

    ; Apply the bank switch.
    ld a, [wBankSwitchTarget]
    ld [wCurrentBank], a

    ; Make sure we don't overflow the bank stack, and loop.
    rst RSTRestoreBank
    jr SFXPlay

    ; Otherwise, put the register in C.
.applyRegister
    ld c, a

    ; Get the value to write.
    ld a, [hl+]

    ; Write it and loop.
    ldh [$ff00+c], a
    jr .getRegister

    ; Save the playhead position.
.savePlayhead
    ld a, l
    ldh [hPlayhead], a
    ld a, h
    ldh [hPlayhead+1], a
    jp RSTRestoreBank


    ; The final challenge song overrides everything and it also causes the sound engine to ignore everything else.
SFXGoRoll::
    ; It kills all sound.
    ld a, %00111111
    ldh [rNR11], a
    ldh [rNR21], a
    ld a, $FF
    ldh [rNR31], a
    ldh [rNR41], a
    ld a, %01000000
    ldh [rNR14], a
    ldh [rNR24], a
    ldh [rNR34], a
    ldh [rNR44], a

    ; Clears the queue.
    ld a, $FF
    ldh [hPlayQueue], a
    ldh [hPlayQueue+1], a
    ldh [hPlayQueue+2], a
    ldh [hPlayQueue+3], a

    ; And all playheads.
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ldh [hNoisePlayhead], a
    ldh [hNoisePlayhead+1], a

    ; Sets the playhead to the start of the music.
    ld a, MUSIC_ROLL
    ldh [hCurrentlyPlaying], a
    ld a, LOW(sMusicRoll1)
    ldh [hPlayhead], a
    ld a, HIGH(sMusicRoll1)
    ldh [hPlayhead+1], a

    ; Makes sure to start in the correct bank.
    ld a, BANK_MUSIC_1
    ld [wCurrentBank], a

    ; And begins playing.
    jp SFXPlay


    ; When the game ends, we kill all the sound unconditionaly.
    ; If we're GM, also play the GM jingle.
SFXEndOfGame::
    ; Reset everything.
    ld a, $FF
    ldh [hPlayQueue], a
    ldh [hPlayQueue+1], a
    ldh [hPlayQueue+2], a
    ldh [hPlayQueue+3], a
    ldh [hCurrentlyPlaying], a
    xor a, a
    ldh [hPlayhead], a
    ldh [hPlayhead+1], a
    ldh [hNoisePlayhead], a
    ldh [hNoisePlayhead+1], a
    ld [wCurrentBank], a
    ld [wBankSwitchTarget], a
    ld [wPlayHeadTarget], a
    ld [wPlayHeadTarget+1], a

    ; Kill remaining sound.
    ld a, %00111111
    ldh [rNR11], a
    ldh [rNR21], a
    ld a, $FF
    ldh [rNR31], a
    ldh [rNR41], a
    ld a, %01000000
    ldh [rNR14], a
    ldh [rNR24], a
    ldh [rNR34], a
    ldh [rNR44], a

    ; If we're GM, play the GM jingle.
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    ret nz

    ld a, BANK_SFX
    ld [wCurrentBank], a
    ld a, SFX_RANKGM
    ldh [hCurrentlyPlaying], a
    ld a, LOW(sSFXRankGM)
    ldh [hPlayhead], a
    ld a, HIGH(sSFXRankGM)
    ldh [hPlayhead+1], a
    jp SFXPlay


ENDC
