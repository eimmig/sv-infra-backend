# CLAUDE.md — infra

Docker Compose local para os serviços de infraestrutura compartilhada (PostgreSQL, RabbitMQ,
Redis, n8n), o teste de resiliência cross-service (DLQ/retry) e — alvo real de implantação
especificado no TCC 1, não apenas ambiente de dev — os manifests/Helm charts de Kubernetes
(ver `../docs/DECISIONS-LOG.md` 2026-09-08 "Correção: Kubernetes não é fora de escopo"). Parte
do harness multinível do projeto — leia `../CLAUDE.md` (raiz) para invariantes cross-service
antes deste arquivo, e `../docs/services/infra.md` para o desenho completo (componentes,
diagramas de resiliência). **Este é seu próprio repositório Git**, não um monorepo — ver
`../docs/DECISIONS-LOG.md` "Topologia".

## Por que este harness existe

`epic-001` e `epic-007` da raiz não pertencem a nenhum serviço de aplicação (não têm domínio de
negócio, não são Java/Python/Angular) — mas também não podem viver na raiz, que não é um
repositório. Este harness (e o repositório que nasce dele) existe para dar a esses dois epics um
lugar real para código/config versionados, seguindo o mesmo padrão dos outros 6 repositórios.

## Fluxo de início de sessão (Startup Workflow)

1. Confirme o diretório de trabalho (`pwd`) — deve ser `infra`.
2. Leia `../CLAUDE.md` e `../docs/services/infra.md`.
3. Rode `./init.sh` para verificar a validade do `docker-compose.yml`.
4. Leia `feature_list.json` (deste harness) para a próxima feature granular.
5. Leia `progress.md` (deste harness).

## Regras específicas deste harness

- **Uma feature por vez (One feature at a time)**: escolha exatamente uma feature `not-started`
  de `feature_list.json` cujas dependências já estejam `done`.
- **Escopo restrito (stay in scope)**: não edite código de nenhum serviço de aplicação a partir
  desta pasta — este harness só cobre orquestração local (Docker Compose) e o teste de
  resiliência cross-service, nunca lógica de negócio.
- **`feat-001` (Docker Compose)**: **entregue em 2026-08-03**. Três containers PostgreSQL
  (`postgres-auth` 5432, `postgres-bets` 5433, `postgres-stats` 5434 — Database per Service,
  ver `../docs/DECISIONS-LOG.md` 2026-08-03), RabbitMQ 4 com **DLQ configurada desde o início**
  (não como melhoria futura), Redis com senha obrigatória (uso exclusivo de `stats-service`),
  n8n (webhook do Telegram, não depende de nenhum outro container). Healthcheck em todos —
  sempre em `CMD-SHELL` quando o comando usa variável de ambiente, porque exec form não expande
  `$$VAR`. Ver `../docs/services/infra.md` e `../docs/OBSERVABILITY-AND-CONFIG.md`.
- **Topologia do RabbitMQ é contrato, não configuração local**: exchanges/filas/bindings vivem em
  `rabbitmq/definitions.json` e estão documentados em `../docs/API-CONTRACTS.md` seção "Topologia
  RabbitMQ" — `bets-service` e `stats-service` consomem/publicam **sem redeclarar**. Mudar um
  nome ou argumento aqui é mudança de contrato e atualiza aquela nota no mesmo commit.
- **A topologia é aplicada pós-boot, não por `load_definitions`**: o container one-shot
  `rabbitmq-init` roda `rabbitmq/apply-definitions.sh` depois do broker ficar `healthy`. Não
  troque isso por `load_definitions` no `rabbitmq.conf`: um nó novo que importa definições **não
  cria o vhost `/` nem o usuário default**, e o healthcheck continua passando — falha silenciosa.
  Racional completo em `../docs/DECISIONS-LOG.md` (2026-08-03).
- **`feat-002` (teste de resiliência)**: **bloqueada até `epic-004` (stats-service) e
  `epic-005` (telegram-integration) da raiz estarem `done`** — dependência cross-repositório, não
  expressável no `dependencies` deste `feature_list.json`. Confira o `feature_list.json` da raiz
  antes de iniciar. Teste de aceite: derrubar `stats-service`, publicar eventos via
  `bets-service`, subir `stats-service` de novo, confirmar reprocessamento sem perda — ver
  `../docs/services/infra.md` seção "Resiliência" para os diagramas esperados.
- **`feat-003` é cross-repositório por natureza** (bootstrap dos 6 repositórios + SonarCloud,
  entregue em 2026-08-17): é a exceção declarada à regra de escopo acima. Ela edita `ci.yml`,
  `.gitignore`/`.gitattributes` e configuração de CI **dos outros 6 repositórios**, nunca código
  de aplicação. O motivo de morar aqui é o mesmo de `feat-001`/`feat-002`: nenhum serviço de
  aplicação é dono desse trabalho, e a raiz não é um repositório. Consequência prática registrada
  no `plan_review` daquela feature: o commit inicial de um repositório vazio **não** passa por
  `feature/`→PR (não existe branch base), então vai direto em `main`; a branch da story vive aqui,
  levando só as mudanças de harness.
