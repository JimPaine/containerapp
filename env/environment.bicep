targetScope = 'resourceGroup'

var suffix = uniqueString(resourceGroup().id)
var location = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: 'vnet'
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'control'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'app'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource logs 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'logs${suffix}'
  location: location

  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource environment 'Microsoft.Web/kubeEnvironments@2021-03-01' = {
  name: 'environment'
  location: location

  properties: {
    type: 'managed'
    // internalLoadBalancerEnabled: true
    // containerAppsConfiguration: {
    //   controlPlaneSubnetResourceId: vnet.properties.subnets[0].id
    //   platformReservedCidr: '10.1.254.0/24'
    //   platformReservedDnsIP: '10.1.254.253'
    //   appSubnetResourceId: vnet.properties.subnets[1].id
    // }
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logs.properties.customerId
        sharedKey: listKeys('${logs.type}/${logs.name}', logs.apiVersion).primarySharedKey
      }
    }
  }
}

output environment_id string = environment.id
