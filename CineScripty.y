// @EMANUELE PIPPA
// CineScript - Linguaggio di programmazione basato sulla sceneggiatura

/* definitions */
%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define CHAR_MAX 256

typedef struct Variable Variable;
typedef struct NodoArgomento NodoArgomento;

//Symbol Table: variabili (float/string)
struct Variable {
    char* type; //float o string
    char* id;   //nome della variabile
    int scope;  //livello profondità dentro IF/WHILE
    union { 
        float floatValue;
        char* stringValue;
    } value;
    struct Variable* next;
};

//Nodo per lista argomenti
typedef struct NodoArgomento {
    Variable* val;
    struct NodoArgomento* next;
} NodoArgomento;


//variabili globali
int currentScope = 0;
Variable* head = NULL;
Variable* tail = NULL;
char* output;

// Prototipi
void yyerror(const char *s);
int yylex(void);

Variable* lookup(char* s);
Variable varOp(Variable a, Variable b, char op);
Variable toVar(char* s, float f);
Variable getValue(Variable v);

void addVariable(char* type, char* name, float numero, char* stringa, int scope);
void changeValue(Variable* v, Variable newVal);
void printValue(Variable* v);
float getFloatValue(Variable v);
char* getStringValue(Variable v);
void printSymbolTable(void);
void outOfBoundRemove(void);

char** newParamList(char* s);
char** appendParam(char** list, char* s);

NodoArgomento* creaNodoArgomento(Variable* var);
NodoArgomento* addNodeToHead(NodoArgomento* catena, Variable* var);
void addFunction(char* name, char** lista_parametri, int paramCount, Variable returnValue);
Variable* callFunction(char* name, NodoArgomento* lista);
%}


%union{
    char* lexeme;   //id, string
    float value;    //num
    struct Variable* variabile;
    struct NodoArgomento* arglist;
    char** paramList;
}

//dichiazione token riconosciuti dal lexer
%token IF WHILE DRAMMA RIPRENDI SCENA TAGLIA BATTUTA FILM REGISTRA FINALE AZIONE
%token <value> NUM FLOAT
%token <lexeme> ID STRING

//Non terminali
%type <lexeme> com_expr compare functionDeclaration
%type <arglist> lista_argomenti
%type <paramList> lista_parametri
%type <variabile> expr function_call stmt



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
stmtLi : stmt stmtLi  { }
       | if_stmt stmtLi    { }
       | while_stmt stmtLi { }
       | FINALE     {printf("\n ### OUTPUT: ### \n%s", output); printSymbolTable(); exit(0);} //stampa contenuto di SCENA
       | TAGLIA     {exit(0);} //termina programma
       |            { } /*empty*/
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
                | expr ',' lista_argomenti {$$ = addNodeToHead($3, $1);}
                |                          {$$ = NULL;}
                ;


functionDeclaration : FILM ID '(' lista_parametri ')' '{' stmtLi REGISTRA expr '}' {addFunction($2, $4, /*count*/0, *$9);}    //id, parametri, corpo, return
                    ;

lista_parametri : ID                 {$$ = newParamList($1);}
           | ID ',' lista_parametri  {$$ = appendParam($3, $1);}
           |                         {$$ = NULL;} /*empty*/
           ;

function_call : ID '(' lista_argomenti ')' {$$ = callFunction($1, $3);}
              ;

//istruzioni
//$$ :   $1   $2   $3  $4
stmt : AZIONE ID '=' expr   {addVariable("float", $2, getFloatValue(*$4), NULL, currentScope);}   //assegnazione variabile float
     | DRAMMA ID '=' expr   {addVariable("string", $2, 0.0, getStringValue(*$4), currentScope);}  //assegnazione variabile stringa
     | RIPRENDI ID '=' expr {changeValue(lookup($2), *$4);}     //riassegnazione variabili
     | SCENA ID             {printValue(lookup($2));}           //stampa variabile
     | BATTUTA              { }     //commento
     | function_call        { }
     ;

