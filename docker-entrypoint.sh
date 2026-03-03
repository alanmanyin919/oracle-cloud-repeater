#!/bin/sh

set -eu

seed_if_missing() {
    target="$1"
    template="$2"

    if [ ! -f "$target" ] && [ -f "$template" ]; then
        cp "$template" "$target"
        echo "Seeded $(basename "$target") from $(basename "$template")"
    fi
}

mkdir -p /app/resources /root/.oci

seed_if_missing /app/resources/main.tf /app/templates/main.tf.example
seed_if_missing /app/resources/config /app/templates/config.example
ln -sf /app/resources/config /root/.oci/config

exec "$@"
