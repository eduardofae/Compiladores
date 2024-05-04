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
program : lst_elements { $$ = get_root($1); arvore = $$; printf("program\n"); }
        |  { $$ = NULL; arvore = $$; printf("program\n"); } ;
lst_elements : lst_elements element { if ($2 == NULL) {
                                        $$ = $1;
                                      }
                                      else {
                                        $$ = $2;
                                        asd_add_father($2, $1);  printf("lst_elements\n");
                                      }
                                        }
             | element { $$ = $1; printf("lst_elements\n"); };
element : global_var { $$ = $1; printf("element\n"); }
        | func       { $$ = $1; printf("element\n"); };

/* Definição de um tipo, que será usado em definições da gramática */
type : TK_PR_BOOL  { $$ = NULL; printf("type\n"); }
     | TK_PR_INT   { $$ = NULL; printf("type\n"); }
     | TK_PR_FLOAT { $$ = NULL; printf("type\n"); };

/* Definição de uma variável global (Item 3.1) */
global_var : type lst_ids ',' { $$ = $2; printf("global_var\n"); };
lst_ids : lst_ids ';' TK_IDENTIFICADOR { $$ = $1; printf("lst_ids\n"); }
        | TK_IDENTIFICADOR { $$ = NULL; printf("lst_ids\n"); };


/* INÍCIO DEFINIÇÃO DE FUNÇÃO (Item 3.2) */
/* Definção geral */
func : header body { $$ = $1; asd_add_child($$, $2); printf("func\n"); };

/* Definção do Cabeçalho */
header : '(' lst_parameters ')' TK_OC_OR type '/' TK_IDENTIFICADOR { $$ = asd_new($7.token); printf("header\n"); }
       | '(' ')' TK_OC_OR type '/' TK_IDENTIFICADOR { $$ = asd_new($6.token); printf("header\n"); };
lst_parameters : lst_parameters ';' parameter { $$ = $1; printf("lst_parameters\n"); }
               | parameter { $$ = $1; printf("lst_parameters\n"); };
parameter : type TK_IDENTIFICADOR { $$ = $1; printf("parameter\n"); };

/* Definição do Corpo */
body : command_block { $$ = $1; printf("body\n"); };
/* FIM DEFINIÇÃO DE FUNÇÃO */


/* Definição de um bloco de comando (Item 3.3) */
command_block : '{' lst_commands '}' { $$ = get_root($2); printf("command_block\n"); }
              | '{' '}' { $$ = NULL; printf("command_block\n"); };
lst_commands : lst_commands command ',' { if ($2 == NULL) {
                                          $$ = $1;
                                          printf("Erro, sai daqui caraaa!");
                                        }
                                        else {
                                          $$ = $2;
                                          asd_add_father($2, $1);
                                          printf("%p %p %p\n", $$, $1, $2);
                                        } printf("lst_commands tudo\n"); }
             | command ',' { $$ = $1; printf("%p\n", $1); printf("lst_commands somente comando\n"); };


/* INÍCIO DEFINIÇÃO DE UM COMANDO (Item 3.4) */
/* Comando Geral */
command : local_var             { $$ = $1; printf("command\n"); }
        | atrib                 { $$ = $1; printf("command\n"); }
        | control_flux          { $$ = $1; printf("command\n"); }
        | return                { $$ = $1; printf("command\n"); }
        | command_block         { $$ = $1; printf("command\n"); }
        | func_call             { $$ = $1; printf("command\n"); };

/* Declaração e atribuição de Variáveis */
local_var : type lst_ids { $$ = $2; printf("local_var\n"); };
atrib : TK_IDENTIFICADOR '=' expression { $$ = asd_new("="); asd_tree_t *n = asd_new($1.token); asd_add_child($$, n); asd_add_child($$, $3); printf("atrib\n"); };

/* Chamadas de função */
func_call : TK_IDENTIFICADOR '(' lst_args ')' { char str[6] = "call "; strcat(str, $1.token); $$ = asd_new(str); asd_add_child($$, $3); printf("func_call\n"); }
          | TK_IDENTIFICADOR '(' ')' { char str[6] = "call "; strcat(str, $1.token); $$ = asd_new(str); printf("func_call\n"); };
lst_args : lst_args ';' expression { $$ = $1; asd_add_child($$, $3); printf("lst_args\n"); }
         | expression { $$ = $1;  printf("lst_args\n");};

/* Comando de Retorno */
return : TK_PR_RETURN expression { $$ = asd_new("return"); asd_add_child($$, $2);  printf("return\n");};

