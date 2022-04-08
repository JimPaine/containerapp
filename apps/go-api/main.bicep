targetScope = 'resourceGroup'

@description('The name of the environment that the app should be deployed to.')
param environmentName string

param image string

resource environment 'Microsoft.Web/kubeEnvironments@2021-03-01' existing = {
  name: environmentName
}

resource go 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'go'
  location: resourceGroup().location

  properties: {
    kubeEnvironmentId: environment.id
    configuration: {
      registries: []
      ingress: {
        external: false
        targetPort: 80
      }
    }

    template: {
      containers: [
        {
          name: 'go-api'
          image: image
          resources: {
            cpu: '.25'
            memory: '.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
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
