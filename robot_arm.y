%{
/* ============================================
 * Robot Arm Language - Syntax Analyzer (Bison)
 * Author: Antonio Lucas Michelon de Almeida
 * ============================================ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
void yyerror(const char *s);

FILE *output_file;
int label_count = 0;
int var_offset = 4;

typedef struct {
    char name[50];
    int offset;
} Variable;

Variable symbol_table[100];
int symbol_count = 0;

int get_var_offset(char *name);
void add_variable(char *name);
void emit(const char *code);
void emit_label(int label);
char* new_label();

%}

%union {
    int num;
    char *id;
}

/* Tokens */
%token VAR MOVER PEGAR SOLTAR ESPERAR
%token SE SENAO ENQUANTO
%token CIMA BAIXO ESQUERDA DIREITA
%token OBJETO PESO LIMITE
%token IGUAL DIFERENTE MENOR_IGUAL MAIOR_IGUAL MENOR MAIOR
%token MAIS MENOS MULT DIV
%token ATRIB DOIS_PONTOS ABRE_PAR FECHA_PAR ABRE_CHAVE FECHA_CHAVE
%token <num> NUMERO
%token <id> IDENTIFICADOR

/* Precedência e Associatividade */
%left IGUAL DIFERENTE MENOR MAIOR MENOR_IGUAL MAIOR_IGUAL
%left MAIS MENOS
%left MULT DIV
%right UMINUS

%type <num> Expr Term Factor Direction Condition RelOp

%%

/* ========== Programa ========== */
Program:
    /* vazio */
    | StatementList
    ;

StatementList:
    Statement
    | StatementList Statement
    ;

/* ========== Statements ========== */
Statement:
    VarDecl
    | Assignment
    | MoveStmt
    | GrabStmt
    | ReleaseStmt
    | WaitStmt
    | IfStmt
    | WhileStmt
    | Block
    ;

/* ========== Declaração de Variável ========== */
VarDecl:
    VAR IDENTIFICADOR ATRIB Expr {
        add_variable($2);
        emit("    ; Declaracao de variavel\n");
        emit("    sub esp, 4\n");
        int offset = get_var_offset($2);
        char buffer[100];
        sprintf(buffer, "    mov [ebp-%d], eax\n", offset);
        emit(buffer);
        emit("\n");
        free($2);
    }
    ;

/* ========== Atribuição ========== */
Assignment:
    IDENTIFICADOR ATRIB Expr {
        int offset = get_var_offset($1);
        if (offset == -1) {
            fprintf(stderr, "Erro: variável '%s' não declarada\n", $1);
            exit(1);
        }
        char buffer[100];
        sprintf(buffer, "    ; Atribuicao: %s = expr\n", $1);
        emit(buffer);
        sprintf(buffer, "    mov [ebp-%d], eax\n", offset);
        emit(buffer);
        emit("\n");
        free($1);
    }
    ;

/* ========== Movimento ========== */
MoveStmt:
    MOVER Direction Expr {
        emit("    ; Comando: mover\n");
        emit("    push eax\n");  // quantidade
        char buffer[50];
        sprintf(buffer, "    push dword %d\n", $2);  // direção
        emit(buffer);
        emit("    call move_arm\n");
        emit("    add esp, 8\n");
        emit("    call print_position\n");  // Feedback visual!
        emit("\n");
    }
    ;

Direction:
    CIMA        { $$ = 0; }
    | BAIXO     { $$ = 1; }
    | ESQUERDA  { $$ = 2; }
    | DIREITA   { $$ = 3; }
    ;

/* ========== Pegar Objeto ========== */
GrabStmt:
    PEGAR {
        emit("    ; Comando: pegar\n");
        emit("    call grab_object\n");
        emit("\n");
    }
    ;

/* ========== Soltar Objeto ========== */
ReleaseStmt:
    SOLTAR {
        emit("    ; Comando: soltar\n");
        emit("    call release_object\n");
        emit("\n");
    }
    ;

/* ========== Esperar ========== */
WaitStmt:
    ESPERAR Expr {
        emit("    ; Comando: esperar\n");
        emit("    push eax\n");
        emit("    call wait_ms\n");
        emit("    add esp, 4\n");
        emit("\n");
    }
    ;

/* ========== IF/ELSE ========== */
IfStmt:
    SE Condition DOIS_PONTOS Block {
        int label = label_count++;
        char buffer[100];
        
        emit("    ; Condicao do IF\n");
        emit("    cmp eax, 0\n");
        sprintf(buffer, "    je end_if_%d\n", label);
        emit(buffer);
        emit("\n");
        
        sprintf(buffer, "end_if_%d:\n", label);
        emit(buffer);
        emit("\n");
    }
    | SE Condition DOIS_PONTOS Block SENAO DOIS_PONTOS Block {
        int label = label_count++;
        char buffer[100];
        
        emit("    ; Condicao do IF-ELSE\n");
        emit("    cmp eax, 0\n");
        sprintf(buffer, "    je else_%d\n", label);
        emit(buffer);
        emit("\n");
        
        // Código do THEN já foi emitido
        sprintf(buffer, "    jmp end_if_%d\n", label);
        emit(buffer);
        sprintf(buffer, "else_%d:\n", label);
        emit(buffer);
        emit("\n");
        
        // Código do ELSE já foi emitido
        sprintf(buffer, "end_if_%d:\n", label);
        emit(buffer);
        emit("\n");
    }
    ;

/* ========== WHILE ========== */
WhileStmt:
    ENQUANTO {
        int label = label_count++;
        char buffer[100];
        sprintf(buffer, "loop_%d:\n", label);
        emit(buffer);
        $<num>$ = label;  // Salva o label para usar depois
    } Condition {
        char buffer[100];
        int label = $<num>2;  // Recupera o label
        
        emit("    ; Avalia condicao do WHILE\n");
        emit("    cmp eax, 0\n");
        sprintf(buffer, "    je end_loop_%d\n", label);
        emit(buffer);
        $<num>$ = label;  // Passa o label adiante
    } DOIS_PONTOS Block {
        char buffer[100];
        int label = $<num>4;  // Recupera o label novamente
        
        // Volta para o início do loop
        sprintf(buffer, "    jmp loop_%d\n", label);
        emit(buffer);
        sprintf(buffer, "end_loop_%d:\n", label);
        emit(buffer);
        emit("\n");
    }
    ;

/* ========== Bloco ========== */
Block:
    ABRE_CHAVE StatementList FECHA_CHAVE
    | ABRE_CHAVE FECHA_CHAVE
    ;

/* ========== Condições ========== */
Condition:
    OBJETO {
        emit("    ; Sensor: objeto\n");
        emit("    mov eax, [S_OBJETO]\n");
        $$ = 0;
    }
    | PESO RelOp Expr {
        emit("    ; Sensor: peso\n");
        emit("    push eax\n");
        emit("    mov eax, [S_PESO]\n");
        emit("    pop ebx\n");
        
        switch($2) {
            case 0: emit("    cmp eax, ebx\n    mov eax, 0\n    sete al\n"); break;
            case 1: emit("    cmp eax, ebx\n    mov eax, 0\n    setne al\n"); break;
            case 2: emit("    cmp eax, ebx\n    mov eax, 0\n    setl al\n"); break;
            case 3: emit("    cmp eax, ebx\n    mov eax, 0\n    setg al\n"); break;
            case 4: emit("    cmp eax, ebx\n    mov eax, 0\n    setle al\n"); break;
            case 5: emit("    cmp eax, ebx\n    mov eax, 0\n    setge al\n"); break;
        }
        $$ = 0;
    }
    | LIMITE {
        emit("    ; Sensor: limite\n");
        emit("    mov eax, [S_LIMITE]\n");
        $$ = 0;
    }
    | IDENTIFICADOR RelOp Expr {
        int offset = get_var_offset($1);
        if (offset == -1) {
            fprintf(stderr, "Erro: variável '%s' não declarada\n", $1);
            exit(1);
        }
        char buffer[100];
        sprintf(buffer, "    ; Comparacao: %s\n", $1);
        emit(buffer);
        emit("    push eax\n");
        sprintf(buffer, "    mov eax, [ebp-%d]\n", offset);
        emit(buffer);
        emit("    pop ebx\n");
        
        switch($2) {
            case 0: emit("    cmp eax, ebx\n    mov eax, 0\n    sete al\n"); break;
            case 1: emit("    cmp eax, ebx\n    mov eax, 0\n    setne al\n"); break;
            case 2: emit("    cmp eax, ebx\n    mov eax, 0\n    setl al\n"); break;
            case 3: emit("    cmp eax, ebx\n    mov eax, 0\n    setg al\n"); break;
            case 4: emit("    cmp eax, ebx\n    mov eax, 0\n    setle al\n"); break;
            case 5: emit("    cmp eax, ebx\n    mov eax, 0\n    setge al\n"); break;
        }
        free($1);
        $$ = 0;
    }
    ;

RelOp:
    IGUAL           { $$ = 0; }
    | DIFERENTE     { $$ = 1; }
    | MENOR         { $$ = 2; }
    | MAIOR         { $$ = 3; }
    | MENOR_IGUAL   { $$ = 4; }
    | MAIOR_IGUAL   { $$ = 5; }
    ;

/* ========== Expressões ========== */
Expr:
    Term
    | Expr MAIS {
        emit("    push eax\n");  // Salva o valor de Expr
    } Term {
        emit("    pop ebx\n");   // Recupera Expr em ebx
        emit("    add eax, ebx\n");  // eax = Term + Expr
    }
    | Expr MENOS {
        emit("    push eax\n");  // Salva o valor de Expr
    } Term {
        emit("    pop ebx\n");   // Recupera Expr em ebx
        emit("    sub ebx, eax\n");  // ebx = Expr - Term
        emit("    mov eax, ebx\n");
    }
    ;

Term:
    Factor
    | Term MULT {
        emit("    push eax\n");  // Salva o valor de Term
    } Factor {
        emit("    pop ebx\n");   // Recupera Term em ebx
        emit("    imul eax, ebx\n");  // eax = Factor * Term
    }
    | Term DIV {
        emit("    push eax\n");  // Salva o valor de Term
    } Factor {
        emit("    mov ebx, eax\n");  // ebx = Factor (divisor)
        emit("    pop eax\n");   // eax = Term (dividendo)
        emit("    xor edx, edx\n");
        emit("    idiv ebx\n");  // eax = Term / Factor
    }
    ;

Factor:
    NUMERO {
        char buffer[50];
        sprintf(buffer, "    mov eax, %d\n", $1);
        emit(buffer);
    }
    | IDENTIFICADOR {
        int offset = get_var_offset($1);
        if (offset == -1) {
            fprintf(stderr, "Erro: variável '%s' não declarada\n", $1);
            exit(1);
        }
        char buffer[50];
        sprintf(buffer, "    mov eax, [ebp-%d]\n", offset);
        emit(buffer);
        free($1);
    }
    | ABRE_PAR Expr FECHA_PAR {
        /* Expressão entre parênteses - valor já está em EAX */
    }
    | MENOS Factor %prec UMINUS {
        emit("    neg eax\n");
    }
    ;

%%

/* ========== Funções Auxiliares ========== */

void add_variable(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            fprintf(stderr, "Erro: variável '%s' já declarada\n", name);
            exit(1);
        }
    }
    strcpy(symbol_table[symbol_count].name, name);
    symbol_table[symbol_count].offset = var_offset;
    var_offset += 4;
    symbol_count++;
}

