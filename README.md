# podinfo-deploy

A GitOps workflow for multi-env deployments with FluxCD [source-controller](https://github.com/fluxcd/source-controller)
and [kustomize-controller](https://github.com/fluxcd/kustomize-controller).

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
  path: "./overlays/dev/"
  prune: true
  sourceRef:
    kind: GitRepository
    name: podinfo
``` 

Staging environment kustomization:

```yaml
apiVersion: kustomize.fluxcd.io/v1alpha1
kind: Kustomization
metadata:
  name: podinfo-staging
spec:
  interval: 1m
  path: "./overlays/staging/"
  prune: true
  sourceRef:
    kind: GitRepository
    name: podinfo
```

Git repository tags semver range:

```yaml
apiVersion: source.fluxcd.io/v1alpha1
kind: GitRepository
metadata:
  name: podinfo-releases
spec:
  interval: 5m
  url: https://github.com/stefanprodan/podinfo-deploy
  ref:
    semver: ">=0.0.1"
```

Production environment kustomization:

```yaml
apiVersion: kustomize.fluxcd.io/v1alpha1
kind: Kustomization
metadata:
  name: podinfo-production
spec:
  interval: 10m
  path: "./overlays/production/"
  prune: true
  sourceRef:
    kind: GitRepository
    name: podinfo-releases
```

Development environment gitops toolkit kustomization:

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: podinfo
  namespace: gotk-system
spec:
  interval: 1m
  url: https://github.com/stefanprodan/podinfo-deploy
  ref:
    branch: master
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: podinfo-dev
  namespace: gotk-system
spec:
  interval: 1m
  path: "./overlays/dev/"
  prune: true
  sourceRef:
    kind: GitRepository
    name: podinfo
  dependsOn:
    - name: monitoring

```
