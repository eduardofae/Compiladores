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

int get_register_index(enum bool *registers){
    int i = 0;
    while (i < MAX_NUMBER_OF_REGISTERS){
        if (registers[i] == FALSE){
            return i;
        }
        i++;
    }
    return -1;
}

void clear_registers(enum bool *registers){
    for (int i = 0; i < MAX_NUMBER_OF_REGISTERS; i++){
        registers[i] = FALSE;
    }
}

void export_code(struct iloc_list *iloc_list){
    enum bool registers[MAX_NUMBER_OF_REGISTERS] = { FALSE };  // Init registers with FALSE = 0
    char *register_names[MAX_NUMBER_OF_REGISTERS] = {"%r8d", "%r9d", "%r10d", "%r11d", "%r12d", "%r13d", "%r14d", "%r15d"};

    for (int i = 0; i < iloc_list->num_ilocs; i++)
    {
        int index = get_register_index(registers);
        struct iloc *iloc = iloc_list->iloc[i];
        char *operation = iloc->operation;
        char **args = iloc->args;
        
        if(!strcmp(operation, "storeAI")){
            printf("\tmovl %s, %s(%%%s)\n", register_names[index-1], args[2], args[1]);
            registers[index-1] = FALSE;
            
        }
        else if(!strcmp(operation, "loadI")){
            printf("\tmovl $%s, %s\n", args[0], register_names[index]);
            registers[index] = TRUE;
            
        }
        else if(!strcmp(operation, "cmp_NE")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetne %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "cmp_EQ")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsete %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "label")){
            printf(".%s:\n", args[0]);
        }
        else if(!strcmp(operation, "jumpI")){
            printf("\tjmp .%s\n", args[0]);
            clear_registers(registers);
        }
        else if(!strcmp(operation, "cmp_GE")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetge %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }   
        else if(!strcmp(operation, "cmp_LE")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetle %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "cmp_GT")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetg %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "cmp_LT")){
            printf("\tcmp %s, %s\n", register_names[index-1], register_names[index-2]);
            printf("\tsetl %%al\n");
            printf("\tmovzbl %%al, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "add")){
            printf("\taddl %s, %s\n", register_names[index-1], register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "sub")){
            printf("\tsubl %s, %s\n", register_names[index-1], register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "mult")){
            printf("\timull %s, %s\n", register_names[index-1], register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "div")){
            printf("\tmovl %s, %%ecx\n", register_names[index-1]);
            printf("\tmovl %s, %%eax\n", register_names[index-2]);
            printf("\tcltd\n");
            printf("\tidivl %%ecx\n");
            printf("\tmovl %%eax, %s\n", register_names[index-2]);
            registers[index-1] = FALSE;
            
            
        }
        else if(!strcmp(operation, "loadAI")){
            printf("\tmovl %s(%%%s), %s\n", args[1], args[0], register_names[index]);
            registers[index] = TRUE;
            
        }
        else if(!strcmp(operation, "je")){
            printf("\tje .%s\n", args[1]);
            clear_registers(registers);
        }
        else if(!strcmp(operation, "jne")){
            printf("\tjne .%s\n", args[1]);
            clear_registers(registers);
        }
        else if(!strcmp(operation, "neg")){
            printf("\tnegl %s\n", register_names[index-1]);
            
        }
        else if(!strcmp(operation, "return")){
            printf("\tmovl %s, %%eax\n", register_names[index-1]);
            printf("\tpopq %%rbp\n");
            printf("\tret\n\n");
            
        }
        else if(!strcmp(operation, "func")){
            printf("\t.text\n");
            printf("\t.globl %s\n", args[0]);
            printf("\t.type %s, @function\n", args[0]);
            printf("%s:\n", args[0]);
            printf("\tpushq %%rbp\n");
            printf("\tmovq %%rsp, %%rbp\n");
        }
        else if(!strcmp(operation, "global")){
            printf("\t.text\n");
            printf("\t.globl %s\n", args[0]);
            printf("\t.bss\n");
            printf("\t.align 4\n");
            printf("\t.type %s, @object\n", args[0]);
            printf("\t.size %s, 4\n", args[0]);
            printf("%s:\n", args[0]);
            printf("\t.zero	4\n");
        }
    }
}

struct iloc_list *merge_code(int num_codes, ...){
    struct iloc_list *list = new_iloc_list();
    va_list valist;
    va_start(valist, num_codes);
    for(int i = 0; i < num_codes; i++){
        struct iloc_list *aux = va_arg(valist, struct iloc_list *);
        if (aux != NULL){
            for(int j = 0; j < aux->num_ilocs; j++){
                add_iloc(list, aux->iloc[j]);   
            }
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
    iloc->args[iloc->num_args-1] = strdup(arg);
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