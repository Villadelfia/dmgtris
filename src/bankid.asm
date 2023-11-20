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


IF !DEF(BANKID_ASM)
DEF BANKID_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Bank ID BANK_MAIN", ROM0[$0]
REPT 7
    rst $00
ENDR
db BANK_MAIN

SECTION "Bank ID BANK_OTHER", ROMX[$4000], BANK[BANK_OTHER]
REPT 7
    rst $00
ENDR
db BANK_OTHER

SECTION "Bank ID BANK_SFX", ROMX[$4000], BANK[BANK_SFX]
REPT 7
    rst $00
ENDR
db BANK_SFX

SECTION "Bank ID BANK_TITLE", ROMX[$4000], BANK[BANK_TITLE]
REPT 7
    rst $00
ENDR
db BANK_TITLE

SECTION "Bank ID BANK_GAMEPLAY", ROMX[$4000], BANK[BANK_GAMEPLAY]
REPT 7
    rst $00
ENDR
db BANK_GAMEPLAY

SECTION "Bank ID BANK_GAMEPLAY_BIG", ROMX[$4000], BANK[BANK_GAMEPLAY_BIG]
REPT 7
    rst $00
ENDR
db BANK_GAMEPLAY_BIG

SECTION "Bank ID BANK_MUSIC_0", ROMX[$4000], BANK[BANK_MUSIC_0]
REPT 7
    rst $00
ENDR
db BANK_MUSIC_0

SECTION "Bank ID BANK_MUSIC_1", ROMX[$4000], BANK[BANK_MUSIC_1]
REPT 7
    rst $00
ENDR
db BANK_MUSIC_1

SECTION "Bank ID BANK_MUSIC_2", ROMX[$4000], BANK[BANK_MUSIC_2]
REPT 7
    rst $00
ENDR
db BANK_MUSIC_2

SECTION "Bank ID BANK_MUSIC_3", ROMX[$4000], BANK[BANK_MUSIC_3]
REPT 7
    rst $00
ENDR
db BANK_MUSIC_3


ENDC
