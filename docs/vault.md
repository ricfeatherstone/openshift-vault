# Vault

Because Vault is using OpenShift generated certs, running commands
locally within the container must use the `-tls-skip-verify` flag
as the cert has the following SANs and is not valid for `127.0.0.1`

* vault.vault.svc
* vault.vault.svc.cluster.local

## Initialise using the command line

```

vault status -tls-skip-verify
vault init -key-shares=5 -key-threshold=3 -tls-skip-verify

```

### Output

```

Unseal Key 1: BE0NwTHrnA7YeMvOtrwevJhjli4LvoOYkt23grMsMadG
Unseal Key 2: 0adfVJQDg6oJo2Q6x0fKbzzob7LW30jg+pzTi3hA5P1R
Unseal Key 3: BVkIHlFyX0n1SO9TUbljr3EaIpt10+0FHCd4OO3+ZQPM
Unseal Key 4: u3VtAqtvCnUTvVdedmmFMFnSMbyfN/87M2a2oplnHsjh
Unseal Key 5: 457higVYVwGQm8FAmdclnCxodntnZpMUIQHvfH8udGVM
Initial Root Token: 39a8f6ce-9327-c6a6-b72d-704d641d949e

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your vault will remain permanently sealed.


```

## Unseal the Vault (must be performed on each pod)

```

vault unseal -tls-skip-verify BE0NwTHrnA7YeMvOtrwevJhjli4LvoOYkt23grMsMadG
vault unseal -tls-skip-verify u3VtAqtvCnUTvVdedmmFMFnSMbyfN/87M2a2oplnHsjh
vault unseal -tls-skip-verify BVkIHlFyX0n1SO9TUbljr3EaIpt10+0FHCd4OO3+ZQPM
vault status -tls-skip-verify

```

## Validate through the route

```

export VAULT_ROUTE=vault.apps.127.0.0.1.nip.io

curl https://$VAULT_ROUTE/v1/sys/health \
    --cacert ~/.oc/certs/ca-bundle.crt
    
```

## Walkthrough Example via Rest API


[Vault Sys API](https://www.vaultproject.io/api/system/index.html)

[Example](https://www.vaultproject.io/intro/getting-started/apis.html)

```

export VAULT_TOKEN=39a8f6ce-9327-c6a6-b72d-704d641d949e
export VAULT_ROUTE=vault.apps.127.0.0.1.nip.io

```

### Enable App Role Authentication

```

curl -X POST -H "X-Vault-Token:$VAULT_TOKEN" \
    -d '{"type":"approle"}' \
    https://$VAULT_ROUTE/v1/sys/auth/approle \
    --cacert ~/.oc/certs/ca-bundle.crt

```

### Create testrole

```

curl -X POST -H "X-Vault-Token:$VAULT_TOKEN" \
    -d '{"policies":"example-policy"}' \
    https://$VAULT_ROUTE/v1/auth/approle/role/testrole \
    --cacert ~/.oc/certs/ca-bundle.crt

```

### Create example-policy

```

curl -H "X-Vault-Token:$VAULT_TOKEN" \
    --request PUT \
    -d @- \
    https://$VAULT_ROUTE/v1/sys/policy/example-policy \
    --cacert ~/.oc/certs/ca-bundle.crt <<'EOF'
{"policy": "{
    \"path\":{\"secret/*\":{\"capabilities\":[\"create\",\"read\",\"update\",\"delete\",\"list\"].
    \"path\":{\"auth/token/lookup-self\":{\"capabilities\":[\"read\"]
}}}"}
EOF

curl -H "X-Vault-Token:$VAULT_TOKEN" \
    https://$VAULT_ROUTE/v1/sys/policy/example-policy \
    --cacert ~/.oc/certs/ca-bundle.crt | jq .

```

### Retrieve Role ID, Secret ID and Vault Token for testrole

```

export ROLE_ID=$(curl -s -X GET -H "X-Vault-Token:$VAULT_TOKEN" \
    https://$VAULT_ROUTE/v1/auth/approle/role/testrole/role-id \
    --cacert ~/.oc/certs/ca-bundle.crt \
    | jq .data.role_id)
echo $ROLE_ID

export SECRET_ID=$(curl -s -X POST -H "X-Vault-Token:$VAULT_TOKEN" \
    https://$VAULT_ROUTE/v1/auth/approle/role/testrole/secret-id \
    --cacert ~/.oc/certs/ca-bundle.crt \
    | jq .data.secret_id)
echo $SECRET_ID

export VAULT_TOKEN=$(curl -s -X POST \
    -d '{"role_id":'$ROLE_ID',"secret_id":'$SECRET_ID'}' \
    https://$VAULT_ROUTE/v1/auth/approle/login \
    --cacert ~/.oc/certs/ca-bundle.crt \
    | jq .auth.client_token | tr -d '"')
echo $VAULT_TOKEN

```

### Create Secret foo

```

curl -s -X POST -H "X-Vault-Token:$VAULT_TOKEN" -d '{"bar":"baz"}' \
    https://$VAULT_ROUTE/v1/secret/foo \
    --cacert ~/.oc/certs/ca-bundle.crt

```

### Retrieve Secret foo

```

curl -s -X GET -H "X-Vault-Token:$VAULT_TOKEN" \
    https://$VAULT_ROUTE/v1/secret/foo \
    --cacert ~/.oc/certs/ca-bundle.crt \
    | jq .data.bar

```
