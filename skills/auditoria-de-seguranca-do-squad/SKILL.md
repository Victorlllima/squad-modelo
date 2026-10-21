---
name: auditoria-de-seguranca-do-squad
description: Lê a configuração do squad do aluno e devolve os 7 botões de segurança em verde, amarelo e vermelho, com o que corrigir primeiro. Use quando o aluno pedir "audita a segurança do meu squad", "confere as permissões" ou depois de preencher a matriz.
---

# Auditoria de segurança do squad

Você **só lê e relata**. Não altera configuração, não apaga nada, não rotaciona chave. Quem corrige é o aluno (ou você, depois do ok dele, numa conversa separada).

## O que ler
- `AGENTS.md`, `permissoes/matriz.md` e `agents/*/SOUL.md` do repositório.
- A configuração do gateway e do Hermes do aluno, **se ele indicar onde está** (por exemplo `~/.hermes/config.yaml`). Nunca abra nem mostre o valor de um segredo: confira só se o campo existe.
- Para o servidor: `sudo ufw status`, `sudo systemctl is-active ssh ufw fail2ban`, e as portas vistas de fora (`nc -vz IP PORTA`).

## Os 7 botões (cada um recebe verde, amarelo ou vermelho)
| # | Botão | Verde | Vermelho |
|---|---|---|---|
| 1 | Confiança: quem pode falar | Lista de permitidos preenchida | Gateway liberado para todos |
| 2 | Aprovações | Manual ou inteligente | YOLO em máquina com dados |
| 3 | Contenção | Docker ou sandbox, sem segredo encaminhado | Local ou SSH sem aprovação |
| 4 | Filtro de segredos | MCP sem variáveis extras | Segredos liberados para todos os processos |
| 5 | Arquivos de contexto | Arquivos próprios e revisados | Regras copiadas de terceiros sem leitura |
| 6 | Rede | URL privada desligada | URL privada ligada em gateway público |
| 7 | Tirith | Ligado | Desligado sem motivo |

Amarelo é o meio: funciona, mas depende de disciplina do aluno.

## O que entregar
1. Uma tabela com os 7 botões, a cor, a evidência (o arquivo ou comando que você olhou) e a posição do caso (só eu, time pequeno ou público).
2. **Os 3 itens vermelhos ou amarelos mais urgentes**, nessa ordem, cada um com a correção em uma frase.
3. A matriz agente × permissão conferida: linha em branco conta como vermelho, e agente com célula vermelha que o SOUL.md contradiz vira alerta.
4. O que você **não conseguiu verificar** e por quê. Nunca preencha verde por suposição.

## Regras
- Se um segredo aparecer na tela, trate como comprometido e avise o aluno para rotacionar.
- Nunca diga "está seguro". Diga "estes sete botões estão assim, e isto falta verificar".

Fonte: as sete camadas de segurança do Hermes, do material de estudo da Formação. O agrupamento em 7 botões é nosso. Em Claude Code e Codex, a "aprovação inteligente" é o modo automático.
