# vault-infrastructure-aws
Deploy Hashicorp Vault+Consul to dynamically generate short-lived credentials per pod.

### Vault Keys

## Rekey and Rotation

### Policy Needed

```json
path "sys/rotate" {
  capabilities = ["update","sudo"]
}
path "sys/key-status" {
  capabilities = ["read"]
}
```

### Rekey with different threshold and key-shares
- vault operator rekey -key-shares=3 -key-threshold=2 -init
- vault operator rekey


### key Status and Rotate
- vault operator key-status
- vault operator rotate


## Cubbyhole

#### Login

```sh
vault login $(cat /home/bob/default_token)
```

#### Create Data

```sh
vault write cubbyhole/hcvop certification=hashicorp

```

#### Read Data

```sh
vault read cubbyhole/hcvop
```

#### Putting some data in kv engine

```sh
vault kv put kv/operations username=admin password=P@ssw0rd1
```

#### Wrap the data

```sh
vault kv get -wrap-ttl=20m kv/operations
```
##### Output

```
Key                              Value
---                              -----
wrapping_token:                  hvs.
wrapping_accessor:               A0aGBm1uUXJCGAGgyLE5nnvO
wrapping_token_ttl:              20m
wrapping_token_creation_time:    2025-09-17 04:24:09.880207814 -0400 EDT
wrapping_token_creation_path:    kv/data/operations
```

#### Read the data with the Wrapping Token

```
vault unwrap $(cat /home/calvine/wrapping_token )
Key         Value
---         -----
data        map[password:P@ssw0rd1 username:admin]
metadata    map[created_time:2025-09-17T08:23:10.574083762Z custom_metadata:<nil> deletion_time: destroyed:false version:1]
```

#### Vault Audit

```sh
vault audit enable file  file_path=/var/log/vault_audit.log
```

##### Checking Logs

```sh
sudo cat /var/log/vault_audit.log | jq -r '.request | (select(.path | contains ("kv/data")))'
```

###### Output

```json
{
  "id": "c5cf3b73-91cc-6bc0-a638-36e58cbf487e",
  "client_id": "0DHqvq2D77kL2/JTPSZkTMJbkFVmUu0TzMi0jiXcFy8=",
  "operation": "create",
  "mount_type": "kv",
  "client_token": "hmac-sha256:f445bf4cbb9f66a0164959e796e28fb818f868081dc533f91b3857b589b84977",
  "client_token_accessor": "hmac-sha256:c09e1aa4c979e78296fe38366f4f8d87adc476ef15078021610276b49c824ba7",
  "namespace": {
    "id": "root"
  },
  "path": "kv/data/certification",
  "data": {
    "data": {
      "vault": "hmac-sha256:d7d520ef665fd4a1c552740551f75e62e941c197820ee2d0abb8adf8fe5f6e21"
    },
    "options": {}
  },
  "remote_address": "10.39.254.10",
  "remote_port": 36416
}
```

#####ß Enable local Audit Log

Enable a file audit device at the path of local_logs – make sure the configuration would NOT be replicated to other clusters if
replication was enabled.

Have vault store the logs at /var/log/local_audit.log

```sh
vault audit enable -path=local_logs -local file file_path="/var/log/local_audit.log"
```

```vault audit list --detailed
Path           Type      Description    Replication    Options
----           ----      -----------    -----------    -------
file/          file      n/a            replicated     file_path=/var/log/vault_audit.log
local_logs/    file      n/a            local          file_path=/var/log/local_audit.log
syslog/        syslog    n/a            replicated     n/a
```

## Vault Secure Initialization

### GPG Keys

```sh
gpg --list-keys
```

 Initialize Vault with GPG Keys
```sh
vault operator init \
  -format=json \
  -key-shares=3 \
  -key-threshold=2 \
  -pgp-keys="/home/bob/PGP-Keys/alexis.pub,/home/bob/PGP-Keys/henry.pub,/home/bob/PGP-Keys/gabriel.pub" | tee /home/bob/init.json
```

Decrypt The Keys

```sh
echo "<encrypted key ciphertext>" | base64 -d | gpg -dq
```

## Vault Auto Unseal with Transit Secret Engine

```sh
vault write -f transit/keys/autounseal
```

Policy needed to use Transit Secret Engine for Auto Unseal

```json
vault policy read unseal-policy
path "transit/encrypt/autounseal" {
  capabilities = ["update"]
}
path "transit/decrypt/autounseal" {
  capabilities = ["update"]
}
path "transit/keys" {
  capabilities = ["list"]
}
path "transit/keys/autounseal" {
  capabilities = ["read"]
}
```

Example of Auto Unseal with Transit Secret Engine

```hcl
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-server"
}

listener "tcp" {
  address     = "192.168.242.156:8200"
  tls_disable = "true"
}
seal "transit" {
  address = "http://transit:8200"
  token = "hvs."
  mount_path = "transit/"
  key_name = "autounseal"
  tls_skip_verify = "true"
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui = true
disable_mlock = true
~                    
```
Vault status with Transit Secret Engine

```sh
root@madrid:~# vault status
Key                      Value
---                      -----
Seal Type                transit
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    5
Threshold                3
Version                  1.15.4
Build Date               2023-12-04T17:45:28Z
Storage Type             raft
Cluster Name             vault-cluster-bcbcce76
Cluster ID               4e050a43-090b-bedd-4539-46ee8f08698f
HA Enabled               true
HA Cluster               https://127.0.0.1:8201
HA Mode                  active
Active Since             2025-10-01T09:49:21.539907968Z
Raft Committed Index     57
Raft Applied Index       57
```

