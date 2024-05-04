#include "valor_lexico.h"

struct val cria_valor(int line, int type, char* token) {
    struct val novo;
    novo.line = line;
    novo.type = type;
    novo.token = token;
    return novo;
}