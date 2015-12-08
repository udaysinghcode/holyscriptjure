%{ open Ast %}

%token PLUS MINUS TIMES DIVIDE PLUSF MINUSF TIMESF DIVIDEF EOF
%token ASSIGN QUOTE AND OR EQ NEQ LT LEQ GT GEQ
%token SEMI LPAREN RPAREN LBRACE RBRACE
%token <int> INT
%token FUNC LET IF FOR WHILE
%token <string> ID
%token <string> STRING
%token <float> FLOAT
%token <bool> BOOL
%token NIL

%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS PLUSF MINUSF
%left TIMES DIVIDE TIMESF DIVIDEF

%start program
%type <Ast.program> program

%%

program:
 expr_list EOF		{ List.rev $1 }

expr_list:
/* nothing */		{ [] }
| expr_list expr SEMI	{ $2 :: $1 }

sexpr:
  LET ID expr expr   		{ Let($2, $3, $4) }
| IF expr expr expr		{ If($2, $3, $4) }
| FOR expr expr expr expr	{ For($2, $3, $4, $5)}
| WHILE expr expr		{ While($2, $3) }
| FUNC LPAREN formals_opt RPAREN expr { Fdecl(List.rev $3, $5) }
| call				{ $1 }

expr:
  atom				{ $1 }
| list				{ $1 }
| LBRACE infix_expr RBRACE	{ $2 }
| LPAREN sexpr RPAREN		{ $2 }

list:
  QUOTE LPAREN args_opt RPAREN 	{ List(List.rev $3) }

formals_opt:
/* nothing */ 	{ [] }
| formal_list	{ List.rev $1 }

 formal_list:
  ID		  { [$1] }
| formal_list ID  { $2 :: $1 }

atom:
  constant		{ $1 }
| ID			{ Id($1) }
| NIL			{ Nil }
| operator		{ Id($1) }
| LET			{ Id("__let") }
| IF			{ Id("__if") }
| FOR			{ Id("__for") }
| WHILE			{ Id("__while") }
| FUNC			{ Id("__func") }

operator:
| PLUS			{ "__add" }
| MINUS			{ "__sub" } 
| TIMES			{ "__mult" }
| DIVIDE		{ "__div" }
| PLUSF			{ "__addf" }
| MINUSF		{ "__subf" }
| DIVIDEF		{ "__divf" } 
| TIMESF		{ "__multf" }
| EQ			{ "__equal" }
| NEQ			{ "__neq" }
| LT			{ "__less" }
| LEQ			{ "__leq" }
| GT			{ "__greater" }
| GEQ			{ "__geq" }
| AND			{ "__and" }
| OR			{ "__or" }


constant: 
  INT 			{ Int($1) } 
| FLOAT			{ Float($1) }
| BOOL			{ Boolean($1) }
| STRING		{ String($1) }

call:
  ID args_opt		{ Eval($1, List.rev $2) }
| operator args 	{ Eval($1, List.rev $2) }

args_opt:
/* nothing */ 		{ [] }
| args			{ List.rev $1 }

args:
  expr			{ [$1] }
| expr args		{ $1 :: $2 }
  
infix_expr:
  constant			{ $1 }
| MINUS INT			{ Int(-1 * $2) }
| MINUS FLOAT			{ Float(-1.0 *. $2) }
| LPAREN infix_expr RPAREN	{ $2 }
| ID ASSIGN infix_expr		{ Assign($1, $3) }
| infix_expr PLUS infix_expr	{ Binop($1, Add, $3) }
| infix_expr MINUS infix_expr	{ Binop($1, Sub, $3) }
| infix_expr TIMES infix_expr	{ Binop($1, Mult, $3) }
| infix_expr DIVIDE infix_expr	{ Binop($1, Div, $3) }
| infix_expr PLUSF infix_expr	{ Binop($1, Addf, $3) }
| infix_expr MINUSF infix_expr	{ Binop($1, Subf, $3) }
| infix_expr TIMESF infix_expr	{ Binop($1, Multf, $3) }
| infix_expr DIVIDEF infix_expr	{ Binop($1, Divf, $3) }
| infix_expr EQ infix_expr	{ Binop($1, Equal, $3) }
| infix_expr NEQ infix_expr	{ Binop($1, Neq, $3) }
| infix_expr LT infix_expr	{ Binop($1, Less, $3) }
| infix_expr LEQ infix_expr	{ Binop($1, Leq, $3) }
| infix_expr GT infix_expr	{ Binop($1, Greater, $3) }
| infix_expr GEQ infix_expr	{ Binop($1, Geq, $3) }
| infix_expr AND infix_expr	{ Binop($1, And, $3) }
| infix_expr OR infix_expr	{ Binop($1, Or, $3) } 
