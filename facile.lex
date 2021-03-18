%{
    #include <assert.h>
    #include <glib.h>
    #include "facile.y.h"
%}

%option yylineno

%%

if {
    assert(printf("'if' found"));
    return TOK_IF;
}

then {
    assert(printf("'then' found"));
    return TOK_THEN;
}

";" {
       assert(printf("';' found"));
       return TOK_SEMI_COLON;
}

":=" {
       assert(printf("':=' found"));
       return TOK_AFFECTATION;
}

"+" {
       assert(printf("'+' found"));
       return TOK_ADD;
}

"-" {
       assert(printf("'-' found"));
       return TOK_SUB;
}

"*" {
       assert(printf("'*' found"));
       return TOK_MUL;
}

"/" {
       assert(printf("'/' found"));
       return TOK_DIV;
}

[a-zA-Z][a-zA-Z0-9_]* {
       assert(printf("identifier'%s(%d)'found", yytext, yyleng));
       yylval.string = yytext;
       return TOK_IDENTIFIER;
}

"0" {
       assert(printf("number '%s(%d)' found", yytext, yyleng));
       sscanf(yytext, "%lu", &yylval.number);
       return TOK_NUMBER;
}

[ \t\n] ;

. {
       return yytext[0];
}

%%