// Licenza: Creative Commons BY-NC 4.0 © 2025 Emanuele Pippa
// Uso consentito solo per scopi non commerciali, con attribuzione

%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define CHAR_MAX 256

//valori delle variabili: float o string
union Value {
    float floatValue;
    char* stringValue;
};

//Symbol Table
struct Variable{
    char* type; //float o string
    char* id;   //nome della variabile
    int scope;  //livello in cui è dichiarata la variabile (if/while) -> (fuori dal loop) scope=0, (dentro il loop) scope=1+
    union Value value;  //Contiene float o string,
    struct Variable* next;  //puntatore alla variabile successiva della lista
};

//Global Variables
int currentScope=0;
struct Variable* head = NULL;
struct Variable* tail = NULL;
char* output; //stringa finale

void yyerror(const char *s) {   //gestione errori
    fprintf(stderr, "Errore di parsing: %s\n", s);
    exit(1);
}

%}

%union{
    char* lexeme;   //id, string
    float value;    //num
    struct Variable variable;   //espressioni
}

//token dal lexer
%token IF WHILE DRAMMA SCENA RIPRENDI FINALE TAGLIA COMMENT
%token <value> NUM
%token <lexeme> ID STRING FLOAT

//Non terminali
%type <variable> expr
%type <lexeme> stmt prog com_expr comparison

%left '+' '-'
%left '*' '/'
%left GREAT LESS EQUAL GREATQ LESSEQ NOTEQ
%left '(' ')'
%left '[' ']'
%left '{' '}'

%start prog

%%

prog : stmtLi
     ;
//lista recorsiva di comandi/istruzioni
stmtLi : stmt '\n' stmtLi   { }
       | if_stmt '\n' stmtLi { }
       | while_stmt '\n' stmtLi { }
       | FINALE {printf("\n ### OUTPUT: ### \n%s", output); printSymbolTable(); exit(0);} //stampa contenuto di SCENA
       | TAGLIA {exit(0)} //termina programma
       ;

while_stmt : WHILE com_expr '{' brace_statement { }
           ;

if_stmt : IF com_expr '{' brace_statement { }
        ;

com_expr : '(' compare ')' { currentScope++; }
         ;

//codice tra graffe
brace_statement : stmt brace_statement { }
                | if_stmt brace_statement { }
                | while_stmt brace_statement { }
                | '}'   {outOfBoundRemove();} /*elimina variabili dichiarate con il current scope*/
                ;

//confronto
compare : expr EQUAL expr   { }
        | expr NOTEQ expr   { }
        | expr GREAT expr   { }
        | expr GREATQ expr  { }
        | expr LESS expr    { }
        | expr LESSQ expr   { }
        ;

//istruzioni
//$$ :   $1    $2   $3  $4  $5
stmt : AZIONE FLOAT ID '=' expr     {add(tail, "float", $3, getFloatValue($5), NULL, currentScope); }   //assegnazione variabile float
     | DRAMMA STRING ID '=' expr    {add(tail, "string", $3, NAN, getStringValue($5), currentScope); }  //assegnazione variabile stringa
     | RIPRENDI ID '=' expr         {changeValue(lookup($2), getValue($4)); }   //riassegnazione variabili
     | SCENA ID                     {printValue(lookup($2)); }
     | COMMENT                      { }
     ;

//expressions
expr : ID               {$$ = lookup($1);}
     | NUM              {$$ = toVar(NULL, $1);}
     | STRINGA          {$$ = toVar($1, NAN);}
     | expr '+' expr    {$$ = varOp($1, $3, '+');}
     | expr '-' expr    {$$ = varOp($1, $3, '-');}
     | expr '*' expr    {$$ = varOp($1, $3, '*');}
     | expr '/' expr    {$$ = varOp($1, $3, '/');}
     ;
%%