# SBOM Manager Local Demo Script

This script makes it easy to spin up a local instance of SBOM Manager using docker.
Both containers have persistent volumes which will retain your data if the containers are stopped.
The script detects your CPU architecture and pulls the correct image for optimal stability (ARM/amd64)

## Prerequisites:
* Docker - Installed and running
* Docker compose - Installed (built-in to Docker, docker-compose is depreciated and not supported)
* Git credential manager is required for cloning private repositories (`brew install --cask git-credential-manager`)

## Instructions:
1. Create and move to a suitable directory on your system for the script (e.g. `mkdir ~/scripts && cd ~/scripts`)
2. Clone the se-scripts repository `git clone https://github.com/sonatype/se-scripts.git`
3. Change directory to the SBOM Manager script `cd ltaylor/SBOM\ Local\ Demo/`
4. Download a new SBOM license from the [Product Licensing](https://sonatype.atlassian.net/wiki/x/iQCYAg) confluence page (Must be the SBOM Manager/Lifecycle on-prem  license from 'SBOM Manager' table)
5. Rename license file to license.lic and place it in the directory containing SBOM-Demo.sh
6. run `chmod u+x ./SBOM-Demo.sh`
7. run `./SBOM-Demo.sh`
8. browse to http://localhost:9070
9. Login with the deafult credentials (admin, admin123)
10. That's it...

## Troubleshooting:
1. If IQ starts but asks you for a license after you have logged in then try and manually install the license
	* If this doesn't work, the license is likely expired or you forgot to add/rename the license to license.lic
	* download a new license from the [Product Licensing](https://sonatype.atlassian.net/wiki/x/iQCYAg) page
	* rename to license.lic and place in the same directory as the script and try again
2. If all else fails send a carrier pigeon or contact Laurence on slack

## Useful Commands:
1. To stop your SBOM instance you should stop the front end (Nexus IQ) first and back-end (Database) last:
    * `docker stop sbomlocaldemo-SBOM-Manager-1`
	* `docker stop sbomlocaldemo-SBOM-db-1` 
2. To start your SBOM instance if you have previously stopped (done in reverse of stopping) it:
	* `docker start sbomlocaldemo-SBOM-db-1` 
	* `docker start sbomlocaldemo-SBOM-Manager-1`
3. If you want to completely remove everything:
	* `docker stop sbomlocaldemo-SBOM-Manager-1 sbomlocaldemo-SBOM-db-1`
	* `docker rm sbomlocaldemo-SBOM-Manager-1 sbomlocaldemo-SBOM-db-1`
	* `docker volume rm sbom-sonatype-work sbom-sonatype-logs sbom-postgres-db`
