# Servianchallenge-infracode

## Deployment Instructions
Markup : 1. Pre-Requirements.
              1.Azure Subscription
              2.GitHub Account
              3.Local Terraform Installation
              4.Local Git Installation

         2. Fork and clone the following git repositories.
              1. git@github.com:ssnyders89/Servianchallenge-infracode.git
              2. git@github.com:ssnyders89/TechChallengeApp.git
         2. Manually Deploy Azure Shared Resources using Terraform, Required files found in git@github.com:ssnyders89/Servianchallenge-infracode.git
              1. This will deploy an azure shared resource group.
              2. Container Registry for us to store our docker Image that contains the app.
              3. A Storage Account and Storage Container to store our Backend Terraform State file.
         4. Deployment Steps.
              1. On your local where you cloned git@github.com:ssnyders89/Servianchallenge-infracode.git navigate to Sharedresources directory.
              2. Run Terraform init
              3. Then run Terraform plan to check for possible syntax Errors.
              4. Run Terraform apply this should create the required Azure Resources.
         5. Azure Devops Pipeline to Build and Push Docker Image to Container Registry.
              1. Create pipeline in Azure Devops, where is your code? point to your github repositories that you forked from git@github.com:ssnyders89/TechChallengeApp.git.
              2. Configure your pipeline by using Exsisting Azure Pipeline YAML File which can be found in our forkd repository called azure-pipelines.yml.
              3. following Variables to be modified:   
                    dockerRegistryServiceConnection: 'YourServiceconnectionname'
                    imageRepository: 'nameofimageRepo'
                    containerRegistry: 'ContainerRegistryname.azurecr.io'
              4. Run Pipeline. If this is Successful should create and push a new docker image to your Container Registry in Azure Shared Resource Group.
         6. Azure Devops Infra code Pipeline to Create Application Resources
              1. Create pipeline in Azure Devops, where is your code? point to your github repositories that you forked from git@github.com:ssnyders89/Servianchallenge-infracode.git
              2. Configure your pipeline by using Exsisting Azure Pipeline YAML File which can be found in our forkd repository called azure-pipelines.yml.
              3.Following Variables to be modified:
                      backendServiceArm: Azure Subscription ID.
                      backendAzureRmResourceGroupName: Name of your shared resource group.
                      backendAzureRmStorageAccountName: Name of Stroage account in shared resource group.(To store Terraform state)
                      backendAzureRmContainerName: name of container in Storage acccount in shared resource group.(To store Terraform state)
                      environmentServiceName: Azure Subscription ID.
              4. Run Pipeline. If this is Successful should create the following resources:
                      Azure Container Instance: Deployed by pulling container image from shared resources container registry.
                      Azure Key Vault.
                      Azure Database for PostgreSQL server.

                