- **`feat-004` (migração Kubernetes)**: **`done`** (2026-09-10) — fecha a lacuna descrita em
  `../docs/DECISIONS-LOG.md` (2026-09-08). Manifests YAML puros (decisão do usuário via
  `AskUserQuestion` — sem Helm, ~10 componentes não justificam templating) em `k8s/`, um
  cluster local por `kind` (não Docker Desktop Kubernetes — não estava habilitado nesta
  máquina e exige toggle manual na GUI; `kind`/`helm` instalados via `winget` só por
  precaução, `helm` acabou não sendo usado). Escopo final maior que o originalmente descrito
  aqui: **`telegram-integration` entrou no escopo** (decisão do usuário) mesmo nunca tendo
  passado por `docker-compose.yml` antes — `Dockerfile` de cada um dos 5 serviços de aplicação
  (4 Java + Python) foi feito como feature própria em cada repositório de serviço (mesmo
  precedente de "porta HTTP fixa"), não neste harness — ver `auth-service feat-011`,
  `bets-service feat-013`, `stats-service feat-011`, `api-gateway feat-009`,
  `telegram-integration feat-007`. Este harness só referencia as imagens já construídas
  (`stakevault/<serviço>:local`).
  - **Segredos**: `k8s/secret.example.yaml` (versionado, placeholders) → copiar para
    `k8s/secret.yaml` (nunca versionado, mesmo padrão do `.env`) com os mesmos valores já
    usados nos `.env` de cada serviço — um único `Secret` (`stakevault-secrets`) referenciado
    por todos os Deployments, não um por serviço (chaves compartilhadas como
    `ADMIN_API_KEY`/`PASETO_LOCAL_KEY`/`SERVICE_KEY` ficariam fáceis de divergir em Secrets
    separados).
  - **Topologia do RabbitMQ**: o `ConfigMap` `rabbitmq-definitions` **não** é um arquivo YAML
    versionado em `k8s/` — geraria uma segunda cópia de `rabbitmq/definitions.json` e
    `rabbitmq/apply-definitions.sh` (os mesmos arquivos que `docker-compose.yml` já usa via
    bind mount) que divergiria se um mudasse sem o outro. Gerar sempre a partir dos 2 arquivos
    reais: `kubectl create configmap rabbitmq-definitions --from-file=rabbitmq/definitions.json
    --from-file=rabbitmq/apply-definitions.sh --dry-run=client -o yaml | kubectl apply -f -`.
  - **Sem `depends_on`/`condition: service_healthy`** (mecanismo do compose, não existe no
    Kubernetes): o `Job` `rabbitmq-init` usa um `initContainer` (`busybox`, `nc -z rabbitmq
    5672` em loop) esperando a porta AMQP responder antes de rodar o mesmo
    `apply-definitions.sh` de sempre.
  - **Rotas administrativas continuam fora do Gateway** (mesmo desenho de sempre, ver
    `../docs/API-CONTRACTS.md`): só `api-gateway` tem `Ingress`; `auth-service`/
    `bets-service`/`stats-service` são `Service` `ClusterIP`-only, alcançáveis de fora do
    cluster só via `kubectl port-forward svc/<nome> <porta>:<porta>` — é assim que o operador
    roda `POST /api/v1/admin/tenants` num cluster real, não um workaround temporário.
  - **`telegram-integration` fica `ClusterIP`-only, sem `Ingress`**: só `n8n` (mesmo cluster)
    fala com ele — o residual de auth/rate-limit em `POST /bets/capture`/`/telegram/link`
    (aceito em `services/telegram-integration/n8n/README.md` enquanto o serviço não era
    exposto) continua válido, a internet nunca alcança esse pod diretamente.
  - **Imagens locais, nunca de um registry**: `imagePullPolicy: Never` nos 5 Deployments de
    aplicação + `kind load docker-image stakevault/<serviço>:local --name stakevault` antes de
    aplicar — sem registry configurado (fora de escopo de um cluster de demonstração local de
    TCC).
- **Sem arquitetura hexagonal, sem i18n**: este harness não tem código de aplicação nem texto
  voltado ao usuário final — as convenções de `../docs/CONVENTIONS.md` sobre estrutura
  `domain/`/`application/`/`adapter/` e internacionalização não se aplicam aqui.
- **CI/CD**: pipeline em `.github/workflows/ci.yml`, adaptada — sem passo de i18n (não há
  texto de usuário) nem SonarCloud (não há código de aplicação para analisar): só changelog e
  validação de `docker compose config`. Ver `../docs/CI-CD.md`.
