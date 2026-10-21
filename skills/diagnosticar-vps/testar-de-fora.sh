#!/bin/bash
# testar-de-fora.sh: SOMENTE LEITURA. Rode na SUA máquina (não na VPS). Tenta abrir cada porta pelo IP público.
# Uso: bash testar-de-fora.sh IP_DA_VPS [porta ...]   (sem portas, testa as mais comuns)
IP="$1"; shift
[ -z "$IP" ] && { echo "uso: bash testar-de-fora.sh IP_DA_VPS [porta ...]"; exit 1; }
PORTAS="${@:-21 22 80 443 3306 5432 5433 6379 6543 8000 8080 8443 9000 9119 27017}"
for p in $PORTAS; do
  if timeout 4 bash -c "echo > /dev/tcp/$IP/$p" 2>/dev/null; then echo "porta $p: ABERTA"; else echo "porta $p: fechada ou filtrada"; fi
done
echo "(somente_leitura=sim)"
