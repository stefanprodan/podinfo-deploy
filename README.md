# podinfo-deploy

A GitOps workflow for multi-env deployments with Flux v2, Kustomize and Helm.

## Repository structure

```
├── apps
│   ├── base
│   ├── production 
│   └── staging
├── infrastructure
│   ├── nginx
│   ├── redis
│   └── repositories
└── clusters
    ├── production
    └── staging
```

Applications:

```
./apps/
├── base
│   └── podinfo
│       ├── kustomization.yaml
│       ├── namespace.yaml
│       └── release.yaml
├── production
│   ├── kustomization.yaml
│   └── podinfo-patch.yaml
└── staging
    ├── kustomization.yaml
    └── podinfo-patch.yaml
```

- **apps/base/** contains namespaces and Helm release definitions
- **apps/production/** contains the production values for Helm releases
- **apps/staging/** contains the staging values for Helm pre-releases

Infrastructure:

```
./infrastructure/
├── nginx
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   └── release.yaml
├── redis
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   └── release.yaml
└── repositories
    ├── bitnami.yaml
    ├── kustomization.yaml
    └── podinfo.yaml
```

Clusters:

```
./clusters/
├── production
│   ├── apps.yaml
│   └── infrastructure.yaml
└── staging
    ├── apps.yaml
    └── infrastructure.yaml
```

## Bootstrap

Staging cluster:

```sh
flux bootstrap github \
    --owner=${GH_OWNER} \
    --repository=${GH_REPO} \
    --branch=main \
    --path=cluster/staging
```

