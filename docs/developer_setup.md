# Setup

## 


### Login as Developer

```bash
oc login -u developer
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

### Create the Deployment Pipeline

```bash
oc project vault-cicd
oc new-build https://github.com/ricfeatherstone/openshift-vault.git#feature/create-rhel-containers \
    --strategy=pipeline \
    --name=vault-deployment \
    --context-dir=openshift/pipelines/deployment
```