- **Skills de agente prioritárias**: `Plan Reviewer` antes de codificar; `Architecture Diagram
  Builder`/`Current Architecture Documenter` para conferir a topologia do compose contra
  `../docs/ARCHITECTURE.md` (nunca gerar diagrama paralelo); `Acceptance Test Builder` para
  `feat-002` (teste de resiliência); `Delivery Reviewer` antes de marcar `done`
  (claude-code-skills) — mapeamento completo em `../docs/AGENT-SKILLS.md`. Instaladas em
  2026-08-02 (escopo `user`), ver `../docs/DECISIONS-LOG.md`.

## Definição de pronto (Definition of Done)

Uma feature deste harness só está `done` quando (done only when):

> **Antes de começar** (não é item de `done`, é pré-requisito de `in-progress`): o campo
> `plan_review` daquela feature em `feature_list.json` precisa estar preenchido com o
> resultado do `Plan Reviewer` — ver `CLAUDE.md` da raiz, seção "Regras de trabalho".


- [ ] Implementada e rodando via `./init.sh` sem erro (`docker compose config` válido).
- [ ] Para `feat-001`: `docker compose up` sobe com todos os healthchecks passando.
- [ ] Para `feat-002`: teste de resiliência documentado em `../docs/services/infra.md` executado
      com sucesso.
- [ ] `Delivery Reviewer` rodado contra a feature (ver `../docs/AGENT-SKILLS.md`).
- [ ] `CHANGELOG.md` deste harness tem uma entrada em `[Unreleased]` descrevendo a mudança.
- [ ] `feature_list.json` atualizado com status e evidência.
- [ ] `../feature_list.json` (raiz) atualizado — `evidence` do epic correspondente
      (`epic-001` para `feat-001`, `epic-007` para `feat-002`).

## Fim de sessão (End of Session)

Antes de encerrar (before ending a session): atualize `progress.md` deste harness, atualize
`feature_list.json`, e deixe `./init.sh` passando (clean, restartable state).

## Verificação

```bash
cp .env.example .env       # uma vez; o .env real nunca e versionado
./init.sh                  # valida o docker-compose.yml (docker compose config)

docker compose up -d
docker compose ps          # os 6 containers de longa duracao devem estar (healthy)
docker compose logs rabbitmq-init   # confirma que a topologia foi aplicada
docker compose down -v     # estado limpo para a proxima sessao
```

`rabbitmq-init` é um container one-shot: `docker compose up -d` **não** espera por ele nem falha
se ele falhar. Sempre confira o log dele — sem a topologia aplicada, o broker sobe vazio e o
problema só apareceria no `epic-003`.

## Verificação — Kubernetes (`feat-004`)

Pré-requisito: as imagens `stakevault/<serviço>:local` já construídas (`docker build` dentro de
cada `services/<serviço>/`, ver o `CLAUDE.md` daquele repositório) — este harness só as
referencia, nunca as constrói.

```bash
# 1. Cluster local (kind, não Docker Desktop Kubernetes — ver nota acima)
kind create cluster --name stakevault --config k8s/kind-config.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.0/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller --timeout=120s

# 2. Carregar as 5 imagens locais no cluster (nunca de um registry)
for s in auth-service bets-service stats-service api-gateway telegram-integration; do
  kind load docker-image stakevault/$s:local --name stakevault
done

# 3. Segredos + topologia RabbitMQ (a partir dos mesmos arquivos que o compose usa)
cp k8s/secret.example.yaml k8s/secret.yaml   # preencher com os mesmos valores dos .env locais
kubectl apply -f k8s/secret.yaml
kubectl create configmap rabbitmq-definitions \
  --from-file=rabbitmq/definitions.json --from-file=rabbitmq/apply-definitions.sh \
  --dry-run=client -o yaml | kubectl apply -f -

# 4. Infra, depois aplicação
kubectl apply -f k8s/postgres.yaml -f k8s/rabbitmq.yaml -f k8s/redis.yaml -f k8s/n8n.yaml
kubectl apply -f k8s/auth-service.yaml -f k8s/bets-service.yaml -f k8s/stats-service.yaml \
  -f k8s/api-gateway.yaml -f k8s/telegram-integration.yaml -f k8s/ingress.yaml

# 5. Confirmar
kubectl get pods                 # todos 1/1 Running (ou Completed, no caso do Job)
kubectl logs job/rabbitmq-init   # confirma que a topologia foi aplicada
curl http://localhost:8888/actuator/health   # api-gateway via Ingress (hostPort do kind-config.yaml)

# Rotas admin (POST /api/v1/admin/tenants) ficam fora do Gateway por design — ver nota acima:
kubectl port-forward svc/auth-service 28081:8081 &
curl -H "X-Admin-Api-Key: ..." -X POST http://localhost:28081/api/v1/admin/tenants -d '...'

# 6. Estado limpo para a proxima sessao
kind delete cluster --name stakevault
```

Verificado de ponta a ponta nesta sessão (não só `kubectl get pods` verde): tenant provisionado
via `port-forward`, login e registro de aposta via `Ingress` (`http://localhost:8888`),
`FACT_BET`/`PROCESSED_EVENT` conferidos dentro do pod `postgres-stats` — o mesmo fluxo do
`docker-compose`, agora rodando no cluster.
