#! /bin/sh

sudo -v

curl -fsSL https://muxiu1997.github.io/cloud-server-services/traefik-secret.yaml.age \
  | age -d \
  | sudo tee /var/lib/rancher/k3s/server/manifests/traefik-secret.yaml > /dev/null

curl -fsSL https://muxiu1997.github.io/cloud-server-services/traefik-github-oauth-server.yaml \
  | sudo tee /var/lib/rancher/k3s/server/manifests/traefik-github-oauth-server.yaml > /dev/null

curl -fsSL https://muxiu1997.github.io/cloud-server-services/traefik-config.yaml \
  | sudo tee /var/lib/rancher/k3s/server/manifests/traefik-config.yaml > /dev/null
