targetScope = 'resourceGroup'

@description('The name of the environment that the app should be deployed to.')
param environmentName string

param image string

resource environment 'Microsoft.Web/kubeEnvironments@2021-03-01' existing = {
  name: environmentName
}

resource nextHop 'Microsoft.Web/containerapps@2021-03-01' existing = {
  name: 'go'
}

resource csharp 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'csharp'
  location: resourceGroup().location

  properties: {
    kubeEnvironmentId: environment.id
    configuration: {
      registries: []
      secrets: [
        {
          name: 'nexthop'
          value: 'https://${go.properties.configuration.ingress.fqdn}/api/go'
        }
      ]
      ingress: {
        external: true
        targetPort: 80
      }
    }

    template: {
      containers: [
        {
          name: 'csharp-api'
          image: image
          env: [
            {
              name: 'nextHop'
              secretref: 'nexthop'
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
