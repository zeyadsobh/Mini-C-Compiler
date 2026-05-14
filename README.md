# Mini-C-Compiler

A compiler for a subset of the C programming language.  
Major differences include:

- No pointers.
- No casts.
- No structs or unions.

## Notes about generated quadruples

- Assumes the presence of five registers - retval, retadr, temp1, temp2, and temp3.

## Building and Running

Prerequisites: GCC, flex, bison, GNU make.

```shell
    make
    ./bin/compiler.exe examples/fibonacci.c
```

The generated quadruple-style assembly is written to `output.asm` in the current working directory.

The compiler is quiet by default. Pass `-v` or `--verbose` to enable phase prints (`Parsing...`, `Parsing complete.`, etc.):

```shell
    ./bin/compiler.exe examples/fibonacci.c -v
```

The Makefile produces `bin/compiler.exe` (Windows-style suffix). On Linux you can rename or adjust the `EXECUTABLE` variable in the Makefile.
