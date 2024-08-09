#!/usr/bin/env sh

ROOT_HINTS=/run/unbound/root.hints
ROOT_KEY=/run/unbound/root.key
ROOT_HINTS_URL="https://www.internic.net/domain/named.root"

echo "Updating root hints..."
echo "Downloading $ROOT_HINTS_URL..."
curl -sSL -o "$ROOT_HINTS" "$ROOT_HINTS_URL"

# NOTE: running "unbound-anchor" twice
# see https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound-anchor.html#exit-code
# if updated (or initial setup), will return exit code 1
echo "Updating root key..."
unbound-anchor -a ${ROOT_KEY} -r ${ROOT_HINTS} || unbound-anchor -a ${ROOT_KEY} -r ${ROOT_HINTS}
