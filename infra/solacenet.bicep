// SolaceNet Dashboard - Azure Static Web App Deployment Bicep Template

param siteName string = 'solacenet-dashboard'
param location string = 'Global'
param repositoryUrl string
@secure()
param repositoryToken string
param branch string

// Fallback logic for location
var effectiveLocation = location == 'Global' ? 'West Europe' : location

// Add resources for Application Insights, Log Analytics Workspace, and Key Vault
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${siteName}-appinsights'
  location: effectiveLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: '${siteName}-loganalytics'
  location: effectiveLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: 'solacenetkv'
  location: effectiveLocation
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: '00000000-0000-0000-0000-000000000000' // Replace with actual object ID
        permissions: {
          secrets: [ 'get', 'list', 'set', 'delete' ]
        }
      }
    ]
  }
}

// Add Static Web App with Managed Identity
resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: siteName
  location: effectiveLocation
  properties: {
    repositoryUrl: repositoryUrl
    branch: branch
    buildProperties: {
      appLocation: '/'
      outputLocation: 'dist'
    }
    repositoryToken: repositoryToken
  }
}

// Update Key Vault access policies to include Static Web App's managed identity
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: staticWebApp.identity.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ]
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: 'solacenet-sql-server'
  location: effectiveLocation
  properties: {
    administratorLogin: 'adminUser'
    administratorLoginPassword: 'securePassword123!'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  name: 'solacenet-db'
  parent: sqlServer
  location: resourceGroup().location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB
    requestedBackupStorageRedundancy: 'Local'
  }
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

output webAppUrl string = staticWebApp.properties.defaultHostname
