#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# O SERVIDOR PRONTO · instalador do Hermes fora da sua máquina
# Material da Hermes Week · RedPro AI Academy
#
# O que ele faz, nesta ordem:
#   1. confere que a máquina aguenta e que você é quem pode instalar
#   2. cria um usuário só para o agente, sem poder de administrador
#   3. instala o Hermes
#   4. registra o agente como serviço, para ele VOLTAR SOZINHO depois de
#      qualquer reinício ou queda
#   5. configura a cópia de segurança diária, com rotação
#   6. instala o vigia que te avisa no Telegram quando o agente cai
#
# Uso:  sudo bash instalar-hermes.sh
# ─────────────────────────────────────────────────────────────────────────────
set -Eeuo pipefail

AGENTE_USER="${AGENTE_USER:-hermes}"
AGENTE_HOME="/home/${AGENTE_USER}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/hermes}"
BACKUP_MANTER_DIAS="${BACKUP_MANTER_DIAS:-14}"
LOG="/var/log/instalar-hermes.log"
FUSO="${FUSO:-America/Sao_Paulo}"

azul()  { printf '\033[1;34m%s\033[0m\n' "$*"; }
verde() { printf '\033[1;32m%s\033[0m\n' "$*"; }
ruim()  { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
passo() { azul ""; azul "── $* ─────────────────────────────"; }

trap 'ruim ""; ruim "Parou no passo acima. O log inteiro está em ${LOG}"; ruim "Manda esse arquivo no grupo que a gente resolve."; exit 1' ERR

exec > >(tee -a "$LOG") 2>&1
azul "Instalador do Hermes · $(date '+%d/%m/%Y %H:%M')"

# ── 1. conferências antes de mexer em qualquer coisa ────────────────────────
passo "1/6 · conferindo a máquina"

[ "$(id -u)" -eq 0 ] || { ruim "Roda com sudo: sudo bash instalar-hermes.sh"; exit 1; }
command -v systemctl >/dev/null || { ruim "Esta máquina não usa systemd. Este instalador não serve para ela."; exit 1; }

RAM_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
DISCO_GB=$(df -BG --output=avail / | tail -1 | tr -dc '0-9')
echo "RAM: ${RAM_MB} MB · disco livre: ${DISCO_GB} GB"

[ "$RAM_MB" -ge 1800 ] || { ruim "Menos de 2 GB de RAM. O agente vai morrer sozinho. Sobe a máquina antes."; exit 1; }
[ "$DISCO_GB" -ge 8 ] || { ruim "Menos de 8 GB livres. Libera espaço antes: o agente guarda sessão e memória."; exit 1; }

if [ "$RAM_MB" -lt 3500 ] && [ ! -f /swapfile ]; then
  echo "Menos de 4 GB de RAM e sem swap. Criando 2 GB de swap, senão ele morre no primeiro pico."
  fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile >/dev/null && swapon /swapfile
  grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Fuso horário. Numa VPS nova o relógio vem em UTC, 3 horas adiantado em relação a Brasília:
# o backup das 04h20 e qualquer tarefa agendada rodariam no horário errado.
timedatectl set-timezone "$FUSO" 2>/dev/null || echo "Não consegui ajustar o fuso para ${FUSO}. Ajuste depois com: timedatectl set-timezone <fuso>"
echo "Fuso: $(timedatectl show -p Timezone --value 2>/dev/null || date +%Z)"

# Bibliotecas que a imagem mínima do Ubuntu 24.04 (Hostinger) não traz e que o instalador do Hermes
# exige. Sem a libatomic1 o Node empacotado nem abre ("libatomic.so.1: cannot open shared object file")
# e a instalação para no passo 3. A libxi6 só serve ao cua-driver (controle de mouse e teclado):
# não bloqueia o agente, mas evita o aviso.
if command -v apt-get >/dev/null; then
  apt-get update -qq
  apt-get install -y -qq libatomic1 libxi6 || apt-get install -y -qq libatomic1 \
    || { ruim "Não consegui instalar a libatomic1. Sem ela o Node do Hermes não roda."; exit 1; }
fi

verde "Máquina ok."

# ── 2. um usuário só para o agente ──────────────────────────────────────────
passo "2/6 · criando o usuário do agente"
# Por que: o agente roda com as próprias mãos. Se ele rodar como root, um pedido
# mal escrito pode apagar a máquina inteira. Aqui ele não tem esse poder.

if id "$AGENTE_USER" >/dev/null 2>&1; then
  echo "O usuário ${AGENTE_USER} já existe, seguindo."
else
  useradd --create-home --shell /bin/bash "$AGENTE_USER"
  verde "Usuário ${AGENTE_USER} criado, sem poder de administrador."
fi
loginctl enable-linger "$AGENTE_USER"   # deixa o serviço dele subir sem login

# ── 3. instalar o Hermes ────────────────────────────────────────────────────
passo "3/6 · instalando o Hermes"

if ! command -v curl >/dev/null; then
  (apt-get update -qq && apt-get install -y -qq curl) || (dnf install -y curl) || (yum install -y curl)
fi

# 🔴 TROQUE ESTA LINHA pelo comando oficial da página de instalação do Hermes,
#    copiado no dia em que você for usar. O endereço muda, e um instalador que
#    aponta para um endereço velho é pior do que instalador nenhum.
COMANDO_OFICIAL_DE_INSTALACAO="${COMANDO_OFICIAL_DE_INSTALACAO:-}"

if [ -z "$COMANDO_OFICIAL_DE_INSTALACAO" ]; then
  ruim "Falta definir o comando oficial de instalação."
  ruim "Abre a página do Hermes, copia a linha de instalação de hoje e roda assim:"
  ruim '  sudo COMANDO_OFICIAL_DE_INSTALACAO="<a linha que você copiou>" bash instalar-hermes.sh'
  exit 1
fi

sudo -u "$AGENTE_USER" -H bash -lc "$COMANDO_OFICIAL_DE_INSTALACAO"

HERMES_BIN="$(sudo -u "$AGENTE_USER" -H bash -lc 'command -v hermes || true')"
[ -n "$HERMES_BIN" ] || { ruim "Instalou mas o comando hermes não apareceu no PATH do usuário."; exit 1; }
verde "Hermes instalado em ${HERMES_BIN}"

# ── 4. o serviço, que é o ponto inteiro deste instalador ────────────────────
passo "4/6 · registrando o serviço, para ele voltar sozinho"

cat > /etc/systemd/system/hermes.service <<SERVICO
[Unit]
Description=Hermes Agent
After=network-online.target
Wants=network-online.target
# Se ele cair 5 vezes em 5 minutos, para de tentar: é problema de configuração, e ficar
# reiniciando em laço só esquenta a máquina e enche o disco de log. Estas duas linhas só
# valem na seção [Unit]; na [Service] o systemd as ignora e avisa "Unknown key name".
StartLimitIntervalSec=300
StartLimitBurst=5

[Service]
Type=simple
User=${AGENTE_USER}
WorkingDirectory=${AGENTE_HOME}
Environment=HOME=${AGENTE_HOME}
ExecStart=${HERMES_BIN} gateway

# Volta sozinho de qualquer queda, sempre, com 10 segundos de respiro.
Restart=always
RestartSec=10
# (o limite de 5 quedas em 5 minutos fica na seção [Unit], lá em cima)

# Cercas: ele não escreve fora da casa dele.
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=${AGENTE_HOME}

StandardOutput=append:/var/log/hermes.log
StandardError=append:/var/log/hermes.log

[Install]
WantedBy=multi-user.target
SERVICO

touch /var/log/hermes.log && chown "$AGENTE_USER" /var/log/hermes.log
systemctl daemon-reload
systemctl enable --now hermes.service

sleep 5
if systemctl is-active --quiet hermes.service; then
  verde "Serviço no ar. Ele volta sozinho depois de qualquer reinício."
else
  ruim "O serviço não subiu. Olha o motivo:"
  journalctl -u hermes.service -n 30 --no-pager || true
  exit 1
fi

# ── 5. cópia de segurança, feita antes de você precisar dela ────────────────
passo "5/6 · configurando a cópia de segurança diária"

mkdir -p "$BACKUP_DIR"
cat > /usr/local/bin/backup-hermes.sh <<BACKUP
#!/usr/bin/env bash
set -Eeuo pipefail
DEST="${BACKUP_DIR}/hermes-\$(date +%Y%m%d-%H%M).tar.gz"
# Só o que importa: configuração, alma, memória e sessões. O que o Hermes baixa de novo sozinho
# (ferramentas, checkout do código, instalações) e os caches ficam de fora: sem isso o backup
# diário passa de 1 GB e, em 14 dias, são 14 GB de gordura.
# O tar sai com código 1 quando um arquivo muda enquanto ele lê (o Hermes está rodando, escrevendo
# em sockets e sessões). Isso é aviso, o arquivo sai inteiro. Só código 2 ou maior é falha de verdade.
set +e
tar -czf "\$DEST" \\
  --exclude='.hermes/tools' --exclude='.hermes/hermes-agent' --exclude='.hermes/installs' \\
  --exclude='*/cache' --exclude='*/audio_cache' --exclude='*/image_cache' --exclude='*.sock' \\
  -C "${AGENTE_HOME}" .hermes
CODIGO=\$?
set -e
if [ "\$CODIGO" -ge 2 ]; then
  echo "\$(date '+%d/%m %H:%M') backup FALHOU (tar saiu com \$CODIGO)" >&2
  rm -f "\$DEST"
  exit "\$CODIGO"
fi
find "${BACKUP_DIR}" -name 'hermes-*.tar.gz' -mtime +${BACKUP_MANTER_DIAS} -delete
echo "\$(date '+%d/%m %H:%M') backup ok: \$DEST (\$(du -h "\$DEST" | cut -f1))"
BACKUP
chmod +x /usr/local/bin/backup-hermes.sh

cat > /etc/systemd/system/backup-hermes.service <<'SVC'
[Unit]
Description=Backup do Hermes
[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-hermes.sh
SVC

cat > /etc/systemd/system/backup-hermes.timer <<'TMR'
[Unit]
Description=Backup do Hermes, todo dia de madrugada
[Timer]
OnCalendar=*-*-* 04:20:00
Persistent=true
[Install]
WantedBy=timers.target
TMR

systemctl daemon-reload && systemctl enable --now backup-hermes.timer
/usr/local/bin/backup-hermes.sh   # roda uma vez agora, para você ver que funciona
verde "Backup diário às 04h20, guardando ${BACKUP_MANTER_DIAS} dias."

# ── 6. o vigia ──────────────────────────────────────────────────────────────
passo "6/6 · instalando o vigia que te avisa quando ele cai"

if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
  cat > /usr/local/bin/vigia-hermes.sh <<VIGIA
#!/usr/bin/env bash
# Só avisa na TRANSIÇÃO. Sem isso ele te manda a mesma mensagem de minuto em minuto.
MARCA=/var/run/hermes-caiu
if systemctl is-active --quiet hermes.service; then
  if [ -f "\$MARCA" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \\
      -d chat_id="${TELEGRAM_CHAT_ID}" -d text="✅ O agente voltou. \$(date '+%d/%m %H:%M')" >/dev/null
    rm -f "\$MARCA"
  fi
else
  if [ ! -f "\$MARCA" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \\
      -d chat_id="${TELEGRAM_CHAT_ID}" -d text="🔴 O agente caiu e não voltou. \$(date '+%d/%m %H:%M')" >/dev/null
    touch "\$MARCA"
  fi
fi
VIGIA
  chmod +x /usr/local/bin/vigia-hermes.sh

  cat > /etc/systemd/system/vigia-hermes.service <<'SVC'
[Unit]
Description=Vigia do Hermes
[Service]
Type=oneshot
ExecStart=/usr/local/bin/vigia-hermes.sh
SVC
  cat > /etc/systemd/system/vigia-hermes.timer <<'TMR'
[Unit]
Description=Vigia do Hermes, de 2 em 2 minutos
[Timer]
OnBootSec=3min
OnUnitActiveSec=2min
[Install]
WantedBy=timers.target
TMR
  systemctl daemon-reload && systemctl enable --now vigia-hermes.timer
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" -d text="🟢 Servidor do Hermes instalado e no ar." >/dev/null
  verde "Vigia ligado. Você recebe aviso no Telegram quando ele cair e quando voltar."
else
  echo "Sem TELEGRAM_BOT_TOKEN e TELEGRAM_CHAT_ID, o vigia não foi instalado."
  echo "Para ligar depois, roda de novo com as duas variáveis preenchidas."
fi

# ── fim ─────────────────────────────────────────────────────────────────────
azul ""
verde "═══════════════════════════════════════════════"
verde " Pronto. O seu agente está fora da sua máquina."
verde "═══════════════════════════════════════════════"
cat <<FIM_RESUMO

O que ficou montado:

  o agente        systemctl status hermes
  os registros    tail -f /var/log/hermes.log
  os backups      ls -lh ${BACKUP_DIR}
  restaurar       tar -xzf <backup> -C ${AGENTE_HOME}

Ele volta sozinho depois de qualquer reinício. Pode testar: reinicia a máquina
e espera um minuto.

FALTA UMA COISA, e é a única que o instalador não faz por você:
conectar o seu Telegram e o seu modelo, que é o que você fez na Aula 1 e na
Aula 2. Abre o Hermes Desktop na sua máquina, conecta neste servidor, e refaz
aqueles dois passos aqui.

FIM_RESUMO
