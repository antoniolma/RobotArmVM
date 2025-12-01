// ============================================
// Exemplo 2: Pegar e Soltar Objeto
// Demonstra uso da garra do braço robótico
// ============================================

// Move até o objeto
mover direita 30
mover cima 15

// Espera estabilizar
esperar 300

// Pega o objeto
pegar

// Espera segurar firmemente
esperar 200

// Move o objeto para outra posição
mover esquerda 50
mover baixo 20

// Solta o objeto
soltar

// Retorna à posição inicial
mover direita 20
mover cima 5
