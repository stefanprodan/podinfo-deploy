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
  prune: "env=dev"
  gitRepositoryRef:
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
  prune: "env=staging"
  gitRepositoryRef:
    name: podinfo
```
