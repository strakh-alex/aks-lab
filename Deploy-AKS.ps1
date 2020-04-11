param(
    [string]$TemplateFilePath = ".\template.json",
    [string]$TemplateFileParametersPath = ".\parameters.json",

    [string]$ResouceGroup = "DefaultResourceGroup-EUS2",
    [string]$Location = "eastus2"
)

$AKSadminUsername = Read-Host("> Enter AKS Admin Username")
$AKSadminKey = Read-Host("> Enter AKS Admin key")

$Parameters = Get-Content $TemplateFileParametersPath | ConvertFrom-Json
$Parameters.parameters.adminUsername = $AKSadminUsername
$Parameters.parameters.adminKey = $AKSadminKey


New-AzResourceGroup -Name $ResouceGroup -Location $Location

New-AzResourceGroupDeployment -ResourceGroupName $ResouceGroup -TemplateFile $TemplateFilePath -TemplateParameterFile $TemplateFileParametersPath -Mode Incremental
