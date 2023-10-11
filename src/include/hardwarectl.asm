SECTION "Hardware Control Functions", ROM0
DisableAudio::
    xor a, a
    ldh [rNR52], a
    ret


DisableLCDKeepingSettings::
    ldh a, [rLCDC]
    and LOW(~LCDCF_ON)
    wait_vram
    ldh [rLCDC], a
    ret


DisableLCD::
    wait_vram
    xor a, a
    ldh [rLCDC], a
    ret


EnableLCD::
    ldh a, [rLCDC]
    or LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh [rLCDC], a
    ret


SetTileDataBanks::
    ldh a, [rLCDC]
    or LCDCF_BLK01
    ldh [rLCDC], a
    ret
