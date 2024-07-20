#include "error.h"
#include <stdio.h>

enum error_types check_use(struct entry *entry, enum natures nature, int line, char *label){
    if(entry == NULL){
        error_message(ERR_UNDECLARED, label, 0, line);
        return ERR_UNDECLARED;
    } 

    return check_nature(*entry, nature, line);
}

enum error_types check_declaration(struct entry *entry, enum natures nature, int line){
    if(entry != NULL){
        error_message(ERR_DECLARED, entry->value.token, entry->line, line);
        return ERR_DECLARED;
    }
    return ERR_NONE;
}

enum error_types check_nature(struct entry entry, enum natures nature, int line){
    if(entry.nature == VAR && nature == FUNC){
        error_message(ERR_VARIABLE, entry.value.token, entry.line, line);
        return ERR_VARIABLE;
    }
    if(entry.nature == FUNC && nature == VAR){
        error_message(ERR_FUNCTION, entry.value.token, entry.line, line);
        return ERR_FUNCTION;
    }
    return ERR_NONE;
}

void error_message(enum error_types error, char *label, int d_line, int u_line)
{
    switch(error){
        case ERR_UNDECLARED:
            printf("Erro: A variável %s, na linha %d não foi declarada!", label, u_line);
            return;
        case ERR_DECLARED:
            printf("Erro: A variável %s, na linha %d já foi declarada na linha %d!", label, u_line, d_line);
            return;
        case ERR_VARIABLE:
            printf("Erro: A variável %s, declarada na linha %d, foi utilizada como uma função na linha %d!", label, d_line, u_line);
            return;
        case ERR_FUNCTION:
            printf("Erro: A função %s, declarada na linha %d, foi utilizada como uma variável na linha %d!", label, d_line, u_line);
            return;
    }
}