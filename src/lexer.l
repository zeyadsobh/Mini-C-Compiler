%{
    #include "y.tab.h"

    static int decode_escape(const char *s, int *consumed);
    static char *process_string_escapes(const char *src, int len, int *out_len);
%}

%option nounput noinput
%option yylineno

D   [0-9]
H   [0-9a-fA-F]

%%

    /* Comments and whitespace ignored. */
"/*"([^*]|\*+[^*/])*\*+"/"          ;
\/\/.*                              ;
[ \t\r\n]+                          ;

    /* Keywords. */
"const"                             return CONST;

"bool"                              return BOOL;
"char"                              return CHAR;
"double"                            return DOUBLE;
"float"                             return FLOAT;
"int"                               return INT;
"long"                              return LONG;
"short"                             return SHORT;
"signed"                            return SIGNED;
"unsigned"                          return UNSIGNED;
"void"                              return VOID;

"break"                             return BREAK;
"case"                              return CASE;
"continue"                          return CONTINUE;
"default"                           return DEFAULT;
"do"                                return DO;
"else"                              return ELSE;
"enum"                              return ENUM;
"for"                               return FOR;
"if"                                return IF;
"return"                            return RETURN;
"switch"                            return SWITCH;
"while"                             return WHILE;

    /* Operators. */
":"                                 return COLON;
","                                 return COMMA;
"{"                                 return LBRACE;
"("                                 return LPAREN;
"?"                                 return QUESTION;
"}"                                 return RBRACE;
")"                                 return RPAREN;
";"                                 return SEMICOLON;

"+="                                return ADD_ASSIGN;
"&="                                return AND_ASSIGN;
"="                                 return ASSIGN;
"/="                                return DIV_ASSIGN;
"%="                                return MOD_ASSIGN;
"*="                                return MUL_ASSIGN;
"|="                                return OR_ASSIGN;
"<<="                               return SHL_ASSIGN;
">>="                               return SHR_ASSIGN;
"-="                                return SUB_ASSIGN;
"^="                                return XOR_ASSIGN;

"+"                                 return ADD;
"&&"                                return AND;
"&"                                 return BIT_AND;
"~"                                 return BIT_NOT;
"|"                                 return BIT_OR;
"--"                                return DEC;
"/"                                 return DIV;
"=="                                return EQ;
">="                                return GE;
">"                                 return GT;
"++"                                return INC;
"<="                                return LE;
"<"                                 return LT;
"%"                                 return MOD;
"*"                                 return MUL;
"!="                                return NE;
"!"                                 return NOT;
"||"                                return OR;
"<<"                                return SHL;
">>"                                return SHR;
"-"                                 return SUB;
"^"                                 return XOR;

    /* Boolean, numeric, character, and string literals. */
"false"                             { yylval.bool_value = 0;                             return FALSE; }
"true"                              { yylval.bool_value = 1;                             return TRUE;  }

0[bB][01]+                          { yylval.int_value = strtol(yytext + 2, NULL, 2);    return INT_LITERAL; }
0[0-7]*                             { yylval.int_value = strtol(yytext, NULL, 8);        return INT_LITERAL; }
[1-9]{D}*                           { yylval.int_value = strtol(yytext, NULL, 10);       return INT_LITERAL; }
0[xX]{H}+                           { yylval.int_value = strtol(yytext, NULL, 16);       return INT_LITERAL; }

{D}+[eE][+-]?{D}+                   { yylval.float_value = strtod(yytext, NULL);         return FLOAT_LITERAL; }
{D}+\.([eE][+-]?{D}+)?              { yylval.float_value = strtod(yytext, NULL);         return FLOAT_LITERAL; }
{D}*\.{D}+([eE][+-]?{D}+)?          { yylval.float_value = strtod(yytext, NULL);         return FLOAT_LITERAL; }
0[xX]{H}+\.?[pP][+-]?{H}+           { yylval.float_value = strtod(yytext, NULL);         return FLOAT_LITERAL; }
0[xX]{H}*\.{H}+[pP][+-]?{H}+        { yylval.float_value = strtod(yytext, NULL);         return FLOAT_LITERAL; }

\'(\\.|\\x[0-9a-fA-F]+|\\[0-7]{1,3}|[^'\\])\'  { 
                                        int consumed = 0;
                                        if (yytext[1] == '\\')
                                            yylval.char_value = (char)decode_escape(yytext + 1, &consumed);
                                        else
                                            yylval.char_value = yytext[1];
                                        return CHAR_LITERAL;
                                    }
\"(\\.|[^"\\])*\"                   { 
                                        int out_len = 0;
                                        yylval.string_value = process_string_escapes(yytext + 1, yyleng - 2, &out_len);    // Freed after use in parser.
                                                                                        return STRING_LITERAL;
                                    }
    /* Identifier. */
[a-zA-Z_][a-zA-Z0-9_]*              { 
                                        yylval.string_value = malloc(yyleng + 1);    // Freed after use in parser.
                                        strncpy(yylval.string_value, yytext, yyleng);
                                        yylval.string_value[yyleng] = '\0';
                                                                                        return IDENTIFIER;
                                    }

.                                   printf("Unmatched: '%s'\n", yytext);

%%

/* Decode a single escape sequence starting at s (s[0] == '\\').
   Sets *consumed to the number of input chars consumed (including backslash).
   Supports: \n \t \r \v \b \f \a \\ \' \" \? \0 \xNN... \NNN (octal, up to 3). */
static int decode_escape(const char *s, int *consumed)
{
    *consumed = 2;
    switch (s[1])
    {
    case 'n':  return '\n';
    case 't':  return '\t';
    case 'r':  return '\r';
    case 'v':  return '\v';
    case 'b':  return '\b';
    case 'f':  return '\f';
    case 'a':  return '\a';
    case '\\': return '\\';
    case '\'': return '\'';
    case '"':  return '"';
    case '?':  return '?';
    case '0': case '1': case '2': case '3':
    case '4': case '5': case '6': case '7':
    {
        int val = 0, i = 1;
        while (i <= 3 && s[i] >= '0' && s[i] <= '7')
        {
            val = val * 8 + (s[i] - '0');
            i++;
        }
        *consumed = i;
        return val & 0xFF;
    }
    case 'x':
    {
        int val = 0, i = 2;
        while ((s[i] >= '0' && s[i] <= '9') ||
               (s[i] >= 'a' && s[i] <= 'f') ||
               (s[i] >= 'A' && s[i] <= 'F'))
        {
            int d = (s[i] <= '9') ? (s[i] - '0')
                   : (s[i] <= 'F') ? (s[i] - 'A' + 10)
                   : (s[i] - 'a' + 10);
            val = val * 16 + d;
            i++;
        }
        *consumed = i;
        return val & 0xFF;
    }
    default:
        fprintf(stderr, "Warning: unknown escape sequence '\\%c'\n", s[1]);
        return s[1];
    }
}

/* Translate a string body (between the quotes) of given length, returning a
   newly malloc'd, NUL-terminated C string. Caller owns the buffer. */
static char *process_string_escapes(const char *src, int len, int *out_len)
{
    char *out = malloc(len + 1);
    int oi = 0;
    for (int i = 0; i < len; )
    {
        if (src[i] == '\\' && i + 1 < len)
        {
            int consumed = 0;
            out[oi++] = (char)decode_escape(src + i, &consumed);
            i += consumed;
        }
        else
        {
            out[oi++] = src[i++];
        }
    }
    out[oi] = '\0';
    if (out_len) *out_len = oi;
    return out;
}
