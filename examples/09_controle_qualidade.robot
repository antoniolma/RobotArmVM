// ============================================
// Exemplo 9: Controle de Qualidade
// Sistema de verificação e classificação de peças
// ============================================

// Move para área de inspeção
mover direita 20
mover cima 15

// Verifica se há peça
se objeto: {
    // Pega a peça
    pegar
    esperar 300
    
    // Verifica o peso e classifica
    se peso < 3: {
        // Peça muito leve - rejeita
        mover baixo 30
        mover esquerda 10
        soltar
        
    } senao: {
        se peso > 7: {
            // Peça muito pesada - rejeita
            mover baixo 30
            mover direita 10
            soltar
            
        } senao: {
            // Peça OK - aceita
            mover cima 20
            mover esquerda 30
            soltar
        }
    }
}

// Retorna à posição inicial
mover direita 0
mover cima 0
