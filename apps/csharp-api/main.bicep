targetScope = 'resourceGroup'

@description('The name of the environment that the app should be deployed to.')
param environmentName string
param location string = resourceGroup().location
param image string

param version string
param previous_version string

param previous_split int = 100
param latest_split int = 0

var revisionSuffix = replace(version, '.', '-')

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName
}

resource nextHop 'Microsoft.App/containerApps@2022-01-01-preview' existing = {
  name: 'go'
}

resource csharp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'csharp-api'
  location: location

  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      registries: []
      secrets: [
        {
          name: 'nexthop'
          value: 'https://${nextHop.properties.configuration.ingress.fqdn}/api/go'
        }
      ]
      activeRevisionsMode: 'multiple'
      ingress: {
        external: true
        targetPort: 80
        traffic: [
          {
            revisionName: 'previous'
            weight: 100
          }
          {
            revisionName: 'current'
            weight: 0
          }
      ]
      }
    }

    template: {
      revisionSuffix: revisionSuffix
      containers: [
        {
          name: 'csharp-api'
          image: image
          env: [
            {
              name: 'nextHop'
              secretRef: 'nexthop'
            }
            {
              name: 'version'
              value: version
            }
          ]
          resources: {
            cpu: json('.25')
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
