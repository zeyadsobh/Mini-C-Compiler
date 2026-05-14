#include <assert.h>
#include <stdio.h>
#include <string.h>

extern int yyparse();
extern FILE *yyin;
extern FILE *output_file;

extern void create_program();
extern void scope_down();
extern void quadruples();
extern void destroy_global_table();
extern void destroy_program();
extern char *get_error_message();

extern int yylineno;

_Bool errored = 0;
static _Bool verbose = 0;

static _Bool is_verbose_flag(const char *arg)
{
    return strcmp(arg, "-v") == 0 || strcmp(arg, "--verbose") == 0;
}

int yyerror(char *error)
{
    char *message = get_error_message();
    message = message == NULL ? error : message;
    assert(message != NULL);
    fprintf(stderr, "Error on line %d: %s\n", yylineno, message);

    errored = 1;
    return 1;
}

int main(int argc, char **argv)
{
    const char *input_filename = NULL;
    for (int i = 1; i < argc; i++)
    {
        if (is_verbose_flag(argv[i]))
        {
            verbose = 1;
        }
        else if (input_filename == NULL)
        {
            input_filename = argv[i];
        }
        else
        {
            fprintf(stderr, "Usage: %s <filename> [-v|--verbose]\n", argv[0]);
            return 1;
        }
    }

    if (input_filename == NULL)
    {
        fprintf(stderr, "Usage: %s <filename> [-v|--verbose]\n", argv[0]);
        return 1;
    }

    yyin = fopen(input_filename, "r");
    if (yyin == NULL)
    {
        fprintf(stderr, "Error: Could not open file %s\n", input_filename);
        return 1;
    }

    create_program();

    scope_down();

    if (verbose) printf("Parsing...\n");

    yyparse();

    fclose(yyin);

    if (verbose) printf("Parsing complete.\n");

    if (!errored)
    {
        char *output_filename = "output.asm";
        output_file = fopen(output_filename, "w");
        if (output_file == NULL)
        {
            fprintf(stderr, "Error: Could not open file %s\n", output_filename);
            return 1;
        }

        quadruples();

        fclose(output_file);

        if (verbose) printf("\nCode generation complete.\n");
    }

    destroy_global_table();
    destroy_program();

    if (verbose) printf("\nCleanup successful.\n");

    return 0;
}
