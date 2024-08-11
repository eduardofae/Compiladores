#include <stdio.h>
#include "ast.h"
#include "iloc.h"
extern int yyparse(void);
extern int yylex_destroy(void);
void *arvore = NULL;

int main (int argc, char **argv)
{
    int ret = yyparse(); 
    exporta_code(arvore);
    free_ast(arvore);
    yylex_destroy();
    return ret;
}
