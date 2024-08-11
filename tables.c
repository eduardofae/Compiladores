#include "tables.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>


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
    if (table != NULL) {
        table->entries = NULL;
        table->num_entries = 0;
        table->scope = "rip";
    }
    return table;
}

void add_entry(struct table *table, struct entry *entry){
    if(table == NULL || entry == NULL) return;
    table->num_entries++;
    sprintf(entry->shift, "%d", -SIZE_OF_INT*table->num_entries);
    entry->scope = strdup(table->scope);

    table->entries = realloc(table->entries, table->num_entries * sizeof(struct entry));
    table->entries[table->num_entries-1] = entry;
}

struct entry *search_table(struct table *table, char *label){
    if(table == NULL) return NULL;
    
    for(int i = 0; i < table->num_entries; i++) {
        struct entry *entry = table->entries[i];
        if(!strcmp(entry->value.token, label)) return entry;
    }
    return NULL;
}

void free_table(struct table *table){
    if(table == NULL) return;

    int i;
    for (i = 0; i < table->num_entries; i++) {
        free(table->entries[i]);
    }
    free(table->entries);
    free(table);
}

struct table_stack *new_table_stack(){
    struct table_stack *table_stack = NULL;
    table_stack = calloc(1, sizeof(struct table_stack));
    if (table_stack != NULL) {
        table_stack->top = NULL;
        table_stack->next = NULL;
    }
    return table_stack;
}

void push_table(struct table_stack **table_stack, struct table *new_table){
    if(new_table == NULL) return;

    if(*table_stack == NULL) {
        *table_stack = new_table_stack();
    }
    if((*table_stack)->top != NULL) {
        struct table_stack *next = new_table_stack();
        next->top = (*table_stack)->top;
        next->next = (*table_stack)->next;
        (*table_stack)->next = next;
        new_table->scope = "rbp";
    }
    (*table_stack)->top = new_table;
}

void pop_table(struct table_stack *table_stack){
    if(table_stack == NULL) return;

    free_table(table_stack->top);
    if(table_stack->next != NULL) {
        struct table_stack *aux = table_stack->next;
        table_stack->top = table_stack->next->top;
        table_stack->next = table_stack->next->next;
        free(aux);
    }
    else {
        free(table_stack);
        table_stack = NULL;
    }
}

struct entry *search_table_stack(struct table_stack *table_stack, char *label){
    if(table_stack == NULL) return NULL;

    struct table_stack *aux = table_stack;
    while(aux != NULL) {
        struct entry *entry = search_table(aux->top, label);
        if(entry != NULL) return entry;
        aux = aux->next;
    }
    return NULL;
}

void free_table_stack(struct table_stack *table_stack){
    if(table_stack == NULL) return;

    free_table_stack(table_stack->next);
    free_table(table_stack->top);
    free(table_stack);
}