## Vault Approle

### Role ID
```sh
vault  read auth/approle/role/ecomm-agent/role-id
```
### Secret ID
```sh
vault write -f auth/approle/role/ecomm-agent/secret-id
```

Modify Token Max TTL

```sh
vault write auth/approle/role/ecomm-agent token_max_ttl=25s
```

Start Vault Agent

```sh
vault agent -config=/etc/vault.d/agent.hcl
```

## Vault DR

Check License status 

```sh
vault read sys/license/status
```

Enable DR Replication

```sh
vault write -f sys/replication/dr/primary/enable
```

Check DR status

```sh
vault read sys/replication/dr/status
Key                            Value
---                            -----
cluster_id                     a0c87b43-c06a-27af-8612-adc3447cbc0e
corrupted_merkle_tree          false
known_secondaries              []
last_corruption_check_epoch    -62135596800
last_dr_wal                    41
last_reindex_epoch             0
last_wal                       41
merkle_root                    080383e7a7894e2f350768e731245da524912837
mode                           primary
primary_cluster_addr           n/a
secondaries                    []
ssct_generation_counter        0
state  
```

Generate Secondary Token

```sh
vault write sys/replication/dr/primary/secondary-token id=eu-barcelona-dr
```

Enable Replication on Secondary Cluster

```sh
vault write sys/replication/dr/secondary/enable token=<dr token>
```

Create a DR operations token so we can promote the
cluster to a primary

```sh
vault operator generate-root -dr-token -init
```

Next run this giving a unique unseal key from the Primary cluster (X times threshold)

```sh
vault operator generate-root -dr-token
```

Once the OTP and the Encoded Token have been generated using the given steps, decode the token:

```sh
vault operator generate-root -dr-token -decode=<encoded token> -otp=<otp> > /home/bob/dr_operations_token
```

Demote the Primary Cluster

```sh
vault write -f sys/replication/dr/primary/demote
```

Promote the secondary cluster

```sh
vault write sys/replication/dr/secondary/promote dr_operation_token=<decoded dr operations token>
```

## HA Vault Setup

```sh
vault operator raft join http://node-1:8200
```

## Transit Secret Engine

Create a new encryption key
```sh
vault write -f transit/keys/hcvop
```
List Encryption Keys

```sh
vault list transit/keys
```

Read Keys

```sh
vault read transit/keys/hcvop
```

Encypt Data with the Key - JSON Format

```sh
vault write -format=json transit/encrypt/hcvop plaintext=$(base64 <<< "vault operations professional") | tee -a /home/bob/encrypted_data.json
```

Output

```json
{
  "request_id": "15c02747-6e6b-dd43-24ee-df09139b595e",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "ciphertext": "vault:v1:M1Ky7EuVT4r21cNQCmgK5GA2dETV4ceyky760MUB1D0ek5qLlHEVtjL47Y0sI5opjUNmrSoQANMMEQ==",
    "key_version": 1
  },
  "warnings": null
}
```
Filter the encrypted Cyphertext

```sh
cat /home/bob/encrypted_data.json | jq -r '.data.ciphertext'
vault:v1:M1Ky7EuVT4r21cNQCmgK5GA2dETV4ceyky760MUB1D0ek5qLlHEVtjL47Y0sI5opjUNmrSoQANMMEQ==
```

Rotate the encryption key

```sh
vault write -f transit/keys/hcvop/rotate
```

Decrypt the cypertext

```sh
vault write transit/decrypt/hcvop \
> ciphertext="$(cat /home/bob/encrypted_data.json \
> | jq -r '.data.ciphertext')"
Key          Value
---          -----
plaintext    dmF1bHQgb3BlcmF0aW9ucyBwcm9mZXNzaW9uYWwK
```

Decode

```sh
echo 'dmF1bHQgb3BlcmF0aW9ucyBwcm9mZXNzaW9uYWwK' | base64 -d
```

Set the minumum decryption version

```sh
vault write transit/keys/hcvop/config min_decryption_version=2
```

Vault Policy that can allow Transit Secret Engine 

```json
path "transit/keys/vault-auto-unseal" {
  capabilities = ["update", "create", "read"]
}
path "transit/encrypt/vault-auto-unseal" {
  capabilities = ["update"]
}
path "transit/decrypt/vault-auto-unseal" {
  capabilities = ["update"]
}
```

## Vault Namespaces

Check license status

```sh
vault read sys/license/status -format=json | jq -r '.data.persiste
d_autoload.features[]'
HSM
Performance Replication
DR Replication
MFA
Sentinel
Seal Wrapping
Control Groups
Performance Standby
Namespaces
KMIP
Entropy Augmentation
Transform Secrets Engine
Lease Count Quotas
Key Management Secrets Engine
Automated Snapshots
Key Management Transparent Data Encryption
```

Create new Vault Namespace

```sh
vault namespace create education
```

Enable a Secret Engine in a namespace

```sh
vault secrets enable -namespace=education database
```
OR

```sh
export VAULT_NAMESPACE=education
vault secrets enable database
```

Create a Policy in a Namespace

```sh
export VAULT_NAMESPACE=education

vault policy write database-full-access -<< EOF
path "database/*" {
capabilities = ["read","create","update","delete","list"]
}
EOF
```
Enable Auth Method in a namespace

```sh
vault auth enable -namespace=education userpass
```
OR

```
export VAULT_NAMESPACE=education
vault auth enable userpass
```

```sh
vault write -namespace=education auth/userpass/users/mary password=abc123 policies=database-full-access
```

```sh
vault login -namespace=education -method=userpass username=mary
```