#!/bin/sh
echo "Cleaning..."
make clean >/dev/null
echo "Making pocket version."
rm src/include/hardware.inc  >/dev/null
cp src/include/hardware.analogue src/include/hardware.inc >/dev/null
make >/dev/null
echo "Fixing pocket version."
mv bin/PandorasBlocks.gbc bin/PandorasBlocks.pocket >/dev/null
python patch_pocket.py >/dev/null
rgbfix -fhg -O bin/PandorasBlocks.pocket >/dev/null
echo "Making regular version."
rm -rf obj >/dev/null
rm src/include/hardware.inc >/dev/null
cp src/include/hardware.nintendo src/include/hardware.inc >/dev/null
make >/dev/null
