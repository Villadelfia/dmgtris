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

IF !DEF(RGB555_ASM)
DEF RGB555_ASM EQU 1


INCLUDE "hardware.inc"


; Macro to define an RGB555 color to be used in CGB mode.
; Will result in a symbol named COLORNAME, COLORNAME_A and COLORNAME_C being created.
; Usage:
;   DEF_RGB555 COLORNAME, R, G, B
MACRO DEF_RGB555
    ASSERT (\2) >= 0 && (\2) <= 31, "ERROR in DEF_RGB555: R value given was not in the range [0; 31]."
    ASSERT (\3) >= 0 && (\3) <= 31, "ERROR in DEF_RGB555: G value given was not in the range [0; 31]."
    ASSERT (\4) >= 0 && (\4) <= 31, "ERROR in DEF_RGB555: B value given was not in the range [0; 31]."

    DEF COLOR   EQUS "\1"

    ; Uncorrected
    DEF RED_A   EQU (\2 & $1F)
    DEF GREEN_A EQU (\3 & $1F)
    DEF BLUE_A  EQU (\4 & $1F)

    DEF {COLOR}   EQU (RED_A << 0) | (GREEN_A << 5) | (BLUE_A << 10)
    DEF {COLOR}_A EQU (RED_A << 0) | (GREEN_A << 5) | (BLUE_A << 10)

    ; Transfer function.
    DEF GAMMA     EQU 2.0q25
    DEF INVGAMMA  EQU DIV(1.0q25, 2.0q25, 25)
    DEF RGBMAX    EQU 31.0q25
    DEF INVRGBMAX EQU DIV(1.0q25, 31.0q25, 25)

    ; From display gamma.
    DEF R_C0 EQU POW(MUL(R_A << 25, INVRGBMAX), GAMMA, 25)
    DEF G_C0 EQU POW(MUL(G_A << 25, INVRGBMAX), GAMMA, 25)
    DEF B_C0 EQU POW(MUL(B_A << 25, INVRGBMAX), GAMMA, 25)

    ; To convert a color as displayed on a game boy color to the original color, the following formulas must be applied:
    ; R' = (0.86629 * R) + (0.13361 * G) + (0.00000 * B)
    ; G' = (0.02429 * R) + (0.70857 * G) + (0.25714 * B)
    ; B' = (0.11337 * R) + (0.11448 * G) + (0.77215 * B)
    ; We need the inverted matrix here.
    DEF R_C1 EQU (MUL(R_C0, +1.15039q25, 25) + MUL(G_C0, -0.22976q25, 25) + MUL(B_C0, +0.07949q25, 25))
    DEF G_C1 EQU (MUL(R_C0, +0.02568q25, 25) + MUL(G_C0, +1.48972q25, 25) + MUL(B_C0, -0.51540q25, 25))
    DEF B_C1 EQU (MUL(R_C0, -0.17271q25, 25) + MUL(G_C0, -0.18713q25, 25) + MUL(B_C0, +1.35983q25, 25))
    ; DEF R_C1 EQU (MUL(R_C0, +1.0q25, 25) + MUL(G_C0, +0.0q25, 25) + MUL(B_C0, +0.0q25, 25))
    ; DEF G_C1 EQU (MUL(R_C0, +0.0q25, 25) + MUL(G_C0, +1.0q25, 25) + MUL(B_C0, +0.0q25, 25))
    ; DEF B_C1 EQU (MUL(R_C0, +0.0q25, 25) + MUL(G_C0, +0.0q25, 25) + MUL(B_C0, +1.0q25, 25))

    ; To display gamma.
    DEF R_C2 EQU MUL(RGBMAX, POW(R_C1, INVGAMMA, 25), 25)
    DEF G_C2 EQU MUL(RGBMAX, POW(G_C1, INVGAMMA, 25), 25)
    DEF B_C2 EQU MUL(RGBMAX, POW(B_C1, INVGAMMA, 25), 25)

    ; To display color.
    DEF R_C3 = (FLOOR(R_C2 + 0.5q25, 25) >> 25)
    DEF G_C3 = (FLOOR(G_C2 + 0.5q25, 25) >> 25)
    DEF B_C3 = (FLOOR(B_C2 + 0.5q25, 25) >> 25)

    ; Clamping
    IF (R_C3) < 0
        DEF R_C3 = 0
    ENDC

    IF (R_C3) > 31
        DEF R_C3 = 31
    ENDC

    IF (G_C3) < 0
        DEF G_C3 = 0
    ENDC

    IF (G_C3) > 31
        DEF G_C3 = 31
    ENDC

    IF (B_C3) < 0
        DEF B_C3 = 0
    ENDC

    IF (B_C3) > 31
        DEF B_C3 = 31
    ENDC

    DEF R_C EQU (R_C3 & $1F)
    DEF G_C EQU (G_C3 & $1F)
    DEF B_C EQU (B_C3 & $1F)

    DEF {COLOR}_C EQU (R_C << 0) | (G_C << 5) | (B_C << 10)

    PURGE COLOR, R_A, G_A, B_A, GAMMA, INVGAMMA, RGBMAX, INVRGBMAX, R_C0, G_C0, B_C0, R_C1, G_C1, B_C1, R_C2, G_C2, B_C2, R_C3, G_C3, B_C3, R_C, G_C, B_C
