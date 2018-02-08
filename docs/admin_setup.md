# Administration: Setup Projects

## Create Projects and Deploy Jenkins


### Login as Administrator

```bash
oc login -u admin
```
### Create the Projects

```bash
oc new-project vault-cicd
oc new-project vault-sandpit
oc new-project vault
```

### Bootstrap Jenkins to include the [OpenShift Client DSL](https://github.com/openshift/jenkins-client-plugin)

```bash
oc project vault-cicd
oc new-build jenkins:2~https://github.com/ricfeatherstone/openshift-jenkins-bootstrap.git \
    --name=jenkins-bootstrap \
    --context-dir='s2i/bootstrap'
```

### Launch Jenkins using the persistent template

```bash
oc project vault-cicd
oc new-app jenkins-persistent \
    -p NAMESPACE=$(oc project -q) \
    -p JENKINS_IMAGE_STREAM_TAG=jenkins-bootstrap:latest
```

Make sure Jenkins is up and there are no issues with the installed plugins before continuing.

### Grant Jenkins Service Account Edit Access to Projects

```bash
for i in vault-sandpit vault
do
    oc policy add-role-to-user edit system:serviceaccount:vault-cicd:jenkins -n $i
done
```

### Grant Developer Edit Access to Vault CICD Project

```bash
oc policy add-role-to-user edit developer -n vault-cicd
```

### Create Vault SCC and Add to Service Accounts in Projects

```bash
oc create -f openshift/resources/cluster
for i in vault-sandpit vault
do
    oc adm policy add-scc-to-user vault system:serviceaccount:$i:consul
    oc adm policy add-scc-to-user vault system:serviceaccount:$i:vault
done
```
