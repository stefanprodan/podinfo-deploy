# podinfo-deploy

A GitOps workflow for multi-env deployments with [Flux Operator](https://fluxoperator.dev/).

## Publishing OCI Artifacts

```shell
make set-version VERSION=6.0.0
make push VERSION=6.9.4
```

## Deploying with Flux Operator

```shell
kubectl create namespace apps --server-side-apply
kubectl apply -f flux/deploy.yaml
```
