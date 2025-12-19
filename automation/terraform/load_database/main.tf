terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}


resource "null_resource" "load_database" {
  triggers = {
    namespace = var.namespace
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e

      echo "Locating PostgreSQL pod..."
      POD=$(oc get pod -n ${var.namespace} -l app=retail-postgres -o jsonpath='{.items[0].metadata.name}')

      if [ -z "$POD" ]; then
        echo "PostgreSQL pod not found"
        exit 1
      fi

      echo "Using pod: $POD"
      echo "Importing database..."

      oc exec -n ${var.namespace} $POD -- \
        psql -U retail_user -d retaildb -f /tmp/full_dump.sql

      echo "Database load completed successfully"
    EOT
  }
}

