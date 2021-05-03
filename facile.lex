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

else {
    assert(printf("'else' found"));
    return TOK_ELSE;
}

elseif {
    assert(printf("'elseif' found"));
    return TOK_ELSEIF;
}

then {
    assert(printf("'then' found"));
    return TOK_THEN;
}

endif {
    assert(printf("'endif' found"));
    return TOK_ENDIF;
}

while {
    assert(printf("'while' found"));
    return TOK_WHILE;
}

do {
    assert(printf("'do' found"));
    return TOK_DO;
}

continue {
    assert(printf("'continue' found"));
    return TOK_CONTINUE;
}

break {
    assert(printf("'break' found"));
    return TOK_BREAK;
}

endwhile {
    assert(printf("'endwhile' found"));
    return TOK_ENDWHILE;
}

end {
    assert(printf("'end' found"));
    return TOK_END;
}

":=" {
       assert(printf("':=' found"));
       return TOK_AFFECTATION;
}

"print" {
       assert(printf("'print' found"));
       return TOK_PRINT;
}

"read" {
       assert(printf("'print' found"));
       return TOK_READ;
}

";" {
       assert(printf("';' found"));
       return TOK_SEMI_COLON;
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

"!" {
       assert(printf("'!' found"));
       return TOK_NOT;
}

true {
       assert(printf("'true' found"));
       return TOK_TRUE;
}

false {
       assert(printf("'false' found"));
       return TOK_FALSE;
}

">=" {
       assert(printf("'>=' found"));
       return TOK_SUP_EGAL;
}

"<=" {
       assert(printf("'<=' found"));
       return TOK_INF_EGAL;
}

">" {
       assert(printf("'>' found"));
       return TOK_SUP;
}

"<" {
       assert(printf("'<' found"));
       return TOK_INF;
}

"=" {
       assert(printf("'=' found"));
       return TOK_EGAL;
}

"#" {
       assert(printf("'#' found"));
       return TOK_SHARP;
}

"not" {
       assert(printf("'not' found"));
       return TOK_NOT;
}

"and" {
       assert(printf("'and' found"));
       return TOK_AND;
}

"or" {
       assert(printf("'or' found"));
       return TOK_OR;
}

[a-zA-Z][a-zA-Z0-9_]* {
       assert(printf("identifier'%s(%d)'found", yytext, yyleng));
       yylval.string = yytext;
       return TOK_IDENTIFIER;
}

0|[1-9][1-9]* {
       assert(printf("number '%s(%d)' found", yytext, yyleng));
       sscanf(yytext, "%lu", &yylval.number);
       return TOK_NUMBER;
}

[ \t\n] ;

. {
       return yytext[0];
}

%%