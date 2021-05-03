%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <glib.h>
	#include <string.h>
	#include <ctype.h>
	#include <errno.h>
	#include <sys/types.h>
        #include <unistd.h>

	void begin_code();
	void produce_code(GNode *node, FILE *stream, char *textPtr);
	void end_code();
	extern int	yylex(void);
	extern int	yyerror(const char *msg);
	extern int	yylineno;

	FILE		*stream;
	GHashTable	*table;
	char		*module_name;

	static int ilcpt = -1;
%}

%define	parse.error	verbose
%union {
	gulong	number;
	gchar	*string;
	GNode	*node;
}

%token<number>	TOK_NUMBER		"number"
%token<string>	TOK_IDENTIFIER		"identifier"
%token 		TOK_AFFECTATION		":="
%token 		TOK_SEMI_COLON		";"
%token 		TOK_IF			"if"
%token 		TOK_ELSE		"else"
%token 		TOK_ELSEIF		"elseif"
%token 		TOK_THEN		"then"
%token 		TOK_ENDIF		"endif"
%token 		TOK_WHILE		"while"
%token 		TOK_DO			"do"
%token 		TOK_CONTINUE		"continue"
%token 		TOK_BREAK		"break"
%token 		TOK_ENDWHILE		"endwhile"
%token 		TOK_END			"end"
%left 		TOK_ADD			"+"
%left 		TOK_SUB			"-"
%left 		TOK_MUL			"*"
%left 		TOK_DIV			"/"
%left 		TOK_NOT			"!"
%token 		TOK_TRUE		"true"
%token 		TOK_FALSE		"false"
%token 		TOK_SUP_EGAL		">="
%token 		TOK_INF_EGAL		"<="
%token 		TOK_SUP			">"
%token 		TOK_INF			"<"
%token 		TOK_EGAL		"="
%token 		TOK_SHARP		"#"
%token 		TOK_NOT			"not"
%token 		TOK_AND			"and"
%token 		TOK_OR			"or"
%token 		TOK_OPEN_PARENTHESIS	"("
%token 		TOK_CLOSE_PARENTHESIS	")"
%token 		TOK_PRINT		"print"
%token 		TOK_READ		"read"

%type<node>    code
%type<node>    instruction
%type<node>    affectation
%type<node>    print
%type<node>    read
%type<node>    if
%type<node>    elseif
%type<node>    else
%type<node>    endif
%type<node>    while
%type<node>    code_while
%type<node>    endwhile
%type<node>    boolean
%type<node>    expression
%type<node>    identifier
%type<node>    number
%%

program:
	code {
	begin_code();
	produce_code($1, stream, "END");
	end_code();
	g_node_destroy($1);
}
;

code:
	code instruction {
	$$ = g_node_new("code");
	g_node_append($$, $1);
	g_node_append($$, $2);
	}
|
	{
	$$ = g_node_new("");
	}
;

instruction:
	affectation |
	print |
	read |
	if |
	while
;

