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
  name: 'csharp'
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
        targetPort: 443
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
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
      revisionSuffix: version
    }
  }
}
