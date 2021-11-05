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
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'app'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
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
    type: 'Managed'
    internalLoadBalancerEnabled: true
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logs.properties.customerId
        sharedKey: listKeys('${logs.type}/${logs.name}', logs.apiVersion).primarySharedKey
      }
    }
  }
}

resource csharp 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'csharp'
  location: location

  properties: {
    kubeEnvironmentId: environment.id
    configuration: {
      secrets: [
        {
          name: 'nexthop'
          value: 'https://${go.properties.configuration.ingress.fqdn}/api/go'
        }
      ]
      registries: []
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {

      containers: [
        {
          name: 'chain-csharp'
          image: 'ghcr.io/jimpaine/chain-csharp:0.1.21'
          env: [
            {
              name: 'nextHop'
              secretref: 'nexthop'
            }
            {
              name: 'version'
              value: '0.1.21'
            }
          ]
          resources: {
            cpu: '.25'
            memory: '.5Gi'
          }
        }
      ]
    }
  }
}

resource go 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'go'
  location: location

  properties: {
    kubeEnvironmentId: environment.id
    configuration: {
      secrets: []
      registries: []
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          name: 'chain-go'
          image: 'ghcr.io/jimpaine/chain-go:0.1.7'
          resources: {
            cpu: '.25'
            memory: '.5Gi'
          }
          env: [
            {
              name: 'VERSION'
              value: '0.1.7'
            }
          ]
        }
      ]
    }
  }
}



output entry string = csharp.properties.configuration.ingress.fqdn
