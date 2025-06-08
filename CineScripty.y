// Licenza: Creative Commons BY-NC 4.0 © 2025 Emanuele Pippa
// Uso consentito solo per scopi non commerciali, con attribuzione

/* definitions */
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
    union { float floatValue;
            char* stringValue;
          } value;
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

struct Variable* lookup(char* s);
struct Variable varOp(struct Variable a, struct Variable b, char op);
struct Variable toVar(char* s, float f);
struct Variable getValue(struct Variable v) { return v; }
void add(struct Variable* tail, char* type, char* id, float f, char* s, int scope) {}
void changeValue(struct Variable* v, struct Variable newVal) {}
void printValue(struct Variable* v) {}
float getFloatValue(struct Variable v) { return 0; }
char* getStringValue(struct Variable v) { return ""; }
void printSymbolTable() {}
void outOfBoundRemove() {}
char** newParamList(char* s) { return NULL; }
char** appendParam(char** list, char* s) { return list; }
struct NodoArgomento* creaNodoArgomento(struct Variable* var);
struct NodoArgomento* aggiungiNodoArgomentoInTesta(struct NodoArgomento* catena, struct Variable* var);
void addFunction(char* name, char** lista_parametri, int paramCount, struct Variable returnValue);
struct Variable* callFunction(char* name, struct NodoArgomento* lista);

int yylex(void);

%}

%union{
    char* lexeme;   //id, string
    float value;    //num
    struct Variable variable; //variabile (non è più un puntatore)
    struct NodoArgomento* arglist;
    char** paramList;
    int dummy;  //per evitare problemi di compilazione
}

//dichiazione token riconosciuti dal lexer
%token IF WHILE DRAMMA RIPRENDI SCENA TAGLIA COMMENT FUNZIONE REGISTRA FINALE AZIONE
%token <value> NUM FLOAT
%token <lexeme> ID STRING

//Non terminali
%type <variable> expr function_call stmt
%type <lexeme> com_expr compare functionDeclaration
%type <arglist> lista_argomenti
%type <paramList> lista_parametri
%type <dummy> stmtLi    //mi serve x compilare senza warning

%left '+' '-'
%left '*' '/'
%left GREAT LESS EQUAL GREATQ LESSQ NOTEQ

%start prog

%%      
/* rules */
/* CFG
 <non_term> : <body> {<action>}
            | <body> {<sction>}
            ;
*/

prog : stmtLi
     | functionDeclaration prog
     ;

//lista recorsiva di comandi/istruzioni
stmtLi : stmt '\n' stmtLi   { }
       | if_stmt '\n' stmtLi { }
       | while_stmt '\n' stmtLi { }
       | FINALE {printf("\n ### OUTPUT: ### \n%s", output); printSymbolTable(); exit(0);} //stampa contenuto di SCENA
       | TAGLIA {exit(0);} //termina programma
       ;

while_stmt : WHILE com_expr '{' brace_statement
           ;

if_stmt : IF com_expr '{' brace_statement
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

lista_argomenti : expr                     {$$ = creaNodoArgomento($1);}
                | expr ',' lista_argomenti {$$ = aggiungiNodoArgomentoInTesta($3, $1);}
                |                          {$$ = NULL;}
                ;


functionDeclaration : FUNZIONE ID '(' lista_parametri ')' '{' stmtLi REGISTRA expr '}' {
    addFunction($2, $4, $7, $9);    //id, parametri, corpo, return
};

lista_parametri : ID                 {$$ = newParamList($1);}
           | ID ',' lista_parametri  {$$ = appendParam($3, $1);}
           |                    {$$ = NULL;} /*empty*/
           ;

function_call : ID '(' lista_argomenti ')' {
    $$ = callFunction($1, $3);
};

//istruzioni
//$$ :   $1    $2   $3  $4  $5
stmt : AZIONE FLOAT ID '=' expr     {add(tail, "float", $3, getFloatValue($5), NULL, currentScope); }   //assegnazione variabile float
     | DRAMMA STRING ID '=' expr    {add(tail, "string", $3, NAN, getStringValue($5), currentScope); }  //assegnazione variabile stringa
     | RIPRENDI ID '=' expr         {changeValue(lookup($2), getValue(*$4)); }   //riassegnazione variabili
     | SCENA ID                     {printValue(lookup($2)); }
     | COMMENT                      { }
     | function_call                {$$ = $1;}  //chiamata funzione
     ;

//expressions     $n sono pseudo-variables
expr : ID               {$$ = lookup($1);}
     | NUM              {$$ = toVar(NULL, $1);}
     | STRING           {$$ = toVar($1, NAN);}
     | expr '+' expr    {$$ = varOp($1, $3, '+');}
     | expr '-' expr    {$$ = varOp($1, $3, '-');}
     | expr '*' expr    {$$ = varOp($1, $3, '*');}
     | expr '/' expr    {$$ = varOp($1, $3, '/');}
     ;
%%      

/* routines */

#include "lex.yy.c"

struct Function {
    char* name;         //nome funzione         (es.somma)
    char** lista_parametri;               //    (x,y)
    int paramCount;     //quantità parametri    (2)
    struct Node* body;  //corpo della funzione  
    char* returnExpressionText;           //    (x+y)
    struct Function* next;  //puntatore funzione successiva
};

//Nodo della catena (linked list) di argomenti
struct NodoArgomento {
    struct Variable* var;                 //Valore argomento (variabile, numero, stringa, ecc.)
    struct NodoArgomento* next;
};

//Crea un nuovo nodo singolo
struct NodoArgomento* creaNodoArgomento(struct Variable* var) {
    struct NodoArgomento* nodo = (struct NodoArgomento*)malloc(sizeof(struct NodoArgomento));
    nodo->var = var;
    nodo->next = NULL;
    return nodo;
}

//Aggiunge un nodo in testa a una catena
struct NodoArgomento* aggiungiNodoArgomentoInTesta(struct NodoArgomento* catena, struct Variable* var) {
    struct NodoArgomento* nodo = (struct NodoArgomento*)malloc(sizeof(struct NodoArgomento));
    nodo->var = var;
    nodo->next = catena;
    return nodo;
}

struct Function* listaFunzioni = NULL;

//registra funzioni: aggiunge una nuova funzione alla lista delle funzioni (Symbol Table)
void addFunction(char* name, char** lista_parametri, int paramCount, struct Variable returnValue) {
    struct Function* f = (struct Function*)malloc(sizeof(struct Function));
    f->name = strdup(name);
    f->paramCount = paramCount;
    f->lista_parametri = lista_parametri;
    f->returnValue = strdup(returnValue);
    f->body = NULL;
    f->next = listaFunzioni;
    listaFunzioni = f;
}

//trova una funzione nella lista delle funzioni
struct Function* lookupFunction(char* name) {
    struct Function* current = listaFunzioni;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}
/*  
 * Cerca la funzione col nome name (lookupFunction)
 * Associa ogni argomento passato ai rispettivi parametri
 * Sostituisce i nomi nella returnTextExpression
 * Valuta l’espressione ottenuta con evalExpr
 * Restituisce il risultato (una struct Variable*)
*/
struct Variable* callFunction(char* name, struct NodoArgomento* lista);

