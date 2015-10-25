@echo off
set CCD=%CD%
set CFN=%0
cd %CFN:~0,-9%
@echo on
%fstar% --smt %z3% --codegen FSharp --odir %CD%\fsharp %CD%\fstar\VList.fst %CD%\fstar\VDigit.fst %CD%\fstar\VNatural.fst"
@echo off
cd %CCD%