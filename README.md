# CineScript 🎥

**CineScript** è un linguaggio di programmazione personalizzato ispirato al mondo del cinema e della sceneggiatura. Il suo obiettivo è rendere l’esperienza di programmazione più narrativa e coinvolgente, soprattutto per chi si avvicina per la prima volta al coding. Le istruzioni, i blocchi di codice e le strutture logiche assumono nomi e forme tipiche della regia cinematografica, come `SCENA`, `AZIONE`, `RIPRENDI`, `DRAMMA`, `FINALE` e così via.

Questo progetto è stato interamente scritto in **C**, utilizzando **FLEX** per il lexer e **BISON** per il parser. L'esecuzione avviene interpretando uno script `.cinema` (o qualsiasi altro file di input testuale) con il programma `cinescript` compilato.

---

## 📆 Contenuto del progetto

* `CineScripty.y` — Parser Bison (YACC)
* `Cine-lex.l` — Lexer Flex
* `Makefile` — Script per la compilazione
* `test.cinema` — Esempio di programma CineScript
* `README.md` — Documentazione dettagliata (questo file)

---

## ⚡ Installazione e Compilazione

Compila il progetto con i seguenti comandi:

```bash
flex Cine-lex.l
bison -d CineScripty.y
gcc lex.yy.c CineScripty.tab.c -o cinescript -lm
```

Oppure usa direttamente:

```bash
make
```

Esegui uno script con:

```bash
./cinescript < test.cinema
```

---

## 🌐 Sintassi e Comandi

### Dichiarazione variabili

* `AZIONE x = 3.5` → dichiarazione di variabile `float`
* `DRAMMA titolo = "Ciao"` → dichiarazione di variabile `string`

### Riassegnazione

* `RIPRENDI x = 7.2`

### Stampa

* `SCENA x` → stampa il valore della variabile

### Commenti

* I commenti iniziano con `@` o possono essere riconosciuti tramite il token `BATTUTA`

### Fine programma

* `FINALE` → stampa finale e termina il programma
* `TAGLIA` → termina senza output

### Operazioni

* `+`, `-`, `*`, `/` per `float`
* `+` per concatenazione di stringhe
* Conversione implicita da `float` a `string` se necessario

### Controlli logici

* `IF`, `WHILE` con scope gestito internamente tramite variabile `currentScope`

### Funzioni

* Dichiarazione con `FILM nome(...) { ... REGISTRA risultato }`
* Invocazione con `nome(...)`

---

## 🔀 Internals: come funziona

### Symbol Table (Variabili)

Struttura collegata `struct Variable` con:

* `id`, `type` ("float"/"string"), `scope`
* `value` come union tra `floatValue` e `stringValue`

### Lista Funzioni

`struct Function` per registrare:

* nome funzione, lista parametri, valore di ritorno e puntatore alla funzione successiva

### Principali funzioni di supporto

#### `Variable toVar(char* stringa, float numero)`

Restituisce una variabile temporanea, utile per rappresentare letterali numerici o stringhe all'interno delle espressioni.

#### `Variable varOp(Variable a, Variable b, char op)`

Esegue un'operazione tra due variabili. Supporta:

* Operazioni aritmetiche se entrambe `float`
* Concatenazione stringhe se almeno una delle due è `string`
* Conversione implicita da `float` a `string`

#### `void addVariable(...)`

Aggiunge una nuova variabile alla symbol table, allocando dinamicamente memoria. Gestisce correttamente il tipo e lo scope.

#### `Variable* lookup(char* s)`

Restituisce un puntatore alla variabile con nome `s`, rispettando lo scope.

#### `char* floatToString(float f)`

Converte un numero `float` in una stringa con due cifre decimali. Utile per concatenazioni.

#### `void printValue(Variable* v)`

Stampa a schermo una variabile: `%.2f` per float, altrimenti stampa la stringa.

---

## 🔹 Esempio completo

```cine
@ Somma e stampa
AZIONE a = 5
AZIONE b = 2.5
AZIONE somma = a + b
SCENA somma

@ Concatenazione
DRAMMA messaggio = "Totale: " + somma
SCENA messaggio

FINALE
```

Output:

```
7.50
Totale: 7.50

 ### OUTPUT: ###
```

---

## 🚫 Funzionalità da completare

* [ ] `changeValue()` → modifica il valore di una variabile esistente
* [ ] `callFunction()` → esecuzione reale di una funzione utente
* [ ] `printSymbolTable()` → stampa la tabella delle variabili
* [ ] `outOfBoundRemove()` → rimuove le variabili locali a blocchi `IF` o `WHILE` terminati
* [ ] `newParamList()` / `appendParam()` → costruzione della lista di parametri formali

---

## 📈 Obiettivi futuri

* Valutazione delle espressioni nelle funzioni utente
* Supporto alle funzioni con parametri
* Estensione con `SCENEGGIATURA` per importare script esterni
* Debugger integrato

---

## 👤 Autore

**Emanuele Pippa** – Progetto accademico, 2025.

CineScript è pensato per essere un linguaggio narrativo, accessibile, e potenzialmente estendibile per uso didattico o ludico.

> "Ogni programma è una storia: raccontala con una sceneggiatura."
