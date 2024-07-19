#include "tables.h"
#include <string.h>
#include <stdlib.h>


struct entry new_entry(int line, enum natures nature, enum types type, struct val value){
    struct entry entry;
    entry.line = line;
    entry.nature = nature;
    entry.type = type;
    entry.value = value;
    return entry;
}

struct table *new_table(){
    struct table *table = NULL;
    table = calloc(1, sizeof(struct table));
    if (table != NULL){
        table->entries = NULL;
        table->num_entries = 0;
    }
    return table;
}

void add_entry(struct table *table, struct entry *entry){
    if (table != NULL && entry != NULL) {
        table->num_entries++;
        table->entries = realloc(table->entries, table->num_entries * sizeof(struct entry));
        table->entries[table->num_entries-1] = entry;
    }
}

struct entry *search_table(struct table *table, char *label){
    for(int i = 0; i < table->num_entries; i++){
        struct entry *entry = table->entries[i];
        if(!strcmp(entry->value.token, label)){
            return entry;
        }
    }
    return NULL;
}

void free_table(struct table *table)
{
  if (table != NULL) {
    int i;
    for (i = 0; i < table->num_entries; i++) {
      free(table->entries[i]);
    }
    free(table->entries);
    free(table);
  }
}

struct table_stack *new_table_stack(){
    struct table_stack *table_stack = NULL;
    table_stack = calloc(1, sizeof(struct table_stack));
    if (table_stack != NULL){
        table_stack->top = NULL;
        table_stack->next = NULL;
    }
    return table_stack;
}

void push_table(struct table_stack *table_stack, struct table *new_table){
    if (new_table != NULL) {
        if(table_stack == NULL){
            table_stack = new_table_stack();
        }
        if(table_stack->top != NULL) {
            struct table_stack *next = new_table_stack();
            next->top = table_stack->top;
            next->next = table_stack->next;
            table_stack->next = next;
        }
        table_stack->top = new_table;
    }
}

void pop_table(struct table_stack *table_stack){
    if(table_stack != NULL){
        struct table_stack *aux = table_stack->next;
        table_stack->top  = table_stack->next->top;
        table_stack->next = table_stack->next->next;

        free_single_table_stack(aux);
    }
}

struct entry *search_table_stack(struct table_stack *table_stack, char *label){
    if(table_stack == NULL) {
        return NULL;
    }

    struct table_stack *aux = new_table_stack();
    aux->top = table_stack->top;
    aux->next = table_stack->next;
    do{
        struct entry *entry = search_table(aux->top, label);
        if(entry != NULL) {
            free_single_table_stack(aux);
            return entry;
        }
        aux->top = aux->next->top;
        aux->next = aux->next->next;
    }while(aux->next != NULL);

    free_single_table_stack(aux);
    return NULL;
}

void free_single_table_stack(struct table_stack *table_stack){
    free(table_stack->top);
    free(table_stack->next);
    free(table_stack);
}


void free_table_stack(struct table_stack *table_stack){
    //for()
    free_single_table_stack(table_stack);
}
