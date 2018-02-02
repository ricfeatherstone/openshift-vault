#!/usr/bin/env bash

PROJECT=vault

oc create -f openshift/resources/cluster --as=system:admin

oc adm policy add-scc-to-user consul system:serviceaccount:$PROJECT:consul --as=system:admin
oc adm policy add-scc-to-user vault system:serviceaccount:$PROJECT:vault --as=system:admin

oc new-project $PROJECT

oc new-build https://github.com/ricfeatherstone/openshift-vault#feature/create-rhel-containers --context-dir=docker/centos/consul --name=consul
oc set image-lookup consul

oc new-build https://github.com/ricfeatherstone/openshift-vault#feature/create-rhel-containers --context-dir=docker/centos/vault --name=vault
oc set image-lookup vault

sleep 120

#
# Consul
#

GOSSIP_ENCRYPTION_KEY=$(consul keygen)

oc create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=ca/ca.pem \
  --from-file=ca/consul.pem \
  --from-file=ca/consul-key.pem

oc create -f openshift/resources/consul

#
# Vault
#

oc create secret generic consul-client \
  --from-file=ca/ca.pem \
  --from-file=ca/consul-client.pem \
  --from-file=ca/consul-client-key.pem

oc create -f openshift/resources/vault

#HOST=$(oc get route vault --template '{{ .spec.host }}' | sed 's/-'"$PROJECT"'*//')
#oc patch route vault -p "{ \"spec\": { \"host\": \""$HOST"\" } }"
