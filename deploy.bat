@echo off
cd /D "%~dp0"
make clean

del /Q src\include\hardware.inc
copy src\include\hardware.analogue src\include\hardware.inc
make

ren bin\DMGTRIS.GBC DMGTRIS.pocket
python patch_pocket.py

rd /S /Q obj
rd /S /Q dep

del /Q src\include\hardware.inc
copy src\include\hardware.nintendo src\include\hardware.inc
make

git add .
git commit -am "Deploy new build."
git push
