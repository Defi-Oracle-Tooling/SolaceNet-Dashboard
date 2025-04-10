// SolaceNet Dashboard - Azure Static Web App Deployment Bicep Template

param siteName string = 'solacenet-dashboard'
param location string = 'West Europe'
param repositoryUrl string = 'https://github.com/Defi-Oracle-Tooling/solacenet-dashboard'
param branch string = 'main'

// Add resources for Application Insights, Log Analytics Workspace, and Key Vault
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${siteName}-appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: '${siteName}-loganalytics'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: '${siteName}-keyvault'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: siteName
  location: location
  
  properties: {
    repositoryUrl: repositoryUrl
    branch: branch
    buildProperties: {
      appLocation: '/'
      outputLocation: 'dist'
    }
  }
}

// Add Azure SQL Database resource
resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: 'solacenet-sql-server'
  location: location
  properties: {
    administratorLogin: 'adminUser'
    administratorLoginPassword: 'securePassword123!'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  location: resourceGroup().location
  name: 'solacenet-database'
  parent: sqlServer
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB
  }
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 10
  }
}

output webAppUrl string = staticWebApp.properties.defaultHostname
