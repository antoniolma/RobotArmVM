// ============================================
// Exemplo 4: Condicionais - IF/ELSE
// Demonstra uso de sensores e decisões
// ============================================

// Move até área de verificação
mover direita 25
mover cima 10

// Verifica se há objeto presente
se objeto: {
    // Se encontrou objeto, pega
    pegar
    esperar 300
    
    // Move para área de destino
    mover esquerda 40
    soltar
}

// Verifica o peso do objeto
se peso > 5: {
    // Objeto pesado - move devagar
    esperar 1000
    mover baixo 5
} senao: {
    // Objeto leve - move rápido
    esperar 200
    mover baixo 15
}

// Verifica limite de movimento
se limite: {
    // Atingiu o limite - retorna
    mover cima 20
    mover esquerda 10
}
