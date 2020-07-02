# podinfo-deploy-helm

A GitOps workflow for multi-env deployments with GitOps Toolkit.

Git repository definition:

```yaml
apiVersion: source.fluxcd.io/v1alpha1
kind: GitRepository
metadata:
  name: podinfo
spec:
  interval: 1m
  url: https://github.com/stefanprodan/podinfo-deploy
  ref:
    branch: master
```

Dev environment kustomization:

```yaml
apiVersion: kustomize.fluxcd.io/v1alpha1
kind: Kustomization
metadata:
  name: podinfo-dev
spec:
  interval: 1m
  path: "./helm/overlays/dev/"
  prune: true
  sourceRef:
    kind: GitRepository
    name: podinfo
``` 

The dev overlay patches [helmrelease.spec.values.resources](overlays/dev).

Staging environment kustomization:

```yaml
apiVersion: kustomize.fluxcd.io/v1alpha1
kind: Kustomization
metadata:
  name: podinfo-staging
spec:
  interval: 1m
  path: "./helm/overlays/staging/"
  prune: true
  sourceRef:
    kind: GitRepository
    name: podinfo
```

The staging overlay patches [helmchart.spec.valuesFileRef](overlays/staging).

Production environment kustomization:

```yaml
apiVersion: kustomize.fluxcd.io/v1alpha1
kind: Kustomization
metadata:
  name: podinfo-production
spec:
  interval: 10m
  path: "./helm/overlays/production/"
  prune: true
  sourceRef:
    kind: GitRepository
    name: podinfo
```

The production overlay patches [helmchart.spec.version](overlays/production) and [helmrelease.spec.values.hpa](overlays/production).
