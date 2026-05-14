## TODO

- refactoring, low priority
  - 3 operation functions -> to 1 or 2
- type conversion
- ASM for comparison in non-cond expressions
- turn to an actual complete compiler - producing an executable
- parse complete C
- rework most memory allocations and check for leaks: enum identifiers, asprintf strings in quadruples.c, lookup-side identifier strings, AST statement arrays
- fix postfix in conditions - possibly rework conditions
- at some point, implement own lexer and parser
- refactor quadruples.c
- remove hacky code done for uni submission
- move symbol table inserts to lexer
- recheck all conditional jumps
