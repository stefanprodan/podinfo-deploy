# podinfo-deploy

A GitOps workflow for multi-env deployments with [Flux Operator](https://fluxoperator.dev/).

## Publishing OCI Artifacts

```shell
make set-version push
```

## Deploying with Flux Operator

Install:

```shell
make deploy
```

Uninstall:

```shell
make undeploy
```
