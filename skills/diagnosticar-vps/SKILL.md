---
name: diagnosticar-vps
description: Faz o diagnóstico, só de leitura, de uma VPS que o aluno já tem (usuários, SSH, firewall, Docker, portas, serviços) e diz o que está certo, o que dá para ajustar e o que é arriscado mexer. Use ANTES de blindar-vps ou instalar-hermes-vps quando o aluno disser "já tenho uma VPS", "posso usar a que eu tenho?", "vai atrapalhar meus projetos?" ou "meu servidor está seguro?".
---

# Diagnosticar uma VPS que já existe

Uma VPS nova pode ser blindada do zero. Uma VPS que **já roda coisas** (sites, bancos, painéis, Docker) não: cada mudança pode derrubar um serviço. Esta skill **só olha**. Ela não muda nada. No fim, diz ao aluno se dá para seguir com a `blindar-vps` e o que ficar de fora.

## Antes de começar
1. Pergunte o IP, o usuário e confirme que o aluno tem a chave SSH e que **a VPS é dele**. Nunca rode em servidor que não seja do aluno.
2. Diga ao aluno, em uma frase, o que vai acontecer: "Vou só ler a configuração do servidor e testar as portas de fora. Nada será alterado."
3. Nunca peça nem use senha. Nunca imprima chave, token nem variável de ambiente (o script já não imprime).

## Passo 1: ler a VPS
Da máquina do aluno, rode o script de leitura pelo SSH:
```
ssh USUARIO@IP 'bash -s' < diagnosticar-vps.sh
```
O script está nesta pasta. Ele imprime blocos `[sistema]`, `[acesso]`, `[firewall]`, `[portas_escutando]`, `[docker]` e `[servicos_e_rotinas]` em linhas `chave=valor`. Se o usuário não tem sudo sem senha, o script segue em modo reduzido e avisa (`ssh_nota`); diga ao aluno o que não pôde ser verificado.

## Passo 2: testar de fora
Da **máquina do aluno** (não da VPS), rode:
```
bash testar-de-fora.sh IP_DA_VPS 22 80 443 5432 9119
```
Inclua as portas que o passo 1 mostrou escutando em `0.0.0.0` ou `[::]`. **Escutar não é o mesmo que estar exposta**: um firewall do provedor pode barrar a porta antes de ela chegar na VPS. Só o teste de fora mostra o resultado real.

## Passo 3: classificar cada item
Use três estados.
- **Verde**: já está como a `blindar-vps` quer.
- **Amarelo**: dá para ajustar com segurança, seguindo os passos da `blindar-vps` (sessão aberta como saída, teste entre os passos).
- **Vermelho**: mexer pode derrubar algo que já funciona. **Não aplicar sem a decisão do aluno.**

| Item | Verde | Amarelo | Vermelho |
|---|---|---|---|
| Sistema | Ubuntu 24.04 ou outro suportado, RAM ≥ 2 GB, disco ≥ 8 GB | Versão antiga com atualizações | Sem espaço ou RAM para o Hermes |
| Usuário | Existe um usuário comum com sudo, e o dia a dia não é no root | Só existe o root | Serviços de terceiros dependem de entrar como root (ex.: Coolify, backup, deploy) |
| SSH: senha (`passwordauthentication`) | `no` | `yes` e o aluno tem chave que já funciona | `yes` e ninguém tem chave |
| SSH: root (`permitrootlogin`) | `no` | `yes`, ou `prohibit-password` / `without-password` sem nenhuma ferramenta dependendo | `prohibit-password` ou `yes` com ferramenta que entra como root |
| Senha do root | Trancada | Ativa | Em uso por alguma rotina |
| Firewall (UFW) | Ativo, só 22 liberada | Instalado e desligado | Há um firewall do provedor ou regras próprias que o aluno não conhece |
| fail2ban e atualizações automáticas | Ativos | Inativos | (n/a) |
| Docker | Ausente, ou com porta testada de fora | Presente com contêineres sem porta publicada | Presente com porta publicada (o Docker passa por cima do UFW) ou **Swarm ativo** |
| Portas de fora | Só 22 (e 80 e 443 se há site) abertas | Porta de banco ou painel aberta sem uso | Porta de banco ou painel aberta e **em uso** por outros sistemas |
| Hermes | Instalado como usuário comum, em serviço | Instalado como root | Instalado e rodando dentro de projeto em produção |
| Fuso | `America/Sao_Paulo` | `UTC` (ajustar antes de agendar cron) | Cron de outros sistemas depende do UTC |
| Backup | Existe e fica fora da VPS | Existe só na mesma VPS | Não existe e há banco de dados rodando |

Regra de ouro: **na dúvida, vermelho.** O aluno decide.

## Passo 4: o relatório (o que você entrega)
1. Uma tabela com: item, valor encontrado, estado (verde, amarelo ou vermelho), o que fazer.
2. A pergunta central, respondida em uma frase: **"Dá para usar esta VPS?"** com uma das três respostas:
   - **Sim, é só seguir** com `instalar-hermes-vps` e `blindar-vps`: tudo verde ou amarelo.
   - **Sim, com ressalvas**: liste os itens vermelhos que ficam de fora e o risco de cada um.
   - **Não recomendo**: há vermelho que a blindagem não resolve sem derrubar serviço; sugira uma VPS nova só para o Hermes.
3. No máximo **três** ações, em ordem de risco, cada uma com a skill que a executa.
4. Termine pedindo o "pode" do aluno. **Nada é alterado antes disso.**

## Regras
- Somente leitura. Nunca rode `ufw enable`, `systemctl restart`, `passwd`, `chmod`, `docker stop` nem nada que mude o servidor.
- Se uma leitura falhar, diga qual e por quê. Não invente o valor.
- Não compartilhe o relatório fora da conversa: ele mostra a superfície do servidor.
- Aluno com várias VPS: um relatório por VPS.

## Estado de teste (honesto)
O script foi testado em 21/10/2026 numa VPS real (Debian 12, Docker em modo Swarm, Coolify, Supabase, Hermes em serviço), como root, e só de leitura. Funcionou: leu os 6 blocos e a classificação separou "escutando em todas as interfaces" de "aberta de fora" (o firewall do provedor barrava 5432, 8000, 9119 e outras). **Não foi testado** em Ubuntu 24.04 recém-criado, nem com usuário comum sem sudo (modo reduzido), nem em outras distribuições.

Fonte: a conversa do Encontro 1 sobre reaproveitar uma VPS existente. A skill é nossa.