affectation:
	identifier TOK_AFFECTATION expression TOK_SEMI_COLON {
	$$ = g_node_new("affectation");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
;

print:
	TOK_PRINT expression TOK_SEMI_COLON {
	$$ = g_node_new("print");
	g_node_append($$, $2);
	}
;

read:
	TOK_READ identifier TOK_SEMI_COLON {
	$$ = g_node_new("read");
	g_node_append($$, $2);
	}
;

if:
	TOK_IF boolean TOK_THEN code elseif else endif {
	$$ = g_node_new("if");
	g_node_append($$, $2);
	g_node_append($$, $4);
	g_node_append($$, $5);
	g_node_append($$, $6);
	g_node_append($$, $7);
	}
;

elseif:
	TOK_ELSEIF boolean TOK_THEN code elseif {
	$$ = g_node_new("elseif");
	g_node_append($$, $2);
        g_node_append($$, $4);
        g_node_append($$, $5);
	}
|
	{
	$$ = g_node_new("");
	}
;

else:
	TOK_ELSE code {
	$$ = g_node_new("else");
	g_node_append($$, $2);
	}
|
	{
        $$ = g_node_new("");
        }
;

endif:
	TOK_ENDIF {
	$$ = g_node_new("endif");
	}
|
	TOK_END {
	$$ = g_node_new("end");
	}
;

while:
	TOK_WHILE boolean TOK_DO code_while endwhile {
	$$ = g_node_new("while");
	g_node_append($$, $2);
	g_node_append($$, $4);
	g_node_append($$, $5);
	}
;

code_while:
	TOK_CONTINUE code_while {
	$$ = g_node_new("continue");
	}
|
	TOK_BREAK code_while {
	$$ = g_node_new("break");
	}
|
	instruction code_while {
	$$ = g_node_new("code_while");
	g_node_append($$, $1);
	g_node_append($$, $2);
	}
|
	{
	$$ = g_node_new("");
	}
;

endwhile:
	TOK_ENDWHILE {
	$$ = g_node_new("endwhile");
	}
|
	TOK_END {
	$$ = g_node_new("end");
	}
;

boolean:
	TOK_TRUE {
	$$ = g_node_new("true");
	g_node_append($$, (gpointer)0);
	}
|
	TOK_FALSE {
	$$ = g_node_new("false");
	g_node_append($$, (gpointer)0);
	}
|
	expression TOK_SUP_EGAL expression {
	$$ = g_node_new("sup_egal");
        g_node_append($$, $1);
        g_node_append($$, $3);
	}
|
	expression TOK_INF_EGAL expression {
	$$ = g_node_new("inf_egal");
        g_node_append($$, $1);
        g_node_append($$, $3);
	}
|
	expression TOK_SUP expression {
	$$ = g_node_new("sup");
        g_node_append($$, $1);
        g_node_append($$, $3);
	}
|
	expression TOK_INF expression {
	$$ = g_node_new("inf");
        g_node_append($$, $1);
        g_node_append($$, $3);
	}
|
	expression TOK_EGAL expression {
	$$ = g_node_new("egal");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	expression TOK_SHARP expression {
	$$ = g_node_new("sharp");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	TOK_NOT boolean {
	$$ = g_node_new("not");
	g_node_append($$, $2);
	}
|
	boolean TOK_AND boolean {
	$$ = g_node_new("and");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	boolean TOK_OR boolean {
	$$ = g_node_new("or");
        g_node_append($$, $1);
        g_node_append($$, $3);
	}
|
	TOK_OPEN_PARENTHESIS boolean TOK_CLOSE_PARENTHESIS {
	$$ = $2;
	}
;

expression:
	identifier
|
	number
|
	expression TOK_ADD expression {
	$$ = g_node_new("add");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	expression TOK_SUB expression {
	$$ = g_node_new("sub");
        g_node_append($$, $1);
        g_node_append($$, $3);
	}
|
	expression TOK_MUL expression {
	$$ = g_node_new("mul");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	expression TOK_DIV expression {
	$$ = g_node_new("div");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	TOK_OPEN_PARENTHESIS expression TOK_CLOSE_PARENTHESIS {
	$$ = $2;
	}
;

identifier:
	TOK_IDENTIFIER {
	$$ = g_node_new("identifier");
	gulong value = (gulong) g_hash_table_lookup(table, $1);
	if (!value) {
		value = g_hash_table_size(table) + 1;
		g_hash_table_insert(table, strdup($1), (gpointer) value);
	}
	g_node_append_data($$, (gpointer) value);
	}
;

number:
	TOK_NUMBER {
	$$ = g_node_new("number");
	g_node_append_data($$, (gpointer) $1);
	}
;

%%

int yyerror(const char *msg) {
	fprintf(stderr, "Line %d: %s\n", yylineno, msg);
}

char	*check_bool(FILE *pStream, char *line, char *invertedNbr) {
	char    *lineptr = NULL;
	int	index = 0;

	if ((lineptr = strstr(line, "BLT")) != NULL) {
		index = lineptr - line;

		fprintf(pStream, "%.*s", index, line);
                fprintf(pStream, (*invertedNbr > 0) ? "bge" : "blt");
                line = lineptr + strlen("BLT");

                *invertedNbr = *invertedNbr - 1;

	} else if ((lineptr = strstr(line, "BGT")) != NULL) {
		index = lineptr - line;

                fprintf(pStream, "%.*s", index, line);
                fprintf(pStream, (*invertedNbr > 0) ? "ble" : "bgt");
                line = lineptr + strlen("BGT");

                *invertedNbr = *invertedNbr - 1;

	} else if ((lineptr = strstr(line, "BLE")) != NULL) {
        	index = lineptr - line;

                fprintf(pStream, "%.*s", index, line);
                fprintf(pStream, (*invertedNbr > 0) ? "bgt" : "ble");
                line = lineptr + strlen("BLE");

                *invertedNbr = *invertedNbr - 1;

	} else if ((lineptr = strstr(line, "BGE")) != NULL) {
		index = lineptr - line;

                fprintf(pStream, "%.*s", index, line);
                fprintf(pStream, (*invertedNbr > 0) ? "blt" : "bge");
                line = lineptr + strlen("BGE");

                *invertedNbr = *invertedNbr - 1;

	} else if ((lineptr = strstr(line, "BNE.UN")) != NULL) {
        	index = lineptr - line;

		fprintf(pStream, "%.*s", index, line);
                fprintf(pStream, (*invertedNbr > 0) ? "beq" : "bne.un");
                line = lineptr + strlen("BNE.UN");

                *invertedNbr = *invertedNbr - 1;

	} else if ((lineptr = strstr(line, "BEQ")) != NULL) {
        	index = lineptr - line;

		fprintf(pStream, "%.*s", index, line);
                fprintf(pStream, (*invertedNbr > 0) ? "bne.un" : "beq");
                line = lineptr + strlen("BEQ");

                *invertedNbr = *invertedNbr - 1;
	}

	return line;
}

void begin_code() {
	fprintf(stream, ".assembly test {}\n");
	fprintf(stream, ".assembly extern mscorlib {}\n");
	fprintf(stream, ".method static void main() {\n");
	fprintf(stream, "\t.entrypoint\n");
	fprintf(stream, "\t.maxstack 10\n");
	fprintf(stream, "\t.locals init (int32, int32, int32)\n");
}

void produce_code(GNode* node, FILE *pStream, char *textPtr) {

	if (node->data == "code") {
    		produce_code(g_node_nth_child(node, 0), pStream, textPtr);
    		produce_code(g_node_nth_child(node, 1), pStream, textPtr);

    	} else if (node->data == "affectation") {
    		produce_code(g_node_nth_child(node, 1), pStream, textPtr);

    		ilcpt += 1;
    		fprintf(pStream, "\tIL_%04x:  ", ilcpt);//TODO
	        fprintf(pStream, "stloc.%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);

	} else if (node->data == "print") {
	        produce_code(g_node_nth_child(node, 0), pStream, textPtr);

	        ilcpt += 1;
	        fprintf(pStream, "\tIL_%04x:  ", ilcpt);
    		fprintf(pStream, "call void class[mscorlib]System.Console::WriteLine(int32)\n");
    		ilcpt += 4;

    	} else if (node->data == "read") {

    		ilcpt += 1;
	        fprintf(pStream, "\tIL_%04x:  ", ilcpt);
                fprintf(pStream, "call string class[mscorlib]System.Console::ReadLine()\n");

		ilcpt += 5;
	        fprintf(pStream, "\tIL_%04x:  ", ilcpt);
         	fprintf(pStream, "call int32 int32::Parse(string)\n");

		ilcpt += 5;
	        fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "stloc.%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);

        } else if (node->data == "if") {
        	FILE	*ifStream;
        	int	if_next;
        	int	if_end;

		char    *line = NULL;
		char    *lineptr = NULL;
		int 	index = 0;
		char	invertedNbr = 0;
        	size_t	len = 0;
        	ssize_t	read;

		if ((ifStream = tmpfile()) == NULL) {
			printf("Cannot create a temporary file, exit\n");
			exit(1);
		}

		produce_code(g_node_nth_child(node, 0), ifStream, "NEXT");
		produce_code(g_node_nth_child(node, 1), ifStream, textPtr);

		ilcpt += 1;
		fprintf(ifStream, "\tIL_%04x:  ", ilcpt);
		fprintf(ifStream, "br %s\n\n", textPtr);

		ilcpt += 4;
		if_next = ilcpt + 1;
		produce_code(g_node_nth_child(node, 2), ifStream, textPtr);
		produce_code(g_node_nth_child(node, 3), ifStream, textPtr);
		if_end = ilcpt + 1;

		produce_code(g_node_nth_child(node, 4), ifStream, textPtr);

		invertedNbr = 0;
		rewind(ifStream);
		while ((read = getline(&line, &len, ifStream)) != -1) {
			line = check_bool(pStream, line, &invertedNbr);

			if ((lineptr = strstr(line, "NEXT")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "IL_%04x", if_next);
                        	fprintf(pStream, "%s", lineptr + strlen("NEXT"));

                        } else if ((lineptr = strstr(line, "END")) != NULL) {
                        	index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "IL_%04x", if_end);
                        	fprintf(pStream, "%s", lineptr + strlen("END"));

                        } else {
                        	fprintf(pStream, "%s", line);
                        }
              	}

    		fclose(ifStream);

        } else if (node->data == "elseif") {
        	FILE	*elseifStream;

		char    *line = NULL;
		char    *lineptr = NULL;
		int 	index = 0;
		char	invertedNbr = 0;
        	size_t	len = 0;
        	ssize_t	read;

		if ((elseifStream = tmpfile()) == NULL) {
			printf("Cannot create a temporary file, exit\n");
			exit(1);
		}


		produce_code(g_node_nth_child(node, 0), elseifStream, "NEXT");
		produce_code(g_node_nth_child(node, 1), elseifStream, textPtr);
		produce_code(g_node_nth_child(node, 2), elseifStream, textPtr);
		ilcpt += 1;
                fprintf(elseifStream, "\tIL_%04x:  ", ilcpt);
                fprintf(elseifStream, "br END\n\n");

                ilcpt += 4;

		invertedNbr = 0;
		rewind(elseifStream);
		while ((read = getline(&line, &len, elseifStream)) != -1) {
			line = check_bool(pStream, line, &invertedNbr);

			if ((lineptr = strstr(line, "NEXT")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "IL_%04x", ilcpt + 1);
                        	fprintf(pStream, "%s", lineptr + strlen("NEXT"));

			} else {
				fprintf(pStream, "%s", line);
                       	}
              	}

    		fclose(elseifStream);

        } else if (node->data == "else") {
        	produce_code(g_node_nth_child(node, 0), pStream, textPtr);

        } else if (node->data == "endif") {
        	//nothing

        } else if (node->data == "while") {
        	FILE	*whileStream;
        	int	while_startInstruc;
        	int	while_endInstruc;
        	int	while_end;

		char    *line = NULL;
		char    *lineptr = NULL;
		int 	index = 0;
		char	invertedNbr = 0;
        	size_t	len = 0;
        	ssize_t	read;

        	if ((whileStream = tmpfile()) == NULL) {
        		printf("Cannot create a temporary file, exit\n");
        		exit(1);
        	}

        	ilcpt += 1;
        	fprintf(whileStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(whileStream, "br END_INSTRUC\n\n");
        	ilcpt += 4;

		while_startInstruc = ilcpt + 1;
        	produce_code(g_node_nth_child(node, 1), whileStream, textPtr);
        	while_endInstruc = ilcpt + 1;

        	produce_code(g_node_nth_child(node, 0), whileStream, "START");
        	produce_code(g_node_nth_child(node, 2), whileStream, textPtr);

        	while_end = ilcpt + 1;

		invertedNbr = 1;
		rewind(whileStream);
		while ((read = getline(&line, &len, whileStream)) != -1) {
			line = check_bool(pStream, line, &invertedNbr);

			if ((lineptr = strstr(line, "END_INSTRUC")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "IL_%04x", while_endInstruc);
                        	fprintf(pStream, "%s", lineptr + strlen("END_INSTRUC"));

                        } else if ((lineptr = strstr(line, "START")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "IL_%04x", while_startInstruc);
                        	fprintf(pStream, "%s", lineptr + strlen("START"));

                        } else if ((lineptr = strstr(line, "BREAK")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "IL_%04x", while_end);
                        	fprintf(pStream, "%s", lineptr + strlen("BREAK"));

                        } else if ((lineptr = strstr(line, "CONTINUE")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "IL_%04x", while_endInstruc);
                        	fprintf(pStream, "%s", lineptr + strlen("CONTINUE"));

			} else {
                        	fprintf(pStream, "%s", line);
                        }
              	}

    		fclose(whileStream);

	} else if (node->data == "code_while") {
		produce_code(g_node_nth_child(node, 0), pStream, textPtr);
		produce_code(g_node_nth_child(node, 1), pStream, textPtr);

        } else if (node->data == "continue") {
        	ilcpt += 1;
        	fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "br CONTINUE\n\n");
    		ilcpt += 4;

        } else if (node->data == "break") {
        	ilcpt += 1;
        	fprintf(pStream, "\tIL_%04x:  ", ilcpt);
                fprintf(pStream, "br BREAK\n\n");
    		ilcpt += 4;

        } else if (node->data == "endwhile") {
        	//Ignored

        } else if (node->data == "true") {

        } else if (node->data == "false") {

        } else if (node->data == "sup_egal") {

                produce_code(g_node_nth_child(node, 0), pStream, textPtr);
                produce_code(g_node_nth_child(node, 1), pStream, textPtr);

        	ilcpt += 1;
        	fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "BLT %s\n\n", textPtr);
		ilcpt += 4;

        } else if (node->data == "inf_egal") {
                produce_code(g_node_nth_child(node, 0), pStream, textPtr);
                produce_code(g_node_nth_child(node, 1), pStream, textPtr);

		ilcpt += 1;
                fprintf(pStream, "\tIL_%04x:  ", ilcpt);
                fprintf(pStream, "BGT %s\n\n", textPtr);
                ilcpt += 4;

        } else if (node->data == "sup") {
                produce_code(g_node_nth_child(node, 0), pStream, textPtr);
                produce_code(g_node_nth_child(node, 1), pStream, textPtr);

		ilcpt += 1;
        	fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "BLE %s\n\n", textPtr);
		ilcpt += 4;

        } else if (node->data == "inf") {
                produce_code(g_node_nth_child(node, 0), pStream, textPtr);
                produce_code(g_node_nth_child(node, 1), pStream, textPtr);

		ilcpt += 1;
        	fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "BGE %s\n\n", textPtr);
		ilcpt += 4;

        } else if (node->data == "egal") {
                produce_code(g_node_nth_child(node, 0), pStream, textPtr);
                produce_code(g_node_nth_child(node, 1), pStream, textPtr);

		ilcpt += 1;
        	fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "BNE.UN %s\n\n", textPtr);
		ilcpt += 4;

        } else if (node->data == "sharp") {
        	//unsupported

        } else if (node->data == "not") {
        	FILE	*notStream;

		char    *line = NULL;
		char    *lineptr = NULL;
		int 	index = 0;
        	size_t	len = 0;
        	ssize_t	read;

        	if ((notStream = tmpfile()) == NULL) {
        		printf("Cannot create a temporary file, exit\n");
        		exit(1);
        	}
                produce_code(g_node_nth_child(node, 0), notStream, textPtr);

		rewind(notStream);
		while ((read = getline(&line, &len, notStream)) != -1) {

			if ((lineptr = strstr(line, "BLT")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "BGE");
                        	fprintf(pStream, "%s", lineptr + strlen("BLT"));

                        } else if ((lineptr = strstr(line, "BGT")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "BLE");
                        	fprintf(pStream, "%s", lineptr + strlen("BGT"));

                        } else if ((lineptr = strstr(line, "BLE")) != NULL) {
                        	index = lineptr - line;

                                fprintf(pStream, "%.*s", index, line);
                                fprintf(pStream, "BGT");
                                fprintf(pStream, "%s", lineptr + strlen("BLE"));

 			} else if ((lineptr = strstr(line, "BGE")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "BLT");
                        	fprintf(pStream, "%s", lineptr + strlen("BGE"));

                        } else if ((lineptr = strstr(line, "BNE.UN")) != NULL) {
                         	index = lineptr - line;

				fprintf(pStream, "%.*s", index, line);
                                fprintf(pStream, "BEQ");
                                fprintf(pStream, "%s", lineptr + strlen("BNE.UN"));

                        } else if ((lineptr = strstr(line, "BEQ")) != NULL) {
                         	index = lineptr - line;

				fprintf(pStream, "%.*s", index, line);
                                fprintf(pStream, "NE.UN");
                                fprintf(pStream, "%s", lineptr + strlen("BEQ"));

                        } else {
                        	fprintf(pStream, "%s", line);
                        }
              	}

    		fclose(notStream);

        } else if (node->data == "and") {
        	FILE	*andStream;

		char    *line = NULL;
		char    *lineptr = NULL;
		int 	index = 0;
		char	invertedNbr = 0;
        	size_t	len = 0;
        	ssize_t	read;

        	if ((andStream = tmpfile()) == NULL) {
        		printf("Cannot create a temporary file, exit\n");
        		exit(1);
        	}

        	produce_code(g_node_nth_child(node, 0), andStream, textPtr);
        	produce_code(g_node_nth_child(node, 1), andStream, textPtr);

		invertedNbr = 0;
		rewind(andStream);
		while ((read = getline(&line, &len, andStream)) != -1) {
			//line = check_bool(pStream, line, &invertedNbr);
			//fprintf(pStream, "%s", line);

			if ((lineptr = strstr(line, "BLT")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "blt");
                        	fprintf(pStream, "%s", lineptr + strlen("BLT"));

                        } else if ((lineptr = strstr(line, "BGT")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "bgt");
                        	fprintf(pStream, "%s", lineptr + strlen("BGT"));

                        } else if ((lineptr = strstr(line, "BLE")) != NULL) {
                        	index = lineptr - line;

                                fprintf(pStream, "%.*s", index, line);
                                fprintf(pStream, "ble");
                                fprintf(pStream, "%s", lineptr + strlen("BLE"));

 			} else if ((lineptr = strstr(line, "BGE")) != NULL) {
				index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "bge");
                        	fprintf(pStream, "%s", lineptr + strlen("BGE"));

                        }
                         else if ((lineptr = strstr(line, "BNE.UN")) != NULL) {
                         	index = lineptr - line;

				fprintf(pStream, "%.*s", index, line);
                                fprintf(pStream, "bne.un");
                                fprintf(pStream, "%s", lineptr + strlen("BNE.UN"));
                        } else {
                        	fprintf(pStream, "%s", line);
                        }
              	}

    		fclose(andStream);

        } else if (node->data == "or") {
        	FILE	*orStream;
        	int	or_endInstruc;

		char    *line = NULL;
		char    *lineptr = NULL;
		int 	index = 0;
		char	invertedNbr = 0;
        	size_t	len = 0;
        	ssize_t	read;

        	if ((orStream = tmpfile()) == NULL) {
        		printf("Cannot create a temporary file, exit\n");
        		exit(1);
        	}

        	produce_code(g_node_nth_child(node, 0), orStream, "END");
        	produce_code(g_node_nth_child(node, 1), orStream, textPtr);
        	or_endInstruc = ilcpt + 1;

		invertedNbr = 1;
		rewind(orStream);
		while ((read = getline(&line, &len, orStream)) != -1) {
			line = check_bool(pStream, line, &invertedNbr);

			if ((lineptr = strstr(line, "END")) != NULL) {
                        	index = lineptr - line;

                        	fprintf(pStream, "%.*s", index, line);
                        	fprintf(pStream, "IL_%04x", or_endInstruc);
                        	fprintf(pStream, "%s", lineptr + strlen("END"));

                        } else {
                        	fprintf(pStream, "%s", line);
                        }
              	}

    		fclose(orStream);

        } else if (node->data == "add") {
        	produce_code(g_node_nth_child(node, 0), pStream, textPtr);
	        produce_code(g_node_nth_child(node, 1), pStream, textPtr);

	        ilcpt += 1;
	        fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "add\n");

    	} else if (node->data == "sub") {
        	produce_code(g_node_nth_child(node, 0), pStream, textPtr);
        	produce_code(g_node_nth_child(node, 1), pStream, textPtr);

	        ilcpt += 1;
	        fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "sub\n");

    	} else if (node->data == "mul") {
        	produce_code(g_node_nth_child(node, 0), pStream, textPtr);
        	produce_code(g_node_nth_child(node, 1), pStream, textPtr);

	        ilcpt += 1;
	        fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "mul\n");

    	} else if (node->data == "div") {
        	produce_code(g_node_nth_child(node, 0), pStream, textPtr);
        	produce_code(g_node_nth_child(node, 1), pStream, textPtr);

	        ilcpt += 1;
	        fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "div\n");

    	}else if (node->data == "identifier") {
	        ilcpt += 1;
		fprintf(pStream, "\tIL_%04x:  ", ilcpt);
                fprintf(pStream, "ldloc.%ld\n", (long)g_node_nth_child(node, 0)->data - 1);

        } else if (node->data == "number") {
        	ilcpt += 1;
		fprintf(pStream, "\tIL_%04x:  ", ilcpt);
        	fprintf(pStream, "ldc.i4.%ld\n", (long)g_node_nth_child(node, 0)->data);

    	} else if (node->data == "end") {
    		//Ignored
    	}
}

