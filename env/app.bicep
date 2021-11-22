// resource csharp 'Microsoft.Web/containerapps@2021-03-01' = {
//   name: 'csharp'
//   location: location

//   properties: {
//     kubeEnvironmentId: environment.id
//     configuration: {
//       secrets: [
//         {
//           name: 'nexthop'
//           value: 'https://${go.properties.configuration.ingress.fqdn}/api/go'
//         }
//       ]
//       registries: []
//       ingress: {
//         external: true
//         targetPort: 80
//       }
//     }
//     template: {

//       containers: [
//         {
//           name: 'chain-csharp'
//           image: 'ghcr.io/jimpaine/chain-csharp:0.1.21'
//           env: [
//             {
//               name: 'nextHop'
//               secretref: 'nexthop'
//             }
//             {
//               name: 'version'
//               value: '0.1.21'
//             }
//           ]
//           resources: {
//             cpu: '.25'
//             memory: '.5Gi'
//           }
//         }
//       ]
//     }
//   }
// }

// resource go 'Microsoft.Web/containerapps@2021-03-01' = {
//   name: 'go'
//   location: location

//   properties: {
//     kubeEnvironmentId: environment.id
//     configuration: {
//       secrets: []
//       registries: []
//       ingress: {
//         external: true
//         targetPort: 80
//       }
//     }
//     template: {
//       containers: [
//         {
//           name: 'chain-go'
//           image: 'ghcr.io/jimpaine/chain-go:0.1.7'
//           resources: {
//             cpu: '.25'
//             memory: '.5Gi'
//           }
//           env: [
//             {
//               name: 'VERSION'
//               value: '0.1.7'
//             }
//           ]
//         }
//       ]
//     }
//   }
// }

// output entry string = csharp.properties.configuration.ingress.fqdn
