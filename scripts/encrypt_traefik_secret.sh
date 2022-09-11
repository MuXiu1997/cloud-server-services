#! /bin/sh

age -R $HOME/.local/share/age_public_key -a -o traefik-secret.yaml.age -- traefik-secret.yaml
