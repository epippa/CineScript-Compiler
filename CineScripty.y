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
    int yylex(void);
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