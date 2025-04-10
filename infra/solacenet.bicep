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
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: repositoryUrl
    branch: branch
    buildProperties: {
      appLocation: '/'
      outputLocation: 'dist'
    }
  }
}

output webAppUrl string = staticWebApp.properties.defaultHostname
