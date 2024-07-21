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
    struct table_stack *stack;
    enum types cur_type;
%}
%define parse.error verbose

%code requires { #include "ast.h" 
                 #include "types.h"
                 #include "tables.h"
                 #include "lex_value.h"
                 #include "error.h" }

%union {
    struct val valor_lexico;
    ast *no;
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

%%

/* Definição de um programa */
program : push lst_elements pop { $$ = get_root($2); arvore = $$; }
        | { $$ = NULL; arvore = $$; } ;
lst_elements : lst_elements element { $$ = $2;
                                      if      ($2 == NULL) $$ = $1;
                                      else if ($1 != NULL) add_child($1, $2); }
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
func : push header body pop { $$ = $2; add_child($$, $3); };

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
command_block : '{' lst_commands '}' { $$ = get_root($2); }
              | '{' '}' { $$ = NULL; };
lst_commands : lst_commands command ',' { $$ = $2;
                                          if ($2 == NULL) $$ = $1;
                                          else if ($1 != NULL) add_child($1, $2); }
             | command ',' { $$ = $1; };


/* INÍCIO DEFINIÇÃO DE UM COMANDO (Item 3.4) */
/* Comando Geral */
command : local_var              { $$ = $1; }
        | atrib                  { $$ = $1; }
        | control_flux           { $$ = $1; }
        | return                 { $$ = $1; }
        | push command_block pop { $$ = $2; }
        | func_call              { $$ = $1; };

/* Declaração e atribuição de Variáveis */
local_var : type lst_ids { $$ = $2; };
atrib : TK_IDENTIFICADOR '=' expression { struct entry *entry = search_table_stack(stack, $1.token);
                                          enum error_types error = check_use(entry, VAR, yylineno, $1.token);
                                          if(error != ERR_NONE) exit(error);
                                          $$ = new_ast("=", entry->type);
                                          ast *n = new_ast($1.token, entry->type); 
                                          add_child($$, n); 
                                          add_child($$, $3); };

/* Chamadas de função */
func_call : TK_IDENTIFICADOR '(' lst_args ')' { struct entry *entry = search_table_stack(stack, $1.token);
                                                enum error_types error = check_use(entry, FUNC, yylineno, $1.token);
                                                if(error != ERR_NONE) exit(error);
                                                char str[6] = "call "; 
                                                strcat(str, $1.token); 
                                                $$ = new_ast(str, entry->type); 
                                                add_child($$, get_root($3)); }
          | TK_IDENTIFICADOR '(' ')' { struct entry *entry = search_table_stack(stack, $1.token);
                                       enum error_types error = check_use(entry, FUNC, yylineno, $1.token);
                                       if(error != ERR_NONE) exit(error);
                                       char str[6] = "call "; 
                                       strcat(str, $1.token); 
                                       $$ = new_ast(str, entry->type); };

lst_args : lst_args ';' expression { $$ = $3; add_child($1, $3); }
         | expression { $$ = $1; };

/* Comando de Retorno */
return : TK_PR_RETURN expression { $$ = new_ast("return", $2->type); add_child($$, $2); };

/* Comandos de Controle de Fluxo */
control_flux : conditional { $$ = $1; }
             | iteractive  { $$ = $1; };
conditional : TK_PR_IF '(' expression ')' push command_block pop TK_PR_ELSE push command_block pop 
                                                                                 { $$ = new_ast("if", BOOL);
                                                                                   add_child($$, $3);
                                                                                   add_child($$, $6); 
                                                                                   add_child($$, $10); }
            | TK_PR_IF '(' expression ')' push command_block pop { $$ = new_ast("if", BOOL);
                                                                   add_child($$, $3);
                                                                   add_child($$, $6); };
iteractive : TK_PR_WHILE '(' expression ')' push command_block pop { $$ = new_ast("while", BOOL); 
                                                                     add_child($$, $3); 
                                                                     add_child($$, $6); };
/* FIM DEFINIÇÃO DE UM COMANDO (Item 3.4) */


/* INÍCIO DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */
/* Definição Geral */
expression : or_exp { $$ = $1; };

/* Expressões OR e AND */
or_exp  : or_exp TK_OC_OR and_exp  { $$ = new_ast("|", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
        | and_exp { $$ = $1; };
and_exp : and_exp TK_OC_AND eq_exp { $$ = new_ast("&", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
        | eq_exp { $$ = $1; };

/* Expressão de igualdade */
eq_exp : eq_exp TK_OC_EQ ineq_exp { $$ = new_ast("==", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
       | eq_exp TK_OC_NE ineq_exp { $$ = new_ast("!=", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
       | ineq_exp { $$ = $1; };

/* Expressão de desigualdade */
ineq_exp : ineq_exp TK_OC_GE sum_exp { $$ = new_ast(">=", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
         | ineq_exp TK_OC_LE sum_exp { $$ = new_ast("<=", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
         | ineq_exp '<' sum_exp      { $$ = new_ast("<", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3);  }
         | ineq_exp '>' sum_exp      { $$ = new_ast(">", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3);  }
         | sum_exp { $$ = $1; };

/* Expressões de soma e subtração */
sum_exp : sum_exp '+' prod_exp { $$ = new_ast("+", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
        | sum_exp '-' prod_exp { $$ = new_ast("+", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
        | prod_exp { $$ = $1; };

/* Expressões de produto e divisão */
prod_exp : prod_exp '*' unary_exp { $$ = new_ast("*", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
         | prod_exp '/' unary_exp { $$ = new_ast("/", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
         | prod_exp '%' unary_exp { $$ = new_ast("%", infer_type($1->type, $3->type)); add_child($$, $1); add_child($$, $3); }
         | unary_exp { $$ = $1; };

/* Expressões unárias */
unary_exp : '-' unary_exp { $$ = new_ast("-", $2->type); add_child($$, $2); }
          | '!' unary_exp { $$ = new_ast("!", $2->type); add_child($$, $2); }
          | par_exp { $$ = $1; };

/* Parênteses */
par_exp : '(' expression ')' { $$ = $2; }
        | operand { $$ = $1; };

/* Operandos */
operand : TK_IDENTIFICADOR { struct entry *entry = search_table_stack(stack, $1.token);
                             enum error_types error = check_use(entry, VAR, yylineno, $1.token);
                             if(error != ERR_NONE) exit(error);
                             $$ = new_ast($1.token, entry->type); }
        | literal          { $$ = $1; }
        | func_call        { $$ = $1; }; /*TODO TESTE*/
literal : TK_LIT_FALSE  { $$ = new_ast($1.token, BOOL);  }
        | TK_LIT_FLOAT  { $$ = new_ast($1.token, FLOAT); }
        | TK_LIT_INT    { $$ = new_ast($1.token, INT);   }
        | TK_LIT_TRUE   { $$ = new_ast($1.token, BOOL);  };
/* FIM DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */

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