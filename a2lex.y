/* a2l bison parser [a2l_lexer.y] */
%{
	#include <stdio.h>
	/* Items from Flex */
	extern int yyparse();
	extern int yylex();
	extern FILE *yyin;
	/* yyerror function declaration, needed to overwrite original */
	void yyerror(const char *error_msg);

	/* Defines */
	#define MAX_IDENT 1024
	#define MAX_STRING 255
	#define FALSE 0
	#define TRUE 1
	#define DEBUG FALSE
	/* A2L Version */
	#define MAJOR 1
	#define MINOR 60

	/* A2L Declarations and Structures */
	#include "./a2l.h"
	/* Global Project Variables */
	int proj_active = FALSE;
	Project project; /* Initialize project, only one can exist per a2l file */
	/* Pointers */
	Module *ActiveModule; /* Pointer to current Module block structure */
	Characteristic *ActiveCharacteristic; /* Pointer to current Characteristic block structure */
	Measurement *ActiveMeasurement; /* Pointer to current Measurement block structure */
	Axis_Descr *ActiveAxisDescr; /* Pointer to current Axis Description block structure */

%}

/****** A2L KEYWORDS ******/
%token _BEGIN _END
%token _ASAP2_VERSION
%token _PROJECT
%token _HEADER
%token _VERSION
%token _PROJECT_NO
%token _MODULE
%token _ARRAY_SIZE
%token _AXIS_DESCR
%token _AXIS_PTS_REF
%token _CURVE_PTS_REF
%token _FORMAT
%token _CHARACTERISTIC
%token _MEASUREMENT
%token _PHYS_UNIT
%token _ADDR_EPK
%token _MONOTONY
%token _MATRIX_DIM
%token _READ_ONLY
%token _STEP_SIZE
%token _NUMBER

/***** POSSIBLE DATA TYPES FROM FLEX ******/
%union {
	int     Enum;
	long    Long;
	int 	Int;
	float 	Float;
	char 	*Str;
	char 	*Ident;
	void 	*Ptr;
}

/***** DATA TYPE TOKENS ******/
%token <Enum>	 _ENUM
%token <Int> 	 _INT
%token <Long>	 _HEX
%token <Str> 	 _STR
%token <Ident>	 _IDENT
%token <Float>   _FLOAT

/***** NON-TERMINAL DATA TYPE DECLARATIONS ******/
%type <Str> version format phys_unit
%type <Ident> project_no axis_pts_ref curve_pts_ref
%type <Int> array_size matrix_dim number
%type <Long> addr_epk
%type <Enum> monotony
%type <Float> step_size
%type <Ptr> axis_descr.block measurement.block module.block characteristic.block

%start a2l /* Defines starting grammar rule */
%error-verbose /* Prints found Token and expected Token on error */

%%

a2l: asap2_version
     project

asap2_version: _ASAP2_VERSION _INT _INT 
			   { snprintf(project.sAsap2version, 5, "%d.%d", $2, $3); }

/*************************************************************************/

project: project.start /* Defines the start of an a2l project */
		 project.opts /* Header and Modules are technically optional */
		 project.end /* /End Project Tag */

project.start:	_BEGIN _PROJECT
				_IDENT /* Project Name */
				_STR /* Project Comment */
				{ 
				  if (DEBUG) { printf("Start Project\n"); }

				  if (proj_active) {
					perror("Only one project allowed per a2l");
				  }
				  else {
				  	proj_active = TRUE;
				  	project.nModules = 0;
				  	project.sName = $3;
				  	project.sComment = $4;
				  }
				}

project.opts: /* Empty */
			| project.opts header.block /* There can only be one header so just set values in project structure */
			| project.opts module.block { SetModule(&project, $2); }

project.end: _END _PROJECT /* Should we do anything when the project ends? */

/****************************** All Defined Parameters ************************************/

 /* Optional Parameters --- Keyword but requires no /begin statement */
