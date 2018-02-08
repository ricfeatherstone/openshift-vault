#!/usr/bin/env bash

echo 'Logging in as developer'
oc login -u developer

oc project vault-cicd

echo 'Creating consul image build pipeline'
oc new-build https://github.com/ricfeatherstone/openshift-vault.git#feature/create-rhel-containers \
    --strategy=pipeline \
    --name=consul-image \
    --context-dir=openshift/pipelines/images/consul

echo 'Creating vault image build pipeline'
oc new-build https://github.com/ricfeatherstone/openshift-vault.git#feature/create-rhel-containers \
    --strategy=pipeline \
    --name=vault-image \
    --context-dir=openshift/pipelines/images/vault

echo 'Creating vault deployment pipeline'
oc new-build https://github.com/ricfeatherstone/openshift-vault.git#feature/create-rhel-containers \
    --strategy=pipeline \
    --name=vault-deployment \
    --context-dir=openshift/pipelines/deployment
