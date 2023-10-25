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


SECTION "Bank ID 0", ROM0[$0]
    REPT 7
        rst $00
    ENDR
    db $00

SECTION "Bank ID 1", ROMX[$4000], BANK[1]
    REPT 7
        rst $00
    ENDR
    db $01

SECTION "Bank ID 2", ROMX[$4000], BANK[2]
    REPT 7
        rst $00
    ENDR
    db $02

SECTION "Bank ID 3", ROMX[$4000], BANK[3]
    REPT 7
        rst $00
    ENDR
    db $03


ENDC
