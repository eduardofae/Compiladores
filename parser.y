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
%}
%define parse.error verbose

%code requires { #include "asd.h" 
                 #include "valor_lexico.h" }

%union {
    struct val valor_lexico;
    asd_tree_t *no;
}

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
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
%type<no> equality
%type<no> ineq_exp
%type<no> inequality
%type<no> sum_exp
%type<no> sum
%type<no> prod_exp
%type<no> prod
%type<no> unary_exp
%type<no> unary
%type<no> par_exp
%type<no> operand
%type<no> literal

%%

/* Definição de um programa */
program : lst_elements { $$ = get_root($1); arvore = $$; }
        |  { $$ = NULL; arvore = $$; } ;
lst_elements : lst_elements element { if ($2 == NULL) {
                                        $$ = $1;
                                      }
                                      else {
                                        $$ = $2;
                                        if ($1 != NULL) {
                                          asd_add_father($2, $1);
                                        }
                                      }
                                        }
             | element { $$ = $1; };
element : global_var { $$ = $1; }
        | func       { $$ = $1; };

/* Definição de um tipo, que será usado em definições da gramática */
type : TK_PR_BOOL  { $$ = NULL; }
     | TK_PR_INT   { $$ = NULL; }
     | TK_PR_FLOAT { $$ = NULL; };

/* Definição de uma variável global (Item 3.1) */
global_var : type lst_ids ',' { $$ = $2; };
lst_ids : lst_ids ';' TK_IDENTIFICADOR { $$ = $1; }
        | TK_IDENTIFICADOR { $$ = NULL; };


/* INÍCIO DEFINIÇÃO DE FUNÇÃO (Item 3.2) */
/* Definção geral */
func : header body { $$ = $1; asd_add_child($$, $2); };

/* Definção do Cabeçalho */
header : '(' lst_parameters ')' TK_OC_OR type '/' TK_IDENTIFICADOR { $$ = asd_new($7.token); }
       | '(' ')' TK_OC_OR type '/' TK_IDENTIFICADOR { $$ = asd_new($6.token); };
lst_parameters : lst_parameters ';' parameter { $$ = $1; }
               | parameter { $$ = $1; };
parameter : type TK_IDENTIFICADOR { $$ = $1; };

/* Definição do Corpo */
body : command_block { $$ = $1; };
/* FIM DEFINIÇÃO DE FUNÇÃO */


/* Definição de um bloco de comando (Item 3.3) */
command_block : '{' lst_commands '}' { $$ = get_root($2); }
              | '{' '}' { $$ = NULL; };
lst_commands : lst_commands command ',' { if ($2 == NULL) {
                                          $$ = $1;
                                        }
                                        else {
                                          $$ = $2;
                                          if ($1 != NULL) {
                                            asd_add_father($2, $1);
                                          }
                                        } 
                                        }
             | command ',' { $$ = $1; };


/* INÍCIO DEFINIÇÃO DE UM COMANDO (Item 3.4) */
/* Comando Geral */
command : local_var             { $$ = $1; }
        | atrib                 { $$ = $1; }
        | control_flux          { $$ = $1; }
        | return                { $$ = $1; }
        | command_block         { $$ = $1; }
        | func_call             { $$ = $1; };

/* Declaração e atribuição de Variáveis */
local_var : type lst_ids { $$ = $2; };
atrib : TK_IDENTIFICADOR '=' expression { $$ = asd_new("="); asd_tree_t *n = asd_new($1.token); asd_add_child($$, n); asd_add_child($$, $3); };

/* Chamadas de função */
func_call : TK_IDENTIFICADOR '(' lst_args ')' { char str[6] = "call "; strcat(str, $1.token); $$ = asd_new(str); asd_add_child($$, get_root($3)); }
          | TK_IDENTIFICADOR '(' ')' { char str[6] = "call "; strcat(str, $1.token); $$ = asd_new(str); };
lst_args : lst_args ';' expression { $$ = $3; asd_add_father($3, $1); }
         | expression { $$ = $1; };

/* Comando de Retorno */
return : TK_PR_RETURN expression { $$ = asd_new("return"); asd_add_child($$, $2); };

/* Comandos de Controle de Fluxo */
control_flux : conditional { $$ = $1; }
             | iteractive  { $$ = $1; };
conditional : TK_PR_IF '(' expression ')' command_block TK_PR_ELSE command_block { $$ = asd_new("if");
                                                                                   asd_add_child($$, $3);
                                                                                   asd_add_child($$, $5); 
                                                                                   asd_add_child($$, $7); }
             | TK_PR_IF '(' expression ')' command_block { $$ = asd_new("if");
                                                           asd_add_child($$, $3);
                                                           asd_add_child($$, $5); }

iteractive : TK_PR_WHILE '(' expression ')' command_block { $$ = asd_new("while"); asd_add_child($$, $3); asd_add_child($$, $5); };
/* FIM DEFINIÇÃO DE UM COMANDO (Item 3.4) */


/* INÍCIO DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */
/* Definição Geral */
expression : or_exp { $$ = $1; };

/* Expressões OR e AND */
or_exp : or_exp TK_OC_OR and_exp { $$ = asd_new("|"); asd_add_child($$, $1); asd_add_child($$, $3); }
       | and_exp { $$ = $1; };
and_exp : and_exp TK_OC_AND eq_exp { $$ = asd_new("&"); asd_add_child($$, $1); asd_add_child($$, $3); }
        | eq_exp { $$ = $1; };

/* Expressão de igualdade */
eq_exp : eq_exp equality ineq_exp { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
       | ineq_exp { $$ = $1; };
equality : TK_OC_EQ { $$ = asd_new("=="); }
         | TK_OC_NE { $$ = asd_new("!="); };

/* Expressão de desigualdade */
ineq_exp : ineq_exp inequality sum_exp { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
         | sum_exp { $$ = $1; };
inequality : TK_OC_GE { $$ = asd_new(">="); }
           | TK_OC_LE { $$ = asd_new("<="); }
           | '<' { $$ = asd_new("<"); }
           | '>' { $$ = asd_new(">"); };

/* Expressões de soma e subtração */
sum_exp : sum_exp sum prod_exp { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
        | prod_exp { $$ = $1; };
sum : '+' { $$ = asd_new("+"); }
    | '-' { $$ = asd_new("-"); };

/* Expressões de produto e divisão */
prod_exp : prod_exp prod unary_exp { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
         | unary_exp { $$ = $1; };
prod : '*' { $$ = asd_new("*"); }
     | '/' { $$ = asd_new("/"); }
     | '%' { $$ = asd_new("%"); };

/* Expressões unárias */
unary_exp : unary unary_exp { $$ = $1; asd_add_child($$, $2); }
          |  par_exp { $$ = $1; }; 
unary : '-' { $$ = asd_new("-"); }
      | '!' { $$ = asd_new("!"); };

/* Parênteses */
par_exp : '(' expression ')' { $$ = $2; }
        | operand { $$ = $1; };

/* Operandos */
operand : TK_IDENTIFICADOR { $$ = asd_new($1.token); }
        | literal          { $$ = $1; }
        | func_call        { $$ = $1; };
literal : TK_LIT_FALSE  { $$ = asd_new($1.token); }
        | TK_LIT_FLOAT  { $$ = asd_new($1.token); }
        | TK_LIT_INT    { $$ = asd_new($1.token); }
        | TK_LIT_TRUE   { $$ = asd_new($1.token); };
/* FIM DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */

%%

void yyerror (char const *mensagem) {
    printf("Problema encontrado: %s na linha %d\n", mensagem, yylineno);
}