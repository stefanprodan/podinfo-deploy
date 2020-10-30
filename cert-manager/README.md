# cert-manager

Assuming you used `flux bootstrap --path=staging-cluster` command to bootstrap Flux v2.

Create a cert-manager dir at the top of your repo:

```
./cert-manager/
├── README.md
├── certs
│   ├── kustomization.yaml
│   └── letsencrypt-staging.yaml
└── controller
    └── kustomization.yaml
```

Create a `cert-manager.yaml` in the `staging-cluster` dir:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: cert-manager
  namespace: flux-system
spec:
  interval: 5m
  path: "./cert-manager/controller/"
  prune: true
  validation: client
  sourceRef:
    kind: GitRepository
    name: flux-system
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: certs
  namespace: flux-system
spec:
  interval: 5m
  dependsOn:
    - name: cert-manager
  path: "./cert-manager/certs/"
  validation: client
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
```

