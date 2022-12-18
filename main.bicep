@sys.description('The Web App name.')
@minLength(3)
@maxLength(100)
param appServiceAppName string 
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(100)
param appServicePlanName string 
@sys.description('The Storage Account name.')
@minLength(3)
@maxLength(100)
param storageAccountName string
@allowed([
  'nonprod'
  'prod'
  ])
param environmentType string = 'nonprod'
param location string = resourceGroup().location
param difTypes array = [ 'FE', 'BE' ]
@secure()
param dbhost string
@secure()
param dbuser string
@secure()
param dbpass string
@secure()
param dbname string


var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'  

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
    name: storageAccountName
    location: location
    sku: {
      name: storageAccountSkuName
    }
    kind: 'StorageV2'
    properties: {
      accessTier: 'Hot'
    }
  }

  module appService 'mods/appMod.bicep' = [  for i in range(0,2): {
    name: 'appService${difTypes[i]}'
    params: {
      location: location
      appServiceAppName:'${appServiceAppName}${difTypes[i]}'
      appServicePlanName: appServicePlanName
      environmentType: environmentType
      dbhost: dbhost
      dbuser: dbuser
      dbpass: dbpass
      dbname: dbname
    }
  }]


  output appServiceAppHostName array = [ for i in range(0,2): {
    name: 'appService${difTypes[i]}'
    value: appService[i].outputs.appServiceAppHostName
  }]
    
    