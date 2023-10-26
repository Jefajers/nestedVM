#parameters
$rgname = 'nested-rg'
$vmName = 'myVM'
$location = 'swedencentral'
$adminUsername = 'localadmin'
$adminPassword = Read-Host -Prompt 'Input the user password' -AsSecureString
#Deploy ResourceGroup
Write-Output -InputObject "Initiating ResourceGroup...$(get-date)"
New-AzResourceGroup -Name $rgname -Location $location
Start-Sleep -Seconds 5
#Deploy Environment
Write-Output -InputObject "Initiating Resources...$(get-date)"
New-AzResourceGroupDeployment -Name 'NestedVmDeploy' -ResourceGroupName $rgname -TemplateFile .\main.bicep -Location $location -vmName $vmName -adminUsername $adminUsername -adminPassword $adminPassword
Start-Sleep -Seconds 5
$resizecommand = 'Resize-Partition -DriveLetter C -Size $(Get-PartitionSupportedSize -DriveLetter C).SizeMax'
az vm run-command invoke  --command-id RunPowerShellScript -g $rgname --name $vmName --scripts $resizecommand
#Enable Hyper-v feature
Write-Output -InputObject "Initiating Hyper-V install...$(get-date)"
$command = 'Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart'
az vm run-command invoke  --command-id RunPowerShellScript -g $rgname --name $vmName --scripts $command
az vm restart -g $rgname -n $vmName