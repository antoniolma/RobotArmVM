; ============================================
; Robot Arm Virtual Machine - Assembly Template
; ============================================
; Arquitetura:
;   Registradores:
;     - R_X: Posição X do braço (0-100)
;     - R_Y: Posição Y do braço (0-100)
;     - R_GARRA: Estado da garra (0=aberta, 1=fechada)
;     - R_TEMP: Registrador temporário
;   
;   Sensores (Read-only):
;     - S_OBJETO: Detecta objeto (0=não, 1=sim)
;     - S_PESO: Peso do objeto segurado (0-10)
;     - S_LIMITE: Detecta limite de movimento (0=ok, 1=limite)
;
;   Memória:
;     - 256 bytes de stack (pilha)
;     - Variáveis de usuário
; ============================================

section .data
    ; Registradores do braço robótico
    R_X:        dd 50       ; Posição X inicial (centro)
    R_Y:        dd 50       ; Posição Y inicial (centro)
    R_GARRA:    dd 0        ; Garra aberta
    R_TEMP:     dd 0        ; Registrador temporário
    
    ; Sensores (simulados)
    S_OBJETO:   dd 0        ; Sem objeto detectado
    S_PESO:     dd 0        ; Peso zero
    S_LIMITE:   dd 0        ; Sem limite detectado
    
    ; Mensagens do sistema
    msg_pos:    db "[ROBO] Posicao atual -> X=%d, Y=%d", 10, 0
    msg_grab:   db "[ROBO] Garra FECHADA - Objeto segurado! (Peso=%d)", 10, 0
    msg_release: db "[ROBO] Garra ABERTA - Objeto liberado!", 10, 0
    msg_wait:   db "[ROBO] Aguardando %d ms...", 10, 0
    msg_limit:  db "[AVISO] Limite de movimento atingido!", 10, 0
    msg_init:   db "========================================", 10, "[ROBO] Iniciando programa...", 10, "========================================", 10, 0
    msg_end:    db "========================================", 10, "[ROBO] Programa finalizado com sucesso!", 10, "========================================", 10, 0
    
    ; Formato para printf/scanf
    format_out: db "%d", 10, 0
    format_in:  db "%d", 0
    scan_int:   dd 0

section .bss
    ; Área de memória para variáveis do usuário
    user_mem:   resb 1024

section .text
    extern printf
    extern scanf
    global main

main:
    push ebp
    mov ebp, esp
    
    ; Mensagem inicial
    push msg_init
    call printf
    add esp, 4
    
    ; Inicializa registradores
    mov eax, 50
    mov [R_X], eax
    mov [R_Y], eax
    xor eax, eax
    mov [R_GARRA], eax
    
    ; Mostra posição inicial
    call print_position
    
    ; =======================================
    ; CÓDIGO GERADO PELO COMPILADOR COMEÇA AQUI
    ; =======================================
BREAK
    ; =======================================
    ; CÓDIGO GERADO TERMINA AQUI
    ; =======================================
    
    ; Mensagem final
    push msg_end
    call printf
    add esp, 4
    
    ; Finaliza o programa
    mov esp, ebp
    pop ebp
    
    ; Retorna 0 (sucesso)
    xor eax, eax
    ret

; ============================================
; FUNÇÕES AUXILIARES DA VM
; ============================================

; Função: Mover braço
; Parâmetros: direção (0=cima, 1=baixo, 2=esquerda, 3=direita), quantidade
move_arm:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    
    mov eax, [ebp+8]    ; direção
    mov ebx, [ebp+12]   ; quantidade
    
    cmp eax, 0          ; cima
    je move_up
    cmp eax, 1          ; baixo
    je move_down
    cmp eax, 2          ; esquerda
    je move_left
    cmp eax, 3          ; direita
    je move_right
    jmp move_end
    
move_up:
    mov ecx, [R_Y]
    add ecx, ebx
    cmp ecx, 100
    jg set_limit
    mov [R_Y], ecx
    jmp move_end
    
move_down:
    mov ecx, [R_Y]
    sub ecx, ebx
    cmp ecx, 0
    jl set_limit
    mov [R_Y], ecx
    jmp move_end
    
move_left:
    mov ecx, [R_X]
    sub ecx, ebx
    cmp ecx, 0
    jl set_limit
    mov [R_X], ecx
    jmp move_end
    
move_right:
    mov ecx, [R_X]
    add ecx, ebx
    cmp ecx, 100
    jg set_limit
    mov [R_X], ecx
    jmp move_end
    
set_limit:
    mov dword [S_LIMITE], 1
    push msg_limit
    call printf
    add esp, 4
    
move_end:
    ; Simula sensor de objeto baseado na posição
    ; Se X > 70 e Y > 60, detecta objeto (área de coleta)
    mov eax, [R_X]
    cmp eax, 70
    jl no_object_detected
    mov eax, [R_Y]
    cmp eax, 60
    jl no_object_detected
    mov dword [S_OBJETO], 1
    jmp object_check_done
    
no_object_detected:
    mov dword [S_OBJETO], 0
    
object_check_done:
    pop ecx
    pop ebx
    pop ebp
    ret

; Função: Pegar objeto
grab_object:
    push ebp
    mov ebp, esp
    
    ; Simula detecção de objeto (sempre detecta para fins de demonstração)
    ; Em um sistema real, isso seria baseado em sensores físicos
    mov dword [S_OBJETO], 1
    
    ; Fecha a garra
    mov dword [R_GARRA], 1
    
    ; Simula peso do objeto (valor fixo para demonstração)
    mov dword [S_PESO], 5
    
    ; Imprime mensagem com peso
    push dword [S_PESO]
    push msg_grab
    call printf
    add esp, 8
    
    pop ebp
    ret

; Função: Soltar objeto
release_object:
    push ebp
    mov ebp, esp
    
    ; Abre a garra
    mov dword [R_GARRA], 0
    
    ; Remove peso
    mov dword [S_PESO], 0
    
    ; Imprime mensagem
    push msg_release
    call printf
    add esp, 4
    
    pop ebp
    ret

; Função: Esperar (delay simulado)
wait_ms:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]    ; tempo em ms
    push eax
    push msg_wait
    call printf
    add esp, 8
    
    pop ebp
    ret

; Função: Imprimir posição
print_position:
    push ebp
    mov ebp, esp
    
    push dword [R_Y]
    push dword [R_X]
    push msg_pos
    call printf
    add esp, 12
    
    pop ebp
    ret
