// SolaceNet Dashboard - Azure Static Web App Deployment Bicep Template

param siteName string = 'solacenet-dashboard'
param location string = 'East US'
param repositoryUrl string = 'https://github.com/YOUR_ORG/solacenet-dashboard'
param branch string = 'main'

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
      appLocation: "/"
      outputLocation: "dist"
    }
  }
}

output webAppUrl string = staticWebApp.properties.defaultHostname