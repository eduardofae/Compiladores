#include "types.h"
#include <string.h>

enum types infer_type(enum types type1, enum types type2) {
    if(type1 >= type2) return type1;
    return type2;
}