version: _VERSION _STR					{ $$ = $2; }
project_no: _PROJECT_NO _IDENT			{ $$ = $2; }
axis_pts_ref: _AXIS_PTS_REF _IDENT		{ $$ = $2; }
array_size: _ARRAY_SIZE _INT			{ $$ = $2; } /* Preferred keyword is MATRIX_DIM */
format: _FORMAT _STR 					{ $$ = $2; }
curve_pts_ref: _CURVE_PTS_REF _IDENT    { $$ = $2; }
phys_unit: _PHYS_UNIT _STR 				{ $$ = $2; }
addr_epk: _ADDR_EPK _HEX				{ $$ = $2; }
monotony: _MONOTONY _ENUM				{ $$ = $2; }
matrix_dim: _MATRIX_DIM _INT 			{ $$ = $2; }
number: _NUMBER _INT 					{ $$ = $2; } /* Preferred keyword is MATRIX_DIM */
step_size: _STEP_SIZE _FLOAT			{ $$ = $2; }
/* read only: _READ_ONLY --- Unnecessary to use just define in block */

/************** START HEADER ****************/
header.block: header.start
			  header.content
			  header.end 

header.start: _BEGIN _HEADER			{ if (DEBUG) { printf("Start Header\n"); } } 
	    	  
header.content: _STR /* header comment */
	    	    header.opts				{ project.sHeaderComment = $1; }

header.end: _END _HEADER 				{ if (DEBUG) { printf("End Header\n"); } }

header.opts: /* Empty */
	       | header.opts header.opt_param

header.opt_param: version 				{ project.sVersion = $1; }
				| project_no 			{ project.sProjectNo = $1; }

/*************** END HEADER ***************/

/*************** START MODULE ***************/
module.block: module.start
			  module.content
			  module.end
			  { $$ = ActiveModule; }
			  /* Return pointer to parent block */

module.start: _BEGIN _MODULE			
			  { 
			  	ActiveModule = CreateModule();
			  	/* Initialize Pointer to Module Struct */
			  	if (DEBUG) { printf("Module Started\n"); }
			  }

module.content: _IDENT
	    	    _STR
	    	    module.opts				
	    	    { 
	    	    	ActiveModule->sName = $1;
	    	    	ActiveModule->sId = $2;
	    	    }

module.opts: /* Empty */
	       | module.opts module.opt_param

module.opt_param: characteristic.block 	{ SetCharacteristic(ActiveModule, $1); }
				| measurement.block 	{ SetMeasurement(ActiveModule, $1); }
			/*  | axis_pts.block 		{ SetAxisPts(ActiveModule, $1); } */
				| other.block
				| data.type

module.end: _END _MODULE
/*************** END MODULE ****************/

/*********** START CHARACTERISTIC ***********/
characteristic.block: characteristic.start
					  characteristic.content
					  characteristic.end 
					  { $$ = ActiveCharacteristic; }

characteristic.start: _BEGIN _CHARACTERISTIC 
					  {
					  	  ActiveCharacteristic = CreateCharacteristic();
					  	  if (DEBUG) { printf("Characteristic\n"); }
					  } 

characteristic.content: _IDENT
						_STR
						_ENUM
						_HEX	
						_IDENT
						_FLOAT 
						_IDENT
						_FLOAT
						_FLOAT
						characteristic.opts
						{
							ActiveCharacteristic->sName = $1;
							ActiveCharacteristic->sId = $2;
							ActiveCharacteristic->eType = $3;
							ActiveCharacteristic->ulAddress = $4;
							ActiveCharacteristic->sDeposit = $5;
							ActiveCharacteristic->fMaxDiff = $6;
							ActiveCharacteristic->sConversion = $7;
							ActiveCharacteristic->fLowerLimit = $8;
							ActiveCharacteristic->fUpperLimit = $9;
						}

characteristic.opts: /* Empty */
				   | characteristic.opts characteristic.opt_param

characteristic.opt_param: axis_descr.block { SetAxisDescr(ActiveCharacteristic, $1); }
						| data.type
						| other.parameter
						| other.block

characteristic.end: _END _CHARACTERISTIC
/*********** END CHARACTERISTIC ***********/

/*********** START MEASUREMENT ************/
measurement.block: measurement.start
				   measurement.content
				   measurement.end 			
				   { $$ = ActiveMeasurement; }

