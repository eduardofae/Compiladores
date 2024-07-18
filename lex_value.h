#ifndef _LEX_VALUE_H_
#define _LEX_VALUE_H_

#include "types.h"

struct val {
    int line;
    enum token_types type;
    char* token;
};

struct val cria_valor(int line, int type, char* token);

#endif //_LEX_VALUE_H_