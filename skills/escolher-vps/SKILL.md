---
name: escolher-vps
description: Ajuda o aluno a escolher o plano de VPS (Hostinger KVM) sem pagar mais do que precisa, com base no que o agente vai rodar. Use quando o aluno disser "qual VPS eu compro", "qual plano", "KVM 1 ou KVM 2" ou "quanto vai custar o servidor".
---

# Escolher a VPS

Você recomenda **um** plano, com o motivo em uma linha e o custo dos 12 primeiros meses. **Confira os preços na página oficial no dia**, porque eles mudam. Não compre nada: quem clica em comprar é o aluno.

## Pergunte (só o que falta)
1. Quantos agentes vão rodar ao mesmo tempo no servidor?
2. Vai rodar Docker (banco de dados, painel, Coolify) na mesma máquina?
3. O Hermes vai usar modelo por API (leve) ou modelo local (pesado)?
4. É só testar ou é produção, com gente dependendo?

## Referência (conferida em 20/10/2026, página `https://www.hostinger.com/br/servidor-vps`)
| Plano | vCPU | RAM | Disco | 1º mês | Renovação |
|---|---|---|---|---|---|
| KVM 1 | 1 | 4 GB | 50 GB | R$ 52,99 | R$ 87,99 por mês |
| KVM 2 | 2 | 8 GB | 100 GB | R$ 70,99 | R$ 108,99 por mês |
| KVM 4 | 4 | 16 GB | 200 GB | R$ 129,99 | R$ 196,99 por mês |

O piso do instalador do Hermes é 2 GB de RAM e 8 GB de disco livres. Abaixo de 4 GB de RAM ele cria swap.

## Como decidir
- Um agente, sem Docker, só API: **KVM 1** basta para começar.
- Vários agentes, ou Docker junto (Coolify, banco): **KVM 2** é o ponto seguro.
- Modelo local ou muitos serviços: **KVM 4**, e vale conferir se a máquina local do aluno não serve melhor.
- Em dúvida entre dois: o menor, e subir depois. A VPS cresce, e o aluno só paga o que usa.

## Avise sempre
- O preço do primeiro mês é promocional. Mostre o valor da renovação ao lado.
- No checkout, confira período, renovação automática e extras marcados por padrão (backup pago, scanner). Desmarque o que o aluno não pediu.
- Escolher a região mais perto do uso reduz a latência.

## Entregue
Uma tabela de uma linha: plano recomendado, motivo, custo do primeiro mês e da renovação, e o link da página oficial.

Estado: preços lidos da página em 20/10/2026. O campo de script pós-instalação do painel da Hostinger não foi testado.
