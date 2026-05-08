#!/bin/bash
# fetch-queues.sh
# Called by the Terraform external data source.
# Queries Genesys Cloud via the gc CLI and returns a JSON object
# where keys are sanitised queue names and values are queue IDs.
#
# The external data source requires the script to output a single
# JSON object to stdout with string values only.

set -e

# Query all queues, returning "name,id" per line
RAW=$(gc routing queues list --autopaginate --transformstr '{{- $list := . -}}{{- if kindIs "map" . -}}{{- if hasKey . "entities" -}}{{- $list = .entities -}}{{- end -}}{{- end -}}{{- range $list -}}{{printf "%s,%s\n" .name .id}}{{- end -}}')

# Build a JSON object from the CSV lines
# Keys: queue name (sanitised for Terraform resource addressing)
# Values: queue ID (UUID)
echo "$RAW" | awk -F',' '
BEGIN { printf "{" ; sep="" }
NF >= 2 && $1 != "" {
    # Sanitise the name: lowercase, replace non-alphanumeric with underscore
    name = tolower($1)
    gsub(/[^a-z0-9_]/, "_", name)
    # Remove leading/trailing underscores and collapse multiples
    gsub(/_+/, "_", name)
    gsub(/^_|_$/, "", name)
    id = $2
    printf "%s\"%s\":\"%s\"", sep, name, id
    sep = ","
}
END { printf "}" }
'
