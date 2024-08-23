#include "cfg.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

void export_cfg(struct iloc_list *iloc_list){
    int line = 1;
    struct cfg_list *cfg = new_cfg_list();
    enum bool new_label = FALSE;
    enum bool jump_i = FALSE;
    char *label = "L0";
    for (int i = 0; i < iloc_list->num_ilocs; i++)
    {
        struct iloc *iloc = iloc_list->iloc[i];
        char *operation = iloc->operation;
        char **args = iloc->args;
        if(!!strcmp(operation, "label")) new_label = FALSE;
        
        if(!strcmp(operation, "storeAI")){
            line++;
        }
        else if(!strcmp(operation, "loadI")){
            line++;
        }
        else if(!strcmp(operation, "cmp_NE")){
            line+=3;
        }
        else if(!strcmp(operation, "cmp_EQ")){
            line+=3;
        }
        else if(!strcmp(operation, "label")){
            line++;
            label = args[0];
            if(!new_label){
                struct cfg *node = new_cfg(line);
                if(!jump_i) add_edge(cfg->nodes[cfg->num_nodes-1], label);
                add_cfg(cfg, node);
                jump_i = FALSE;
            }
            add_label(cfg->nodes[cfg->num_nodes-1], label, line);
            new_label = TRUE;
        }
        else if(!strcmp(operation, "jumpI")){
            line++;
            add_edge(cfg->nodes[cfg->num_nodes-1], args[0]);
            jump_i = TRUE;
        }
        else if(!strcmp(operation, "cmp_GE")){
            line+=3;
        }   
        else if(!strcmp(operation, "cmp_LE")){
            line+=3;
        }
        else if(!strcmp(operation, "cmp_GT")){
            line+=3; 
        }
        else if(!strcmp(operation, "cmp_LT")){
            line+=3;
        }
        else if(!strcmp(operation, "add")){
            line++;
        }
        else if(!strcmp(operation, "sub")){
            line++;
        }
        else if(!strcmp(operation, "mult")){
            line++;
        }
        else if(!strcmp(operation, "div")){
            line+=5;
        }
        else if(!strcmp(operation, "loadAI")){
            line++;
        }
        else if(!strcmp(operation, "je")){
            line++;
            add_edge(cfg->nodes[cfg->num_nodes-1], args[1]);
        }
        else if(!strcmp(operation, "jne")){
            line++;
            add_edge(cfg->nodes[cfg->num_nodes-1], args[1]);
        }
        else if(!strcmp(operation, "neg")){
            line++;
        }
        else if(!strcmp(operation, "return")){
            line+=3;
            remove_edges(cfg->nodes[cfg->num_nodes-1]);
            jump_i = TRUE;
        }
        else if(!strcmp(operation, "func")){
            struct cfg *node = new_cfg(line);
            add_label(node, label, line);
            add_cfg(cfg, node);
            line+=2;
        }

        if(!!strcmp(operation, "global")){
            cfg->nodes[cfg->num_nodes-1]->end_line = line;
        }
    }
    print_dot(cfg);
}

void print_dot(struct cfg_list *cfg){
    printf("digraph G {\n");
    for(int i=0; i < cfg->num_nodes; i++) {
        struct cfg *node = cfg->nodes[i]; 
        for(int j=0; j < node->num_edges; j++){
            char *label = node->edges[j];
            struct cfg *node2 = get_node(cfg, label);
            printf("\"%d-%d\" -> \"%d-%d\";\n", node->start_line, node->end_line-1, node2->start_line, node2->end_line-1);
        }
    }
    printf("}\n");
}

struct cfg_list *new_cfg_list(){
    struct cfg_list *ret = NULL;
    ret = calloc(1, sizeof(struct cfg_list));
    if (ret != NULL) {
        ret->nodes = NULL;
        ret->num_nodes = 0;
    }
    return ret;
}

struct cfg *new_cfg(int line){
    struct cfg *ret = NULL;
    ret = calloc(1, sizeof(struct cfg));
    if (ret != NULL) {
        ret->edges = NULL;
        ret->num_edges = 0;
        ret->start_line = line;
        ret->end_line = line;
        ret->num_labels = 0;
        ret->labels = NULL;
    }
    return ret;
}

void add_edge(struct cfg *node, char* node2){
    if (node != NULL && node2 != NULL) {
        node->num_edges++;
        node->edges = realloc(node->edges, node->num_edges * sizeof(char*));
        node->edges[node->num_edges-1] = strdup(node2);
    }
}

void add_cfg(struct cfg_list *cfg_list, struct cfg *cfg){
    if (cfg_list != NULL && cfg != NULL) {
        cfg_list->num_nodes++;
        cfg_list->nodes = realloc(cfg_list->nodes, cfg_list->num_nodes * sizeof(struct cfg *));
        cfg_list->nodes[cfg_list->num_nodes-1] = cfg;
    }
}

struct cfg *get_node(struct cfg_list *cfg, char *label){
    for(int i=0; i < cfg->num_nodes; i++){
        struct cfg *node = cfg->nodes[i];
        for(int j=0; j < node->num_labels; j++){
            if(!strcmp(node->labels[j], label)){
                return node;
            }
        }
    }
}

void add_label(struct cfg *node, char* label, int line){
    if (node != NULL && label != NULL) {
        node->num_labels++;
        node->labels = realloc(node->labels, node->num_labels * sizeof(char*));
        node->labels[node->num_labels-1] = strdup(label);
        node->start_line = line;
    }
}

void remove_edges(struct cfg *node){
    node->edges = NULL;
    node->num_edges = 0;
}