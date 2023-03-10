param location string = resourceGroup().location
param appServiceAppName string
param appServicePlanName string
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

param dbhost string
param dbuser string
param dbpass string
param dbname string

var appServicePlanSkuName = (environmentType == 'prod' ) ? 'P2V3' : 'B1'

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: appServicePlanSkuName
  }
}


resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
name: appServiceAppName
location: location


properties: {
  serverFarmId: appServicePlan.id
  httpsOnly: true
  siteConfig: {
    linuxFxVersion: 'python|3.10'
    appSettings: [
      {
      name: 'DBUSER'
      value: dbuser
      }

      {
      name: 'DBPASS'
      value: dbpass
      }

      {
      name: 'DBHOST'
      value: dbhost
      }

      {
      name: 'DBNAME'
      value: dbname
      }


    ]
 }
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
