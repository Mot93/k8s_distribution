# Include config.env and export all variables
include config.env
# Ensures these variables are available to any subprocesses (e.g., shell commands in targets)
export

# Prefix to add in front of charts inside the registry
# Usefull when storing charts inside a registry also used for container images
#TODO:
CHART_PREFIX="charts/"

upload: upload_helm upload_container

upload_helm:
	@$(SCRIPTS_DIR)/helm.sh $(env) $(CHART_PREFIX)

upload_container:
	@$(SCRIPTS_DIR)/container.sh $(env)
