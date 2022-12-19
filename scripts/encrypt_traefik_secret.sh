#! /bin/sh

yq 'with(.data; map_values(@base64))' < traefik-secret.yaml | age -p -a -o traefik-secret.yaml.age
yq 'with(.data; map_values(. = ""))' < traefik-secret.yaml > traefik-secret.preview.yaml
