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


IF !DEF(HISCORE_ASM)
DEF HISCORE_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Hi Score Data", ROM0
sHiscoreDefaultData::
    db 0, 0, 0, 0, 0, 0, 0, 0, "DMG", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "TRI", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "SDM", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "GTR", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "ISD", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "MGT", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "RIS", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "DMG", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "TRI", GRADE_NONE
    db 0, 0, 0, 0, 0, 0, 0, 0, "SDM", GRADE_NONE


SECTION "Hi Score Variables", WRAM0
wTargetHSTable:: ds 2
wWorkingCopy:: ds (11*(8+3+1))


SECTION "Hi Score Functions", ROM0
CheckAndAddHiscore::
    ret

GetTargetHSTable:
    ret

ENDC
