#! /bin/sh

curl -fsSL http://kube.muxiu1997.com/traefik-secret.yaml.age \
  | age -d -i $HOME/.local/share/age_secret_key \
  | sudo tee /var/lib/rancher/k3s/server/manifests/traefik-secret.yaml > /dev/null

curl -fsSL http://kube.muxiu1997.com/traefik-config.yaml \
  | sudo tee /var/lib/rancher/k3s/server/manifests/traefik-config.yaml > /dev/null
