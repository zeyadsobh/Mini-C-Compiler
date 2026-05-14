#ifndef MINI_C_COMPILER_HELPERS_H
#define MINI_C_COMPILER_HELPERS_H

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int asprintf(char **ret, const char *format, ...);

/* Resolve C escape sequences in a quoted string lexer token (yytext, including surrounding double
 * quotes). Returns a freshly malloc'd, null-terminated string with escapes resolved, or NULL on
 * invalid input. Caller owns the returned string. */
char *unescape_string(const char *quoted, size_t len);

/* Resolve a quoted char literal token (e.g. 'x' or '\n') into a single byte. Writes the decoded
 * byte to *out and returns 0 on success; returns -1 on empty, multi-byte, or invalid escape. */
int unescape_char(const char *quoted, size_t len, char *out);

/* Convert a raw byte string back into a printable, single-line representation suitable for
 * embedding inside quotes in the .asm output. Returns a freshly malloc'd string. */
char *reescape_for_asm(const char *raw, size_t len);

#endif // MINI_C_COMPILER_HELPERS_H
