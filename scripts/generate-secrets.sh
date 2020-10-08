#!/bin/sh

help()
{
  echo "Generates a keypair for encryption tasks on the server, e.g. cookies"
  echo
  echo "Syntax: $0 [-r]"
  echo "  -h  show this help text"
  echo "  -r replace the secret named web-secret instead of creating it"
}

REPLACE=false

while getopts "hr" arg; do
  case $arg in
    h)
      help
      exit
      ;;
    r)
      REPLACE=true
      ;;
  esac
done

TMPDIR=$(mktemp -d)
openssl genrsa -out "$TMPDIR"/web-secret-private.pem -passout pass:coursiers -aes256 4096
openssl rsa -pubout -passin pass:coursiers -in "$TMPDIR"/web-secret-private.pem -out "$TMPDIR"/web-secret-public.pem

if [ "$REPLACE" = true ]; then
  kubectl create secret generic web-secret --from-file="$TMPDIR"/web-secret-private.pem --from-file "$TMPDIR"/web-secret-public.pem --dry-run=client -o yaml | kubectl replace secret web-secret -f - ;
else
  kubectl create secret generic web-secret --from-file="$TMPDIR"/web-secret-private.pem --from-file "$TMPDIR"/web-secret-public.pem ;
fi

rm -rf "$TMPDIR"
