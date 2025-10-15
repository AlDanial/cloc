/*
 https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/file
 */
metadata description = 'Creates a storage account and a web app'

@description('The prefix to use for the storage account name.')
@minLength(3)
@maxLength(11)
param storagePrefix string

param storageSKU string = 'Standard_LRS'
param location string = resourceGroup().location

    // Generate a unique name for the storage account
var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

// Create a storage account
resource stg 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

// Deploy the web app module
module webModule './webApp.bicep' = {
  name: 'webDeploy'
  params: {
    skuName: 'S1'
    location: location
  }
}
