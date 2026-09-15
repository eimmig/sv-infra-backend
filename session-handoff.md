# Session Handoff — infra

> Estado atual, não histórico. O diário cronológico é o `progress.md` — este arquivo é reescrito
> a cada sessão para responder "o que a próxima sessão precisa saber agora".

**Última atualização:** 2026-09-15

## Objetivo atual

`feat-001`..`feat-006` `done`. `feat-007` (`epic-028` da raiz, ServiceAccount de CI restrito +
`KUBE_CONFIG` pros 6 repos) `in-progress`, parcial — ver abaixo.

## Concluído nesta sessão (2026-09-15)

- [x] `feat-007.1`/`.2`: `k8s/ci-deployer-rbac.yaml` + `tools/kube_deploy_setup.py` (raiz)
      autorados e revisados (`Plan Reviewer` corrigiu o mecanismo de token — TokenRequest API,
      não `Secret` estática legada). `feature/SV-418` (+ subtasks `SV-419`/`SV-420`) empurrada
      pro GitHub, **não mergeada em `develop`** — feature não funcionalmente completa.
- [ ] `feat-007.3` (aplicar RBAC + gerar token + distribuir `KUBE_CONFIG` nos 6 repos): **não
      feita nesta sessão de propósito** — o classificador de auto-mode do Claude Code bloqueou a
      tentativa de checar conectividade SSH com o servidor real ("Production Reads", nega acesso
      a produção sem autorização explícita nesta sessão). Comportamento esperado pra essa
      categoria de ação, não um bug. Precisa do usuário rodando diretamente, ou de uma sessão que
      ele autorize explicitamente para acesso de produção.

## Bloqueios / Riscos

- **`feat-007.3` bloqueada por design** (autorização de acesso a produção, não falta de
  informação) — ver acima. `k8s/ci-deployer-rbac.yaml` e `tools/kube_deploy_setup.py` já estão
  prontos, só falta rodar.

## Próxima sessão — por onde começar

1. Rodar `./init.sh` (raiz e deste repositório) — deve sair `0`.
2. Se o usuário autorizar acesso de produção nesta sessão (ou rodar diretamente): `ssh
   eduardo@192.168.2.123`, `export KUBECONFIG=~/.kube/config` (não é o padrão do usuário
   `eduardo` nessa máquina), repo `~/infra` em `develop` — `git pull` antes de qualquer coisa
   (buscar os commits desta sessão: `feature/SV-418`, ainda só no GitHub, precisa também chegar
   em `~/infra` local do servidor ou ser aplicado via checkout daquela branch). Depois:
   `python tools/kube_deploy_setup.py --check` (só lê) e, se ok, sem `--check` (aplica RBAC +
   gera token + distribui `KUBE_CONFIG` nos 6 repositórios).
3. Depois de `.3` confirmado (`--check` mostrando os 6 `KUBE_CONFIG` gravados): `.4` (CHANGELOG +
   fechamento), merge `feature/SV-418` → `develop`, `feature_list.json` `feat-007` `done`,
   `epic-028` (raiz) segue `in-progress` até os 6 repositórios de aplicação implementarem o job
   `deploy` próprio (`auth-service feat-016`, `bets-service feat-018`, `stats-service feat-019`,
   `api-gateway feat-014`, `telegram-integration feat-010`, `web feat-030` — todos dependem
   deste).
