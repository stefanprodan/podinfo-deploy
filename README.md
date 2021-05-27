# podinfo-deploy

```shell
flux create source git webapp-deploy \
--url=https://github.com/stefanprodan/podinfo-deploy \
--branch=include
```

```shell
flux create kustomization webapp-deploy \
    --source=GitRepository/webapp-deploy \
    --path="./clusters/staging/" \
    --prune=true \
    --interval=10m \
    --validation=client
```
