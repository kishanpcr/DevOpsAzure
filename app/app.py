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
