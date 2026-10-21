---
name: blindar-vps
description: Blinda uma VPS Ubuntu recém-criada antes de instalar o Hermes: usuário com sudo, SSH só com chave, firewall UFW, fail2ban e senha do root trancada. Use quando o aluno disser "blindar a VPS", "proteger o servidor" ou logo depois de comprar a VPS.
---

# Blindar a VPS (4 passos, mais o teste de fora)

Você roda por SSH, de fora da VPS, com a chave do aluno. A ordem existe para nunca fechar uma porta sem ter certeza de que a outra abre. **Nunca pule o teste entre os passos.**

## As 5 camadas (a cebola da aula)
De fora para dentro: a internet, o firewall, o SSH, o usuário sem root e, no centro, o Hermes. Cada passo abaixo fecha uma camada, e o Hermes só entra depois que todas estão de pé.

## Como falar com o aluno (didático)
Depois de cada passo, diga em **uma frase** o que ele protege, em português simples e sem jargão solto. Se usar uma sigla, diga o significado entre parênteses na primeira vez. Use estas frases como base:
- **Passo 1:** "Criei um usuário comum. O sudo empresta poder de administrador só no comando que precisa, e fica registrado. Assim você não trabalha como root o tempo todo, que é o administrador total e pode apagar tudo."
- **Passo 2:** "Tranquei o SSH, que é a porta de entrada da VPS. Agora não entra com senha, que um robô consegue adivinhar, nem como root, que é um nome que todo mundo conhece. Só entra com a sua chave e com o usuário certo."
- **Passo 3:** "O firewall barra tudo que eu não liberei, e só a porta 22 do SSH ficou liberada. O fail2ban bloqueia quem erra a chave várias vezes."
- **Passo 4:** "Tranquei também a senha do root, para o caso de alguém reabrir o SSH por engano."
- **Teste de fora:** "Testei do seu computador, e não de dentro da VPS, porque só o teste de fora mostra o que está realmente aberto."

## Antes de começar, pergunte ao aluno
- O IP da VPS e o caminho da chave SSH privada.
- O nome do usuário que ele quer (padrão: `admin`).
- Se ele ainda consegue entrar como root. Se não, pare e peça para ele resolver o acesso primeiro.

## Regras
- A chave privada nunca sai do computador do aluno. Não copie, não cole em chat.
- Nunca escreva senha em arquivo de texto. Se aparecer segredo em log de comando, trate como comprometido.
- Se qualquer teste falhar, **pare e mostre a saída**. Não tente o passo seguinte.

## Passo 1: usuário comum com sudo (antes de tocar em qualquer regra de acesso)
```bash
ssh -i <CHAVE> root@<IP> bash -s <<'EOF2'
useradd -m -s /bin/bash <USUARIO>
usermod -aG sudo <USUARIO>
mkdir -p /home/<USUARIO>/.ssh
cp /root/.ssh/authorized_keys /home/<USUARIO>/.ssh/authorized_keys
chown -R <USUARIO>:<USUARIO> /home/<USUARIO>/.ssh
chmod 700 /home/<USUARIO>/.ssh && chmod 600 /home/<USUARIO>/.ssh/authorized_keys
echo "<USUARIO> ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/<USUARIO>
chmod 440 /etc/sudoers.d/<USUARIO> && visudo -cf /etc/sudoers.d/<USUARIO>
EOF2
```
**Teste obrigatório:** `ssh -i <CHAVE> <USUARIO>@<IP> "whoami && sudo whoami"` deve imprimir `<USUARIO>` e `root`. Só siga se imprimir.
(NOPASSWD é aceitável porque o usuário só entra por chave: pedir senha de novo no sudo não soma segurança e atrapalha automação.)

## Passo 2: trancar o SSH (só chave, sem root)
```bash
ssh -i <CHAVE> <USUARIO>@<IP> sudo bash -s <<'EOF2'
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak-hardening
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config
sshd -t && systemctl restart ssh
EOF2
```
**Testes obrigatórios (os dois):**
1. `ssh -i <CHAVE> <USUARIO>@<IP> "echo ACESSO_OK"` deve imprimir `ACESSO_OK`.
2. `ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no root@<IP> exit` deve responder `Permission denied`.
Mantenha uma sessão SSH antiga aberta enquanto testa. Se o teste 1 falhar, restaure o backup `/etc/ssh/sshd_config.bak-hardening` por ela.

## Passo 3: firewall, vigia e atualizações
```bash
ssh -i <CHAVE> <USUARIO>@<IP> sudo bash -s <<'EOF2'
export DEBIAN_FRONTEND=noninteractive
apt-get update -y -qq
apt-get install -y -qq ufw fail2ban unattended-upgrades
ufw allow OpenSSH      # PRIMEIRO libera o SSH, DEPOIS ativa: ao contrário, você se tranca para fora
ufw --force enable
systemctl enable --now fail2ban unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' > /etc/apt/apt.conf.d/51unattended-upgrades-local
EOF2
```
**Teste:** `sudo ufw status` mostra só `22/tcp (OpenSSH)` liberado; `sudo fail2ban-client status` mostra o jail `sshd`.

## Passo 4: trancar a senha do root
`ssh -i <CHAVE> <USUARIO>@<IP> sudo passwd -l root`

## Passo 5: o teste de fora (obrigatório)
O firewall mostra a regra que você escreveu, e isso não prova o que está de fato aberto. Rode **do computador do aluno**, e não da VPS: `nc -vz <IP> 22` deve conectar e `nc -vz <IP> 80`, `nc -vz <IP> 443` e `nc -vz <IP> 5432` devem falhar (ou ficar sem resposta). Liste as portas que responderam. Se alguma além da 22 responder, pare e investigue antes de seguir.
Se a VPS já tem Docker, repita o teste **depois de publicar qualquer porta**: o Docker passa por fora do UFW.

## Verificação final
`sudo systemctl is-active ssh ufw fail2ban unattended-upgrades` deve imprimir `active` quatro vezes. Diga ao aluno que agora o Hermes pode entrar, porque o servidor está blindado (use a skill `instalar-hermes-vps`). Resuma ao aluno em uma tabela: root por SSH bloqueado, senha do root trancada, usuário com sudo só por chave, senha SSH desligada, só a porta 22 aberta, fail2ban ativo.

## Armadilhas conhecidas
- **Docker passa por cima do UFW.** Porta publicada por contêiner fica aberta mesmo com o UFW dizendo "deny". Depois de subir qualquer contêiner, **teste de fora** (do seu computador, não da VPS): `nc -vz <IP> <PORTA>`. Para bloquear, use a cadeia `DOCKER-USER` ou publique a porta só em `127.0.0.1`.
- **Ferramentas que entram por SSH como root** (Coolify e similares) falham com o root trancado, e cada falha conta para o fail2ban, que pode banir o IP do gateway do Docker. Sintoma: ferramenta "não alcançável" com o SSH normal funcionando. Veja com `sudo fail2ban-client status sshd` e libere com `sudo fail2ban-client set sshd unbanip <IP>`.
- **`sudo echo ... | tee arquivo`:** o `sudo` vale só para o `echo`. Use `echo ... | sudo tee arquivo`.
- **Botão "Salvar" da chave SSH travado no painel da Hostinger:** atualize a página (F5). A chave costuma ter salvado mesmo assim, e uma senha root nova pode ser gerada no recarregamento.

Fonte: uma VPS real (Hostinger, Ubuntu 24.04), sessões 1, 2 e 8, executado em 29/09/2026.
