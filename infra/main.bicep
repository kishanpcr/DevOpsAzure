@description('The name of the container group')
param containerGroupName string = 'devops-demo-${uniqueString(resourceGroup().id)}'

@description('Container image to deploy')
param containerImage string

@description('The number of CPU cores to allocate')
param cpuCores int = 1

@description('The amount of memory to allocate in gigabytes')
param memoryInGb int = 1

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name')
param environment string = 'production'

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: 'web-app'
        properties: {
          image: containerImage
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
          environmentVariables: [
            {
              name: 'ENVIRONMENT'
              value: environment
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
  }
}

output containerGroupId string = containerGroup.id
output containerGroupIpAddress string = containerGroup.properties.ipAddress.ip
output appUrl string = 'http://${containerGroup.properties.ipAddress.ip}:80'
