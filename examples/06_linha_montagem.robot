// ============================================
// Exemplo 6: Linha de Montagem Simplificada
// Simula processamento de 3 peças
// ============================================

var pecas = 0

enquanto pecas < 3: {
    // Move para área de coleta
    mover direita 30
    mover cima 20
    esperar 500
    
    // Pega peça
    pegar
    esperar 300
    
    // Move para área de entrega
    mover esquerda 40
    mover baixo 10
    esperar 300
    
    // Solta peça
    soltar
    esperar 300
    
    // Volta à posição inicial
    mover direita 10
    mover baixo 10
    
    // Incrementa contador
    pecas = pecas + 1
}
