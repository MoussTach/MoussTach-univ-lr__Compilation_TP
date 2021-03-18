%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <glib.h>
	#include <string.h>
	#include <ctype.h>

	void begin_code();
	void produce_code(GNode* node);
	void end_code();
	extern int	yylex(void);
	extern int	yyerror(const char *msg);
	extern int	yylineno;

	FILE		*stream;
	GHashTable	*table;
	char		*module_name;
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
%token 		TOK_THEN		"then"
%left 		TOK_ADD			"+"
%left 		TOK_SUB			"-"
%left 		TOK_MUL			"*"
%left 		TOK_DIV			"/"
%token 		TOK_OPEN_PARENTHESIS	"("
%token 		TOK_CLOSE_PARENTHESIS	")"
%token 		TOK_PRINT		"print"
%token 		TOK_READ		"read"

%type<node>    code
%type<node>    expression
%type<node>    instruction
%type<node>    identifier
%type<node>    print
%type<node>    read
%type<node>    affectation
%type<node>    number
%%

program: code {
	begin_code();
	produce_code($1);
	end_code();
	g_node_destroy($1);
}
;

code:
	code instruction
	{
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
	read
;

affectation:
	identifier TOK_AFFECTATION expression TOK_SEMI_COLON
	{
	$$ = g_node_new("affectation");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
;

print:
	TOK_PRINT expression TOK_SEMI_COLON
	{
	$$ = g_node_new("print");
	g_node_append($$, $2);
	}

read:
	TOK_READ identifier TOK_SEMI_COLON
	{
	$$ = g_node_new("read");
	g_node_append($$, $2);
	}
;

expression:
	identifier
|
	number
|
	expression TOK_ADD expression
	{
	$$ = g_node_new("add");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	expression TOK_SUB expression
	{
	$$ = g_node_new("sub");
        g_node_append($$, $1);
        g_node_append($$, $3);
	}
|
	expression TOK_MUL expression
	{
	$$ = g_node_new("mul");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	expression TOK_DIV expression
	{
	$$ = g_node_new("div");
	g_node_append($$, $1);
	g_node_append($$, $3);
	}
|
	TOK_OPEN_PARENTHESIS expression TOK_CLOSE_PARENTHESIS
	{
	$$ = $2;
	}
;

identifier:
	TOK_IDENTIFIER
	{
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
	TOK_NUMBER
	{
	$$ = g_node_new("number");
	g_node_append_data($$, (gpointer) $1);
	}
;

%%

int yyerror(const char *msg) {
	fprintf(stderr, "Line %d: %s\n", yylineno, msg);
}

void begin_code() {
}

void produce_code(GNode* node) {
    if (node->data == "code") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
    } else if (node->data == "affectation") {
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " stloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
    } else if (node->data == "add") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " add\n");
    } else if (node->data == "sub") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " sub\n");
    } else if (node->data == "mul") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " mul\n");
    } else if (node->data == "div") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " div\n");
    } else if (node->data == "number") {
        fprintf(stream, " ldc.i4\t%ld\n", (long)g_node_nth_child(node, 0)->data);
    } else if (node->data == "identifier") {
        fprintf(stream, " ldloc\t%ld\n", (long)g_node_nth_child(node, 0)->data - 1);
    } else if (node->data == "print") {
        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " call void class[mscorlib]System.Console::WriteLine(int32)\n");
    } else if (node->data == "read") {
        fprintf(stream, " call string class[mscorlib]System.Console::ReadLine()\n");
        fprintf(stream, " call int32 int32::Parse(string)\n");
        fprintf(stream, " stloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
    }
}

void end_code() {
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
    }
    else {
        fprintf(stderr, "No input filename given\n");
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}