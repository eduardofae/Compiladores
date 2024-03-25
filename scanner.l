%{
    #include "./lib/tokens.h"
%}

%x multiline_comment
%option noyywrap
%option yylineno

%%


"int"    { return TK_PR_INT;   }
"float"  { return TK_PR_FLOAT; }
"bool"   { return TK_PR_BOOL;  }
"if"     { return TK_PR_IF;    }
"else"   { return TK_PR_ELSE;  }
"while"  { return TK_PR_WHILE; }


"<=" { return TK_OC_LE;  }
">=" { return TK_OC_GE;  }
"==" { return TK_OC_EQ;  }
"!=" { return TK_OC_NE;  }
"&"  { return TK_OC_AND; }
"|"  { return TK_OC_OR;  }

"true"          { return TK_LIT_TRUE;  }
"false"         { return TK_LIT_FALSE; }
[0-9]+          { return TK_LIT_INT;   }
[0-9]*\.[0-9]+  { return TK_LIT_FLOAT; }

"//".* {}
"/*" { BEGIN(multiline_comment); }
<multiline_comment>[^(*/)]* {}
<multiline_comment>"*/" { BEGIN(INITIAL); }

[-!*/%+-<>{}()=,;] { return *yytext; }

[a-z_][a-z0-9_]* { return TK_IDENTIFICADOR; }

"\n" {}
" " {}
. { return TK_ERRO; }

%%

int get_line_number(void)
{
    return yylineno;
}