//expressions
expr : ID              {$$ = lookup($1);}
     | NUM             {Variable temp = toVar(NULL, $1); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | STRING          {Variable temp = toVar($1, 0.0); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr '+' expr   {Variable temp = varOp(*$1, *$3, '+'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr '-' expr   {Variable temp = varOp(*$1, *$3, '-'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr '*' expr   {Variable temp = varOp(*$1, *$3, '*'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr '/' expr   {Variable temp = varOp(*$1, *$3, '/'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     ;

%%      
/* routines */

struct Function {
    char* name;         //nome funzione         (es.somma)
    char** lista_parametri;               //    (x,y)
    int paramCount;     //quantità parametri    (2)
    Variable returnValue;                 //    (x+y)
    struct Function* next;  //puntatore funzione successiva
};

//Crea un nuovo nodo singolo
NodoArgomento* creaNodoArgomento(Variable* valore) {
    NodoArgomento* nodo = malloc(sizeof *nodo);
    nodo->val = valore;
    nodo->next = NULL;
    return nodo;
}

//Aggiunge un nodo in testa a una catena
NodoArgomento* addNodeToHead(NodoArgomento* catena, Variable* valore) {
    NodoArgomento* nodo = malloc(sizeof *nodo);
    nodo->val = valore;
    nodo->next = catena;
    return nodo;
}

struct Function* listaFunzioni = NULL;

//registra funzioni: aggiunge una nuova funzione alla lista delle funzioni (Symbol Table)
void addFunction(char* name, char** parameters, int numberParameters, Variable returnVal) {
    struct Function* f = malloc(sizeof *f);
    f->name = strdup(name);
    f->paramCount = numberParameters;
    f->lista_parametri = parameters;
    f->returnValue = returnVal;
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
Variable* callFunction(char* name, struct NodoArgomento* lista);

//trova variabile nella symbol table
Variable* lookup(char* s) {
    Variable* current = head;
      while (current != NULL) {
            if (strcmp(current->id, s) == 0 && current->scope <= currentScope) {
                  return current;
            }
            current = current->next;
      }
      return NULL; //se non trova la variabile
}

char* floatToString(float f);

//crea una variabilee temporanea, senza salvarla nella Symbol Table
Variable toVar(char* stringa, float number) {
    Variable var;
    var.id = strdup("");    //temporaneo
    var.scope = 0;          //non ha scope
    if (stringa != NULL){
        var.type = "string";    //se è stringa, risultato è stringa
        var.value.stringValue = strdup(stringa);
    } else {
        var.type = "float";     //altrimenti è un numero
        var.value.floatValue = number;
    }
    var.next = NULL;
    return var;
}

Variable varOp(Variable a, Variable b, char op) {
    Variable result;
    result.id = "";
    result.scope = -1;

    //Se uno dei 2 è stringa, funziona solo la concatenazione +
    if (strcmp(a.type, "string") == 0 || strcmp(b.type, "string") == 0) {
        if (op != '+') {
            yyerror("Errore: con stringhe va solo il + per concatenare");
        }
        // Se uno dei due è float, lo converte in stringa
        char* aStr = (strcmp(a.type, "float") == 0) ? floatToString(a.value.floatValue) : a.value.stringValue;
        char* bStr = (strcmp(b.type, "float") == 0) ? floatToString(b.value.floatValue) : b.value.stringValue;

        result.type = "string";
        result.value.stringValue = malloc(strlen(aStr) + strlen(bStr) + 1);
        strcpy(result.value.stringValue, aStr);
        strcat(result.value.stringValue, bStr);
        return result;
    }

    //Se entrambi float fa operazioni aritmetiche
    if (strcmp(a.type, "float") == 0 && strcmp(b.type, "float") == 0) {
        result.type = "float";
        switch(op) {
            case '+':
                result.value.floatValue = a.value.floatValue + b.value.floatValue;
                break;
            case '-':
                result.value.floatValue = a.value.floatValue - b.value.floatValue;
                break;
            case '*':
                result.value.floatValue = a.value.floatValue * b.value.floatValue;
                break;
            case '/':
                if (b.value.floatValue == 0)
                    yyerror("Errore: divisione per zero");
                result.value.floatValue = a.value.floatValue / b.value.floatValue;
                break;
            default:
                yyerror("Errore: operatore non valido. Scegli tra +, -, *, /");
        }
        return result;
    }

    //Se non è ne float ne string
    yyerror("Errore: tipi non compatibili");    //per evitare possibili errori
    return result;
}

Variable getValue(Variable val) {
    return val;
}

void addVariable(char* type, char* name, float numero, char* stringa, int scope) {
    //assegna memoria per la nuova variabile
    Variable* nuova = malloc(sizeof(Variable));
    if (!nuova) {
        yyerror("Errore: allocazione fallita");
        exit(1);
    }

    //Assegna tipo, nome e scope
    nuova->type = strdup(type);
    nuova->id = strdup(name);
    nuova->scope = scope;
    nuova->next = NULL;

    //Assegna il valore in base al tipo (float o string)
    if (strcmp(type, "float") == 0) {
        nuova->value.floatValue = numero;
    } else if (strcmp(type, "string") == 0) {
        nuova->value.stringValue = strdup(stringa);
    } else {
        yyerror("Errore: tipo non riconosciuto, dev'essere float o string");
    }

    nuova->next = NULL;

    //aggiunge la variabile alla fine della lista / Symbol Table
    if (head == NULL) {
    head = nuova;
    tail = nuova;
    } else {
        tail->next = nuova;
        tail = nuova;
    }

}


void changeValue(Variable* v, Variable newVal) {
    // dummy
}

void printValue(Variable* v) {
    if (strcmp(v->type, "float") == 0)
        printf("%.2f\n", v->value.floatValue);
    else
        printf("%s\n", v->value.stringValue);
}

float getFloatValue(struct Variable v) {
    if (strcmp(v.type, "float") == 0) {
        return v.value.floatValue;
    }
    return 0.0;
}


char* getStringValue(Variable v) {
    return v.value.stringValue;
}

void printSymbolTable(void) {
    // dummy
}

void outOfBoundRemove(void) {
    // dummy
}

char** newParamList(char* s) {
    return NULL;
}

char** appendParam(char** list, char* s) {
    return NULL;
}

Variable* callFunction(char* name, NodoArgomento* lista) {
    return NULL;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

char* floatToString(float f) {
    char* buffer = malloc(32);    // Allocate memory for the string
    snprintf(buffer, 32, "%.2f", f);    // Format the float to a string with 2 decimal places
    return buffer;
}

int main() {
    output = malloc(CHAR_MAX);
    strcpy(output, "");
    yyparse();
    return 0;
}
