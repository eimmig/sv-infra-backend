# Changelog

Todas as mudanças notáveis deste repositório são documentadas neste arquivo. Formato baseado em
[Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Toda feature que altera este
repositório adiciona uma entrada em `[Unreleased]` — verificado automaticamente pela pipeline de
CI (ver `docs/CI-CD.md`).

## [Unreleased]

- `k8s/hpa.yaml`: HorizontalPodAutoscaler (CPU 70%, 1 a 4 réplicas) para `api-gateway`, `auth-service`, `bets-service` e `stats-service`; `replicas` removido dos 4 Deployments (`feat-011`)
- `docker-compose.yml` e manifests `k8s/` sobem PostgreSQL 18 (`postgres:18-alpine`, volume em `/var/lib/postgresql`) e Redis 8 (`redis:8-alpine`) (`feat-010`)
- Remover todos os comentários restantes do código, testes e configuração (convenção de zero comentário, `docs/convencoes.md`)
- [SV-664](https://stakevault.atlassian.net/browse/SV-664) - Corrigir 80 apontamentos reais do SonarCloud nos manifests k8s/scripts + fechar a lacuna de nunca terem sido gateados
- [SV-665](https://stakevault.atlassian.net/browse/SV-665) - resources (CPU/memory/ephemeral-storage requests+limits) em todos os containers
- [SV-666](https://stakevault.atlassian.net/browse/SV-666) - automountServiceAccountToken:false em todos os pod specs
- [SV-667](https://stakevault.atlassian.net/browse/SV-667) - Corrigir shell (shelldre:S7688) + resolver tag :latest como accept (decisao do epic-028)
- [SV-668](https://stakevault.atlassian.net/browse/SV-668) - Onboarding real do infra no gate SonarCloud (fecha a causa raiz) + fechamento
- [SV-715](https://stakevault.atlassian.net/browse/SV-715) - Subir PostgreSQL 17->18 e Redis 7->8 (compose + k8s)
- [SV-716](https://stakevault.atlassian.net/browse/SV-716) - docker-compose: postgres:18-alpine e redis:8-alpine
- [SV-717](https://stakevault.atlassian.net/browse/SV-717) - k8s: postgres.yaml (x3) e redis.yaml
- [SV-718](https://stakevault.atlassian.net/browse/SV-718) - CHANGELOG e verificacao final
- [SV-719](https://stakevault.atlassian.net/browse/SV-719) - HPAs para api-gateway, auth-service, bets-service e stats-service
- [SV-720](https://stakevault.atlassian.net/browse/SV-720) - k8s/hpa.yaml com os 4 HPAs
- [SV-721](https://stakevault.atlassian.net/browse/SV-721) - Remover replicas dos 4 Deployments com HPA
- [SV-722](https://stakevault.atlassian.net/browse/SV-722) - Documentar apply e verificacao
- [SV-723](https://stakevault.atlassian.net/browse/SV-723) - CHANGELOG e verificacao final

## [0.1.0] - 2026-09-23

- `docker-compose.yml` com a infraestrutura local completa (`feat-001`, fecha `epic-001`): 3x
  PostgreSQL, RabbitMQ 4, Redis, n8n, todos com healthcheck
- Topologia RabbitMQ versionada em `rabbitmq/definitions.json` (exchange/fila/DLQ)
- `rabbitmq/apply-definitions.sh` + container one-shot `rabbitmq-init`
- `.env.example` + `.gitignore`/`.gitattributes` (LF fixo em `.sh`/`.yml`/`.json`)
- `k8s/auth-service.yaml` ganha `BETS_SERVICE_URL`/`STATS_SERVICE_URL` (`feat-006`)
- `feature_list.json` ganha o campo `plan_review` por feature (7 harnesses)
- `feature_list.json` ganha os campos `jira`/`subtasks` por feature
- Bootstrap dos 6 repositórios de aplicação: commit inicial + `develop` publicados (`feat-003`)
- Chave de projeto do SonarCloud alinhada ao formato `eimmig_<repo>` nos 6 repos (`feat-003.8`)
- Credencial do SonarCloud distribuída via `tools/sonar_setup.py`
- Guarda por arquivo-marcador (`hashFiles`) nos 6 `ci.yml` dos repositórios de aplicação
- `.github/scripts/validate-changelog.sh` corrigido para `100755` (bit de execução ausente)
- `feat-002` não cita mais RNF06 como justificativa do teste de resiliência (era RNF de volume,
  não de tolerância a falha)
- [SV-261](https://stakevault.atlassian.net/browse/SV-261) - Teste de resiliencia cross-service: DLQ e retry (fecha epic-007 da raiz)
- [SV-262](https://stakevault.atlassian.net/browse/SV-262) - Migração para Kubernetes (fecha epic-010 da raiz) — alvo real de implantação do TCC 1
- [SV-263](https://stakevault.atlassian.net/browse/SV-263) - Ambiente: infra + 4 servicos Java no ar com segredos sincronizados
- [SV-264](https://stakevault.atlassian.net/browse/SV-264) - Provisionamento do tenant de teste + caso de controle
- [SV-265](https://stakevault.atlassian.net/browse/SV-265) - Cenario retry: derrubar/subir stats-service sem perda de mensagem
- [SV-266](https://stakevault.atlassian.net/browse/SV-266) - Cenario DLQ: falha consecutiva de consumo isola sem travar o fluxo
- [SV-267](https://stakevault.atlassian.net/browse/SV-267) - Evidencia, documentacao e fechamento
- [SV-286](https://stakevault.atlassian.net/browse/SV-286) - Dockerfiles dos 5 servicos de aplicacao (cross-repo, feature propria em cada um)
- [SV-287](https://stakevault.atlassian.net/browse/SV-287) - Cluster kind + ingress-nginx + manifests de infra (Postgres x3, RabbitMQ+Job, Redis, n8n)
- [SV-288](https://stakevault.atlassian.net/browse/SV-288) - Manifests dos 5 servicos de aplicacao + Ingress + verificacao end-to-end real
- [SV-289](https://stakevault.atlassian.net/browse/SV-289) - Documentacao (CLAUDE.md, ARCHITECTURE.md, docs/services/infra.md) + CHANGELOG e verificacao final
- [SV-351](https://stakevault.atlassian.net/browse/SV-351) - Migrar manifests do kind local pro k3s de producao (Debian) + GHCR
- [SV-352](https://stakevault.atlassian.net/browse/SV-352) - Atualizar 6 manifests + criar web.yaml + dividir ingress.yaml por path
- [SV-353](https://stakevault.atlassian.net/browse/SV-353) - CHANGELOG e verificacao final
- [SV-390](https://stakevault.atlassian.net/browse/SV-390) - auth-service: env vars BETS_SERVICE_URL/STATS_SERVICE_URL (orquestracao de tenant)
- [SV-391](https://stakevault.atlassian.net/browse/SV-391) - Adicionar env vars + aplicar no cluster real + CHANGELOG
- [SV-418](https://stakevault.atlassian.net/browse/SV-418) - ServiceAccount de CI com RBAC restrito + kubeconfig para deploy automatico (fecha epic-028 da raiz)
- [SV-419](https://stakevault.atlassian.net/browse/SV-419) - Manifest RBAC (ServiceAccount + Role + RoleBinding restritos)
- [SV-420](https://stakevault.atlassian.net/browse/SV-420) - Script de aplicacao/token/distribuicao (tools/kube_deploy_setup.py) + docs
- [SV-421](https://stakevault.atlassian.net/browse/SV-421) - Aplicar RBAC + gerar token + distribuir KUBE_CONFIG nos 6 repos (exige kubectl real, operador)
- [SV-422](https://stakevault.atlassian.net/browse/SV-422) - CHANGELOG e verificacao final
- [SV-579](https://stakevault.atlassian.net/browse/SV-579) - CI: gerar versao (semver + tag + Release + corte de CHANGELOG) ao merge em main
- [SV-580](https://stakevault.atlassian.net/browse/SV-580) - Job 'release' no ci.yml + .github/scripts/cut-changelog.py
- [SV-581](https://stakevault.atlassian.net/browse/SV-581) - CHANGELOG, verificacao final e fechamento do epic-033 da raiz
