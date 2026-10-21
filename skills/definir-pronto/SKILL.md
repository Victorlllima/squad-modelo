---
name: definir-pronto
description: Reescreve o pedido do aluno com um critério de conclusão verificável (o que precisa existir para o agente parar). Use quando o aluno colar um pedido para um agente, ou disser "melhora esse pedido", "define o pronto" ou "o agente nunca sabe quando terminou".
---

# Definir o pronto

Um agente trabalha em loop e só para quando acha que terminou. Sem uma definição de pronto, ele para cedo demais, ou nunca para. Você transforma o pedido do aluno em um pedido com **critério de conclusão que dá para conferir**.

## Entrada
O pedido do aluno, do jeito que ele escreveu.

## O que fazer
1. Leia o pedido e responda a si mesmo: o que precisa existir, ao final, para o aluno dizer "está pronto"? Se não der para responder, pergunte **uma** coisa ao aluno (a mais importante) e siga.
2. Reescreva o pedido mantendo a intenção e as palavras do aluno onde der. Acrescente, no fim, um bloco **"Está pronto quando"** com 2 a 5 itens que:
   - são verificáveis por alguém de fora (um arquivo existe, um teste passa, uma mensagem chegou no Telegram, um número bate);
   - dizem **onde** olhar (qual arquivo, qual canal, qual comando);
   - incluem pelo menos um item que prova o resultado, e não só que o agente rodou.
3. Acrescente um bloco **"Não faça"** só se o pedido tiver risco real (apagar, enviar para fora, gastar). Uma linha por risco.
4. Mostre o pedido reescrito e **uma linha** dizendo o que mudou. Não explique teoria.

## Exemplo
Pedido: "Me manda toda segunda de manhã o resumo das vendas da semana."
Reescrito: o mesmo pedido, mais:
- Está pronto quando: (1) chegou uma mensagem no meu Telegram até as 7h30 da segunda; (2) ela traz faturamento bruto e líquido da semana, com a comparação com a anterior; (3) o total bate com o painel da Hotmart do mesmo período.
- Não faça: enviar para qualquer outro chat.

## Regras
- Não invente critério que o aluno não pode conferir.
- Não aumente o escopo do pedido. Só feche a porta do "quando termina".
- Se o aluno pedir algo sem resultado verificável (por exemplo, "pense sobre isso"), diga isso e proponha o resultado mais próximo que dá para conferir.

Fonte da ideia: o critério de conclusão (definition of done) que o Nick Saraev descreve no vídeo de agentes de 2026. A skill é nossa.
