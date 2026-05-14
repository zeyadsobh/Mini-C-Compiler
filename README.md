# Mini-C-Compiler

A compiler for a subset of the C programming language.  
Major differences include:

- No pointers.
- No casts.
- No structs or unions.

## Notes about generated quadruples

- Assumes the presence of five registers - retval, retadr, temp1, temp2, and temp3.

## Building and Running

```shell
    make
    ./bin/compiler.exe examples/fibonacci.c
```

## Running tests

```shell
    make test
```

Runs the suite in `tests/`:
- All `examples/*.c` (except `source.c`) are expected to compile and emit `Code generation complete`.
- All `tests/parse_fail/*.c` are expected to produce the error substring found in the matching `.err` file.
