# 
# AKS VMSS Cluster template: https://github.com/Azure/azure-quickstart-templates/tree/master/kubernetes-on-ubuntu-vmss
#
# The example of Kubernetes application: https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/
#

param(
    [string]$TemplateFilePath = ".\template.json",
    [string]$TemplateFileParametersPath = ".\parameters.json",

    [string]$ResouceGroup = "aks-lab",
    [string]$Location = "southcentralus",

    [string]$StorageAccount = "akslabsastrakh",
    [string]$StorageAccountSKU = "Standard_LRS",
    [string]$ShareName = "aks-lab-ms"
)

Login-AzAccount

$SP = az ad sp create-for-rbac --name akslabsp
$SPparameters = $SP | ConvertFrom-Json
$AKSadminUsername = Read-Host("> Enter AKS Admin Username")
$AKSadminKeyPath = Read-Host("> Enter path to public key")
$AKSadminKey = Get-Content $AKSadminKeyPath

$Parameters = Get-Content $TemplateFileParametersPath -Raw | ConvertFrom-Json
$Parameters.parameters.linuxAdminUsername.value = $AKSadminUsername
$Parameters.parameters.sshRSAPublicKey.value = $AKSadminKey.ToString()
$Parameters.parameters.servicePrincipalClientId.value = $SPparameters.appId
$Parameters.parameters.servicePrincipalClientSecret.value = $SPparameters.password
$Parameters | ConvertTo-Json | Set-Content $TemplateFileParametersPath -Encoding UTF8 -Force

New-AzResourceGroup -Name $ResouceGroup -Location $Location
New-AzResourceGroupDeployment -ResourceGroupName $ResouceGroup -TemplateFile $TemplateFilePath -TemplateParameterFile $TemplateFileParametersPath


New-AzStorageAccount -ResourceGroupName $ResouceGroup -Name $StorageAccount -SkuName $StorageAccountSKU -Location $Location
New-AzRmStorageShare -ResourceGroupName $ResouceGroup -StorageAccountName $StorageAccount -Name $ShareName
$StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $ResouceGroup -Name $StorageAccount)[0].Value

kubectl create secret generic azure-fileshare-secret --from-literal=azurestorageaccountname=$StorageAccount --from-literal=azurestorageaccountkey=$StorageKey


#az aks install-cli
az aks get-credentials --resource-group $ResouceGroup --name "aks101cluster"
kubectl.exe get nodes