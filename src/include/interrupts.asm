SECTION "Interrupt Initialization Functions", ROM0
InitializeLCDCInterrupt::
    ld a, STATF_LYC
    ldh [rSTAT], a
    ld a, 6
    ldh [rLYC], a
    ld a, 0
    ldh [rSCY], a
    ld a, IEF_STAT
    ldh [rIE], a
    xor a, a
    ldh [rIF], a
    ei
    ret


SECTION "LCDC Interrupt", ROM0[$0048]
LCDCInterrupt:
    push af
    push hl

    ld hl, rSTAT
LCDCInterrupt_WaitUntilNotBusy:
    bit STATB_BUSY, [hl]
    jr nz, LCDCInterrupt_WaitUntilNotBusy

    ; Increment SCY
    ldh a, [rSCY]
    inc a
    ldh [rSCY], a

    ; Increment LYC by 7
    ldh a, [rLYC]
    add a, 7
    ldh [rLYC], a

    ; Check our interrupt counter
    ld a, [wLCDCCtr]
    cp 21
    jp nz, LCDCInterrupt_End
    ld a, 255
    ld [wLCDCCtr], a
    ld a, 6
    ldh [rLYC], a
    ld a, 0
    ldh [rSCY], a

LCDCInterrupt_End:
    inc a
    ld [wLCDCCtr], a
    pop hl
    pop af
    reti

