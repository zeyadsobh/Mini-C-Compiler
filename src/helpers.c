#include "helpers.h"

static int decode_escape(char c, char *out)
{
    switch (c)
    {
    case 'n':  *out = '\n'; return 0;
    case 't':  *out = '\t'; return 0;
    case 'r':  *out = '\r'; return 0;
    case '\\': *out = '\\'; return 0;
    case '\'': *out = '\''; return 0;
    case '"':  *out = '"';  return 0;
    case '0':  *out = '\0'; return 0;
    case 'b':  *out = '\b'; return 0;
    case 'f':  *out = '\f'; return 0;
    case 'v':  *out = '\v'; return 0;
    case 'a':  *out = '\a'; return 0;
    default:   return -1;
    }
}

static int hex_digit(char c)
{
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return 10 + (c - 'a');
    if (c >= 'A' && c <= 'F') return 10 + (c - 'A');
    return -1;
}

char *unescape_string(const char *quoted, size_t len)
{
    if (len < 2 || quoted[0] != '"' || quoted[len - 1] != '"') return NULL;
    const char *p = quoted + 1;
    const char *end = quoted + len - 1;
    char *out = malloc(len); /* upper bound: never longer than the raw token */
    if (out == NULL) return NULL;
    char *w = out;
    while (p < end)
    {
        if (*p != '\\')
        {
            *w++ = *p++;
            continue;
        }
        p++;
        if (p >= end) { free(out); return NULL; }
        if (*p == 'x')
        {
            if (p + 2 >= end) { free(out); return NULL; }
            int hi = hex_digit(p[1]);
            int lo = hex_digit(p[2]);
            if (hi < 0 || lo < 0) { free(out); return NULL; }
            *w++ = (char)((hi << 4) | lo);
            p += 3;
        }
        else
        {
            char c;
            if (decode_escape(*p, &c) != 0) { free(out); return NULL; }
            /* Embedded NUL in strings is rejected until length-tracked strings exist. */
            if (c == '\0') { free(out); return NULL; }
            *w++ = c;
            p++;
        }
    }
    *w = '\0';
    return out;
}

int unescape_char(const char *quoted, size_t len, char *out)
{
    if (len < 3 || quoted[0] != '\'' || quoted[len - 1] != '\'') return -1;
    const char *p = quoted + 1;
    size_t body = len - 2;
    if (body == 1)
    {
        if (*p == '\\' || *p == '\'') return -1;
        *out = *p;
        return 0;
    }
    if (*p != '\\') return -1;
    if (body == 2)
    {
        return decode_escape(p[1], out);
    }
    if (body == 4 && p[1] == 'x')
    {
        int hi = hex_digit(p[2]);
        int lo = hex_digit(p[3]);
        if (hi < 0 || lo < 0) return -1;
        *out = (char)((hi << 4) | lo);
        return 0;
    }
    return -1;
}

char *reescape_for_asm(const char *raw, size_t len)
{
    char *out = malloc(len * 4 + 1);
    if (out == NULL) return NULL;
    char *w = out;
    for (size_t i = 0; i < len; i++)
    {
        unsigned char c = (unsigned char)raw[i];
        switch (c)
        {
        case '\n': *w++ = '\\'; *w++ = 'n';  break;
        case '\t': *w++ = '\\'; *w++ = 't';  break;
        case '\r': *w++ = '\\'; *w++ = 'r';  break;
        case '\\': *w++ = '\\'; *w++ = '\\'; break;
        case '"':  *w++ = '\\'; *w++ = '"';  break;
        case '\'': *w++ = '\\'; *w++ = '\''; break;
        case '\b': *w++ = '\\'; *w++ = 'b';  break;
        case '\f': *w++ = '\\'; *w++ = 'f';  break;
        case '\v': *w++ = '\\'; *w++ = 'v';  break;
        case '\a': *w++ = '\\'; *w++ = 'a';  break;
        default:
            if (c < 0x20 || c == 0x7f)
            {
                w += sprintf(w, "\\x%02x", c);
            }
            else
            {
                *w++ = (char)c;
            }
        }
    }
    *w = '\0';
    return out;
}

int asprintf(char **ret, const char *format, ...)
{
    *ret = NULL;

    va_list args;
    va_start(args, format);
    int count = vsnprintf(NULL, 0, format, args);
    va_end(args);

    if (count >= 0)
    {
        char *buffer = malloc(count + 1);

        va_start(args, format);
        count = vsnprintf(buffer, count + 1, format, args);
        va_end(args);

        *ret = buffer;
    }

    return count;
}
