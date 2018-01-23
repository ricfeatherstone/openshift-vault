# Openshift Vault

This repository contains configuration to run [HashiCorp Vault](https://www.vaultproject.io/) on a local 
[OpenShift](https://www.openshift.com/) cluster, launched with the 
[OC Cluster Wrapper](https://github.com/openshift-evangelists/oc-cluster-wrapper) and should work with OpenShift 
versions 3.6 and 3.7.

This is intended for bringing up a Vault cluster locally for experimentation and is not intended for production use.

The [HashiCorp Consul](https://www.consul.io/) configuration is based on Kelsey Hightower's 
[Consul-on-Kubernetes](https://github.com/kelseyhightower/consul-on-kubernetes) repository with changes due to its role
as a Vault backend (e.g. disabling HTTP and DNS etc.).

## Pre Requisites

* Install the [Consul Client](https://www.consul.io/downloads.html)
* Install the [Vault Client](https://www.vaultproject.io/downloads.html)
* Install [jq](https://stedolan.github.io/jq/)

## Launching

1.  Run `./scripts/generate-tls-certs.sh` to generate the Consul server and client certs in the `ca` folder.
2.  Run `./scripts/create-resources.sh` to generate the OpenShift resources
