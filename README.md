# containerapp
## Done

- Bicep IaC
- Deployment of 2 apps
- Go http api with internal ingress
- C# http api with external ingress
- C# http has dependency on the go api
- Configuration via Bicep to set env variable
- Configuration via Bicep to set env variable via Secret

## TODO
- C# update revision via app workflow
- C# update env variables via app workflow
- queue example
- akv for secrets ?
- blue green
- roll back revision
- split traffic
- end to end tls
- ui
- workflows
- scale to and from 0

# Missing / Not working
- MSI
- private endpoints
- vnet integration
- view of current instance

# Broken / Suspect

can't deploy an app named 'csharp' all of a sudden have tried delete everything including the environment, rolled back recent changes still nothing. change the name to csharp-api and boom it works.

revisionSuffix after trying to set to semantic version number the app has stopped deploying, says it has deployed but no new revision turned up. deployment step shows all items as null. Removed the revision suffix and still broken. Change to basic string no numbers or specials and it works again.