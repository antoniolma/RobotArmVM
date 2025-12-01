%{
/* ============================================
 * Robot Arm Language - Lexical Analyzer (Flex)
 * Author: Antonio Lucas Michelon de Almeida
 * ============================================ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "robot_arm.tab.h"

int line_num = 1;

void yyerror(const char *s);
%}

%option noyywrap

%%

    /* ========== Comentários ========== */
"//".*                  { /* Ignora comentários de linha */ }

    /* ========== Palavras-chave ========== */
"var"                   { return VAR; }
"mover"                 { return MOVER; }
"pegar"                 { return PEGAR; }
"soltar"                { return SOLTAR; }
"esperar"               { return ESPERAR; }
"se"                    { return SE; }
"senao"                 { return SENAO; }
"enquanto"              { return ENQUANTO; }

    /* ========== Direções ========== */
"cima"                  { return CIMA; }
"baixo"                 { return BAIXO; }
"esquerda"              { return ESQUERDA; }
"direita"               { return DIREITA; }

    /* ========== Sensores ========== */
"objeto"                { return OBJETO; }
"peso"                  { return PESO; }
"limite"                { return LIMITE; }

    /* ========== Operadores Relacionais ========== */
"=="                    { return IGUAL; }
"!="                    { return DIFERENTE; }
"<="                    { return MENOR_IGUAL; }
">="                    { return MAIOR_IGUAL; }
"<"                     { return MENOR; }
">"                     { return MAIOR; }

    /* ========== Operadores Aritméticos ========== */
"+"                     { return MAIS; }
"-"                     { return MENOS; }
"*"                     { return MULT; }
"/"                     { return DIV; }

    /* ========== Delimitadores ========== */
"="                     { return ATRIB; }
":"                     { return DOIS_PONTOS; }
"("                     { return ABRE_PAR; }
")"                     { return FECHA_PAR; }
"{"                     { return ABRE_CHAVE; }
"}"                     { return FECHA_CHAVE; }

    /* ========== Números ========== */
[0-9]+                  { 
                            yylval.num = atoi(yytext); 
                            return NUMERO; 
                        }

    /* ========== Identificadores ========== */
[a-zA-Z_][a-zA-Z0-9_]*  { 
                            yylval.id = strdup(yytext); 
                            return IDENTIFICADOR; 
                        }

    /* ========== Espaços e quebras de linha ========== */
[ \t]+                  { /* Ignora espaços e tabs */ }
\n                      { line_num++; }

    /* ========== Caracteres inválidos ========== */
.                       { 
                            fprintf(stderr, "Erro léxico: caractere inválido '%s' na linha %d\n", 
                                    yytext, line_num);
                            exit(1);
                        }

%%
