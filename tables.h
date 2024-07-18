#ifndef _TABLES_H_
#define _TABLES_H_

#include "types.h"
#include "lex_value.h"

struct entry {
    int line;
    enum natures nature;
    enum types type;
    struct val value;
};

struct table {
    struct entry **entries;
    int num_entries;
};

struct table_stack{
    struct table *top;
    struct table_stack *next;
};

struct val cria_valor(int line, int type, char* token);

struct table *create_table();

void add_entry(struct table *table, struct entry *entry);

void free_table(struct table *table);

struct entry create_entry(int line, enum natures nature, enum types type, struct val value);

struct table_stack *create_table_stack();

void pop_table(struct table_stack *table_stack);

void push_table(struct table_stack *table_stack, struct table *new_table);

struct entry *search_table(struct table *table, char *label);

struct entry *search_stack(struct table_stack *table_stack, char *label);

#endif //_TABLES_H_