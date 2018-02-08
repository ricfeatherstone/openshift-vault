#!/usr/bin/env bash

echo 'Logging in as admin'
oc login -u admin <<EOF
password
EOF

for i in vault vault-cicd
do
    echo "Creating project $i"
    oc new-project $i
done

echo 'Bootstrapping Jenkins image with OpenShift Client DSL'
oc new-build jenkins:2~https://github.com/ricfeatherstone/openshift-jenkins-bootstrap.git \
    --name=jenkins-bootstrap \
    --context-dir='s2i/bootstrap'
sleep 15

echo 'Launching Jenkins from persistent template'
oc new-app jenkins-persistent \
    -p NAMESPACE=$(oc project -q) \
    -p JENKINS_IMAGE_STREAM_TAG=jenkins-bootstrap:latest

echo 'Creating vault SCC'
oc create -f openshift/resources/cluster

echo "Adding edit role to jenkins service account in project vault"
oc policy add-role-to-user edit system:serviceaccount:vault-cicd:jenkins -n vault

echo "Adding vault SCC to consul service account in project vault"
oc adm policy add-scc-to-user vault system:serviceaccount:vault:consul

echo "Adding vault SCC to vault service account in project vault"
oc adm policy add-scc-to-user vault system:serviceaccount:vault:vault

echo 'Adding admin role to developer in project vault-cicd'
oc policy add-role-to-user admin developer -n vault-cicd
