#ifndef _ARVORE_H_
#define _ARVORE_H_
#include "types.h"
#include "iloc.h"

typedef struct tree {
  char *label;
  enum types type;
  int number_of_children;
  struct tree *father;
  struct tree **children;

  // Geração de código
  // struct iloc_list code;
  struct iloc_list *code;
  char *temp;
} ast;

// Cria um novo nodo de ast
ast *new_ast(const char *label, enum types type);

// Libera recursivamente a memória alocada para um nodo de ast e seus filhos
void free_ast(ast *tree);

// Adiciona um filho a um nodo ast
void add_child(ast *tree, ast *child);

// Dado um nodo de uma ast, retorna o nodo ast raiz da árvore
ast *get_root(ast *tree);

// Printa formatado de acordo com os requerimentos da etapa 3 informações de um dado nodo ast
void exporta_ast(ast *tree);

// Printa formatado o código assembly de acordo com a estrutura iloc_list presente em ast
void exporta_code(ast *tree);

#endif //_ARVORE_H_
