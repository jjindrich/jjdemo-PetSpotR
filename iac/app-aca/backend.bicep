@description('Address of the container registry where container resides')
param containerRegistry string

@description('Tag of container to use')
param containerTag string = 'latest'

@description('Id of ACA Environment')
param acaId string

@description('Service Bus Authorization Rule connection string')
@secure()
param serviceBusConnectionString string

param location string = resourceGroup().location

resource backend 'Microsoft.App/containerApps@2022-11-01-preview' = {
  name: 'backend'
  location: location
  properties: {
    environmentId: acaId
    configuration: {
      secrets: [
        {
          name: 'servicebus'
          value: serviceBusConnectionString
        }
      ]
      dapr:{
        enabled: true
        appPort: 5000
        appId: 'backend'
      }
    }
    template: {
      containers: [
        {
          name: 'backend'
          image: '${containerRegistry}/backend:${containerTag}'          
          env: [
            {
              name: 'SERVICEBUS_CONNECTIONSTRING'
              secretRef: 'servicebus'
            }
          ]
        }
      ]
    }
  }
}
