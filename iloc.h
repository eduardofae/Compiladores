#ifndef _ILOC_H_
#define _ILOC_H_

#define MAX_NUM_ARGS 3

struct iloc {
    char  *operation;
    char **args;
    int num_args;
};

struct iloc_list {
    struct iloc **iloc;
    int num_ilocs;
};

char *new_label();
char *new_temp();

struct iloc *new_iloc(char *operation, char* arg1, char* arg2, char* arg3);
void add_iloc_arg(struct iloc *iloc, char* arg);

struct iloc_list *new_iloc_list();
void add_iloc(struct iloc_list *iloc_list, struct iloc *iloc);

struct iloc_list *gen_code(char *operation, char* arg1, char* arg2, char* arg3);
struct iloc_list *merge_code(int num_codes, ...);
void export_code(struct iloc_list *iloc_list);


#endif //_ILOC_H_