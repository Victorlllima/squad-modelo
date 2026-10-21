#!/bin/bash
# diagnosticar-vps.sh: SOMENTE LEITURA. Não altera nada, não imprime senha, chave nem variável de ambiente.
# Uso, da sua máquina:   ssh usuario@IP 'bash -s' < diagnosticar-vps.sh
# Saída: linhas "chave=valor", uma seção por assunto. Quem interpreta é o agente (ver SKILL.md).
export LC_ALL=C
S() { echo; echo "[$1]"; }
V() { echo "$1=$2"; }
SUDO=""; if sudo -n true 2>/dev/null; then SUDO="sudo -n"; fi

S sistema
V so "$(. /etc/os-release 2>/dev/null; echo "$PRETTY_NAME")"
V kernel "$(uname -r)"
V uptime "$(uptime -p 2>/dev/null)"
V ram_mb "$(free -m | awk '/Mem:/{print $2}')"
V disco_raiz "$(df -h / | awk 'NR==2{print $2" total, "$5" usado"}')"
V fuso "$(timedatectl show -p Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null)"

S acesso
V usuario_atual "$(whoami)"
V pode_sudo_sem_senha "$([ -n "$SUDO" ] && echo sim || echo nao)"
V usuarios_humanos "$(awk -F: '$3>=1000 && $3<65534 && $7!~/nologin|false/ {printf "%s ", $1}' /etc/passwd)"
V usuarios_no_grupo_sudo "$(getent group sudo | cut -d: -f4)"
V usuarios_no_grupo_docker "$(getent group docker | cut -d: -f4)"
SSHD="$($SUDO sshd -T 2>/dev/null)"
if [ -n "$SSHD" ]; then
  for k in port permitrootlogin passwordauthentication pubkeyauthentication kbdinteractiveauthentication; do V "ssh_$k" "$(echo "$SSHD" | awk -v k="$k" '$1==k{print $2; exit}')"; done
else
  V ssh_nota "sem sudo: valores lidos do arquivo, podem não ser os efetivos"
  for k in Port PermitRootLogin PasswordAuthentication PubkeyAuthentication; do V "ssh_$k" "$(grep -rhiE "^\s*$k\s" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/ 2>/dev/null | tail -1 | awk '{print $2}')"; done
fi
V senha_root_trancada "$($SUDO passwd -S root 2>/dev/null | awk '{print ($2=="L"||$2=="LK")?"sim":"nao ("$2")"}' || echo nao_verificado)"
V chaves_autorizadas_do_usuario_atual "$(grep -cE '^(ssh|ecdsa|sk)-' ~/.ssh/authorized_keys 2>/dev/null || echo 0)"

S firewall
if command -v ufw >/dev/null 2>&1; then V ufw "$($SUDO ufw status 2>/dev/null | head -1)"; else V ufw "nao_instalado"; fi
$SUDO ufw status 2>/dev/null | awk 'NR>4 && NF{print "ufw_regra="$0}' | head -20
V fail2ban "$(systemctl is-active fail2ban 2>/dev/null)"
V atualizacoes_automaticas "$(systemctl is-active unattended-upgrades 2>/dev/null)"
V iptables_docker_user "$($SUDO iptables -S DOCKER-USER 2>/dev/null | wc -l | awk '{print ($1>1)?"tem regras":"vazia ou ausente"}')"

S portas_escutando
ss -tlnH 2>/dev/null | awk '{print $4}' | sort -u | awk '{print "escuta="$0}'

S docker
if command -v docker >/dev/null 2>&1; then
  V docker_versao "$(docker -v 2>/dev/null)"
  V swarm "$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || $SUDO docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null)"
  (docker ps --format 'conteiner={{.Names}} | portas={{.Ports}}' 2>/dev/null || $SUDO docker ps --format 'conteiner={{.Names}} | portas={{.Ports}}' 2>/dev/null) | head -40
else V docker_instalado nao; fi

S servicos_e_rotinas
V servicos_rodando "$(systemctl list-units --type=service --state=running --no-legend 2>/dev/null | wc -l)"
V hermes_comando "$(command -v hermes || echo ausente)"
V hermes_servicos_rodando "$(systemctl list-units --type=service --state=running --no-legend 2>/dev/null | awk '/hermes/{printf "%s ", $1}')"
V hermes_timers "$(systemctl list-units --type=timer --no-legend 2>/dev/null | grep -c hermes)"
V hermes_pasta "$([ -d ~/.hermes ] && echo existe || echo ausente)"
V cron_do_usuario_linhas "$(crontab -l 2>/dev/null | grep -vE '^\s*(#|$)' | wc -l)"
V cron_menciona_backup "$({ crontab -l 2>/dev/null; ls /etc/cron.d 2>/dev/null; } | grep -ci backup)"
V disco_hermes_mb "$(du -sm ~/.hermes 2>/dev/null | cut -f1)"
echo; echo "[fim]"; echo "somente_leitura=sim"
