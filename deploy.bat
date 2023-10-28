@echo off
cd /D "%~dp0"
echo Cleaning up...
make clean > NUL

echo Making pocket version...
del /Q src\include\hardware.inc > NUL
copy src\include\hardware.analogue src\include\hardware.inc > NUL
make > NUL

echo Fixing pocket version header...
ren bin\DMGTRIS.GBC DMGTRIS.pocket > NUL
python patch_pocket.py > NUL
rgbfix -fhg -O bin\DMGTRIS.pocket > NUL

echo Making GB version...
rd /S /Q obj > NUL
rd /S /Q dep > NUL
del /Q src\include\hardware.inc > NUL
copy src\include\hardware.nintendo src\include\hardware.inc > NUL
make > NUL

echo Pushing new version...
git add . > NUL
git commit -am %* > NUL
git push
