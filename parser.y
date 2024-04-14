    /* Trabalho de Compiladores:
        Integrantes:
         - Eduardo Dalmás Faé (00334087)
         - João Pedro Kuhn Braun (00325265)
    */


%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror (char const *mensagem);
%}

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
%token TK_IDENTIFICADOR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_ERRO

%%

/* Definição de um programa */
program : lst_elements | ;
lst_elements : lst_elements element | element;
element : global_var | func;

/* Definição de um tipo, que será usado em definições da gramática */
type : TK_PR_BOOL | TK_PR_INT | TK_PR_FLOAT;

/* Definição de uma variável global (Item 3.1) */
global_var : type lst_ids ',';
lst_ids : lst_ids ';' TK_IDENTIFICADOR | TK_IDENTIFICADOR;


/* INÍCIO DEFINIÇÃO DE FUNÇÃO (Item 3.2) */
/* Definção geral */
func : header body;

/* Definção do Cabeçalho */
header : '(' header_params ')' TK_OC_OR type '/' TK_IDENTIFICADOR;
header_params : lst_parameters | ;
lst_parameters : lst_parameters ';' parameter | parameter;
parameter : type TK_IDENTIFICADOR;

/* Definção do Corpo */
body : command_block;
/* FIM DEFINIÇÃO DE FUNÇÃO */


/* Definição de um bloco de comando (Item 3.3) */
command_block : '{' commands '}';
commands : lst_commands | ;
lst_commands : lst_commands command ',' | command ',';


/* INÍCIO DEFINIÇÃO DE UM COMANDO (Item 3.4) */
/* Comando Geral */
command : local_var | atrib | control_flux | return | command_block | func_call;

/* Declaração e atribuição de Variáveis */
local_var : global_var;
atrib : TK_IDENTIFICADOR '=' expression;

/* Chamadas de função */
func_call : TK_IDENTIFICADOR '(' func_args ')';
func_args : lst_args | ;
lst_args : lst_args ';' expression | expression;

/* Comando de Retorno */
return : TK_PR_RETURN expression;

/* Comandos de Controle de Fluxo */
control_flux : conditional | iteractive;
conditional : TK_PR_IF '(' expression ')' command_block else_case;
else_case : cond_else | ;
cond_else : TK_PR_ELSE command_block;
iteractive : TK_PR_WHILE '(' expression ')' command_block;
/* FIM DEFINIÇÃO DE UM COMANDO (Item 3.4) */


/* INÍCIO DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */
/* Definição Geral */
expression : or_exp;

/* Expressões OR e AND */
or_exp : or_exp TK_OC_OR and_exp | and_exp;
and_exp : and_exp TK_OC_AND eq_exp | eq_exp;

/* Expressão de igualdade */
eq_exp : eq_exp equality ineq_exp | ineq_exp;
equality : TK_OC_EQ | TK_OC_NE;

/* Expressão de inequidade */
ineq_exp : ineq_exp inequality sum_exp | sum_exp;
inequality : TK_OC_GE | TK_OC_LE | '<' | '>';

/* Expressões de soma e subtração */
sum_exp : sum_exp sum prod_exp | prod_exp;
sum : '+' | '-';

/* Expressões de produto e divisão */
prod_exp : prod_exp prod unary_exp | unary_exp;
prod : '*' | '/' | '%';

/* Expressões unárias */
unary_exp : unary unary_exp |  par_exp; 
unary : '-' | '!';

/* Parênteses */
par_exp : '(' expression ')' | operand;

/* Operandos */
operand : TK_IDENTIFICADOR | literal | func_call;
literal : TK_LIT_FALSE | TK_LIT_FLOAT | TK_LIT_INT | TK_LIT_TRUE;
/* FIM DEFINIÇÃO DE DEFINIÇÃO DE EXPRESSÕES (Item 3.5) */

%%

void yyerror (char const *mensagem) {
    printf("%s", mensagem);
}