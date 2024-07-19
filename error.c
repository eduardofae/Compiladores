#include "error.h"

enum error_types check_nature(struct entry entry, enum natures nature){
    if(entry.nature == VAR && nature == FUNC){
        error_message(ERR_VARIABLE);
        return ERR_VARIABLE;
    }
    if(entry.nature == FUNC && nature == VAR){
        error_message(ERR_FUNCTION);
        return ERR_FUNCTION;
    }
    return ERR_NONE;
}

void error_message(enum error_types error)
{
    switch(error){
        case ERR_UNDECLARED:
            printf();
            return;
        case ERR_DECLARED:
            printf();
            return;
        case ERR_VARIABLE:
            printf();
            return;
        case ERR_FUNCTION:
            printf();
            return;
    }
}