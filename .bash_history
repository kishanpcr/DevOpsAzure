# Create a basic web app
cat > app/app.py << 'EOF'
from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from Azure Container Instances!',
        'hostname': socket.gethostname(),
        'environment': os.getenv('ENVIRONMENT', 'production'),
        'deployed_by': 'Bicep + GitHub Actions'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

cat > app/requirements.txt << 'EOF'
Flask==3.0.0
gunicorn==21.2.0
EOF

cat > app/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
EOF

mkdir -p app
cat > app/app.py << 'EOF'
from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from Azure Container Instances!',
        'hostname': socket.gethostname(),
        'environment': os.getenv('ENVIRONMENT', 'production'),
        'deployed_by': 'Bicep + GitHub Actions'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

cat > app/requirements.txt << 'EOF'
Flask==3.0.0
gunicorn==21.2.0
EOF

cat > app/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
EOF

# Main Bicep file
cat > infra/main.bicep << 'EOF'
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
              port: 8080
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
          port: 8080
          protocol: 'TCP'
        }
      ]
    }
  }
}

output containerGroupId string = containerGroup.id
output containerGroupIpAddress string = containerGroup.properties.ipAddress.ip
output appUrl string = 'http://${containerGroup.properties.ipAddress.ip}:8080'
EOF

# Parameters file
cat > infra/main.bicepparam << 'EOF'
using './main.bicep'

param containerGroupName = 'devops-demo-app'
param containerImage = 'nginx:latest' // Will be overridden by GitHub Actions
param cpuCores = 1
param memoryInGb = 1
param environment = 'production'
EOF

mkdir -p infra
cat > infra/main.bicep << 'EOF'
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
              port: 8080
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
          port: 8080
          protocol: 'TCP'
        }
      ]
    }
  }
}

output containerGroupId string = containerGroup.id
output containerGroupIpAddress string = containerGroup.properties.ipAddress.ip
output appUrl string = 'http://${containerGroup.properties.ipAddress.ip}:8080'
EOF

cat > infra/main.bicepparam << 'EOF'
using './main.bicep'

param containerGroupName = 'devops-demo-app'
param containerImage = 'nginx:latest' // Will be overridden by GitHub Actions
param cpuCores = 1
param memoryInGb = 1
param environment = 'production'
EOF

# Create a resource group
az group create   --name rg-devops-demo   --location polandcentral
# Verify it was created
az group list -o table
# Validate Bicep template
az deployment group validate   --resource-group rg-devops-demo   --template-file infra/main.bicep   --parameters containerImage='nginx:latest'
# Do a what-if deployment (preview changes)
az deployment group what-if   --resource-group rg-devops-demo   --template-file infra/main.bicep   --parameters containerImage='nginx:latest'
# Actually deploy (with nginx for now)
az deployment group create   --resource-group rg-devops-demo   --template-file infra/main.bicep   --parameters containerImage='nginx:latest'   --name initial-deployment
# Get the container IP address
az container show   --resource-group rg-devops-demo   --name devops-demo-app   --query ipAddress.ip   --output tsv
# Or get all details
az deployment group show   --resource-group rg-devops-demo   --name initial-deployment   --query properties.outputs
az container show   --resource-group rg-devops-demo   --name devops-demo-7jzrkwuiwzy5w   --query ipAddress.ip   --output tsv
# Change all 8080 to 80
...
ports: [
]
...
ipAddress: {
}
...
nano infra/main.bicep
az deployment group create   --resource-group rg-devops-demo   --template-file infra/main.bicep   --parameters containerImage='nginx:latest'   --name redeploy-nginx
echo "# DevOpsAzure" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/kishanpcr/DevOpsAzure.git
git push -u origin main
git config --global user.name "kishanpcr"
git config --global user.email "warriorkishan@gmail.com"
git branch -m main
