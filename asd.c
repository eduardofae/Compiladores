#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "asd.h"
#define ARQUIVO_SAIDA "saida.dot"

asd_tree_t *asd_new(const char *label)
{
  asd_tree_t *ret = NULL;
  ret = calloc(1, sizeof(asd_tree_t));
  if (ret != NULL){
    ret->label = strdup(label);
    ret->number_of_children = 0;
    ret->children = NULL;
  }
  return ret;
}

void asd_free(asd_tree_t *tree)
{
  if (tree != NULL){
    int i;
    for (i = 0; i < tree->number_of_children; i++){
      asd_free(tree->children[i]);
    }
    free(tree->children);
    free(tree->label);
    free(tree);
  }else{
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_add_child(asd_tree_t *tree, asd_tree_t *child)
{
  if (tree != NULL && child != NULL){
    tree->number_of_children++;
    tree->children = realloc(tree->children, tree->number_of_children * sizeof(asd_tree_t*));
    tree->children[tree->number_of_children-1] = child;
  }else{
    if (tree == NULL) {
      printf("Erro: %s recebeu parâmetro tree = %p / %p.\n", __FUNCTION__, tree, child);
    }
    else {
      
    }
  }
}

void asd_add_father(asd_tree_t *tree, asd_tree_t *father)
{
  if (tree != NULL && father != NULL){
    tree->father = father;
    asd_add_child(father, tree);
  }else{
    if (father == NULL) {
      printf("Erro: %s recebeu parâmetro tree = %p / %p.\n", __FUNCTION__, tree, father);
    }
    else {
      
    }
  }
}

asd_tree_t *get_root(asd_tree_t *tree)
{
  if (tree != NULL)
  {
    if (tree->father != NULL)
    {
      return get_root(tree->father);
    }
    else
    {
      return tree;
    }
  }
}

void exporta(asd_tree_t *tree)
{
  int i;
  if (tree != NULL){
    printf("%p [label=\"%s\"];\n", tree, tree->label);

    for (i = 0; i < tree->number_of_children; i++){
      printf("%p, %p\n", tree, tree->children[i]);
    }

    for (i = 0; i < tree->number_of_children; i++){
      exporta(tree->children[i]);
    }

  }else{
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}