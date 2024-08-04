#ifndef _ILOC_H_
#define _ILOC_H_

// struct iloc {
//     char  *operation;
//     char **args;
// };

// struct iloc_list {
//     struct iloc **list;
// };

char *new_label();
char *new_temp();

char *gen_code(char *operation, char* arg1, char* arg2, char* arg3);
char *merge_code(int num_codes, ...);

#endif //_ILOC_H_