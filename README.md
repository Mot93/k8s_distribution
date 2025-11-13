# K8s offline installation
During my career I had to do "offline installation" on k8s clusters that couldn't reach the internet and could only pull from private registries.
This repo is a collection of tools ment to help archieve "k8s offline installtions".

## Makefile
The Makefile it's only a wrapper ment to help launch the bash scripts.

Upload both charts and containers specified in the folder `environments/example`
```bash
make upload ENV=example
```

Upload containers specified in the folder `environments/example`
```bash
make upload_container ENV=example
```

Upload charts specified in the folder `environments/example` using `charts` ad a prefix 
```bash
make upload_helm ENV=example
```
Upload charts specified in the folder `environments/example` using `foo` ad a prefix 
```bash
make upload_helm ENV=example CHART_PREFIX=foo
```
Upload both charts and container specified in the folder `environments/example` withouth any prefix
```bash
make upload_helm ENV=example CHART_PREFIX=""
```

## Helm
Download all specified charts.

Each chart can be uploaded to a registy with a prefix.
Using the Makefile withouth setting the `CHART_PREFIX` variable, all the charts will use `charts` as a prefix.

Configurations file:
```json
{
    "destinations": [
        {
            "url": "URL of the repo where to push charts",
            "auth": "(Optional) Authentication command launched before. CAREFULL there are no checks onwhat is runned"
        }
    ],
    "repos": [
        {  // helm repo add $name $url
            "name": "Name used by helm when calling the repo",
            "url": "URL of the repos from where to download",
            "auth": "(Optional) Authentication command launched before. CAREFULL there are no checks onwhat is runned"
        }
    ],
    "charts": [
        {
            "name": "Chart name",
            "version": "Chart version",
            "repo": "Name of the repo, has to be the same specified in repos list"
        }
    ]

}
```

## Container
Download all specified containers.
Configurations file:
```json
{
    "destinations": [
        {
            "url": "URL of the repo where to push charts",
            "auth": "(Optional) Authentication command launched before. CAREFULL there are no checks onwhat is runned"
        }
    ],
    "repos": [
        {
            "auth": "(Optional) Authentication command launched before. CAREFULL there are no checks onwhat is runned"
        }
    ],
    "charts": [
        {
            "name": "Chart name",
            "version": "Chart version",
            "repo": "Name of the repo, has to be the same specified in repos list"
        }
    ]

}
```
