// location of storage account
param location string = resourceGroup().location
param storageAccountName string

// storage account for storing images
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

//output storage account name
output storageAccountName string = storageAccount.name

