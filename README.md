# Robot Arm VM

**Autor:** Antonio Lucas Michelon de Almeida 


## Descrição do Projeto

O projeto tem como objetivo a criação de uma **linguagem de alto nível** para controle de **braços mecânicos**, podendo ser aplicada tanto em contextos industriais como em projetos pessoais.

A proposta da linguagem é ser **simples** e **direta**, com uma estrutura **clara**, **receptiva**, **intuitiva** e **facilmente compreensível**.


## EBNF da linguagem

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

Block           = { Statement } ;

Condition       = "objeto" 
                | "peso" RelOp Expr
                | "limite"
                | Identifier RelOp Expr ;

Expr            = Term { ("+" | "-") Term } ;
Term            = Factor { ("*" | "/") Factor } ;
Factor          = Number | Identifier | "(" Expr ")" ;

Direction       = "cima" | "baixo" | "esquerda" | "direita" ;
RelOp           = "==" | "!=" | "<" | ">" | "<=" | ">=" ;

Identifier      = Letter { Letter | Digit | "_" } ;
Number          = Digit { Digit } ;
Letter          = "a" | "b" | "c" | ... | "z" | "A" | "B" | ... | "Z" ;
Digit           = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
```