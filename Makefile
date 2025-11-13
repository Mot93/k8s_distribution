ifndef ENV
	$(error ENV variable is not set. Please pass ENV as a variable, e.g. make upload ENV=example)
endif

# Prefix to add in front of charts inside the registry
# Usefull when storing charts inside a registry also used for container images
#TODO:
CHART_PREFIX="charts/"

upload: upload_helm upload_container

upload_helm:
	@./scripts/helm.sh $(ENV) $(CHART_PREFIX)

upload_container:
	@./scripts/container.sh $(ENV)
