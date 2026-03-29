# K8s offline installation

During my career I had to do "offline installation" on k8s clusters that couldn't reach the internet and could only pull from private registries.
This repo is a collection of tools ment to help archieve "k8s offline installtions".

## Taskfile

The Taskfile it's only a wrapper ment to help launch the bash scripts.

To list all the feature available via the Taskfile:

```shell
task --list
```

To get detail esxplanation of a task:

```shell
task <task> --summary
```

## Container

Download all specified containers and upload them to the specified registries.
Configurations file:

```yaml
# List of container registry where to ship the containers
destinations:
  - "container registry 1"
  - "container registry 2"
# List of containers to ship
containers:
  - name: "container 1 name"
    tag: "container 1 tag"
    registry: "container 1 registry"
  - name: "container 2 name"
    tag: "container 2 tag"
    registry: "container 2 registry"
```

## Helm

Given a list of charts download each and uploade the downloaded charts plus the one stored in.

Each chart can be uploaded to a registy with a prefix.
Using the Makefile withouth setting the `CHART_PREFIX` variable, all the charts will use `charts` as a prefix.

Configurations file:

```yaml
# List of chart registry where to ship the helm charts
destinations:
  - "container registry 1"
  - "container registry 2"
# List of charts to ship
charts:
  - name: "helm chart 1 name"
    version: "helm chart 1 version"
    repo: "helm chart 1 repo"
  - name: "helm chart 2 name"
    version: "helm chart 2 version"
    repo: "helm chart 2 repo"

```

### Useful tips

List all available repos:

```bash
helm repo list
```

List all available charts inside across all repos:

```bash
helm search repo
```

List all available charts inside a specified repo:

```bash
helm search repo <repo>
```

List all available version for a specific chart in the specified repo:

```bash
helm search repo <repo>/<chart-name> --versions --devel
```
