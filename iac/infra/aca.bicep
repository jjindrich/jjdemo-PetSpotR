@description('Azure region to deploy resources into. Defaults to location of target resource group')
param location string = resourceGroup().location

@description('Name of the ACA environment. Defaults to a unique hash prefixed with "petspotr-"')
param acaName string = 'petspotr-aca'

@description('Azure Service Bus authorization rule name')
param serviceBusAuthorizationRuleName string = 'petspotr-${uniqueString(resourceGroup().id)}/Dapr'

@description('Azure Storage Account name')
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource serviceBusAuthorizationRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' existing = {
  name: serviceBusAuthorizationRuleName
}

resource aca 'Microsoft.App/managedEnvironments@2023-05-02-preview' = {
  name: acaName
  location: location
  properties: {
  }
}

resource images 'Microsoft.App/managedEnvironments/daprComponents@2023-05-01' = {
  parent: aca
  name: 'images'
  properties: {
    componentType: 'bindings.azure.blobstorage'
    version: 'v1'
    secrets:[
      {
        name: 'storagekey'
        value: storageAccount.listKeys().keys[0].value
      }
    ]
    metadata: [
      {
        name: 'accountName'
        value: storageAccountName
      }
      {
        name: 'accountKey'
        secretRef: 'storagekey'
      }
      {
        name: 'containerName'
        value: 'images'
      }
      {
        name: 'decodeBase64'
        value: 'true'
      }
    ]    
  }
}

resource pubsub 'Microsoft.App/managedEnvironments/daprComponents@2023-05-01' = {
  parent: aca
  name: 'pubsub'
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    secrets: [
      {
        name: 'servicebus'
        value: serviceBusAuthorizationRule.listKeys().primaryConnectionString
      }
    ]
    metadata: [
      {
        name: 'connectionString'
        secretRef: 'servicebus'
      }
    ]
  }
}

resource pets 'Microsoft.App/managedEnvironments/daprComponents@2023-05-01' = {
  parent: aca
  name: 'pets'
  properties: {
    componentType: 'state.azure.blobstorage'
    version: 'v1'
    secrets:[
      {
        name: 'storagekey'
        value: storageAccount.listKeys().keys[0].value
      }
    ]
    metadata: [
      {
        name: 'accountName'
        value: storageAccountName
      }
      {
        name: 'accountKey'
        secretRef: 'storagekey'
      }
      {
        name: 'containerName'
        value: 'pets'
      }
    ]    
  }
}

output acaEnvironment string = aca.name
