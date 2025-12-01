# Robot Arm VM

**Autor:** Antonio Lucas Michelon de Almeida  
**Disciplina:** Lógica da Computação - 2025.2  
**Instituto:** Insper

---

##  Exemplo Rápido

```robot
// Seu primeiro programa em Robot Arm!
mover cima 20
mover direita 30
pegar
esperar 1000
soltar
```

**Apenas 5 linhas** para controlar um braço robótico! 

---

##  Descrição do Projeto

O projeto consiste em um **compilador completo** para controle de braços mecânicos, desenvolvido com **Flex** (análise léxica) e **Bison** (análise sintática). 

A linguagem possui sintaxe simples em português e compila para **Assembly x86**, incluindo uma **Máquina Virtual própria** que simula registradores, memória e sensores de um braço robótico real.

**Componentes:**
- **Analisador Léxico (Flex)**: Tokenização do código fonte
- **Analisador Sintático (Bison)**: Parsing e validação da gramática
- **Gerador de Código**: Produção de Assembly x86
- **VM Assembly**: Simulação de hardware com registradores (posição X/Y, garra) e sensores (objeto, peso, limite)

---

##  Características da Linguagem

### Estruturas de Controle
-  **Variáveis**: Declaração e atribuição com suporte a expressões aritméticas
-  **Condicionais**: `se` / `senao` para tomada de decisões
-  **Loops**: `enquanto` para repetição de comandos

### Comandos Específicos do Robô
-  **mover**: Move o braço em 4 direções (cima, baixo, esquerda, direita)
-  **pegar**: Fecha a garra para segurar objetos
-  **soltar**: Abre a garra para liberar objetos
- ⏱ **esperar**: Delay para sincronização de movimentos

### Sensores Inteligentes
-  **objeto**: Detecta presença de objetos
-  **peso**: Mede o peso do objeto segurado (0-10)
-  **limite**: Detecta limites de movimento (segurança)

### Operadores Suportados
- **Aritméticos**: `+`, `-`, `*`, `/`
- **Relacionais**: `==`, `!=`, `<`, `>`, `<=`, `>=`

---

##  Como Rodar

### 1. Instalar Dependências (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install flex bison gcc gcc-multilib nasm make
```

### 2. Compilar o Compilador

```bash
make
```

### 3. Testar os Exemplos

```bash
make test
```

### 4. Executar um Programa

```bash
./robotarm examples/07_hello_robot.robot
```

Isso vai:
-  Compilar o código .robot para Assembly
-  Montar o Assembly para código objeto
-  Linkar e criar o executável
-  Executar e mostrar o feedback visual!

**Saída esperada:**
```
[1/4] Compilando para Assembly...
[2/4] Montando código Assembly...
[3/4] Linkando executável...
[4/4] Executando programa...


========================================
[ROBO] Iniciando programa...
========================================
[ROBO] Posicao atual -> X=50, Y=50
[ROBO] Posicao atual -> X=50, Y=70
[ROBO] Posicao atual -> X=80, Y=70
[ROBO] Garra FECHADA - Objeto segurado! (Peso=5)
[ROBO] Aguardando 1000 ms...
[ROBO] Garra ABERTA - Objeto liberado!
========================================
[ROBO] Programa finalizado com sucesso!
========================================


 Programa executado com sucesso!
```

### 5. Ver Todos os Exemplos Disponíveis

```bash
./robotarm
```

### 6. Modo Manual (Passo a Passo)

Se preferir fazer manualmente:

```bash
# Compile o programa .robot para Assembly
./robot_arm_compiler examples/07_hello_robot.robot examples/07_hello_robot.asm

# Monte o Assembly para código objeto
nasm -f elf32 examples/07_hello_robot.asm -o examples/07_hello_robot.o

# Linke e crie o executável
gcc -m32 -no-pie examples/07_hello_robot.o -o examples/07_hello_robot.out

# Execute
./examples/07_hello_robot.out
```

 **Cada comando do robô imprime mensagens mostrando o que está acontecendo!**

---

##  EBNF da Linguagem

```ebnf
Program         = { Statement } ;

Statement       = VarDecl | AssignStmt 
                  | MoveStmt | GrabStmt | ReleaseStmt | WaitStmt
                  | IfStmt | WhileStmt | Block ;

VarDecl         = "var" Identifier "=" Expr ;
AssignStmt      = Identifier "=" Expr ;

MoveStmt        = "mover" Direction Expr ;
GrabStmt        = "pegar" ;
ReleaseStmt     = "soltar" ;
WaitStmt        = "esperar" Expr ;

IfStmt          = "se" Condition ":" Block [ "senao:" Block ] ;
WhileStmt       = "enquanto" Condition ":" Block ;

Block           = "{" { Statement } "}" ;

Condition       = "objeto" 
                | "peso" RelOp Expr
                | "limite"
                | Identifier RelOp Expr ;

Expr            = Term { ("+" | "-") Term } ;
Term            = Factor { ("*" | "/") Factor } ;
Factor          = Number | Identifier | "(" Expr ")" | "-" Factor ;

Direction       = "cima" | "baixo" | "esquerda" | "direita" ;
RelOp           = "==" | "!=" | "<" | ">" | "<=" | ">=" ;

Identifier      = Letter { Letter | Digit | "_" } ;
Number          = Digit { Digit } ;
Letter          = "a" | "b" | "c" | ... | "z" | "A" | "B" | ... | "Z" ;
Digit           = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
```

---

##  Arquivos do Projeto

- **`robot_arm.l`** - Analisador Léxico (Flex)
- **`robot_arm.y`** - Analisador Sintático (Bison)
- **`robot_vm.asm`** - Template da Máquina Virtual
- **`Makefile`** - Automação de build e testes
- **`robotarm`** - Script wrapper para execução rápida (compile + monte + execute)
- **`examples/`** - 10 programas de exemplo

### Exemplos Incluídos

1. **01_movimento_basico.robot** - Movimentos básicos em todas as direções
2. **02_pegar_soltar.robot** - Operações de pegar e soltar objetos
3. **03_variaveis.robot** - Declaração e uso de variáveis
4. **04_condicionais.robot** - Estruturas condicionais (if/else)
5. **05_loop_while.robot** - Loops while com diferentes condições
6. **06_linha_montagem.robot** - Simulação de linha de montagem com loop
7. **07_hello_robot.robot** - Programa simples de demonstração
8. **08_operacoes_avancadas.robot** - Operações aritméticas (+, -, *, /)
9. **09_controle_qualidade.robot** - Condicionais aninhados
10. **10_padrao_movimento.robot** - Padrões geométricos de movimento

---

**Desenvolvido como APS da disciplina de Lógica da Computação - Insper 2025.2**
