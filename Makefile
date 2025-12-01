# ============================================
# Makefile - Robot Arm Language Compiler
# Author: Antonio Lucas Michelon de Almeida
# ============================================

# Compiladores
LEX = flex
YACC = bison
CC = gcc
ASM = nasm
LD = ld

# Flags
CFLAGS = -Wall -g -Wno-unused-function
YFLAGS = -d -v
LFLAGS = 
ASMFLAGS = -f elf32
LDFLAGS = -m elf_i386

# Arquivos
LEX_SRC = robot_arm.l
YACC_SRC = robot_arm.y
LEX_OUT = lex.yy.c
YACC_OUT = robot_arm.tab.c
YACC_HDR = robot_arm.tab.h
COMPILER = robot_arm_compiler

# Exemplos
EXAMPLES = $(wildcard examples/*.robot)

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# ============================================
# Regras Principais
# ============================================

.PHONY: all clean test help install

all: $(COMPILER)
	@echo "$(GREEN)✓ Compilador construído com sucesso!$(NC)"
	@echo "$(BLUE)Execute 'make test' para testar os exemplos$(NC)"

# Compila o compilador
$(COMPILER): $(YACC_SRC) $(LEX_SRC)
	@echo "$(YELLOW)➜ Gerando analisador sintático (Bison)...$(NC)"
	$(YACC) $(YFLAGS) $(YACC_SRC)
	@echo "$(YELLOW)➜ Gerando analisador léxico (Flex)...$(NC)"
	$(LEX) $(LFLAGS) $(LEX_SRC)
	@echo "$(YELLOW)➜ Compilando compilador...$(NC)"
	$(CC) $(CFLAGS) -o $(COMPILER) $(YACC_OUT) $(LEX_OUT) -ll
	@echo ""

# Testa todos os exemplos
test: $(COMPILER)
	@echo "$(BLUE)========================================$(NC)"
	@echo "$(BLUE)  Testando Exemplos$(NC)"
	@echo "$(BLUE)========================================$(NC)"
	@for example in $(EXAMPLES); do \
		echo "$(YELLOW)➜ Compilando: $$example$(NC)"; \
		./$(COMPILER) $$example $${example%.robot}.asm; \
		if [ $$? -eq 0 ]; then \
			echo "$(GREEN)  ✓ Sucesso!$(NC)"; \
		else \
			echo "$(RED)  ✗ Falhou!$(NC)"; \
		fi; \
		echo ""; \
	done
	@echo "$(GREEN)========================================$(NC)"
	@echo "$(GREEN)  Testes Concluídos!$(NC)"
	@echo "$(GREEN)========================================$(NC)"

# Compila um arquivo específico
compile: $(COMPILER)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Erro: especifique o arquivo com FILE=<arquivo.robot>$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)➜ Compilando $(FILE)...$(NC)"
	./$(COMPILER) $(FILE) $(FILE:.robot=.asm)
	@echo "$(GREEN)✓ Assembly gerado: $(FILE:.robot=.asm)$(NC)"

# Compila e monta (gera executável) - EXPERIMENTAL
build: compile
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Erro: especifique o arquivo com FILE=<arquivo.robot>$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)➜ Montando $(FILE:.robot=.asm)...$(NC)"
	$(ASM) $(ASMFLAGS) $(FILE:.robot=.asm) -o $(FILE:.robot=.o)
	@echo "$(YELLOW)➜ Linkando...$(NC)"
	$(LD) $(LDFLAGS) $(FILE:.robot=.o) -o $(FILE:.robot=) -lc --dynamic-linker /lib/ld-linux.so.2
	@echo "$(GREEN)✓ Executável gerado: $(FILE:.robot=)$(NC)"

# Limpa arquivos gerados
clean:
	@echo "$(YELLOW)➜ Limpando arquivos gerados...$(NC)"
	rm -f $(COMPILER) $(LEX_OUT) $(YACC_OUT) $(YACC_HDR) robot_arm.output
	rm -f examples/*.asm examples/*.o examples/*.out
	rm -f *.o *.out
	@echo "$(GREEN)✓ Limpeza concluída!$(NC)"

# Instala dependências (Ubuntu/Debian)
install:
	@echo "$(YELLOW)➜ Instalando dependências...$(NC)"
	sudo apt-get update
	sudo apt-get install -y flex bison gcc nasm build-essential
	@echo "$(GREEN)✓ Dependências instaladas!$(NC)"

# Mostra ajuda
help:
	@echo "$(BLUE)========================================$(NC)"
	@echo "$(BLUE)  Robot Arm Language - Makefile$(NC)"
	@echo "$(BLUE)========================================$(NC)"
	@echo ""
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@echo "  $(YELLOW)make$(NC)              - Compila o compilador"
	@echo "  $(YELLOW)make test$(NC)         - Testa todos os exemplos"
	@echo "  $(YELLOW)make compile$(NC)      - Compila arquivo específico"
	@echo "                      Uso: make compile FILE=exemplo.robot"
	@echo "  $(YELLOW)make build$(NC)        - Compila e gera executável (experimental)"
	@echo "                      Uso: make build FILE=exemplo.robot"
	@echo "  $(YELLOW)make clean$(NC)        - Remove arquivos gerados"
	@echo "  $(YELLOW)make install$(NC)      - Instala dependências (Ubuntu/Debian)"
	@echo "  $(YELLOW)make help$(NC)         - Mostra esta ajuda"
	@echo ""
	@echo "$(GREEN)Exemplos:$(NC)"
	@echo "  make"
	@echo "  make test"
	@echo "  make compile FILE=examples/01_movimento_basico.robot"
	@echo "  make clean"
	@echo ""

# Regra padrão para arquivos .robot
%.asm: %.robot $(COMPILER)
	./$(COMPILER) $< $@
