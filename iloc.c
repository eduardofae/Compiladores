#include "iloc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


char *new_label(){
    static int label = 1;
    char *str = calloc(1, sizeof(char)*(label/10+2));
    sprintf(str, "L%d", label);
    label++;
    return str;
}

char *new_temp(){
    static int temp = 1;
    char *str = calloc(1, sizeof(char)*(temp/10+2));
    sprintf(str, "r%d", temp);
    temp++;
    return str;
}

void export_code(struct iloc_list *iloc_list){
    for (int i = 0; i < iloc_list->num_ilocs; i++)
    {
        struct iloc *iloc = iloc_list->iloc[i];
        char *operation = iloc->operation;
        char **args = iloc->args;
        if(!strcmp(operation, "storeAI")){
            printf("%s %s => %s, %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "loadI")){
            printf("%s %s => %s\n", operation, args[0], args[1]);
        }
        else if(!strcmp(operation, "cmp_NE")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "nop")){
            printf("%s:\n%s\n", args[0], operation);
        }
        else if(!strcmp(operation, "jumpI")){
            printf("%s -> %s\n", operation, args[0]);
        }
        else if(!strcmp(operation, "or")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "and")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cmp_EQ")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cmp_GE")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }   
        else if(!strcmp(operation, "cmp_LE")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cmp_GT")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cmp_LT")){
            printf("%s %s, %s -> %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "add")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "sub")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "mult")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "div")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "multI")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "loadAI")){
            printf("%s %s, %s => %s\n", operation, args[0], args[1], args[2]);
        }
        else if(!strcmp(operation, "cbr")){
            printf("%s %s -> %s, %s\n", operation, args[0], args[1], args[2]);
        }
    }
}

struct iloc_list *merge_code(int num_codes, ...){
    struct iloc_list *list = new_iloc_list();
    va_list valist;
    va_start(valist, num_codes);
    for(int i = 0; i < num_codes; i++){
        struct iloc_list *aux = va_arg(valist, struct iloc_list *);
        for(int j = 0; j < aux->num_ilocs; j++)
        {
            add_iloc(list, aux->iloc[j]);   
        }
    }
    va_end(valist);
    return list;
}

struct iloc_list *gen_code(char *operation, char* arg1, char* arg2, char* arg3){
    struct iloc_list *list = new_iloc_list();
    struct iloc *iloc = new_iloc(operation, arg1, arg2, arg3);
    add_iloc(list, iloc);   
    return list;
}

struct iloc_list *new_iloc_list()
{
  struct iloc_list *ret = NULL;
  ret = calloc(1, sizeof(struct iloc_list));
  if (ret != NULL) {
    ret->iloc = NULL;
    ret->num_ilocs = 0;
  }
  return ret;
}

struct iloc *new_iloc(char *operation, char* arg1, char* arg2, char* arg3)
{
  struct iloc *ret = NULL;
  ret = calloc(1, sizeof(struct iloc));
  if (ret != NULL) {
    ret->operation = operation;
    ret->num_args = 0;
    add_iloc_arg(ret, arg1);
    add_iloc_arg(ret, arg2);
    add_iloc_arg(ret, arg3);
  }
  return ret;
}

void add_iloc_arg(struct iloc *iloc, char* arg)
{
  if (iloc != NULL && arg != NULL) {
    iloc->num_args++;
    iloc->args = realloc(iloc->args, iloc->num_args * sizeof(char*));
    iloc->args[iloc->num_args-1] = arg;
  }
}

void add_iloc(struct iloc_list *iloc_list, struct iloc *iloc)
{
  if (iloc_list != NULL && iloc != NULL) {
    iloc_list->num_ilocs++;
    iloc_list->iloc = realloc(iloc_list->iloc, iloc_list->num_ilocs * sizeof(struct iloc *));
    iloc_list->iloc[iloc_list->num_ilocs-1] = iloc;
  }
}