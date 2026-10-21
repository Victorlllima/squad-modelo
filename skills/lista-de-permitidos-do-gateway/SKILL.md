---
name: lista-de-permitidos-do-gateway
description: Configura a camada 1 de segurança do gateway do Hermes: quem pode falar com o agente (lista de permitidos por plataforma), em dois minutos. Use quando o aluno disser "só eu posso falar com o bot", "liberar meu ID no Telegram" ou "proteger o gateway".
---

# Lista de permitidos do gateway

A camada 1 é a mais esquecida. O gateway segue uma cadeia de verificações e o **padrão final é negar**: sem nada configurado, ninguém entra. O risco real é liberar todos da plataforma sem querer.

## Pergunte
1. Em quais plataformas o agente conversa (Telegram, WhatsApp, Discord)?
2. Quem deve poder falar com ele? Só o aluno, ou um time pequeno (peça cada ID)?

## Como achar o ID no Telegram
O aluno manda uma mensagem para o bot `@userinfobot` (ou outro bot de ID de confiança dele) e copia o número. Nunca peça o token do bot nem a senha de nada.

## O que fazer
1. Localize onde o Hermes guarda a lista de permitidos da plataforma **na versão instalada**: confira a documentação do comando de configuração (`hermes --help`, `hermes config`). **Não invente o nome do campo.** Se não achar, diga isso e peça ao aluno para abrir a página oficial.
2. Coloque só os IDs confirmados. Não use "permitir todos da plataforma".
3. Reinicie o serviço (`sudo systemctl restart hermes`) e **teste dos dois lados**: o aluno manda uma mensagem (deve responder) e, se possível, uma segunda conta não listada manda outra (não deve responder).
4. Mostre ao aluno a lista final e o resultado dos dois testes.

## Regras
- Nunca escreva o token do bot em arquivo versionado. Use o `.env`, que está no `.gitignore`.
- Se o aluno pedir para liberar "todo mundo", explique o risco e peça confirmação por escrito.

Estado: a regra vem da Masterclass 10 do Tonbi (camada 1). O nome exato do campo na versão instalada ainda precisa ser conferido em máquina real.
