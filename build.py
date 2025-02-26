#!/usr/bin/env python
# Game ID and title of the game. ID has to be four characters, title can be up to 11
GAME_ID = "DTGM"
GAME_TITLE = "DMGTRIS"

# Version of the game as embedded in the rom
GAME_VERSION = "0x01"

# Mapper type and sram size
MAPPER_TYPE = "MBC5+RAM+BATTERY"
SRAM_AMOUNT = "0x04"

# Rom filename, without extension
ROM_NAME = "PandorasBlocks"

# Extra flags
RGBASM_FLAGS = ["-Q", "25"]
RGBLINK_FLAGS = []
RGBFIX_FLAGS = ["-c"]

# You will not be likely to need to change these options.
OLD_LICENSEE = "0x33"
PAD_VALUE = "0xFF"
LICENSEE = "HB"


# Do not edit below this line.
import sys, shutil, hashlib, subprocess
from pathlib import Path

def clean():
    shutil.rmtree("./bin", ignore_errors=True)
    shutil.rmtree("./obj", ignore_errors=True)

def assemble(file, out, extra = []):
    cmd = [
        "rgbasm",
        "-p", PAD_VALUE,
        "-Isrc/",
        "-Isrc/include",
        "-Wall",
        "-Wextra"
    ]
    cmd += RGBASM_FLAGS
    cmd += extra
    cmd += [
        "-o", out, file
    ]
    result = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, text=True)
    if result.returncode == 0:
        return True
    else:
        print(result.stdout)
        return False

def link(files, out, extra = []):
    cmd = [
        "rgblink",
        "-p", PAD_VALUE
    ]
    cmd += RGBLINK_FLAGS
    cmd += extra
    cmd += [
        "-o", out
    ]
    cmd += files
    result = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, text=True)
    if result.returncode == 0:
        return True
    else:
        print(result.stdout)
        return False

def fix(file, extra = []):
    cmd = [
        "rgbfix",
        "-v",
        "-p", PAD_VALUE,
        "-i", GAME_ID,
        "-k", LICENSEE,
        "-l", OLD_LICENSEE,
        "-m", MAPPER_TYPE,
        "-n", GAME_VERSION,
        "-r", SRAM_AMOUNT,
        "-t", GAME_TITLE
    ]
    cmd += RGBFIX_FLAGS
    cmd += extra
    cmd += [file]
    result = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, text=True)
    if result.returncode == 0:
        return True
    else:
        print(result.stdout)
        return False

def build():
    # Make sure the output directories exist.
    Path("./bin").mkdir(exist_ok=True)
    Path("./obj").mkdir(exist_ok=True)
    Path("./obj/a").mkdir(exist_ok=True)
    Path("./obj/n").mkdir(exist_ok=True)

    # RGBASM pass
    files = [f for f in Path("./src").glob("*.asm") if f.is_file()]
    for file in files:
        # Check if the file needs reassembly
        digest_file = Path(f"./obj/{file.stem}.sha256")
        n_file = Path(f"./obj/n/{file.stem}.o")
        a_file = Path(f"./obj/a/{file.stem}.o")
        old_digest = ""
        new_digest = ""
        if digest_file.exists(): old_digest = digest_file.read_text()
        with file.open("rb") as f: new_digest = hashlib.file_digest(f, "sha256").hexdigest()

        if old_digest != new_digest:
            print(f"Assembling {file.name}...")
            n_file.unlink(missing_ok=True)
            n_result = assemble(str(file), str(n_file), [])
            if not n_result:
                print("Aborting.")
                return
            a_file.unlink(missing_ok=True)
            a_result = assemble(str(file), str(a_file), ["-D" "BUILD_POCKET"])
            if not a_result:
                print("Aborting.")
                return
            digest_file.write_text(new_digest)

    # RGBLINK + RGBFIX pass
    print(f"Linking bin/{ROM_NAME}.gbc...")
    n_files = [str(f) for f in Path("./obj/n").glob("*.o") if f.is_file()]
    Path(f"./bin/{ROM_NAME}.gbc").unlink(missing_ok=True)
    Path(f"./bin/{ROM_NAME}.map").unlink(missing_ok=True)
    Path(f"./bin/{ROM_NAME}.sym").unlink(missing_ok=True)
    n_result = link(n_files, f"bin/{ROM_NAME}.gbc", ["-m", f"bin/{ROM_NAME}.map", "-n", f"bin/{ROM_NAME}.sym"])
    if not n_result:
        print("Aborting.")
        return
    print(f"Fixing bin/{ROM_NAME}.gbc...")
    n_result = fix(f"bin/{ROM_NAME}.gbc")
    if not n_result:
        print("Aborting.")
        return

    print(f"Linking bin/{ROM_NAME}.pocket...")
    Path(f"./bin/{ROM_NAME}.pocket").unlink(missing_ok=True)
    a_files = [str(f) for f in Path("./obj/a").glob("*.o") if f.is_file()]
    a_result = link(a_files, f"bin/{ROM_NAME}.pocket")
    if not a_result:
        print("Aborting.")
        return
    print(f"Fixing bin/{ROM_NAME}.pocket...")
    a_result = fix(f"bin/{ROM_NAME}.pocket", ["-L", "src/include/pocket-logo.1bpp"])
    if not a_result:
        print("Aborting.")
        return

if __name__ == "__main__":
    if sys.argv[-1] == "clean": clean()
    if sys.argv[-1] == "rebuild": clean(); build()
    else: build()
