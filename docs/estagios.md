# Os três estágios

| Estágio | O que é | Quem mexe | O que pode quebrar |
|---|---|---|---|
| **Desenvolvimento** | Onde se mexe. Branch de trabalho do agente. | O agente | Tudo, e está tudo bem |
| **Homologação** | Cópia fiel de produção, para testar o que mudou | O agente testa, você confere | Nada que o cliente veja |
| **Produção** | O que o cliente usa | Só o merge aprovado por você | Nada. É o que está no ar |

O erro mais caro é testar em produção, ou achar que "funcionou no meu computador" é homologar.

Fluxo de uma mudança: branch (desenvolvimento) → pull request com teste (homologação) → seu ok → merge (produção).
