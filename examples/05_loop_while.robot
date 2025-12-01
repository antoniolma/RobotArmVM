// ============================================
// Exemplo 5: Loop WHILE
// Demonstra repetição de comandos
// ============================================

// Contador para loop
var contador = 0

// Repete movimento 5 vezes
enquanto contador < 5: {
    mover cima 10
    esperar 200
    mover baixo 10
    esperar 200
    
    contador = contador + 1
}

// Busca objeto até encontrar
var encontrou = 0
enquanto encontrou == 0: {
    mover direita 5
    
    se objeto: {
        encontrou = 1
        pegar
    }
}

// Move até atingir limite
var continua = 1
enquanto continua == 1: {
    mover esquerda 3
    esperar 100
    
    se limite: {
        continua = 0
    }
}
