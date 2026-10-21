---
name: fluxo-de-aprovacao-git
description: Conduz qualquer mudança no repositório do squad pelo fluxo branch, commit, pull request, revisão e merge, parando para o aluno aprovar. Use sempre que for alterar arquivos do repositório, ou quando o aluno disser "faz essa mudança", "abre o pull request" ou "sobe isso".
---

# Fluxo de aprovação: você executa, o aluno aprova

Git, aqui, é um fluxo de aprovação de um time. O aluno não precisa decorar comando. Ele precisa saber em qual etapa você parou e se aquilo pode ir pro ar.

## As 5 etapas

| Etapa | O que é | Quem faz |
|---|---|---|
| **Branch** | Uma cópia de trabalho, para você mexer sem tocar no que está no ar | Você |
| **Commit** | Um ponto salvo, com nome que diz o que mudou | Você |
| **Pull request** | O pedido de aprovação, com resumo e o que foi testado | Você abre, o aluno lê |
| **Revisão** | O aluno confere o resumo e o que mudou | **O aluno** |
| **Merge** | A mudança entra no que está no ar | **Só depois do ok do aluno** |

## Passo a passo
1. **Antes de mexer:** confira `git status` (deve estar limpo) e leia `AGENTS.md` e a sua linha em `permissoes/matriz.md`.
2. **Branch:** `git switch -c agente/<seu-nome>/<assunto-curto>` a partir da `main` atualizada.
3. **Commits pequenos.** Um assunto por commit, mensagem no formato "o que mudou, e por quê". Nada de "ajustes".
4. **Antes do pull request:** rode `bash scripts/verificar.sh`. Se falhar, corrija. Não abra o pull request com a verificação vermelha.
5. **Abra o pull request** com o modelo de `.github/pull_request_template.md`, preenchido de verdade, incluindo **o que NÃO foi testado**:
   `gh pr create --base main --title "<resumo>" --body-file <arquivo-preenchido>`
6. **PARE.** Mostre o endereço do pull request ao aluno, resuma em três linhas e espere. Não peça merge, não faça merge, não sugira "posso mesclar?" como se fosse formalidade.
7. **Depois do ok:** o aluno faz o merge (ou autoriza você, por escrito, naquele pull request específico). Só então apague a branch de trabalho.

## Regras
- **Nunca merge sozinho. Nunca push direto na `main`.**
- Se a mudança toca uma célula amarela da matriz, peça aprovação **antes** de executar, não só no pull request.
- Se a mudança toca uma célula vermelha, não execute. Explique o que seria preciso e pare.
- Se o teste que você rodou não prova o que você diz, escreva isso no pull request. "Testado" só quando foi.
- Se a branch ficou desatualizada, atualize (`git fetch` e rebase ou merge da `main` na sua branch) e mostre ao aluno o que mudou antes de continuar.

## Do código ao ar (checklist de 4 linhas antes de pedir o merge)
1. A verificação automática passou no pull request.
2. O que mudou foi testado em homologação, não só no seu computador (veja `docs/estagios.md`).
3. Nenhum segredo, `.env` ou chave no diff.
4. O resumo diz o que foi e o que não foi testado.

Estado de teste: o fluxo foi escrito a partir da regra do projeto (agente propõe, dono aprova) e ainda não rodou contra o repositório de um aluno.
