// Application -----------------------------------------

@description('URL of the container registry. Defaults to "petspotr.azurecr.io"')
param registryUrl string = 'petspotr.azurecr.io'

@description('Name of the AKS cluster. Defaults to a unique hash prefixed with "petspotr-"')
param acaName string = 'petspotr-aca'

@description('Azure Storage Account name')
param storageAccountName string = 'petspotr${uniqueString(resourceGroup().id)}'

@description('Azure Service Bus authorization rule name')
param serviceBusAuthorizationRuleName string = 'petspotr-${uniqueString(resourceGroup().id)}/Dapr'

param location string = resourceGroup().location

resource aca 'Microsoft.App/managedEnvironments@2023-05-02-preview' existing = {
  name: acaName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource serviceBusAuthorizationRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' existing = {
  name: serviceBusAuthorizationRuleName
}

module frontend 'app-aca/frontend.bicep' = {
  name: 'frontend'
  params: {
    containerRegistry: registryUrl
    acaId: aca.id
    location: location
  }
}

module backend 'app-aca/backend.bicep' = {
  name: 'backend'
  params: {
    containerRegistry: registryUrl
    acaId: aca.id
    serviceBusConnectionString: serviceBusAuthorizationRule.listKeys().primaryConnectionString
    location: location
  }
}
