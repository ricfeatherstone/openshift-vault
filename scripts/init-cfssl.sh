#!/usr/bin/env bash

DIR=cfssl

if [ ! -d cfssl ]; then
  mkdir $DIR
  cfssl print-defaults config > $DIR/ca-config.json
  cfssl print-defaults csr > $DIR/ca-csr.json
  cfssl print-defaults csr > $DIR/consul-csr.json
fi