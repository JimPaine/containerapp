targetScope = 'subscription'

param location string = 'northeurope'

var suffix = uniqueString(subscription().id)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-containerapps-${suffix}'
  location: location
}

module environment './environment.bicep' = {
  name: 'environment'
  scope: rg
}
