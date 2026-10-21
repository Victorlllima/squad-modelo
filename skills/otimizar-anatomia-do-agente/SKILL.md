---
name: otimizar-anatomia-do-agente
description: Audita um agente etapa por etapa (entender, planejar, recuperar, raciocinar, agir, observar, loop, verificar, responder) e devolve uma lista curta de ajustes. Use quando o aluno disser "meu agente erra e não sei onde", "revisa o meu agente", "otimiza o meu agente" ou colar o SOUL.md, o AGENTS.md ou as regras de um agente para você olhar.
---

# Otimizar a anatomia do agente

Todo agente passa pelas mesmas nove etapas, e cada uma pode falhar sozinha. Esta skill percorre as etapas na ordem, confere o que o aluno já tem escrito e devolve **só o que falta ou está frouxo**, com o texto pronto para colar.

## Entrada
Os arquivos do agente que o aluno indicar: `SOUL.md` ou `AGENT.md`, `AGENTS.md` (ou `CLAUDE.md`), a lista de ferramentas e permissões e, se existir, um pedido típico que o agente recebe. Se faltar algum, siga com o que tem e diga o que não pôde conferir.

## O que fazer
Para cada etapa abaixo, leia os arquivos, responda "sim", "parcial" ou "não" à pergunta e, se não for "sim", escreva a correção. **Não reescreva o que já está bom.**

| # | Etapa | Pergunta | Sinal de que está frouxo | Correção que você propõe |
|---|---|---|---|---|
| 1 | **Entender** | O agente pergunta antes de agir quando o pedido é ambíguo? | Nenhuma regra de "perguntar primeiro"; pedidos genéricos viram palpite | Regra: "Se o pedido tiver mais de uma leitura, faça até 3 perguntas curtas antes de agir" |
| 1 | **Entender** | As restrições estão em **permissão**, e não só em texto? | "Nunca faça X" só no prompt; nada na plataforma que barre | Mover a restrição crítica para a permissão da ferramenta (leitura x escrita) e deixar o texto como reforço |
| 2 | **Planejar** | Ele escreve um mini plano antes de agir? | Vai direto para a ferramenta | Regra: "Antes de agir, liste os passos e a ferramenta de cada um" |
| 2 | **Planejar** | Tem só as ferramentas de que precisa? | Muitas skills e MCPs carregados "por via das dúvidas" | Cortar para o mínimo; o que sobrar vai para outro agente do squad |
| 2 | **Planejar** | O pedido traz a definição de pronto? | O agente "acha" que terminou | Usar a skill `definir-pronto` em cada pedido recorrente |
| 3 | **Recuperar** | Onde moram memória, base externa e estado? | Tudo na conversa; nada sobrevive à sessão | Memória em arquivo (`AGENTS.md`, `CLAUDE.md`), documentos em base consultável, estado em arquivo (etapa atual, resultados parciais) |
| 3 | **Recuperar** | A busca devolve o trecho, e não a base inteira? | Ele carrega documentos completos | Pedir só o trecho relevante e limitar o tamanho do retorno |
| 4 | **Raciocinar** | Cada ferramenta tem nome e uso claros? | O agente "parece preguiçoso" ou escolhe a ferramenta errada | Descrever cada ferramenta em uma linha: para que serve e quando usar |
| 4 | **Raciocinar** | O teste "preciso responder?" compara com algo verificável? | "Um bom resumo" | Trocar por critério que dá para contar ou conferir |
| 5 | **Agir** | Cada tipo de ação tem seu cuidado? | Todas as ações com a mesma permissão | Busca: retorno enxuto. API: leitura separada de escrita. Código: ambiente isolado e aprovação. Banco: credencial só da tabela necessária. MCP: segredos filtrados |
| 5 | **Agir** | Conta é feita por código? | O agente soma "de cabeça" | Regra: "Todo cálculo é feito por script, nunca de cabeça" |
| 6 | **Observar** | Ele lê o erro e muda de rota? | Repete a mesma chamada falhando | Regra de saída: "Se a chamada falhar duas vezes, pare e me avise com a mensagem do erro" |
| 6 | **Observar** | Novas informações podem mudar o plano? | Segue o plano mesmo com dado novo | Regra: "Se um dado novo contradiz o plano, revise o plano antes de continuar" |
| 7 | **Loop** | Há limite de voltas e de contexto? | O loop pode crescer sem fim | Limite de voltas e instrução de compactar ou limpar o contexto ao mudar de assunto |
| 8 | **Verificar** | Existe avaliação contra a definição de pronto? | Ninguém confere a saída | Checklist, teste ou outro agente revisor (de preferência outra LLM) |
| 8 | **Verificar** | Há proteção antes de efeito externo? | O agente publica, paga ou apaga sozinho | Aprovação humana para o que sai do ambiente e bloqueio de ações destrutivas |
| 8 | **Verificar** | A autonomia cresce com o histórico? | Autonomia máxima desde o primeiro dia | Começar aprovando tudo; soltar aos poucos depois de 3 ou 4 acertos seguidos; voltar à aprovação quando um erro custar caro |
| 9 | **Responder** | A entrega deixa rastro? | Só a mensagem no chat | Além da resposta, gravar um artefato em disco (arquivo, CSV, relatório) |
| 9 | **Responder** | A resposta aciona o próximo agente quando deve? | O agente termina e ninguém sabe | Disparar o workflow seguinte (por exemplo, criar um cartão no quadro para o agente certo) |

## Formato da resposta
1. Uma linha por etapa com o resultado ("sim", "parcial" ou "não").
2. Só para o que não for "sim": o **trecho pronto para colar**, dizendo em qual arquivo vai.
3. No fim, as **três** correções que mais reduzem o risco, em ordem.

## Regras
- Mostre o que você mudaria **antes** de alterar qualquer arquivo. Só edite depois do "pode" do aluno.
- Não aumente o poder do agente: se uma correção abre permissão, diga isso em voz alta.
- Se o agente nunca recebeu um pedido real, peça um e rode a auditoria em cima dele.
- Nada de segredo na conversa: se aparecer chave ou token nos arquivos, avise e peça para trocar por variável de ambiente.

Fonte: as nove etapas do Encontro 1 da Formação Arquiteto de Agentes (anatomia de um agente). A skill é nossa.
