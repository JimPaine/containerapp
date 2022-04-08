targetScope = 'resourceGroup'

var suffix = uniqueString(resourceGroup().id)
param location string = resourceGroup().location

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
        name: 'controlplane'
        properties: {
          addressPrefix: '10.0.8.0/21'
        }
      }
      {
        name: 'app'
        properties: {
          addressPrefix: '10.0.16.0/21'
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
    internalLoadBalancerEnabled: true
    containerAppsConfiguration: {
      controlPlaneSubnetResourceId: vnet.properties.subnets[0].id
      appSubnetResourceId: vnet.properties.subnets[1].id
      internalOnly: false
    }
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logs.properties.customerId
        sharedKey: logs.listKeys().primarySharedKey
      }
    }
  }
}

output environment_id string = environment.id
