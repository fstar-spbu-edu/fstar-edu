@echo off
set fstar=%CD%\compiler\fstar-0.9.1.1-x86-win\bin\fstar.exe
set z3=%CD%\compiler\z3-4.4.1-x64-win\bin\z3.exe

for /R %CD%\tasks %%F in (build.bat) do (
  @echo off
  if exist %%F %%F
  @echo off
)