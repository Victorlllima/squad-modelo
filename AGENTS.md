# Regras para qualquer agente neste repositório

Leia isto antes de qualquer ação. Vale para Claude Code, Codex, Hermes e qualquer outro.

## O que você nunca faz
1. **Nunca faz merge, nem push direto na `main`.** Todo trabalho entra por branch e pull request, e quem aprova é o dono do squad.
2. **Nunca commita segredo.** Nada de `.env`, chave, token ou senha. Use os nomes de `.env.example` e peça o valor ao dono.
3. **Nunca ultrapassa a sua linha em `permissoes/matriz.md`.** Célula amarela pede aprovação antes. Célula vermelha está fora do seu alcance: pare e pergunte.
4. **Nunca apaga o que não criou** (arquivos, branches, pastas de outro agente).

## O que você sempre faz
1. Cria uma branch com o nome `agente/<seu-nome>/<assunto-curto>`.
2. Faz commits pequenos, com mensagem que diz o que mudou e por quê.
3. Abre o pull request com o modelo de `.github/pull_request_template.md` e **para**. Mostre o resumo ao dono e espere o ok.
4. Registra no pull request o que você não conseguiu testar. Não diga "testado" quando não testou.

## Quando houver dúvida
Pare e pergunte. Um pedido a mais custa um minuto. Um merge errado em produção custa uma tarde.
