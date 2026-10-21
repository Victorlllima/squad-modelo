---
name: repositorio-modelo
description: Cria no GitHub o repositório do squad de agentes do aluno a partir do modelo squad-qg, com a proteção da branch main, o dono do código e a verificação ligada. Use quando o aluno pedir "criar o repositório do meu squad", "usar o repositório modelo" ou "montar o QG no GitHub".
---

# Repositório modelo do squad

Você prepara o repositório onde os agentes do aluno moram e são revisados. **Quem aprova é o aluno. Você executa e para nos pontos marcados.**

## Antes de começar, pergunte
1. Qual conta do GitHub vai ser dona (`gh auth status` mostra a conta ativa). Se houver mais de uma, confirme qual antes de criar qualquer coisa.
2. O nome do repositório (padrão: `squad-qg`) e se ele é **privado** (padrão e recomendado).
3. Os nomes dos agentes que ele já tem ou quer ter. Pode ser uma lista curta.

**Pare e confirme** conta, nome e visibilidade antes do passo 1. Criar repositório é uma ação que aparece fora do computador do aluno.

## Passos
1. **Criar a partir do modelo.** Com o `gh`:
   `gh repo create <CONTA>/<NOME> --private --template <CONTA-DO-MODELO>/squad-qg --clone`
   Se o modelo ainda não estiver publicado, copie a pasta `squad-qg/` que o aluno recebeu para um diretório novo, rode `git init -b main`, `git add -A`, `git commit -m "Repositório do squad, a partir do modelo"` e `gh repo create <CONTA>/<NOME> --private --source . --push`.
2. **Trocar o dono do código.** Em `.github/CODEOWNERS`, troque `@SEU-USUARIO-NO-GITHUB` pelo usuário do aluno. Commite numa branch, não na `main` (veja `fluxo-de-aprovacao-git`).
3. **Um agente por pasta.** Para cada agente da lista: copie `agents/_modelo/` para `agents/<nome>/`, preencha o `AGENT.md` com o papel em uma frase e o `SOUL.md` com leituras, escrita permitida, approval gate e segredos. **Não invente permissão.** Onde faltar informação, deixe o campo para o aluno e liste no resumo final.
4. **A matriz.** Preencha uma linha por agente em `permissoes/matriz.md` **só com o que o aluno confirmar**. Célula sem confirmação fica em branco (conta como vermelho).
5. **Rodar a verificação.** `bash scripts/verificar.sh` deve imprimir `OK`. Se falhar, corrija antes de seguir.
6. **Proteger a `main`** (peça ok antes: muda configuração do repositório):
   `gh api -X PUT repos/<CONTA>/<NOME>/branches/main/protection --input -` com um corpo que exija pull request com 1 aprovação, a verificação `verificar` passando e `enforce_admins` desligado para o dono poder aprovar o próprio squad. Se o plano gratuito de repositório privado não permitir a proteção, **diga isso ao aluno** e deixe o repositório público ou documente que a regra depende de disciplina. Não finja que ficou protegido.
7. **Confirmar de fora.** `gh repo view <CONTA>/<NOME> --json visibility,defaultBranchRef` e uma tentativa de push direto na `main` com um commit de teste numa cópia (deve ser recusado). Mostre o resultado.

## Nunca faça
- Nunca crie o repositório na conta errada. Em dúvida, pare e pergunte.
- Nunca commite `.env`, chave, token ou senha. O `.gitignore` e o `verificar.sh` existem para isso, mas a atenção é sua.
- Nunca faça merge do pull request que você mesmo abriu.

## Entregue ao aluno
Uma tabela curta: URL do repositório, visibilidade, quem é o dono do código, agentes criados, o que ficou em branco para ele preencher, e se a proteção da `main` ficou ativa de verdade.

Estado de teste: o `verificar.sh` foi exercitado localmente (passa no modelo e falha com token ou `.env` versionado). Os comandos do `gh` ainda não rodaram contra o repositório de um aluno.
