param location string
param vnetName string = 'myVNet'
param vmsubnetName string = 'myVmSubnet'
param bastionsubnetName string = 'AzureBastionSubnet'
param vmName string = 'myVM'
param adminUsername string
@secure()
param adminPassword string

var vmsubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vmsubnetName)
var bastionsubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, bastionsubnetName)

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: vmsubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: bastionsubnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'myPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: 'myNIC'
  location: location
  dependsOn: [
    vnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: vmsubnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_E4s_v3'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-pro'
        version: 'latest'
      }
      osDisk: {
        name: 'osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 256
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-05-01' = {
  name: 'myBastionHost'
  location: location
  dependsOn: [
    vnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionsubnetRef
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'myNsg'
  location: location
  properties: {
    securityRules: [
    ]
  }
}
