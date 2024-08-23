#ifndef _CFG_H_
#define _CFG_H_
#include "types.h"
#include "iloc.h"

struct cfg {
    char **labels;
    int num_labels;
    int start_line;
    int end_line;
    char **edges;
    int num_edges;
};

struct cfg_list {
    struct cfg **nodes;
    int num_nodes;
};

struct cfg *new_cfg(int line);
void add_edge(struct cfg *node1, char *node2);
void add_label(struct cfg *node, char* label, int line);

struct cfg_list *new_cfg_list();
void add_cfg(struct cfg_list *cfg_list, struct cfg *node);
struct cfg *get_node(struct cfg_list *cfg, char *label);

void export_cfg(struct iloc_list *iloc_list);
void print_dot(struct cfg_list *cfg);

#endif //_CFG_H_