/* Comandos de Controle de Fluxo */
control_flux : conditional { $$ = $1;  printf("control_flux\n");}
             | iteractive  { $$ = $1;  printf("control_flux\n");};
conditional : TK_PR_IF '(' expression ')' command_block TK_PR_ELSE command_block { $$ = asd_new("if");
                                                                                   asd_add_child($$, $3);
                                                                                   asd_add_child($$, $5); 
                                                                                   asd_add_child($$, $7);  printf("conditional\n");}
             | TK_PR_IF '(' expression ')' command_block { $$ = asd_new("if");
                                                           asd_add_child($$, $3);
                                                           asd_add_child($$, $5);  printf("conditional\n");}

iteractive : TK_PR_WHILE '(' expression ')' command_block { $$ = asd_new("while"); asd_add_child($$, $3); asd_add_child($$, $5);  printf("iteractive\n");};
/* FIM DEFINIÇÃO DE UM COMANDO (Item 3.4) */


/* INÍCIO DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */
/* Definição Geral */
expression : or_exp { $$ = $1;  printf("expression\n");};

/* Expressões OR e AND */
or_exp : or_exp TK_OC_OR and_exp { $$ = asd_new("|"); asd_add_child($$, $1); asd_add_child($$, $3);  printf("or_exp\n");}
       | and_exp { $$ = $1;  printf("or_exp\n");};
and_exp : and_exp TK_OC_AND eq_exp { $$ = asd_new("&"); asd_add_child($$, $1); asd_add_child($$, $3);  printf("and_exp\n");}
        | eq_exp { $$ = $1;  printf("and_exp\n");};

/* Expressão de igualdade */
eq_exp : eq_exp equality ineq_exp { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3);  printf("eq_exp\n");}
       | ineq_exp { $$ = $1;  printf("eq_exp\n");};
equality : TK_OC_EQ { $$ = asd_new("==");  printf("equality\n");}
         | TK_OC_NE { $$ = asd_new("!=");  printf("equality\n");};

/* Expressão de desigualdade */
ineq_exp : ineq_exp inequality sum_exp { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3);  printf("ineq_exp\n");}
         | sum_exp { $$ = $1;  printf("ineq_exp\n");};
inequality : TK_OC_GE { $$ = asd_new(">=");  printf("inequality\n");}
           | TK_OC_LE { $$ = asd_new("<=");  printf("inequality\n");}
           | '<' { $$ = asd_new("<");  printf("inequality\n");}
           | '>' { $$ = asd_new(">");  printf("inequality\n");};

/* Expressões de soma e subtração */
sum_exp : sum_exp sum prod_exp { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3);  printf("sum_exp\n");}
        | prod_exp { $$ = $1;  printf("sum_exp\n");};
sum : '+' { $$ = asd_new("+");  printf("sum\n");}
    | '-' { $$ = asd_new("-");  printf("sum\n");};

/* Expressões de produto e divisão */
prod_exp : prod_exp prod unary_exp { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3);  printf("prod_exp\n");}
         | unary_exp { $$ = $1;  printf("prod_exp\n");};
prod : '*' { $$ = asd_new("*");  printf("prod\n");}
     | '/' { $$ = asd_new("/");  printf("prod\n");}
     | '%' { $$ = asd_new("%");  printf("prod\n");};

/* Expressões unárias */
unary_exp : unary unary_exp { $$ = $1; asd_add_child($$, $2);  printf("unary_exp\n");}
          |  par_exp { $$ = $1;  printf("unary_exp\n");}; 
unary : '-' { $$ = asd_new("-");  printf("unary\n");}
      | '!' { $$ = asd_new("!");  printf("unary\n");};

/* Parênteses */
par_exp : '(' expression ')' { $$ = $2;  printf("par_exp\n");}
        | operand { $$ = $1;  printf("par_exp\n");};

/* Operandos */
operand : TK_IDENTIFICADOR { $$ = asd_new($1.token);  printf("operand\n");}
        | literal          { $$ = $1;  printf("operand\n");}
        | func_call        { $$ = $1;  printf("operand\n");};
literal : TK_LIT_FALSE  { $$ = asd_new($1.token);  printf("literal\n");}
        | TK_LIT_FLOAT  { $$ = asd_new($1.token);  printf("literal\n");}
        | TK_LIT_INT    { $$ = asd_new($1.token);  printf("literal\n");}
        | TK_LIT_TRUE   { $$ = asd_new($1.token);  printf("literal\n");};
/* FIM DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */

%%

void yyerror (char const *mensagem) {
    printf("Problema encontrado: %s na linha %d\n", mensagem, yylineno);
}