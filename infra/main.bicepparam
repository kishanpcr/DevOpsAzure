using './main.bicep'

param containerGroupName = 'devops-demo-app'
param containerImage = 'nginx:latest' // Will be overridden by GitHub Actions
param cpuCores = 1
param memoryInGb = 1
param environment = 'production'
