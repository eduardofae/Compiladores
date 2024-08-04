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

char *gen_code(char *operation, char* arg1, char* arg2, char* arg3){
    char *code = calloc(1, sizeof(char)*1024);
    if(!strcmp(operation, "storeAI")){
        sprintf(code, "%s %s => %s, %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "loadI")){
        sprintf(code, "%s %s => %s\n", operation, arg1, arg2);
    }
    else if(!strcmp(operation, "cmp_NE")){
        sprintf(code, "%s %s, %s -> %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "nop")){
        sprintf(code, "%s:\n%s\n", arg1, operation);
    }
    else if(!strcmp(operation, "jumpI")){
        sprintf(code, "%s -> %s\n", operation, arg1);
    }
    else if(!strcmp(operation, "or")){
        sprintf(code, "%s %s, %s => %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "and")){
        sprintf(code, "%s %s, %s => %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "cmp_EQ")){
        sprintf(code, "%s %s, %s -> %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "cmp_GE")){
        sprintf(code, "%s %s, %s -> %s\n", operation, arg1, arg2, arg3);
    }   
    else if(!strcmp(operation, "cmp_LE")){
        sprintf(code, "%s %s, %s -> %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "cmp_GT")){
        sprintf(code, "%s %s, %s -> %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "cmp_LT")){
        sprintf(code, "%s %s, %s -> %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "add")){
        sprintf(code, "%s %s, %s => %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "sub")){
        sprintf(code, "%s %s, %s => %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "mult")){
        sprintf(code, "%s %s, %s => %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "div")){
        sprintf(code, "%s %s, %s => %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "multI")){
        sprintf(code, "%s %s, %s => %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "loadAI")){
        sprintf(code, "%s %s, %s => %s\n", operation, arg1, arg2, arg3);
    }
    else if(!strcmp(operation, "cbr")){
        sprintf(code, "%s %s -> %s, %s\n", operation, arg1, arg2, arg3);
    }

    return code;
}

char *merge_code(int num_codes, ...){
    char *code = calloc(1, sizeof(char)*1024);
    int i = 0; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!MUITO IMPORTANTE NÃO REMOVER POR NADA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    va_list valist;
    va_start(valist, num_codes);

    for(int i = 0; i < num_codes; i++){
        strcat(code, va_arg(valist, char*));
    }

    va_end(valist);
    return code;
}