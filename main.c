#include <stdio.h>
#include "ast.h"
extern int yyparse(void);
extern int yylex_destroy(void);
void *arvore = NULL;
void *stack = NULL;

int main (int argc, char **argv)
{
  int ret = yyparse(); 
  exporta(arvore);
  free_ast(arvore);
  yylex_destroy();
  return ret;
}
