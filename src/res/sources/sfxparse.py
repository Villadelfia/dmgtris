# DMGTRIS
# Copyright (C) 2023 - Randy Thiemann <randy.thiemann@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

from construct import Struct, Const, Int32ul, Int16ul, Int8ul, Bytes

vgm_header = Struct(
    "magic" / Const(b"Vgm "),
    "eof_offset" / Int32ul,
    "version" / Int32ul,
    "sn76489_clock" / Int32ul,
    "ym2413_clock" / Int32ul,
    "gd3_offset" / Int32ul,
    "total_samples" / Int32ul,
    "loop_offset" / Int32ul,
    "loop_samples" / Int32ul,
    "rate" / Int32ul,
    "sn_fb" / Int16ul,
    "sn_w" / Int8ul,
    "sn_c" / Int8ul,
    "ym2612_clock" / Int32ul,
    "ym2151_clock" / Int32ul,
    "vgm_data_offset" / Int32ul,
    "seg_pcm_clock" / Int32ul,
    "seg_pcm_intf_reg" / Int32ul,
    "rf5c68_clock" / Int32ul,
    "ym2203_clock" / Int32ul,
    "ym2608_clock" / Int32ul,
    "ym2610_clock" / Int32ul,
    "ym3812_clock" / Int32ul,
    "ym3526_clock" / Int32ul,
    "y8950_clock" / Int32ul,
    "ymf262_clock" / Int32ul,
    "ymf278b_clock" / Int32ul,
    "ymf271_clock" / Int32ul,
    "ymz280b_clock" / Int32ul,
    "rf5c164_clock" / Int32ul,
    "pwm_clock" / Int32ul,
    "ay8910_clock" / Int32ul,
    "ay8910_type" / Int8ul,
    "ay8910_flags" / Int8ul,
    "ym2203_ay8910_flags" / Int8ul,
    "ym2608_ay8910_flags" / Int8ul,
    "volume_mod" / Int8ul,
    "reserved_0" / Bytes(1),
    "loop_base" / Int8ul,
    "loop_modifier" / Int8ul,
    "dmg_clock" / Int32ul,
    "nes_apu_clock" / Int32ul,
    "multi_pcm_clock" / Int32ul,
    "upd7759_clock" / Int32ul,
    "okim6258_clock" / Int32ul,
    "okim6258_flags" / Int8ul,
    "k054539_flags" / Int8ul,
    "c140_chip_type" / Int8ul,
    "reserved_1" / Bytes(1),
    "okim6295_clock" / Int32ul,
    "k051649_k052539_clock" / Int32ul,
    "k054539_clock" / Int32ul,
    "huc6280_clock" / Int32ul,
    "c140_clock" / Int32ul,
    "k053260_clock" / Int32ul,
    "pokey_clock" / Int32ul,
    "qsound_clock" / Int32ul,
    "scsp_clock" / Int32ul,
    "extra_hdr_offset" / Int32ul,
    "wonder_swan_clock" / Int32ul,
    "vsu_clock" / Int32ul,
    "saa1099_clock" / Int32ul,
    "es5503_clock" / Int32ul,
    "es5505_es5506_clock" / Int32ul,
    "es5503_num_channels" / Int8ul,
    "es5505_es5506_num_channels" / Int8ul,
    "c352_clock_div" / Int8ul,
    "reserved_2" / Bytes(1),
    "x1_010_clock" / Int32ul,
    "c352_clock" / Int32ul,
    "ga20_clock" / Int32ul,
    "reserved_3" / Bytes(28)
)

b3_command = Struct(
    "command" / Const(b'\xB3'),
    "reg" / Int8ul,
    "data" / Int8ul
)

