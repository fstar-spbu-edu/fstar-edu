# fstar-edu

For build on Windows may used build.bat

Structure of folders:
- build.bat
- compiler
  - `<name>-<version>-<processor>-<os>`
    - ...
- tasks
  - `<year>.<group>`
    - `<name>`
      - build.bat
      - fstar
        - `<name>`.fst
      - fsharp | only for generation
        - `<name>`.fs
