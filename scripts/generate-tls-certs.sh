#!/usr/bin/env bash

[ -d ca ] || mkdir ca

cd ca

cfssl gencert -initca ../cfssl/ca-csr.json | cfssljson -bare ca

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=../cfssl/ca-config.json \
  -profile=default \
  ../cfssl/consul-csr.json | cfssljson -bare consul

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=../cfssl/ca-config.json \
  -profile=default \
  ../cfssl/consul-client-csr.json | cfssljson -bare consul-client
