# flux2-kustomize-helm-example

A GitOps workflow example for multi-env deployments with Flux v2, Kustomize and Helm.

For this example we assume a scenario with two clusters: staging and production.
The end goal is to leverage Flux and Kustomize to manage both clusters while minimizing duplicated declarations.

We will configure Flux to install, test and upgrade a demo app using
`HelmRepository` and `HelmRelease` custom resources.
Flux will monitor the Helm repository, and it will automatically
upgrade the Helm releases to their latest chart version based on semver ranges.

## Repository structure

The Git repository contains the following top directories:

- **apps** dir contains Helm releases with a custom configuration per cluster
- **infrastructure** dir contains common infra tools such as NGINX ingress controller and Helm repository definitions
- **clusters** dir contains the Flux configuration per cluster

```
├── apps
│   ├── base
│   ├── production 
│   └── staging
├── infrastructure
│   ├── nginx
│   ├── redis
│   └── sources
└── clusters
    ├── production
    └── staging
```

The apps configuration is structured into:

- **apps/base/** dir contains namespaces and Helm release definitions
- **apps/production/** dir contains the production Helm release values
- **apps/staging/** dir contains the staging values

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

In **apps/base/podinfo/** dir we have a HelmRelease with common values for both clusters:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: podinfo
  namespace: podinfo
spec:
  releaseName: podinfo
  chart:
    spec:
      chart: podinfo
      sourceRef:
        kind: HelmRepository
        name: podinfo
        namespace: flux-system
  interval: 5m
  values:
    cache: redis.redis:6379
    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
      path: "/*"
```

In **apps/staging/** dir we have a Kustomize patch with the staging specific values:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: podinfo
spec:
  chart:
    spec:
      version: ">=1.0.0-alpha"
  test:
    enable: true
  values:
    ingress:
      hosts:
        - podinfo.staging
```

Note that with ` version: ">=1.0.0-alpha"` we configure Flux to automatically upgrade
the `HelmRelease` to the latest chart version including alpha, beta and pre-releases.

In **apps/production/** dir we have a Kustomize patch with the production specific values:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: podinfo
  namespace: podinfo
spec:
  chart:
    spec:
      version: ">=1.0.0"
  values:
    ingress:
      hosts:
        - podinfo.production
```

Note that with ` version: ">=1.0.0"` we configure Flux to automatically upgrade
the `HelmRelease` to the latest stable chart version (alpha, beta and pre-releases will be ignored).

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
└── sources
    ├── bitnami.yaml
    ├── kustomization.yaml
    └── podinfo.yaml
```

In **infrastructure/sources/** dir we have the Helm repositories definitions:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: podinfo
spec:
  interval: 5m
  url: https://stefanprodan.github.io/podinfo
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: bitnami
spec:
  interval: 30m
  url: https://charts.bitnami.com/bitnami
```

Note that with ` interval: 5m` we configure Flux to pull the Helm repository index every five minutes.
If the index contains a new chart version that matches a `HelmRelease` semver range, Flux will upgrade the release.


## Cluster bootstrap

The clusters dir contains the Flux configuration:

```
./clusters/
├── production
│   ├── apps.yaml
│   └── infrastructure.yaml
└── staging
    ├── apps.yaml
    └── infrastructure.yaml
```

In **clusters/staging/** dir we have the Kustomization definitions:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 10m0s
  dependsOn:
    - name: infrastructure
  sourceRef:
    kind: GitRepository
    name: flux-sytem
  path: ./apps/staging
  prune: true
  validation: client
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: infrastructure
  namespace: flux-system
spec:
  interval: 10m0s
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./infrastructure
```

Note that with `path: ./apps/staging` we configure Flux to sync the staging Kustomize overlay and 
with `dependsOn` we tell Flux to create the infrastructure items before deploying the apps.

Fork this repository and export your GitHub personal access token, username and repo name:

```sh
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
export GITHUB_REPO=<repository-name>
```

Install the Flux CLI with `brew install fluxcd/tap/flux` and bootstrap the staging cluster:

```sh
flux bootstrap github \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --personal \
    --path=cluster/staging
```

The bootstrap command commits the manifests for the Flux components in `clusters/staging/flux-system` dir
and creates a deploy key with read-only access on GitHub, so it can pull changes inside the cluster.

Watch for the Helm releases being install on the cluster:

```console
$ flux get helmreleases --all-namespaces 
NAMESPACE	NAME   	REVISION	SUSPENDED	READY	MESSAGE                          
nginx    	nginx  	5.6.14  	False    	True 	release reconciliation succeeded	
podinfo  	podinfo	5.0.3   	False    	True 	release reconciliation succeeded	
redis    	redis  	11.3.4  	False    	True 	release reconciliation succeeded
```
