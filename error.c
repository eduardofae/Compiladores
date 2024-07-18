#include "error.h"

enum error_types check_nature(struct entry entry, enum natures nature){
    if(entry.nature == VAR && nature == FUNC){
        return ERR_VARIABLE;
    }
    if(entry.nature == VAR && nature == FUNC){
        return ERR_FUNCTION;
    }
    else{
        ERR_NONE;
    }
}