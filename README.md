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
