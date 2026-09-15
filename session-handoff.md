# Session Handoff — infra

> Estado atual, não histórico. O diário cronológico é o `progress.md` — este arquivo é reescrito
> a cada sessão para responder "o que a próxima sessão precisa saber agora".

**Última atualização:** 2026-09-15

## Objetivo atual

- **Todas as 6 features deste harness estão `done`** (`feat-001..006`). Nenhum trabalho pendente
  neste harness até surgir uma nova feature.

## Concluído nesta sessão (2026-09-15)

- [x] `feat-006` (env vars `BETS_SERVICE_URL`/`STATS_SERVICE_URL` em `auth-service.yaml`, cross-
      repo com `auth-service feat-015`) fechada — manifest já tinha as env vars commitadas
      (`b97dc3e`), esta sessão fez a verificação real que faltava: SSH no servidor Debian
      (`eduardo@192.168.2.123`), `git pull --ff-only` em `~/infra` pra sincronizar o manifest,
      `kubectl apply` + `rollout restart deployment auth-service`, confirmado via `kubectl exec`
      que o pod novo tem as 2 env vars, e 1 chamada admin real
      (`POST /api/v1/admin/tenants` via `kubectl port-forward svc/auth-service`) confirmando
      `downstreamProvisioningFailures: []`. Mesma evidência fecha `auth-service feat-015`
      (estava em Review, faltava só essa prova de produção).

## Bloqueios / Riscos

- Nenhum.

## Próxima sessão — por onde começar

1. Rodar `./init.sh` (raiz e deste repositório) — deve sair `0`.
2. Nenhuma feature pendente neste harness. Acesso ao servidor real: `ssh eduardo@192.168.2.123`,
   `KUBECONFIG=~/.kube/config` (não é o padrão do usuário `eduardo` nessa máquina — precisa do
   export explícito), repo `~/infra` em `develop` — sempre `git pull` antes de aplicar manifest,
   servidor pode estar atrás do que já foi commitado localmente.
