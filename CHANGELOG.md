# Changelog

Todas as mudanças notáveis deste repositório são documentadas neste arquivo. Formato baseado em
[Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Toda feature que altera este
repositório adiciona uma entrada em `[Unreleased]` — verificado automaticamente pela pipeline de
CI (ver `docs/CI-CD.md`).

## [Unreleased]

## [0.1.1] - 2026-09-24

- Remover todos os comentários restantes do código, testes e configuração (convenção de zero comentário, `docs/convencoes.md`)

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
