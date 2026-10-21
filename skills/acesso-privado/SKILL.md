---
name: acesso-privado
description: Deixa o aluno ver o painel (dashboard) do Hermes na VPS sem abrir porta para a internet, por túnel SSH ou por Tailscale. Use quando o aluno disser "quero ver o painel do Hermes", "abrir o dashboard da VPS", "acesso privado" ou "Tailscale".
---

# Acesso privado ao painel do Hermes

O painel do Hermes escuta só em `127.0.0.1`, o endereço da própria VPS. Isso é de propósito: ele carrega corpo de tarefa, comentários e caminhos de arquivo e não tem proteção forte para ficar na internet. **Regra: nunca abra a porta do painel.** Nunca rode o painel com `--host 0.0.0.0`.

## Como falar com o aluno (didático)
Explique em uma frase: "O painel só é visto de dentro da VPS. Para ver do seu computador, a gente cria um caminho privado que só você usa, sem abrir porta para a internet." Se usar uma sigla, diga o significado entre parênteses na primeira vez (SSH é Secure Shell, o acesso remoto seguro; VPN é rede privada virtual).

## Antes de começar
1. Confirme que o painel está de pé e só local: na VPS, `ss -tlnp | grep 9119` deve mostrar `127.0.0.1:9119` e **não** `0.0.0.0:9119`. Se aparecer `0.0.0.0`, pare e corrija antes de seguir.
2. Pergunte: quantas pessoas precisam ver o painel, e se alguma delas não usa terminal.
   - **Uma pessoa técnica, de vez em quando:** túnel SSH.
   - **Um time, ou gente que não usa terminal, ou vários painéis:** Tailscale.
   Em dúvida, comece pelo túnel SSH (não instala nada na VPS).

## Caminho A: túnel SSH (testado em 29/09/2026)
1. Se o painel não estiver rodando, suba-o como o usuário do Hermes (nunca como root): `hermes dashboard --no-open --skip-build` (porta 9119, `127.0.0.1`). Confira o nome exato do comando na versão instalada com `hermes --help` e **não invente flags**.
2. No **computador do aluno**, abra o túnel: `ssh -i <CHAVE> -N -L 9119:127.0.0.1:9119 <USUARIO>@<IP>`. O `-N` mantém o túnel aberto sem abrir terminal.
3. Teste: `curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9119` deve imprimir `200`. Depois peça ao aluno para abrir `http://localhost:9119` no navegador.
4. Explique que **fechar o terminal do túnel fecha o acesso**. Nada ficou aberto na VPS.
5. Teste de fora: `nc -vz <IP> 9119` do computador do aluno deve **falhar**. Se conectar, a porta está exposta: pare e corrija.

## Caminho B: Tailscale (NÃO testado por nós)
O Tailscale cria uma rede privada entre os dispositivos do aluno: cada um ganha um IP privado (começa com `100.`) e só enxerga os outros dispositivos da rede.
1. **Siga a documentação oficial do Tailscale para Ubuntu** (a instalação e o login mudam). Não improvise comandos nem copie de memória. Se não conseguir abrir a página, diga ao aluno e pare.
2. Instale o Tailscale na VPS e em cada dispositivo que vai participar. O login é feito pelo aluno, por link, com a conta dele. Você nunca digita a senha da conta dele.
3. Confira que cada dispositivo aparece na rede e tem IP `100.x.y.z`.
4. O painel continua escutando só em `127.0.0.1`. Para expô-lo **somente na rede do Tailscale**, use o recurso do próprio Tailscale previsto na documentação (por exemplo, o serviço de proxy interno) em vez de mudar o painel para `0.0.0.0`. Se a documentação da versão instalada não permitir, volte para o Caminho A e avise o aluno.
5. Teste de fora: `nc -vz <IP-PÚBLICO> 9119` deve falhar, e o acesso pelo IP do Tailscale deve funcionar.
6. Diga ao aluno que o Tailscale é uma peça nova na infraestrutura: se a conta dele sair do ar, o acesso privado também sai.

## Nunca faça
- Nunca libere a porta do painel no firewall nem publique a porta por Docker para a internet.
- Nunca peça nem grave o token do Tailscale, a senha ou a chave SSH do aluno em arquivo.
- Nunca diga "está seguro". Diga o que você testou: porta 9119 fechada para fora, painel respondendo por dentro do caminho privado.

## Entregue
Uma tabela: caminho escolhido, endereço de acesso, resultado do teste de dentro (`200`), resultado do teste de fora (porta fechada) e o que ficou sem testar.

Estado de teste: o Caminho A foi testado em 29/09/2026 numa VPS real (resposta `HTTP 200`). O Caminho B segue a recomendação do manual, mas a instalação do Tailscale na VPS não foi testada por nós.
