#! /bin/sh

yq 'with(.data; map_values(@base64))' < secret.yml | age -p -a -o secret.yml.age
yq 'with(.data; map_values(. = ""))' < secret.yml > secret.preview.yml