ENDM


; Macro to define an RGB555 color to be used in CGB mode using standard 32 bit color semantics.
; Will result in a symbol named COLORNAME, COLORNAME_A and COLORNAME_C being created.
; Usage:
;   DEF_RGB555_FROM24 COLORNAME, R, G, B
MACRO DEF_RGB555_FROM24
    ASSERT (\2) >= 0 && (\2) <= 255, "ERROR in DEF_RGB555_FROM24: R value given was not in the range [0; 255]."
    ASSERT (\3) >= 0 && (\3) <= 255, "ERROR in DEF_RGB555_FROM24: G value given was not in the range [0; 255]."
    ASSERT (\4) >= 0 && (\4) <= 255, "ERROR in DEF_RGB555_FROM24: B value given was not in the range [0; 255]."

    DEF COLOR EQUS "\1"

    ; Uncorrected
    DEF R_A EQU ((\2 >> 3) & $1F)
    DEF G_A EQU ((\3 >> 3) & $1F)
    DEF B_A EQU ((\4 >> 3) & $1F)

    DEF {COLOR}   EQU (R_A << 0) | (G_A << 5) | (B_A << 10)
    DEF {COLOR}_A EQU (R_A << 0) | (G_A << 5) | (B_A << 10)

    ; Transfer function.
    DEF GAMMA     EQU 2.0q25
    DEF INVGAMMA  EQU DIV(1.0q25, 2.0q25, 25)
    DEF RGBMAX    EQU 31.0q25
    DEF INVRGBMAX EQU DIV(1.0q25, 31.0q25, 25)

    ; From display gamma.
    DEF R_C0 EQU POW(MUL(R_A << 25, INVRGBMAX), GAMMA, 25)
    DEF G_C0 EQU POW(MUL(G_A << 25, INVRGBMAX), GAMMA, 25)
    DEF B_C0 EQU POW(MUL(B_A << 25, INVRGBMAX), GAMMA, 25)

    ; To convert a color as displayed on a game boy color to the original color, the following formulas must be applied:
    ; R' = (0.86629 * R) + (0.13361 * G) + (0.00000 * B)
    ; G' = (0.02429 * R) + (0.70857 * G) + (0.25714 * B)
    ; B' = (0.11337 * R) + (0.11448 * G) + (0.77215 * B)
    ; We need the inverted matrix here.
    DEF R_C1 EQU (MUL(R_C0, +1.15039q25, 25) + MUL(G_C0, -0.22976q25, 25) + MUL(B_C0, +0.07949q25, 25))
    DEF G_C1 EQU (MUL(R_C0, +0.02568q25, 25) + MUL(G_C0, +1.48972q25, 25) + MUL(B_C0, -0.51540q25, 25))
    DEF B_C1 EQU (MUL(R_C0, -0.17271q25, 25) + MUL(G_C0, -0.18713q25, 25) + MUL(B_C0, +1.35983q25, 25))
    ; DEF R_C1 EQU (MUL(R_C0, +0.86629q25, 25) + MUL(G_C0, +0.13361q25, 25) + MUL(B_C0, +0.00000q25, 25))
    ; DEF G_C1 EQU (MUL(R_C0, +0.02429q25, 25) + MUL(G_C0, +0.70857q25, 25) + MUL(B_C0, +0.25714q25, 25))
    ; DEF B_C1 EQU (MUL(R_C0, +0.11337q25, 25) + MUL(G_C0, +0.11448q25, 25) + MUL(B_C0, +0.77215q25, 25))


    ; To display gamma.
    DEF R_C2 EQU MUL(RGBMAX, POW(R_C1, INVGAMMA, 25), 25)
    DEF G_C2 EQU MUL(RGBMAX, POW(G_C1, INVGAMMA, 25), 25)
    DEF B_C2 EQU MUL(RGBMAX, POW(B_C1, INVGAMMA, 25), 25)

    ; To display color.
    DEF R_C3 = (FLOOR(R_C2 + 0.5q25, 25) >> 25)
    DEF G_C3 = (FLOOR(G_C2 + 0.5q25, 25) >> 25)
    DEF B_C3 = (FLOOR(B_C2 + 0.5q25, 25) >> 25)

    ; Clamping
    IF (R_C3) < 0
        DEF R_C3 = 0
    ENDC

    IF (R_C3) > 31
        DEF R_C3 = 31
    ENDC

    IF (G_C3) < 0
        DEF G_C3 = 0
    ENDC

    IF (G_C3) > 31
        DEF G_C3 = 31
    ENDC

    IF (B_C3) < 0
        DEF B_C3 = 0
    ENDC

    IF (B_C3) > 31
        DEF B_C3 = 31
    ENDC

    DEF R_C EQU (R_C3 & $1F)
    DEF G_C EQU (G_C3 & $1F)
    DEF B_C EQU (B_C3 & $1F)

    DEF {COLOR}_C EQU (R_C << 0) | (G_C << 5) | (B_C << 10)

    PURGE COLOR, R_A, G_A, B_A, GAMMA, INVGAMMA, RGBMAX, INVRGBMAX, R_C0, G_C0, B_C0, R_C1, G_C1, B_C1, R_C2, G_C2, B_C2, R_C3, G_C3, B_C3, R_C, G_C, B_C
