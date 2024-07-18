#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ast.h"
#define ARQUIVO_SAIDA "saida.dot"

ast *ast_new(const char *label)
{
  ast *ret = NULL;
  ret = calloc(1, sizeof(ast));
  if (ret != NULL) {
    ret->label = strdup(label);
    ret->number_of_children = 0;
    ret->children = NULL;
    ret->father = NULL;
  }
  return ret;
}

void ast_free(ast *tree)
{
  if (tree != NULL) {
    int i;
    for (i = 0; i < tree->number_of_children; i++) {
      ast_free(tree->children[i]);
    }
    free(tree->children);
    free(tree->label);
    free(tree);
  }
}

void ast_add_child(ast *tree, ast *child)
{
  if (tree != NULL && child != NULL) {
    tree->number_of_children++;
    tree->children = realloc(tree->children, tree->number_of_children * sizeof(ast*));
    tree->children[tree->number_of_children-1] = child;
    child->father = tree;
  }
}

ast *get_root(ast *tree)
{
  if (tree != NULL) {
    if (tree->father != NULL) {
      return get_root(tree->father);
    }
    else {
      return tree;
    }
  }
}

void exporta(ast *tree)
{
  int i;
  if (tree != NULL) {
    printf("%p [label=\"%s\"];\n", tree, tree->label);

    for (i = 0; i < tree->number_of_children; i++) {
      printf("%p, %p\n", tree, tree->children[i]);
    }

    for (i = 0; i < tree->number_of_children; i++) {
      exporta(tree->children[i]);
    }
  }
}