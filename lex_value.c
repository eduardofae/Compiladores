#include "lex_value.h"

struct val new_value(int line, int type, char* token) {
    struct val novo;
    novo.line = line;
    novo.type = type;
    novo.token = token;
    return novo;
}
