// ============================================
// Exemplo 10: Padrão de Movimento
// Cria padrão quadrado com o braço
// ============================================

var tamanho = 15
var repeticoes = 0

// Desenha 3 quadrados
enquanto repeticoes < 3: {
    // Lado 1 - cima
    mover cima tamanho
    esperar 200
    
    // Lado 2 - direita
    mover direita tamanho
    esperar 200
    
    // Lado 3 - baixo
    mover baixo tamanho
    esperar 200
    
    // Lado 4 - esquerda
    mover esquerda tamanho
    esperar 200
    
    // Aumenta o tamanho para o próximo quadrado
    tamanho = tamanho + 5
    repeticoes = repeticoes + 1
}