ENDM


; Macro to write a set of 4 colors to a CGB background palette.
; Usage:
;   WRITEPAL_B ID, COLOR0, COLOR1, COLOR2, COLOR3
MACRO WRITEPAL_B
    ASSERT (\1) >= 0 && (\1) <= 7, "ERROR in WRITEPAL_B: ID value given was not in the range [0; 7]."

    ld a, BCPSF_AUTOINC | (\1 * 8)
    ldh [rBCPS], a

    ld bc, \2
    ld a, c
    ldh [rBCPD], a
    ld a, b
    ldh [rBCPD], a

    ld bc, \3
    ld a, c
    ldh [rBCPD], a
    ld a, b
    ldh [rBCPD], a

    ld bc, \4
    ld a, c
    ldh [rBCPD], a
    ld a, b
    ldh [rBCPD], a

    ld bc, \5
    ld a, c
    ldh [rBCPD], a
    ld a, b
    ldh [rBCPD], a
ENDM


; Macro to write a set of 4 colors to a CGB object palette.
; Usage:
;   WRITEPAL_O ID, COLOR0, COLOR1, COLOR2, COLOR3
MACRO WRITEPAL_O
    ASSERT (\1) >= 0 && (\1) <= 7, "ERROR in WRITEPAL_O: ID value given was not in the range [0; 7]."

    ld a, 0CPSF_AUTOINC | (\1 * 8)
    ldh [rOCPS], a

    ld bc, \2
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a

    ld bc, \3
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a

    ld bc, \4
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a

    ld bc, \5
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
ENDM


; Macro to write a set of 4 colors to a CGB object and background palette.
; Usage:
;   WRITEPAL_A ID, COLOR0, COLOR1, COLOR2, COLOR3
MACRO WRITEPAL_A
    ASSERT (\1) >= 0 && (\1) <= 7, "ERROR in WRITEPAL_O: ID value given was not in the range [0; 7]."

    ld a, OCPSF_AUTOINC | (\1 * 8)
    ldh [rOCPS], a
    ldh [rBCPS], a

    ld bc, \2
    ld a, c
    ldh [rOCPD], a
    ldh [rBCPD], a
    ld a, b
    ldh [rOCPD], a
    ldh [rBCPD], a

    ld bc, \3
    ld a, c
    ldh [rOCPD], a
    ldh [rBCPD], a
    ld a, b
    ldh [rOCPD], a
    ldh [rBCPD], a

    ld bc, \4
    ld a, c
    ldh [rOCPD], a
    ldh [rBCPD], a
    ld a, b
    ldh [rOCPD], a
    ldh [rBCPD], a

    ld bc, \5
    ld a, c
    ldh [rOCPD], a
    ldh [rBCPD], a
    ld a, b
    ldh [rOCPD], a
    ldh [rBCPD], a
ENDM


ENDC
