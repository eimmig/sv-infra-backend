# Session Handoff — infra

> Estado atual, não histórico. O diário cronológico é o `progress.md` — este arquivo é reescrito
> a cada sessão para responder "o que a próxima sessão precisa saber agora".

**Última atualização:** 2026-09-15

## Objetivo atual

`feat-001`..`feat-007` `done`. Nenhuma feature elegível neste harness agora. `epic-028` (raiz)
segue `in-progress` — o lado de `infra/` fechou, falta a feature própria de deploy em cada um dos
6 repositórios de aplicação (agora desbloqueadas pelo `KUBE_CONFIG` existir).

## Concluído nesta sessão (2026-09-15)

- [x] **`feat-007` fechada** (ServiceAccount de CI restrito + `KUBE_CONFIG` nos 6 repos, PR #6
      merged em `develop`). `k8s/ci-deployer-rbac.yaml` + `tools/kube_deploy_setup.py` (raiz)
      autorados e revisados (`Plan Reviewer` corrigiu o mecanismo de token — TokenRequest API,
      não `Secret` estática legada). Aplicação real bloqueada nesta sessão pelo classificador de
      auto-mode do Claude Code (categoria "Production Reads" — recusou até uma checagem SSH de
      leitura, mesmo depois do usuário autorizar explicitamente no chat; é bloqueio de
      configuração, não algo que se contorna pedindo de novo). **Usuário rodou pessoalmente**:
      túnel SSH (`ssh -L 6443:127.0.0.1:6443 eduardo@192.168.2.123`) + kubeconfig copiado do
      servidor (`scp`) + `python tools/kube_deploy_setup.py` desta máquina — `ServiceAccount`/
      `Role`/`RoleBinding` criados no cluster real, token de 1 ano gerado, `KUBE_CONFIG` gravado
      nos 6 repositórios (confirmado via `--check` antes/depois). Sessão fechou os 4 subtasks e a
      feature depois, com a evidência real do usuário.

## Bloqueios / Riscos

- Nenhum.

## Próxima sessão — por onde começar

1. Rodar `./init.sh` (raiz e deste repositório) — deve sair `0`.
2. Nenhuma feature pendente neste harness. `epic-028` (raiz) continua aberto — as 6 features de
   deploy nos repositórios de aplicação (`auth-service feat-016`, `bets-service feat-018`,
   `stats-service feat-019`, `api-gateway feat-014`, `telegram-integration feat-010`, `web
   feat-030`) já podem começar, cada uma no seu próprio repositório/sessão.
3. Se alguma sessão futura precisar tocar o cluster de produção de novo: o padrão que funcionou
   foi túnel SSH local (`ssh -L 6443:127.0.0.1:6443 eduardo@192.168.2.123`) + kubeconfig copiado
   via `scp` pra esta máquina — trocar o `server: https://127.0.0.1:6443` do kubeconfig pelo IP
   direto do servidor NÃO funciona (certificado TLS do k3s só é válido pra `127.0.0.1`/
   `localhost`), o túnel evita esse problema. Acesso de produção via Bash desta sessão (SSH
   direto) é recusado pelo classificador de auto-mode — sempre vai precisar do usuário rodando
   os comandos de rede/túnel pessoalmente, mesmo com autorização explícita no chat.
