#ifndef _ERROR_H_
#define _ERROR_H_

#include "types.h"
#include "tables.h"

enum error_types{
    ERR_UNDECLARED = 10,
    ERR_DECLARED   = 11,
    ERR_VARIABLE   = 20,
    ERR_FUNCTION   = 21,
    ERR_NONE       = 0
};

enum error_types check_nature(struct entry entry, enum natures nature);

void error_message(enum error_types error);

#endif //_ERROR_H_