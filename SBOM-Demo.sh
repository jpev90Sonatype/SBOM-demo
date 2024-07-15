#!/bin/bash

# Check if license file exists
if [ ! -f "license.lic" ]; then
    echo "Warning: license.lic file not found."
    exit 1
fi

# Create docker volumes for SBOM Manager and PostgreSQL
echo "Creating persistent volumes"
docker volume create --name sbom-sonatype-work
sleep 2
echo "Successfully created persistent volume for sonatype-work"
docker volume create --name sbom-sonatype-logs
sleep 2
echo "Successfully created persistent volume for sonatype-logs"
docker volume create --name sbom-postgres-db
sleep 2
echo "Successfully created persistent volume for postgres-db"

sleep 2
# Detect CPU architecture
ARCH=$(uname -m)

# Set the image version based on CPU architecture
if [ "$ARCH" = "x86_64" ]; then
  APP_IMAGE_VERSION="sonatype/nexus-iq-server:latest"
elif [[ "$ARCH" = "arm"* || "$ARCH" = "aarch64" ]]; then
  APP_IMAGE_VERSION="sonatypecommunity/nexus-iq-server:latest"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Display the chosen image version
echo "Using $APP_IMAGE_VERSION for architecture $ARCH."

# Create a temporary docker-compose file with the chosen image version
cat > docker-compose-temp.yml <<EOL

# The configurations included here are intended for testing
# purposes only.

services:
  # Database configuration
  SBOM-db:
    image: postgres:latest
    command: "postgres -c max_connections=200"
    environment:
      POSTGRES_DB: "sbom-db"
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "admin"
    ports:
      - "5432:5432"
    volumes:
      - "sbom-postgres-db:/var/lib/postgresql/data"
  SBOM-Manager:
    image: ${APP_IMAGE_VERSION}
    depends_on:
      - SBOM-db
    ports:
      - "9070:8070"
    volumes:
      - "./license.lic:/opt/sonatype/nexus-iq-server/license.lic"
      - "./config.yaml:/etc/nexus-iq-server/config.yml:delegated"
      - "sbom-sonatype-work:/sonatype-work"
      - "sbom-sonatype-logs:/var/log/nexus-iq-server"

volumes:
  sbom-sonatype-work:
    external: true
  sbom-sonatype-logs:
    external: true
  sbom-postgres-db:
    external: true
EOL

# Run docker-compose with the temporary file
docker-compose -f docker-compose-temp.yml up -d
sleep 2

# Clean up the temporary file after running
rm docker-compose-temp.yml
sleep 2

# Checks to see if SBOM Manager is ready
while true; do
    ison=$(curl -s --head --request GET http://localhost:9070/assets/index.html | grep "200 OK")
    if [[ -z "$ison" ]]; then
        echo "SBOM Manager not ready, retrying in 2 seconds..."
        sleep 2
    else
        echo "SBOM Manager is now ready on http://localhost:9070/"
        break
    fi
done

echo "Default Credentials Username: admin Password: admin123"
