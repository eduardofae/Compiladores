    /* Trabalho de Compiladores:
        Integrantes:
         - Eduardo Dalmás Faé (00334087)
         - João Pedro Kuhn Braun (00325265)
    */

%{
    #include "tokens.h"
%}

    /* Opções do Flex */
%option noyywrap
%option yylineno

    /* Contexto dos Comentários */
%x multiline_comment

%%

    /* Palavras Reservadas */
"int"    { return TK_PR_INT;    }
"float"  { return TK_PR_FLOAT;  }
"bool"   { return TK_PR_BOOL;   }
"if"     { return TK_PR_IF;     }
"else"   { return TK_PR_ELSE;   }
"while"  { return TK_PR_WHILE;  }
"return" { return TK_PR_RETURN; }

    /* Palavras Operadores Compostos */
"<=" { return TK_OC_LE;  }
">=" { return TK_OC_GE;  }
"==" { return TK_OC_EQ;  }
"!=" { return TK_OC_NE;  }
"&"  { return TK_OC_AND; }
"|"  { return TK_OC_OR;  }

    /* Palavras Literais */
"true"          { return TK_LIT_TRUE;  }
"false"         { return TK_LIT_FALSE; }
[0-9]+          { return TK_LIT_INT;   }
[0-9]*\.[0-9]+  { return TK_LIT_FLOAT; }

    /* Comentários */
"//".* {}
"/*" { BEGIN(multiline_comment); }
<multiline_comment>"*/" { BEGIN(INITIAL); }
<multiline_comment>"\n" {}
<multiline_comment>. {}


    /* Caracteres Especiais */
[-!*/%+<>{}()=,;] { return *yytext; }

    /* Identificadores */
[a-z_][a-z0-9_]* { return TK_IDENTIFICADOR; }

    /* Quebra de Linha e Espaços */
"\n" {}
" " {}

    /* Erro */
. { return TK_ERRO; }

%%

    /* Retorna a linha atual do código */
int get_line_number(void)
{
    return yylineno;
}