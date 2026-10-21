#!/usr/bin/env bash
# Verificação mínima do repositório. Roda local e no GitHub Actions.
set -u
erros=0
falha() { echo "FALHOU: $*" >&2; erros=$((erros+1)); }

# 1. nenhum segredo versionado
if git ls-files | grep -E '(^|/)\.env$|\.pem$|\.key$|(^|/)id_(rsa|ed25519)' >/dev/null; then
  falha "arquivo de segredo versionado (.env, .pem, .key ou chave SSH)"
fi
# 2. padrões comuns de token no diff do repositório
if git grep -nE '(sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{30,}|[0-9]{8,10}:[A-Za-z0-9_-]{35})' -- . ':!scripts/verificar.sh' >/dev/null 2>&1; then
  falha "parece haver um token dentro de algum arquivo"
fi
# 3. todo agente (menos o modelo) tem AGENT.md e SOUL.md com as seções obrigatórias
for d in agents/*/; do
  nome=$(basename "$d"); [ "$nome" = "_modelo" ] && continue
  [ -f "$d/AGENT.md" ] || falha "$nome sem AGENT.md"
  if [ -f "$d/SOUL.md" ]; then
    for sec in "Escrita permitida" "Approval gate" "Segredos"; do
      grep -q "$sec" "$d/SOUL.md" || falha "$nome: SOUL.md sem a seção '$sec'"
    done
  else falha "$nome sem SOUL.md"; fi
done
# 4. a matriz existe
[ -f permissoes/matriz.md ] || falha "permissoes/matriz.md não existe"

[ "$erros" -eq 0 ] && echo "OK: repositório conferido." || { echo "$erros problema(s)." >&2; exit 1; }
