targetScope = 'resourceGroup'

@description('The name of the environment that the app should be deployed to.')
param environmentName string

param image string

param version string

resource environment 'Microsoft.Web/kubeEnvironments@2021-03-01' existing = {
  name: environmentName
}

resource nextHop 'Microsoft.Web/containerapps@2021-03-01' existing = {
  name: 'go'
}

resource csharp 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'csharp-api'
  location: resourceGroup().location

  properties: {
    kubeEnvironmentId: environment.id
    configuration: {
      registries: []
      secrets: [
        {
          name: 'nexthop'
          value: 'https://${nextHop.properties.configuration.ingress.fqdn}/api/go'
        }
      ]
      ingress: {
        external: true
        targetPort: 80
      }
    }

    template: {
      revisionSuffix: replace(version, '.', '-')
      containers: [
        {
          name: 'csharp-api'
          image: image
          env: [
            {
              name: 'nextHop'
              secretref: 'nexthop'
            }
            {
              name: 'version'
              value: version
            }
          ]
          resources: {
            cpu: '.25'
            memory: '.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 5
        rules: [
          {
            name: 'http-requests'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}