int get_var_offset(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return symbol_table[i].offset;
        }
    }
    return -1;
}

void emit(const char *code) {
    fprintf(output_file, "%s", code);
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Uso: %s <arquivo_entrada.robot> <arquivo_saida.asm>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Erro ao abrir arquivo de entrada: %s\n", argv[1]);
        return 1;
    }

    output_file = fopen(argv[2], "w");
    if (!output_file) {
        fprintf(stderr, "Erro ao criar arquivo de saída: %s\n", argv[2]);
        return 1;
    }

    // Escreve o template da VM
    FILE *template = fopen("robot_vm.asm", "r");
    if (template) {
        char line[1000];
        while (fgets(line, sizeof(line), template)) {
            if (strstr(line, "BREAK")) {
                break;
            }
            fprintf(output_file, "%s", line);
        }
        
        // Processa o código fonte
        yyparse();
        
        // Continua com o resto do template
        while (fgets(line, sizeof(line), template)) {
            fprintf(output_file, "%s", line);
        }
        fclose(template);
    } else {
        fprintf(stderr, "Erro: arquivo robot_vm.asm não encontrado\n");
        return 1;
    }

    fclose(yyin);
    fclose(output_file);
    
    printf("Compilação concluída com sucesso!\n");
    printf("Arquivo Assembly gerado: %s\n", argv[2]);
    
    return 0;
}
