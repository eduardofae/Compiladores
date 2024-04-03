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

program : lst_elements | ;
lst_elements : lst_elements element | element;
element : global_var | func;

type : TK_PR_BOOL | TK_PR_INT | TK_PR_FLOAT;

global_var : type lst_ids ',';
lst_ids : lst_ids ';' TK_IDENTIFICADOR | TK_IDENTIFICADOR;

func : header body;

header : '(' (lst_parameters | ) ')' TK_OC_OR type '/' TK_IDENTIFICADOR;
lst_parameters : lst_parameters ';' parameter | parameter;
parameter : type TK_IDENTIFICADOR;

body : command_block
command_block : '{' lst_commands '}'
lst_commands : lst_commands command ',' | command ',';

command : local_var | atrib | control_flux | return | command_block | func_calls;
local_var : global_var;
atrib : TK_IDENTIFICADOR '=' expression;
func_call : TK_IDENTIFICADOR '(' (lst_args | ) ')';
lst_args : lst_args ';' expression | expression;
return : TK_PR_RETURN expression;
control_flux : conditional | iteractive;
conditional : TK_PR_IF '(' expression ')' command_block (cond_else | );
cond_else : TK_PR_ELSE command_block;
iteractive : TK_PR_WHILE '(' expression ')' command_block;

    /*
        expression : unary | binary | operand;
        unary : u_operator expression;
        binary : expression b_operator expression;
        operand : TK_IDENTIFICADOR | literal | func_call;
        literal : TK_LIT_FALSE | TK_LIT_FLOAT | TK_LIT_INT | TK_LIT_TRUE;
        u_operator : '-' | '!';
        b_operator : '+' | '-' | '*' | '/' | '%' | comp_operators;
        comp_operators : TK_OC_AND | TK_OC_EQ | TK_OC_GE | TK_OC_LE | TK_OC_NE | TK_OC_OR;
    */

expression : or_exp;
or_exp : expression TK_OC_OR expression | and_exp;
and_exp : expression TK_OC_AND expression | eq_exp;
eq_exp : expression equality expression | ineq_exp;
equality : TK_OC_EQ | TK_OC_NE;
ineq_exp : expression inequality expression | sum_exp;
inequality : TK_OC_GE | TK_OC_LE | '<' | '>';
sum_exp : expression sum expression | prod_exp;
sum : '+' | '-';
prod_exp : expression prod expression | unary_exp;
prod : '*' | '/' | '%';
unary_exp : unary expression | '(' expression ')';
unary : '-' | '!'

%%

void yyerror (char const *mensagem) {
    printf("%s", mensagem);
}