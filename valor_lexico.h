#define ID  0
#define LIT 1

struct val {
    int   line;
    int   type;
    char* token;
};

struct val cria_valor(int line, int type, char* token);