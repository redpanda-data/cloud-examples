REGION=eastus2 DRY_RUN=true ./create_resource_groups.sh 60fc0bed-3072-4c53-906a-d130a934d520
Setting subscription: 60fc0bed-3072-4c53-906a-d130a934d520 ...
az group create --location eastus2 --name redpanda-rg
az group create --location eastus2 --name network-rg
az group create --location eastus2 --name storage-rg
az group create --location eastus2 --name iam_rg

