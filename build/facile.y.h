/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_HOME_MOUSSTACH_BUREAU_UNIV_LR_L3_SEMESTRE6_UNIV_LR_COMPILATION_TP_BUILD_FACILE_Y_H_INCLUDED
# define YY_YY_HOME_MOUSSTACH_BUREAU_UNIV_LR_L3_SEMESTRE6_UNIV_LR_COMPILATION_TP_BUILD_FACILE_Y_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TOK_NUMBER = 258,
    TOK_IDENTIFIER = 259,
    TOK_AFFECTATION = 260,
    TOK_SEMI_COLON = 261,
    TOK_IF = 262,
    TOK_ELSE = 263,
    TOK_ELSEIF = 264,
    TOK_THEN = 265,
    TOK_ENDIF = 266,
    TOK_WHILE = 267,
    TOK_DO = 268,
    TOK_CONTINUE = 269,
    TOK_BREAK = 270,
    TOK_ENDWHILE = 271,
    TOK_END = 272,
    TOK_ADD = 273,
    TOK_SUB = 275,
    TOK_MUL = 277,
    TOK_DIV = 279,
    TOK_NOT = 281,
    TOK_TRUE = 283,
    TOK_FALSE = 284,
    TOK_SUP_EGAL = 285,
    TOK_INF_EGAL = 286,
    TOK_SUP = 287,
    TOK_INF = 288,
    TOK_EGAL = 289,
    TOK_SHARP = 290,
    TOK_AND = 291,
    TOK_OR = 292,
    TOK_OPEN_PARENTHESIS = 293,
    TOK_CLOSE_PARENTHESIS = 294,
    TOK_PRINT = 295,
    TOK_READ = 296
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 26 "facile.y"

	gulong	number;
	gchar	*string;
	GNode	*node;

#line 100 "/home/mousstach/Bureau/univ-lr/L3/semestre6/univ-lr__Compilation_TP/build/facile.y.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_HOME_MOUSSTACH_BUREAU_UNIV_LR_L3_SEMESTRE6_UNIV_LR_COMPILATION_TP_BUILD_FACILE_Y_H_INCLUDED  */
