# squad-qg

O repositório modelo do seu squad de agentes. Aqui moram os agentes (papel, regras, permissões), as skills que eles usam e o fluxo que impede qualquer um deles de mudar o que está no ar sem a sua aprovação.

**Você aprova, o agente executa.** Nenhum agente faz merge sozinho, e nenhum segredo entra no repositório.

## O que tem aqui

| Pasta ou arquivo | Para quê |
|---|---|
| `AGENTS.md` | As regras que todo agente lê antes de mexer em qualquer coisa (Claude Code, Codex e Hermes) |
| `agents/` | Uma pasta por agente, com `AGENT.md` (o papel) e `SOUL.md` (o contrato). Copie `_modelo/` |
| `permissoes/matriz.md` | A matriz agente × permissão, em verde, amarelo e vermelho |
| `skills/` | 11 skills prontas: `definir-pronto`, `diagnosticar-vps`, `otimizar-anatomia-do-agente`, `escolher-vps`, `blindar-vps`, `acesso-privado`, `instalar-hermes-vps`, `lista-de-permitidos-do-gateway`, `auditoria-de-seguranca-do-squad`, `repositorio-modelo`, `fluxo-de-aprovacao-git` |
| `.github/` | Modelo de pull request, dono do código e a verificação automática |
| `docs/estagios.md` | Desenvolvimento, homologação e produção: o que muda em cada um |
| `.env.example` | Os nomes dos segredos, sem os valores |

## Como começar

1. Clique em **Use this template** no GitHub (ou peça ao seu agente: "use a skill repositorio-modelo").
2. Copie `agents/_modelo/` para `agents/<nome-do-agente>/` e preencha o `SOUL.md`.
3. Preencha a linha do agente em `permissoes/matriz.md`.
4. Ative a proteção da branch `main` (a skill `repositorio-modelo` faz isso pelo `gh`).
5. Todo trabalho entra por pull request. Veja `skills/fluxo-de-aprovacao-git/SKILL.md`.
