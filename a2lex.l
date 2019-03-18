/* Start of Section One */

/* Options */
/* noyywrap removes Flex library dependency */
%option noyywrap yylineno

/* Parsing States */
%x SINGLE_COMMENT
%x MULTI_COMMENT
%x A2ML

/* Verbatims */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <Python/Python.h>
	#include "a2lex.tab.h"
	#include "a2l.h"
%}

%% 
 /* Start of Section Two */
 /* Patterns */

 /* A2L KEYWORDS */
"/begin" 									{ return _BEGIN; }
"/end"										{ return _END; }
 /* Blocks */
ASAP2_VERSION								{ return _ASAP2_VERSION; }
PROJECT										{ return _PROJECT; }
HEADER										{ return _HEADER; }
MODULE										{ return _MODULE; }
AXIS_DESCR									{ return _AXIS_DESCR; }
CHARACTERISTIC								{ return _CHARACTERISTIC; }
 /* Optional Parameters */
VERSION 									{ return _VERSION; }
PROJECT_NO									{ return _PROJECT_NO; }
ARRAY_SIZE									{ return _ARRAY_SIZE; }
MATRIX_DIM 									{ return _MATRIX_DIM; }
MONOTONY 									{ return _MONOTONY; }
FORMAT										{ return _FORMAT; }
AXIS_PTS_REF								{ return _AXIS_PTS_REF; }
NUMBER										{ return _NUMBER; }
READ_ONLY									{ return _READ_ONLY; }
STEP_SIZE									{ return _STEP_SIZE; }
 /******* START ENUMERATIONS ********/
 /* Monotony Enumerations */
MON_DECREASE								{ yylval.Enum = MON_DECREASE; return _ENUM; }
MON_INCREASE								{ yylval.Enum = MON_INCREASE; return _ENUM; }
STRICT_DECREASE								{ yylval.Enum = STRICT_DECREASE; return _ENUM; }
STRICT_INCREASE								{ yylval.Enum = STRICT_INCREASE; return _ENUM; }
MONOTONOUS									{ yylval.Enum = MONOTONOUS; return _ENUM; }
STRICT_MON									{ yylval.Enum = STRICT_MON; return _ENUM; }
NOT_MON										{ yylval.Enum = NOT_MON; return _ENUM; }
 /* Axis Type Enumerations */
ASCII										{ yylval.Enum = ASCII; return _ENUM; }
CURVE										{ yylval.Enum = CURVE; return _ENUM; }
MAP											{ yylval.Enum = MAP; return _ENUM; }
CUBOID										{ yylval.Enum = CUBOID; return _ENUM; } 
CUBE_4										{ yylval.Enum = CUBE_4; return _ENUM; }
CUBE_5										{ yylval.Enum = CUBE_5; return _ENUM; }
VAL_BLK										{ yylval.Enum = VAL_BLK; return _ENUM; }
VALUE										{ yylval.Enum = VALUE; return _ENUM; }
 /* Attribute Enumerations */
CURVE_AXIS   								{ yylval.Enum = CURVE_AXIS; return _ENUM; }
COM_AXIS   									{ yylval.Enum = COM_AXIS; return _ENUM; }
FIX_AXIS   									{ yylval.Enum = FIX_AXIS; return _ENUM; }
RES_AXIS   									{ yylval.Enum = RES_AXIS; return _ENUM; }
STD_AXIS									{ yylval.Enum = STD_AXIS; return _ENUM; }
 /******* END ENUMERATIONS ********/

 /******* START DATA TYPES *******/
"0x"[a-fA-F0-9]+							{ yylval.Long = strtol(yytext, NULL, 0); return _HEX; }
-?[0-9]+									{ yylval.Int = atoi(yytext); return _INT; }	
-?[0-9]*(\.)?[0-9]*([eE][-+]?[0-9]+)?		{ yylval.Float = atof(yytext); return _FLOAT; }
([a-zA-Z0-9_]+(\[.*\])?(\.)?)+				{ yylval.Ident = strdup(yytext); return _IDENT; }
\"(\\.|[^\"])*\"							{ yylval.Str = strdup(yytext); return _STR; }

 /* A2ML */
"/begin A2ML"								{ BEGIN(A2ML); }
<A2ML>"/end A2ML" 							{ BEGIN(INITIAL); }
<A2ML>(.|\n)+								{ /* Burn */ }

 /* Single Comment */
"//".*\n 									{ /* Burn */ }

 /*Multi Comment */
"/*"										{ BEGIN(MULTI_COMMENT); }
<MULTI_COMMENT>"*/" 						{ BEGIN(INITIAL); }
<MULTI_COMMENT>([^*]|\n)+|.					{ /* Burn */ }
<MULTI_COMMENT><<EOF>> 						{ printf("%d: Unterminated comment\n", yylineno); return 0; }

 /* Catch Alls */
[ \t\r\n]+									{ /* Burn whitespaces, tabs, and carriage returns */ }
.											{ printf("Extra Extra: %s", yytext); }

%%