void end_code() {
	ilcpt += 1;
	fprintf(stream, "\tIL_%04x:  ", ilcpt);
	fprintf(stream, "ret\n");
	fprintf(stream, "}\n");
}

int main(int argc, char **argv) {
	if (argc == 2) {
        	char *file_name_input = argv[1];
        	char *extension;
        	char *directory_delimiter;
        	char *basename;
        	char *module_name;
	        extension = rindex(file_name_input, '.');
        	if (!extension || strcmp(extension, ".facile") != 0) {
            		fprintf(stderr, "Input filename extension must be '.facile'\n");
            		return EXIT_FAILURE;
        	}

        	directory_delimiter = rindex(file_name_input, '/');
        	if (!directory_delimiter) {
            		directory_delimiter = rindex(file_name_input, '\\');
        	}

        	if (directory_delimiter) {
            		basename = strdup(directory_delimiter + 1);
        	} else {
            		basename = strdup(file_name_input);
	        }

        	module_name = strdup(basename);
        	*rindex(module_name, '.') = '\0';
        	strcpy(rindex(basename, '.'), ".il");
        	char *onechar = module_name;
        	if (!isalpha(*onechar) && *onechar != '_') {
            		free(basename);
            		fprintf(stderr, "Base input filename must start with a letter or an underscore\n");
            		return EXIT_FAILURE;
        	}
        	onechar++;
        	while (*onechar) {
            		if (!isalnum(*onechar) && *onechar != '_') {
                		free(basename);
                		fprintf(stderr, "Base input filename cannot contains special characters\n");
                		return EXIT_FAILURE;
            		}
            		onechar++;
        	}

        	if (stdin = fopen(file_name_input, "r")) {
            		if (stream = fopen(basename, "w")) {
                		table = g_hash_table_new_full(g_str_hash, g_str_equal, free, NULL);
                		yyparse();
                		g_hash_table_destroy(table);
                		fclose(stream);
                		fclose(stdin);
            		} else {
                		free(basename);
                		fclose(stdin);
                		fprintf(stderr, "Output filename cannot be opened\n");
                		return EXIT_FAILURE;
            		}
        	} else {
            		free(basename);
            		fprintf(stderr, "Input filename cannot be opened\n");
            		return EXIT_FAILURE;
        	}
        	free(basename);
    	} else {
        	fprintf(stderr, "No input filename given\n");
        	return EXIT_FAILURE;
    	}
    	return EXIT_SUCCESS;
}