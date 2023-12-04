@description('Address of the container registry where container resides')
param containerRegistry string

@description('Tag of container to use')
param containerTag string = 'latest'

@description('Id of ACA Environment')
param acaId string

param location string = resourceGroup().location

resource frontend 'Microsoft.App/containerApps@2022-11-01-preview' = {
  name: 'frontend'
  location: location
  properties: {
    environmentId: acaId
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        transport: 'auto'
      }
      secrets: []
      dapr:{
        enabled: true
        appPort: 80
        appId: 'frontend'
      }
    }
    template: {
      containers: [
        {
          name: 'frontend'
          image: '${containerRegistry}/frontend:${containerTag}'          
        }
      ]
    }
  }
}
