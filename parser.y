    /* Trabalho de Compiladores:
        Integrantes:
         - Eduardo Dalmás Faé (00334087)
         - João Pedro Kuhn Braun (00325265)
    */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    int yylex (void);
    void yyerror (char const *mensagem);
%}

/* Tornando o retorno a respeito do erro mais legível */
%{
    extern int yylineno;
    extern void *arvore;
    struct tree *tree;
    struct table_stack *stack;
    enum types cur_type;
%}
%define parse.error verbose

%code requires { #include "ast.h" 
                 #include "types.h"
                 #include "tables.h"
                 #include "lex_value.h"
                 #include "error.h"
                 #include "iloc.h" }

%union {
    struct val valor_lexico;
    ast *no;
    char *label;
}

%token TK_PR_BOOL
%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_IF
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_RETURN
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token <valor_lexico> TK_IDENTIFICADOR
%token <valor_lexico> TK_LIT_INT
%token <valor_lexico> TK_LIT_FLOAT
%token <valor_lexico> TK_LIT_FALSE
%token <valor_lexico> TK_LIT_TRUE
%token TK_ERRO

%type<no> program
%type<no> lst_elements
%type<no> element
%type<no> type
%type<no> global_var
%type<no> lst_ids
%type<no> func
%type<no> header
%type<no> lst_parameters
%type<no> parameter
%type<no> body
%type<no> command_block
%type<no> lst_commands
%type<no> command
%type<no> local_var
%type<no> atrib
%type<no> func_call
%type<no> lst_args
%type<no> return
%type<no> control_flux
%type<no> conditional
%type<no> iteractive
%type<no> expression
%type<no> or_exp
%type<no> and_exp
%type<no> eq_exp
%type<no> ineq_exp
%type<no> sum_exp
%type<no> prod_exp
%type<no> unary_exp
%type<no> par_exp
%type<no> operand
%type<no> literal
%type<no> push
%type<no> pop
%type<no> id_use

%type<valor_lexico> unary
%type<valor_lexico> prod
%type<valor_lexico> sum
%type<valor_lexico> ineq
%type<valor_lexico> eq

%%

/* Definição de um programa */
program : push lst_elements { $$ = get_root($2); if($$ != NULL){
                                   struct table *table = stack->top;
                                   struct iloc_list *c_out;
                                   for (int i = 0; i < table->num_entries; i++){
                                        struct entry *entry = table->entries[i];
                                        if (entry->nature == VAR){
                                             struct iloc_list *c = gen_code("global", entry->value.token, NULL, NULL);
                                             if (i > 0){
                                                  c_out = merge_code(2, c_out, c);
                                             } else{
                                                  c_out = c;
                                             }
                                        } else{
                                             if (i > 0){
                                                  c_out = merge_code(2, c_out, $2->code);
                                             } else{
                                                  c_out = $2->code;
                                             }
                                        }
                                   }
                                   $$->code = c_out;
                              }
                              arvore = $$;
}
        | { $$ = NULL; arvore = $$; } ;
lst_elements : lst_elements element { $$ = $2;
                                      if      ($2 == NULL) $$ = $1;
                                      else if ($1 != NULL) {
                                        add_child($1, $2);
                                        $$->code = merge_code(2, $1->code, $2->code);
                                      }}
             | element { $$ = $1; };
element : global_var { $$ = $1; }
        | func       { $$ = $1; };

/* Definição de um tipo, que será usado em definições da gramática */
type : TK_PR_BOOL  { cur_type = BOOL;  $$ = NULL; }
     | TK_PR_INT   { cur_type = INT;   $$ = NULL; }
     | TK_PR_FLOAT { cur_type = FLOAT; $$ = NULL; };

/* Definição de uma variável global (Item 3.1) */
global_var : type lst_ids ',' { $$ = $2; };
lst_ids : lst_ids ';' TK_IDENTIFICADOR { struct entry *entry = search_table(stack->top, $3.token);
                                         enum error_types error = check_declaration(entry, yylineno);
                                         if(error != ERR_NONE) exit(error);
                                         entry = calloc(1, sizeof(struct entry));
                                         *entry = new_entry(yylineno, VAR, cur_type, $3);
                                         add_entry(stack->top, entry);
                                         $$ = $1; }
        | TK_IDENTIFICADOR { struct entry *entry = search_table(stack->top, $1.token);
                             enum error_types error = check_declaration(entry, yylineno);
                             if(error != ERR_NONE) exit(error);
                             entry = calloc(1, sizeof(struct entry));
                             *entry = new_entry(yylineno, VAR, cur_type, $1);
                             add_entry(stack->top, entry);
                             $$ = NULL; };

/* INÍCIO DEFINIÇÃO DE FUNÇÃO (Item 3.2) */
/* Definção geral */
func : push header body pop { $$ = $2; add_child($$, $3); 
                              struct iloc_list *c = gen_code("func", $2->label, NULL, NULL);
                              $$->code = merge_code(2, c, $3->code); };

/* Definção do Cabeçalho */
header : '(' lst_parameters ')' TK_OC_OR type '/' TK_IDENTIFICADOR { struct entry *entry = search_table(stack->next->top, $7.token);
                                                                     enum error_types error = check_declaration(entry, yylineno);
                                                                     if(error != ERR_NONE) exit(error);
                                                                     entry = calloc(1, sizeof(struct entry));
                                                                     *entry = new_entry(yylineno, FUNC, cur_type, $7);
                                                                     add_entry(stack->next->top, entry);
                                                                     $$ = new_ast($7.token, cur_type); }
       | '(' ')' TK_OC_OR type '/' TK_IDENTIFICADOR { struct entry *entry = search_table(stack->next->top, $6.token);
                                                      enum error_types error = check_declaration(entry, yylineno);
                                                      if(error != ERR_NONE) exit(error);
                                                      entry = calloc(1, sizeof(struct entry));
                                                      *entry = new_entry(yylineno, FUNC, cur_type, $6);
                                                      add_entry(stack->next->top, entry);
                                                      $$ = new_ast($6.token, cur_type); };
lst_parameters : lst_parameters ';' parameter { $$ = $1; }
               | parameter { $$ = $1; };
parameter : type TK_IDENTIFICADOR { struct entry *entry = search_table(stack->top, $2.token);
                                    enum error_types error = check_declaration(entry, yylineno);
                                    if(error != ERR_NONE) exit(error);
                                    entry = calloc(1, sizeof(struct entry));
                                    *entry = new_entry(yylineno, VAR, cur_type, $2);
                                    add_entry(stack->top, entry);
                                    $$ = $1; };

/* Definição do Corpo */
body : command_block { $$ = $1; };
/* FIM DEFINIÇÃO DE FUNÇÃO */


/* Definição de um bloco de comando (Item 3.3) */
command_block : '{' lst_commands '}' { $$ = get_root($2); if($$ != NULL) $$->code = $2->code; }
              | '{' '}' { $$ = NULL; };
lst_commands : lst_commands command ',' { $$ = $2;
                                          if ($2 == NULL) $$ = $1;
                                          else if ($1 != NULL) {
                                            add_child($1, $2);
                                            $$->code = merge_code(2, $1->code, $2->code);
                                          }}
             | command ',' { $$ = $1; };


/* INÍCIO DEFINIÇÃO DE UM COMANDO (Item 3.4) */
/* Comando Geral */
command : local_var              { $$ = $1; }
        | atrib                  { $$ = $1; }
        | control_flux           { $$ = $1; }
        | return                 { $$ = $1; }
        | /* push */ command_block /* pop */ { $$ = $1; /* $$ = $2; */ }
        | func_call              { $$ = $1; };

/* Declaração e atribuição de Variáveis */
local_var : type lst_ids { $$ = $2; };
atrib : id_use '=' expression  { $$ = new_ast("=", $1->type);
                                 add_child($$, $1); add_child($$, $3);
                                 struct entry *entry = search_table_stack(stack, $1->label);
                                 struct iloc_list *c = gen_code("storeAI", $3->temp, entry->scope, !strcmp(entry->scope, "rbp") ? entry->shift : entry->value.token);
                                 $$->code = merge_code(2, $3->code, c);
                               };

/* Chamadas de função */
func_call : TK_IDENTIFICADOR '(' lst_args ')' { struct entry *entry = search_table_stack(stack, $1.token);
                                                enum error_types error = check_use(entry, FUNC, yylineno, $1.token);
                                                if(error != ERR_NONE) exit(error);
                                                char str[6] = "call "; 
                                                strcat(str, $1.token); 
                                                $$ = new_ast(str, entry->type); 
                                                add_child($$, get_root($3));
                                                $$->code = $3->code; }
          | TK_IDENTIFICADOR '(' ')' { struct entry *entry = search_table_stack(stack, $1.token);
                                       enum error_types error = check_use(entry, FUNC, yylineno, $1.token);
                                       if(error != ERR_NONE) exit(error);
                                       char str[6] = "call "; 
                                       strcat(str, $1.token); 
                                       $$ = new_ast(str, entry->type); };

lst_args : lst_args ';' expression { $$ = $3; add_child($1, $3); $$->code = merge_code(2, $1->code, $3->code); }
         | expression { $$ = $1; };

/* Comando de Retorno */
return : TK_PR_RETURN expression { $$ = new_ast("return", $2->type); add_child($$, $2); 
                                   struct iloc_list *c = gen_code("return", $2->temp, NULL, NULL);
                                   $$->code = merge_code(2, $2->code, c);
                                   };

/* Comandos de Controle de Fluxo */
control_flux : conditional { $$ = $1; }
             | iteractive  { $$ = $1; };
conditional : TK_PR_IF '(' expression ')' /* push */ command_block /* pop */ TK_PR_ELSE /* push */ command_block /* pop */ 
                                                                                 { $$ = new_ast("if", BOOL);
                                                                                   add_child($$, $3); add_child($$, $5); add_child($$, $7); /* add_child($$, $6); add_child($$, $10); */ 
                                                                                   char *l1 = new_label();
                                                                                   char *l2 = new_label();
                                                                                   char *t1 = new_temp();
                                                                                   struct iloc_list *c1 = gen_code("loadI", "0", t1, NULL);
                                                                                   char *t2 = new_temp();
                                                                                   struct iloc_list *c2 = gen_code("cmp_NE", t1, $3->temp, t2);
                                                                                   struct iloc_list *c3 = gen_code("je", t2, l2, NULL);
                                                                                   char *l3 = new_label();
                                                                                   struct iloc_list *c4 = gen_code("label", l1, NULL, NULL); // coloca label
                                                                                   struct iloc_list *c5 = gen_code("jumpI", l3, NULL, NULL);
                                                                                   struct iloc_list *c6 = gen_code("label", l2, NULL, NULL); // coloca label
                                                                                   struct iloc_list *c7 = gen_code("label", l3, NULL, NULL); // coloca label
                                                                                   $$->code = merge_code(10, $3->code, c1, c2, c3, c4, $5->code, c5, c6, $7->code, c7);
                                                                                    }
            | TK_PR_IF '(' expression ')' /* push */ command_block /* pop */ { $$ = new_ast("if", BOOL);
                                                                   add_child($$, $3); add_child($$, $5); /* add_child($$, $6); */
                                                                   char *l1 = new_label();
                                                                   char *l2 = new_label();
                                                                   char *t1 = new_temp();
                                                                   struct iloc_list *c1 = gen_code("loadI", "0", t1, NULL);
                                                                   char *t2 = new_temp();
                                                                   struct iloc_list *c2 = gen_code("cmp_NE", t1, $3->temp, t2);
                                                                   struct iloc_list *c3 = gen_code("je", t2, l2, NULL);
                                                                   struct iloc_list *c4 = gen_code("label", l1, NULL, NULL); // coloca label
                                                                   struct iloc_list *c5 = gen_code("jumpI", l2, NULL, NULL);
                                                                   struct iloc_list *c6 = gen_code("label", l2, NULL, NULL); // coloca label
                                                                   $$->code = merge_code(8, $3->code, c1, c2, c3, c4, $5->code, c5, c6); };
iteractive : TK_PR_WHILE '(' expression ')' /* push */ command_block /* pop */ { $$ = new_ast("while", BOOL); 
                                                                     add_child($$, $3); add_child($$, $5); /* add_child($$, $6); */
                                                                     char *l1 = new_label();
                                                                     char *l2 = new_label();
                                                                     char *l3 = new_label();
                                                                     char *t1 = new_temp();
                                                                     struct iloc_list *c1 = gen_code("label", l1, NULL, NULL); // coloca label
                                                                     struct iloc_list *c2 = gen_code("loadI", "0", t1, NULL);
                                                                     char *t2 = new_temp();
                                                                     struct iloc_list *c3 = gen_code("cmp_NE", t1, $3->temp, t2);
                                                                     struct iloc_list *c4 = gen_code("je", t2, l3, NULL);
                                                                     struct iloc_list *c5 = gen_code("label", l2, NULL, NULL); // coloca label
                                                                     struct iloc_list *c6 = gen_code("jumpI", l1, NULL, NULL);
                                                                     struct iloc_list *c7 = gen_code("label", l3, NULL, NULL); // coloca label
                                                                     $$->code = merge_code(9, c1, $3->code, c2, c3, c4, c5, $5->code, c6, c7); };
/* FIM DEFINIÇÃO DE UM COMANDO (Item 3.4) */


/* INÍCIO DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */
/* Definição Geral */
expression : or_exp { $$ = $1; };

/* Expressões OR e AND */
or_exp  : or_exp TK_OC_OR and_exp  {    $$ = new_ast("|", infer_type($1->type, $3->type)); 
                                        add_child($$, $1); add_child($$, $3);
                                        $$->temp = new_temp();
                                        char *l1 = new_label();
                                        char *l2 = new_label();
                                        char *l3 = new_label();
                                        char *l4 = new_label();
                                        char *t1 = new_temp();
                                        char *t2 = new_temp();
                                        struct iloc_list *c1 = gen_code("loadI", "0", t1, NULL);
                                        struct iloc_list *c2 = gen_code("cmp_NE", t1, $1->temp, t2);
                                        struct iloc_list *c3 = gen_code("jne", t2, l3, NULL);
                                        struct iloc_list *c4 = gen_code("label", l1, NULL, NULL); // coloca label
                                        struct iloc_list *c5 = gen_code("loadI", "0", t1, NULL);
                                        struct iloc_list *c6 = gen_code("cmp_NE", t1, $3->temp, t2);
                                        struct iloc_list *c7 = gen_code("jne", t2, l3, NULL);
                                        struct iloc_list *c8 = gen_code("label", l2, NULL, NULL); // coloca label
                                        struct iloc_list *c9 = gen_code("loadI", "0", $$->temp, NULL);
                                        struct iloc_list *c10 = gen_code("jumpI", l4, NULL, NULL);
                                        struct iloc_list *c11 = gen_code("label", l3, NULL, NULL); // coloca label
                                        struct iloc_list *c12 = gen_code("loadI", "1", $$->temp, NULL);
                                        struct iloc_list *c13 = gen_code("label", l4, NULL, NULL); // coloca label
                                        $$->code = merge_code(15, $1->code, c1, c2, c3, c4, $3->code, c5, c6, c7, c8, c9, c10, c11, c12, c13); }
        | and_exp { $$ = $1; };
and_exp : and_exp TK_OC_AND eq_exp {    $$ = new_ast("&", infer_type($1->type, $3->type)); 
                                        add_child($$, $1); add_child($$, $3);
                                        $$->temp = new_temp();
                                        char *l1 = new_label();
                                        char *l2 = new_label();
                                        char *l3 = new_label();
                                        char *l4 = new_label();
                                        char *t1 = new_temp();
                                        char *t2 = new_temp();
                                        struct iloc_list *c1 = gen_code("loadI", "0", t1, NULL);
                                        struct iloc_list *c2 = gen_code("cmp_NE", t1, $1->temp, t2);
                                        struct iloc_list *c3 = gen_code("je", t2, l2, NULL);
                                        struct iloc_list *c4 = gen_code("label", l1, NULL, NULL); // coloca label
                                        struct iloc_list *c5 = gen_code("loadI", "0", t1, NULL);
                                        struct iloc_list *c6 = gen_code("cmp_NE", t1, $3->temp, t2);
                                        struct iloc_list *c7 = gen_code("jne", t2, l3, NULL);
                                        struct iloc_list *c8 = gen_code("label", l2, NULL, NULL); // coloca label
                                        struct iloc_list *c9 = gen_code("loadI", "0", $$->temp, NULL);
                                        struct iloc_list *c10 = gen_code("jumpI", l4, NULL, NULL);
                                        struct iloc_list *c11 = gen_code("label", l3, NULL, NULL); // coloca label
                                        struct iloc_list *c12 = gen_code("loadI", "1", $$->temp, NULL);
                                        struct iloc_list *c13 = gen_code("label", l4, NULL, NULL); // coloca label
                                        $$->code = merge_code(15, $1->code, c1, c2, c3, c4, $3->code, c5, c6, c7, c8, c9, c10, c11, c12, c13); }
        | eq_exp { $$ = $1; };

/* Expressão de igualdade */
eq_exp : eq_exp eq ineq_exp { $$ = new_ast($2.token, infer_type($1->type, $3->type)); 
                              add_child($$, $1); add_child($$, $3);
                              $$->temp = new_temp();
                              if(!strcmp($2.token, "==")){
                                struct iloc_list *c = gen_code("cmp_EQ", $1->temp, $3->temp, $$->temp);
                                $$->code = merge_code(3, $1->code, $3->code, c);
                              }
                              else{
                                struct iloc_list *c = gen_code("cmp_NE", $1->temp, $3->temp, $$->temp);
                                $$->code = merge_code(3, $1->code, $3->code, c);
                              }}
       | ineq_exp { $$ = $1; };

eq : TK_OC_EQ { $$ = new_value(yylineno, LIT, "=="); }
   | TK_OC_NE { $$ = new_value(yylineno, LIT, "!="); };

/* Expressão de desigualdade */
ineq_exp : ineq_exp ineq sum_exp { $$ = new_ast($2.token, infer_type($1->type, $3->type)); 
                                   add_child($$, $1); add_child($$, $3);
                                   $$->temp = new_temp();
                                   if(!strcmp($2.token, ">=")){
                                        struct iloc_list *c = gen_code("cmp_GE", $1->temp, $3->temp, $$->temp);
                                        $$->code = merge_code(3, $1->code, $3->code, c);
                                   }
                                   else if(!strcmp($2.token, "<=")){
                                        struct iloc_list *c = gen_code("cmp_LE", $1->temp, $3->temp, $$->temp);
                                        $$->code = merge_code(3, $1->code, $3->code, c);
                                   }
                                   else if(!strcmp($2.token, ">")){
                                        struct iloc_list *c = gen_code("cmp_GT", $1->temp, $3->temp, $$->temp);
                                        $$->code = merge_code(3, $1->code, $3->code, c);
                                   } else {
                                        struct iloc_list *c = gen_code("cmp_LT", $1->temp, $3->temp, $$->temp);
                                        $$->code = merge_code(3, $1->code, $3->code, c);
                                   }}
         | sum_exp { $$ = $1; };

ineq : TK_OC_GE { $$ = new_value(yylineno, LIT, ">="); }
     | TK_OC_LE { $$ = new_value(yylineno, LIT, "<="); }
     | '<'      { $$ = new_value(yylineno, LIT, "<"); } 
     | '>'      { $$ = new_value(yylineno, LIT, ">"); };

/* Expressões de soma e subtração */
sum_exp : sum_exp sum prod_exp { $$ = new_ast($2.token, infer_type($1->type, $3->type)); 
                                 add_child($$, $1); add_child($$, $3);
                                 $$->temp = new_temp();
                                 if(!strcmp($2.token, "+")){
                                    struct iloc_list *c = gen_code("add", $1->temp, $3->temp, $$->temp);
                                    $$->code = merge_code(3, $1->code, $3->code, c);
                                 }
                                 else {
                                    struct iloc_list *c = gen_code("sub", $1->temp, $3->temp, $$->temp);
                                    $$->code = merge_code(3, $1->code, $3->code, c);
                                 }}
        | prod_exp { $$ = $1; };

sum : '+' { $$ = new_value(yylineno, LIT, "+"); }
    | '-' { $$ = new_value(yylineno, LIT, "-"); };

/* Expressões de produto e divisão */
prod_exp : prod_exp prod unary_exp { $$ = new_ast($2.token, infer_type($1->type, $3->type)); 
                                     add_child($$, $1); add_child($$, $3);
                                     $$->temp = new_temp();
                                     if(!strcmp($2.token, "*")){
                                        struct iloc_list *c = gen_code("mult", $1->temp, $3->temp, $$->temp);
                                        $$->code = merge_code(3, $1->code, $3->code, c);
                                     }
                                     else if(!strcmp($2.token, "/")){
                                        struct iloc_list *c = gen_code("div", $1->temp, $3->temp, $$->temp);
                                        $$->code = merge_code(3, $1->code, $3->code, c);
                                     }}
         | unary_exp { $$ = $1; };

prod : '*' { $$ = new_value(yylineno, LIT, "*"); }
     | '/' { $$ = new_value(yylineno, LIT, "/"); }
     | '%' { $$ = new_value(yylineno, LIT, "%"); };

/* Expressões unárias */
unary_exp : unary unary_exp { $$ = new_ast($1.token, $2->type); 
                              add_child($$, $2);
                              $$->temp = new_temp();
                              if(!strcmp($1.token, "-")){
                                   struct iloc_list *c = gen_code("neg", $2->temp, $$->temp, NULL);
                                   $$->code = merge_code(2, $2->code, c);
                              }
                              else {
                                   char *l1 = new_label();
                                   char *l2 = new_label();
                                   char *t1 = new_temp();
                                   struct iloc_list *c1 = gen_code("loadI", "0", t1, NULL);
                                   char *t2 = new_temp();
                                   struct iloc_list *c2 = gen_code("cmp_NE", t1, $2->temp, t2);
                                   struct iloc_list *c3 = gen_code("je", t2, l2, NULL);
                                   char *l3 = new_label();
                                   struct iloc_list *c4 = gen_code("label", l1, NULL, NULL); // coloca label
                                   struct iloc_list *c5 = gen_code("loadI", "0", $$->temp, NULL);
                                   struct iloc_list *c6 = gen_code("jumpI", l3, NULL, NULL);
                                   struct iloc_list *c7 = gen_code("label", l2, NULL, NULL); // coloca label
                                   struct iloc_list *c8 = gen_code("loadI", "1", $$->temp, NULL);
                                   struct iloc_list *c9 = gen_code("label", l3, NULL, NULL); // coloca label
                                   $$->code = merge_code(10, $2->code, c1, c2, c3, c4, c5, c6, c7, c8, c9);
                              }}
          | par_exp { $$ = $1; };

unary: '-' { $$ = new_value(yylineno, LIT, "-"); } 
     | '!' { $$ = new_value(yylineno, LIT, "!"); };

/* Parênteses */
par_exp : '(' expression ')' { $$ = $2; }
        | operand { $$ = $1; };

/* Operandos */
operand : id_use        { $$ = $1;
                          $$->temp = new_temp();
                          struct entry *entry = search_table_stack(stack, $1->label);
                          $$->code = gen_code("loadAI", entry->scope, !strcmp(entry->scope, "rbp") ? entry->shift : entry->value.token, $$->temp);
                        }
        | literal       { $$ = $1;
                          $$->temp = new_temp();
                          $$->code = gen_code("loadI", $1->label, $$->temp, NULL);
                        }
        | func_call     { $$ = $1; }; /*TODO TESTE*/
literal : TK_LIT_FALSE  { $$ = new_ast($1.token, BOOL);  }
        | TK_LIT_FLOAT  { $$ = new_ast($1.token, FLOAT); }
        | TK_LIT_INT    { $$ = new_ast($1.token, INT);   }
        | TK_LIT_TRUE   { $$ = new_ast($1.token, BOOL);  };
/* FIM DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */

id_use : TK_IDENTIFICADOR { struct entry *entry = search_table_stack(stack, $1.token);
                            enum error_types error = check_use(entry, VAR, yylineno, $1.token);
                            if(error != ERR_NONE) exit(error);
                            $$ = new_ast($1.token, entry->type); };

/* Adiciona e remove uma tabela do Stack */
push: { struct table *table = new_table();
        push_table(&stack, table);
        $$ = NULL; };
pop: { pop_table(stack);
       $$ = NULL; };

%%

void yyerror (char const *mensagem) {
    printf("Problema encontrado: %s na linha %d\n", mensagem, yylineno);
}