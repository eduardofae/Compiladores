#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

ast *new_ast(const char *label, enum types type)
{
    ast *ret = NULL;
    ret = calloc(1, sizeof(ast));
    if (ret != NULL) {
        ret->type = type;
        ret->label = strdup(label);
        ret->number_of_children = 0;
        ret->children = NULL;
        ret->father = NULL;
    }
    return ret;
}

void free_ast(ast *tree)
{
    if (tree != NULL) {
        int i;
        for (i = 0; i < tree->number_of_children; i++) {
        free_ast(tree->children[i]);
        }
        free(tree->children);
        free(tree->label);
        free(tree);
    }
}

void add_child(ast *tree, ast *child)
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

void exporta_ast(ast *tree)
{
    int i;
    if (tree != NULL) {
        printf("%p [label=\"%s\"];\n", tree, tree->label);

        for (i = 0; i < tree->number_of_children; i++) {
            printf("%p, %p\n", tree, tree->children[i]);
        }

        for (i = 0; i < tree->number_of_children; i++) {
            exporta_ast(tree->children[i]);
        }
    }
}

void exporta_code(ast *tree)
{
    if(tree != NULL)
    {
        generateAsm(tree->code);
    }
}

void exporta_cfg(ast *tree)
{
    if(tree != NULL)
    {
        export_cfg(tree->code);
    }
}