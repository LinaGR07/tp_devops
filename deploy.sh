#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/infra"

terraform init
terraform plan -out=tfplan
terraform apply tfplan

echo "API disponible sur http://localhost:8080"
