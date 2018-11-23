

##
# Note, these prereqs are for Mac OS
# You will need to do something else for Windows or Linux!
##

Install-Module -Force Az
Import-Module Az
# Enable AzureRM aliases for the user
Enable-AzureRmAlias -Scope CurrentUser

# The Azure CLI
brew install azure-cli

# Kubernetes and related
brew install kubernetes-cli
brew install kubernetes-helm