register_names = [
    "REG_UNK",               # 0x00
    "REG_UNK",               # 0x01
    "REG_UNK",               # 0x02
    "REG_UNK",               # 0x03
    "REG_UNK",               # 0x04
    "REG_UNK",               # 0x05
    "REG_UNK",               # 0x06
    "REG_UNK",               # 0x07
    "REG_UNK",               # 0x08
    "REG_UNK",               # 0x09
    "REG_UNK",               # 0x0A
    "REG_UNK",               # 0x0B
    "REG_UNK",               # 0x0C
    "REG_UNK",               # 0x0D
    "REG_UNK",               # 0x0E
    "REG_UNK",               # 0x0F
    "REG_NR10_CH1_SWEEP",    # 0x10
    "REG_NR11_CH1_LENDT",    # 0x11
    "REG_NR12_CH1_VOLEV",    # 0x12
    "REG_NR13_CH1_FRQLO",    # 0x13
    "REG_NR14_CH1_FRQHI",    # 0x14
    "REG_UNK",               # 0x15
    "REG_NR21_CH2_LENDT",    # 0x16
    "REG_NR22_CH2_VOLEV",    # 0x17
    "REG_NR23_CH2_FRQLO",    # 0x18
    "REG_NR24_CH2_FRQHI",    # 0x19
    "REG_NR30_CH3_DACEN",    # 0x1A
    "REG_NR31_CH3_LENGT",    # 0x1B
    "REG_NR32_CH3_VOLUM",    # 0x1C
    "REG_NR33_CH3_FRQLO",    # 0x1D
    "REG_NR34_CH3_FRQHI",    # 0x1E
    "REG_UNK",               # 0x1F
    "REG_NR41_CH4_LENGT",    # 0x20
    "REG_NR42_CH4_VOLEV",    # 0x21
    "REG_NR43_CH4_FQRND",    # 0x22
    "REG_NR44_CH4_CNTRL",    # 0x23
    "REG_NR50_MVOLVINPN",    # 0x24
    "REG_NR51_MASTERPAN",    # 0x25
    "REG_NR52_MASTERCTL",    # 0x26
    "REG_UNK",               # 0x27
    "REG_UNK",               # 0x28
    "REG_UNK",               # 0x29
    "REG_UNK",               # 0x2A
    "REG_UNK",               # 0x2B
    "REG_UNK",               # 0x2C
    "REG_UNK",               # 0x2D
    "REG_UNK",               # 0x2E
    "REG_UNK",               # 0x2F
    "REG_WAVE_PATTERN_0",    # 0x30
    "REG_WAVE_PATTERN_1",    # 0x31
    "REG_WAVE_PATTERN_2",    # 0x32
    "REG_WAVE_PATTERN_3",    # 0x33
    "REG_WAVE_PATTERN_4",    # 0x34
    "REG_WAVE_PATTERN_5",    # 0x35
    "REG_WAVE_PATTERN_6",    # 0x36
    "REG_WAVE_PATTERN_7",    # 0x37
    "REG_WAVE_PATTERN_8",    # 0x38
    "REG_WAVE_PATTERN_9",    # 0x39
    "REG_WAVE_PATTERN_A",    # 0x3A
    "REG_WAVE_PATTERN_B",    # 0x3B
    "REG_WAVE_PATTERN_C",    # 0x3C
    "REG_WAVE_PATTERN_D",    # 0x3D
    "REG_WAVE_PATTERN_E",    # 0x3E
    "REG_WAVE_PATTERN_F",    # 0x3F
]

sfx_names = [
    "sSFXPieceI",
    "sSFXPieceZ",
    "sSFXPieceS",
    "sSFXPieceJ",
    "sSFXPieceL",
    "sSFXPieceO",
    "sSFXPieceT",
    "sSFXIHS",
    "sSFXPieceIRSI",
    "sSFXPieceIRSZ",
    "sSFXPieceIRSS",
    "sSFXPieceIRSJ",
    "sSFXPieceIRSL",
    "sSFXPieceIRSO",
    "sSFXPieceIRST",
    "sSFXIHSIRS",
    "sSFXLineClear",
    "sSFXLand",
    "sSFXLock",
    "sSFXLevelLock",
    "sSFXLevelUp",
    "sSFXRankUp",
    "sSFXReadyGo",
]

def chunks(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

class DB:
    l = []

    def __init__(self):
        self.l = []

    def __str__(self):
        out = []
        for chunk in chunks(self.l, 8):
            out.append(f"    db {', '.join(chunk)}")
        return "\n".join(out) + "\n"

    def __repr__(self):
        return str(self)

    def __len__(self):
        return len(self.l)

    def add(self, *args):
        if len(args) == 1:
            self.l.append(f"${args[0]:02X}")
        else:
            self.l.append(register_names[args[0]])
            self.l.append(f"${args[1]:02X}")

    def trim(self):
        while self.l[-1] == "$FF":
            self.l.pop()

for c, v in enumerate(register_names):
    if v != "REG_UNK":
        print(f"DEF {v} EQU ${c:02X}")

print()

with open("sfx.vgm", "rb") as f:
    data = f.read()
    header = vgm_header.parse(data)
    data_offset = 0x34 + header.vgm_data_offset
    data = data[data_offset:]
    db = DB()
    ctr = 0
    last = None
    while len(data) > 0:
        if data.startswith(b'\x67\x66'):
            if len(db) > 0:
                db.trim()
                db.add(0xFE)
                print(db, end="")
                print(f"{sfx_names[ctr-1]}End::")
            db = DB()
            print(f"{sfx_names[ctr]}::")
            ctr += 1
            last = None
            data = data[3:]
            data = data[Int32ul.parse(data) + 4:]
        elif data.startswith(b'\xB3'):
            b3 = b3_command.parse(data)
            if last == 0x62:
                print(db)
                db = DB()
            db.add(b3.reg + 0x10, b3.data)
            last = 0xB3
            data = data[3:]
        elif data.startswith(b'\x62'):
            db.add(0xFF)
            last = 0x62
            data = data[1:]
        elif data.startswith(b'\x66'):
            if len(db) > 0:
                db.trim()
                db.add(0xFE)
                print(db, end="")
            print(f"{sfx_names[ctr-1]}End::")
            break
        else:
            print(f"Unknown command: ${data[0]:02X}")
            data = data[1:]
