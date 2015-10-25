@echo off
set CCD=%CD%
set CFN=%0
cd %CFN:~0,-9%

rmdir /S /Q %CD%\fharp
mkdir %CD%\fharp
echo fstar.exe --codegen FSharp VList.fst VDigit.fst VNatural.fst
%fstar% --smt %z3% --codegen FSharp --odir %CD%\fsharp %CD%\fstar\VList.fst %CD%\fstar\VDigit.fst %CD%\fstar\VNatural.fst"

cd %CCD%