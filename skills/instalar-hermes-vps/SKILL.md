---
name: instalar-hermes-vps
description: Instala o Hermes Agent numa VPS Ubuntu já blindada, com serviço que volta sozinho, backup diário, fuso certo e vigia no Telegram, usando o instalar-hermes.sh. Use quando o aluno pedir "instalar o Hermes na VPS" ou "rodar o script de instalação". Rode blindar-vps antes.
---

# Instalar o Hermes na VPS

Pré-requisito: a VPS já está blindada (skill `blindar-vps`). O Hermes **não** roda como root: o script cria o usuário `hermes` sem poder de administrador, e essa é a proteção central. Nunca dê root ao Hermes para "ele mesmo se blindar".

## Confira antes de rodar
1. Acesso: entre como o usuário com sudo (não como root).
2. Máquina: mínimo 2 GB de RAM e 8 GB livres (o script confere e para se faltar; abaixo de 4 GB de RAM ele cria 2 GB de swap).
3. O comando oficial de instalação do Hermes, copiado **no dia**, da página do projeto. Última linha que funcionou (29/09/2026):
   `curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive`
   Baixe e leia o instalador antes de confiar. Nunca `curl | bash` às cegas numa máquina de produção.
4. Opcional, para o vigia: o token do bot do Telegram e o ID do chat. Sem os dois, o vigia não é instalado (o resto funciona).

## Rodar
```bash
scp instalar-hermes.sh <USUARIO>@<IP>:/tmp/instalar-hermes.sh
ssh <USUARIO>@<IP> sudo COMANDO_OFICIAL_DE_INSTALACAO='<linha copiada>' \
    TELEGRAM_BOT_TOKEN='<token>' TELEGRAM_CHAT_ID='<id>' bash /tmp/instalar-hermes.sh
```
O script é seguro de rodar de novo: detecta usuário existente e retoma. Se parar, mande ao aluno o log `/var/log/instalar-hermes.log`.

## O que o script já resolve (erros reais de 29/09/2026)
| Sintoma | Causa | Já tratado no script |
|---|---|---|
| `libatomic.so.1: cannot open shared object file` no passo do Node | A imagem mínima do Ubuntu 24.04 da Hostinger não traz a `libatomic1` | Instala `libatomic1` e `libxi6` antes |
| Aviso do `cua-driver` com `libXi.so.6` | Falta a `libxi6` | Instala; não bloqueava o agente |
| Backup "falha" com código 1 e o `.tar.gz` existe | O `tar` avisa quando o arquivo muda durante a leitura; `set -e` tratava como erro | Só código 2 ou maior é falha |
| Backup de 1 GB por dia | Entrava `.hermes/tools`, `.hermes/hermes-agent` e sockets, que se recriam sozinhos | Ficam de fora (resultado real: 1 MB) |
| `Unknown key name 'StartLimitIntervalSec' in section 'Service'` | As duas chaves valem só em `[Unit]`; na `[Service]` são ignoradas e o limite de 5 quedas não existia | Movidas para `[Unit]` |
| Agendamentos e backup 3 horas errados | A VPS nova vem em UTC | Ajusta para `America/Sao_Paulo` (troque com `FUSO=...`) |

## Depois de rodar: verificar
- `systemctl is-active hermes` deve imprimir `active`; `systemctl status hermes` sem o aviso de chave desconhecida.
- `ls -lh /var/backups/hermes` mostra um backup de poucos MB.
- Reinicie a máquina, espere um minuto e confira que o serviço voltou sozinho.
- Conecte o Telegram e o modelo no Hermes (o script não faz isso), e **teste a primeira resposta vinda de fora**: sem ela a VPS não está pronta.
- Se você sobe Docker depois, teste as portas de fora da VPS (o Docker passa por cima do UFW).

## Armadilhas fora do script
- **Docker:** instale pelo instalador oficial (Docker CE, `get.docker.com`), não por `apt install docker.io docker-compose-v2`, que deu conflito de dependências. Nunca rode dois instaladores de infra ao mesmo tempo.
- **Credenciais:** saldo adicionado na OpenRouter não resolve se o erro vem de credencial por perfil. Erro 402 ou 429 não significa configuração errada.
- **Segredos:** tudo que aparecer em log de comando deve ser tratado como comprometido e rotacionado.

Estado de teste: o script foi corrigido em 20/10/2026 com base no teste real de 29/09, mas **a versão corrigida ainda não rodou numa VPS nova**. Diga isso ao aluno se ele perguntar.
