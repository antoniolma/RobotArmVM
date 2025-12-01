// ============================================
// Exemplo 8: Operações Aritméticas Avançadas
// Testa todas as operações matemáticas
// ============================================

// Operações básicas
var a = 10
var b = 5

// Adição
var soma = a + b
mover cima soma

// Subtração
var diferenca = a - b
mover direita diferenca

// Multiplicação
var produto = a * b
mover baixo produto

// Divisão
var quociente = a / b
mover esquerda quociente

// Expressões complexas
var resultado = (a + b) * 2
var outro = a * 2 + b * 3
var complexo = (a + b) * (a - b)

mover cima resultado
esperar 100
mover direita outro
esperar 100
mover baixo complexo
