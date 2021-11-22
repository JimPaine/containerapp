# containerapp

[C# http api](https://github.com/jimpaine/chain-csharp)
[go http api](https://github.com/jimpaine/chain-go)

## Done

- Bicep IaC
- Deployment of 2 apps
- Go http api with internal ingress
- C# http api with external ingress
- C# http has dependency on the go api
- Configuration via Bicep to set env variable
- Configuration via Bicep to set env variable via Secret
- C# update revision via app workflow
- C# update env variables via app workflow

## TODO
- clean up Bicep
- queue example
- akv for secrets ?
- blue green
- roll back revision
- split traffic
- end to end tls
- ui
- workflows
- scale to and from 0
- repo structure?
    - iac repo with placeholder apps
    - app repos use az cli to deploy into container app
    - app repo then handles rotation of revisions
    - revision strategy set in iac repo
- Trigger app workflow to deploy latest from IaC deploy
- switch apps to no or placeholder containers

# Missing
- MSI
- private endpoints
- vnet integration
- view of current instances

# Broken
- http scale rule ignores max
- http scale rule ignores min