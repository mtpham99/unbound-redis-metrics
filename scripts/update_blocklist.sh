#!/usr/bin/env sh

URLS_FILE="/etc/unbound.d/blocklist_urls.txt"
BLOCK_CONF="/etc/unbound.d/blocklist.conf"
TEMP_FILE=$(mktemp)

echo "Updating blocklists..."

if [ ! -f $URLS_FILE ]; then
  echo "Blocklist urls file ($URLS_FILE) missing!"
  exit 1
fi

while IFS= read -r URL; do
  if [ -n "$URL" ]; then
    echo "Downloading $URL..."
    curl -sSL "$URL" | \
               grep ^0.0.0.0 - | \
               sed 's/ #.*$//;
               s/^0.0.0.0 \(.*\)/local-zone: "\1" always_nxdomain/' \
               >> "$TEMP_FILE"
  fi
done < $URLS_FILE

# remove duplicates
sort -u "$TEMP_FILE" -o "$TEMP_FILE"

echo "New blocklist contains $(wc -l < "$TEMP_FILE") hosts..."

mv "$TEMP_FILE" "$BLOCK_CONF"