measurement.start: _BEGIN _MEASUREMENT
				  {
				      ActiveMeasurement = CreateMeasurement();
				      if (DEBUG) { printf("Measurement\n"); }
				  } 

measurement.content: _IDENT
					 _STR
					 _IDENT
					 _IDENT
					 _INT
					 _FLOAT
					 _FLOAT
					 _FLOAT
					 measurement.opts
					 {
					 	ActiveMeasurement->sName = $1;
					 	ActiveMeasurement->sId = $2;
					 	ActiveMeasurement->sDataType = $3;
					 	ActiveMeasurement->sConversion = $4;
					 	ActiveMeasurement->uiResolution = $5;
					 	ActiveMeasurement->fAccuracy = $6;
					 	ActiveMeasurement->fLowerLimit = $7;
					 	ActiveMeasurement->fUpperLimit = $8;
					 }

measurement.opts: /* Empty */
				| measurement.opts measurement.opt_param

measurement.opt_param: array_size
					 | matrix_dim

measurement.end: _END _MEASUREMENT
/*********** END MEASUREMENT ************/

/************* START AXIS_DESCR **************/
axis_descr.block: axis_descr.start
				  axis_descr.content
				  axis_descr.end            { $$ = ActiveAxisDescr; }

axis_descr.start: _BEGIN _AXIS_DESCR		{ printf("Axis started\n"); }

axis_descr.content: _ENUM /* attribute */	
				    _IDENT /* input_quantity */
				    _IDENT /* conversion */
				    _INT  /* max_axis_points */
				    _FLOAT /* lower_limit */
				    _FLOAT /* upper_limit */ 
				    axis_descr.opts

axis_descr.opts: /* Empty */
			   | axis_descr.opts axis_descr.opt_param

axis_descr.opt_param: axis_pts_ref
					| curve_pts_ref
					| monotony 			{printf("%i\n", $1);}
					| format
					| data.type 
					| other.block

axis_descr.end: _END _AXIS_DESCR
/************** END AXIS_DESCR ***************/

/*************** START OTHER ***************/
/* Other is all the blocks that are not
   needed and we need to just loop through */

other.block: other.start
			 other.content
			 other.end

other.start: _BEGIN _IDENT				{ printf("Start %s\n", $2); free($2); }

other.content: /* Empty */
			 | other.content data.type /* Undefined Parameters */
			 | other.content other.parameter /* Defined Parameters */
			 | other.content other.block /* Undefined Blocks */

/* defined_block is used to burn defined blocks within an undefined block */

/* parameter is used to burn found keywords in unwanted blocks */
other.parameter: version 				{ free($1); }
		       | project_no     		{ free($1); }
		 	   | axis_pts_ref 			{ free($1); }
		 	   | format 				{ free($1); }
			   | array_size
			   | curve_pts_ref 			{ free($1); }
			   | phys_unit 				{ free($1); }
			   | addr_epk
			   | monotony
			   | matrix_dim
			   | number
			   | step_size

other.end: _END _IDENT					{ printf("End %s\n", $2); free($2); }

/************* END OTHER *************/

/************* START DATA TYPES ***************/
data.type: _IDENT						{ free($1); }
		 | _STR 						{ free($1); }
		 | _FLOAT
		 | _HEX
		 | _INT
/************ END DATA TYPES *****************/

%%
/* Function call from terminal */
int main(int argc, char **argv) {	
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
		if (!yyin) {
			char *error;
			asprintf(&error, "%s is not a valid file", argv[1]);
			perror(error);
			return -1;
		}
	}
 	yyparse();
 	if (DEBUG) { printf("%s\n",project.sAsap2version); }
}

/* Function call from Library */
Project a2lparse(char *file_path) {
	yyin = fopen(file_path, "r");
	if (!yyin) {
		char *error;
		asprintf(&error, "%s is not a valid file", file_path);
		perror(error);
		return reset_project;
	}
 	yyparse();
 	FreeProject(&project);
 	return project;
}

void yyerror(const char *error_msg) {
	perror(error_msg);
}