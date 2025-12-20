Retail Application – End-to-End Gold Standard Deployment (v2)

This package automates the complete deploy.sh workflow using
Ansible (orchestration) and Terraform (cluster state),
in the exact same sequence as the shell script.

Run:
ansible-playbook site.yaml \
  -e oc_token=<OC_TOKEN> \
  -e oc_server=<OC_SERVER> \
  -e docker_username=<DOCKER_USERNAME> \
  -e docker_password=<DOCKER_PASSWORD>
