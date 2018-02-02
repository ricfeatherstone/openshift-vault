# Setup

## Create Projects and Deploy Jenkins

### Create the Projects

```bash
oc new-project vault-cicd
oc new-project vault-sandpit
oc new-project vault
```

### Grant Jenkins Service Account Access to Projects

```bash
for i in vault-sandpit vault
do
    oc policy add-role-to-user edit system:serviceaccount:vault-cicd:jenkins -n $i
done
```

### Create Vault SCC and Add to Service Accounts in Projects

```bash
oc create -f openshift/resources/cluster --as=system:admin
for i in vault-sandpit vault
do
    oc adm policy add-scc-to-user vault system:serviceaccount:$i:consul --as=system:admin
    oc adm policy add-scc-to-user vault system:serviceaccount:$i:vault --as=system:admin
done
```

###

```bash
for i in vault-sandpit vault
do
    oc project $i
    GOSSIP_ENCRYPTION_KEY=$(consul keygen)
    
    oc create secret generic consul \
      --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
      --from-file=ca/ca.pem \
      --from-file=ca/consul.pem \
      --from-file=ca/consul-key.pem
done
```

### Bootstrap Jenkins to include the [OpenShift Client DSL](https://github.com/openshift/jenkins-client-plugin)

```bash
oc project vault-cicd
oc new-build jenkins:2~https://github.com/ricfeatherstone/openshift-jenkins-bootstrap.git \
    --name=jenkins-bootstrap
```

### Launch Jenkins using the persistent template

```bash
oc project vault-cicd
oc new-app jenkins-persistent \
    -p NAMESPACE=$(oc project -q) \
    -p JENKINS_IMAGE_STREAM_TAG=jenkins-bootstrap:latest
```


```bash
oc project vault-cicd
oc new-build https://github.com/ricfeatherstone/openshift-vault.git#feature/create-rhel-containers \
    --strategy=pipeline \
    --name=test \
    --context-dir=openshift/pipelines/e2e
```


### Create the Consul Image Build Pipeline

```bash
oc project vault-cicd
oc new-build https://github.com/ricfeatherstone/openshift-vault.git#feature/create-rhel-containers \
    --strategy=pipeline \
    --name=consul-image \
    --context-dir=openshift/pipelines/images/consul
```

### Create the Vault Image Build Pipeline

```bash
oc project vault-cicd
oc new-build https://github.com/ricfeatherstone/openshift-vault.git#feature/create-rhel-containers \
    --strategy=pipeline \
    --name=vault-image \
    --context-dir=openshift/pipelines/images/vault
```
