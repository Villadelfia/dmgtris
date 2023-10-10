SECTION "Hardware Control Functions", ROM0
SetBGPalette::
    ldh [rBGP], a
    ret


DisableAudio::
    xor a, a
    ldh [rNR52], a
    ret


DisableLCD::
    wait_vram
    xor a, a
    ldh [rLCDC], a
    ret


EnableLCD::
    ld a, LCDCF_ON | LCDCF_BGON
    ldh [rLCDC], a
    ret
