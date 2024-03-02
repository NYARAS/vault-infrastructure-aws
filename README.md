# vault-infrastructure-aws
Deploy Hashicorp Vault+Consul to dynamically generate short-lived credentials per pod.

### Vault Tokens
- `Service token` is the general token that most people talk about when referring to a token in Vault.
- `Batch token` is an encrypted binary large object (blobs) that carries just enough information for authentication.
- `Periodic service tokens` have a TTL, but no max TTL.
- `Orphan tokens` are not children of their parent; therefore, do not expire when their parent does.

#### TTL and Max TTL
The `TTL` defines when the token will expire. If the token reaches its TTL, it will be immediately revoked by Vault. The `Max TTL` defines the maximum timeframe for which the token can be renewed. Once the max TTL is reached, the token cannot be renewed any longer and will be revoked.

#### Understanding Vault KV delete commands
The `kv delete` command deletes the data for the provided path in the key/value secrets engine. If using K/V Version 2, its versioned data will not be fully removed, but marked as deleted and will no longer be returned in normal get requests.

The `kv destroy` command permanently removes the specified versions' data from the key/value secrets engine. If no key exists at the path, no action is taken.

The `kv metadata delete` command deletes all versions and metadata for the provided key.

### Vault Auth Methods

Different auth methods have different intentions and purposes. The following defines what different auth methods are intended for within Vault:
-  Machine-oriented: AppRole, TLS, tokens, platform-specific methods (cloud, k8s)
-  Operator-oriented: Github, LDAP, username & password

### Vault Agent is a client daemon that provides the following features:

- Auto-Auth - Automatically authenticate to Vault and manage the token renewal process for locally-retrieved dynamic secrets.
- Caching - Allows client-side caching of responses containing newly created tokens and responses containing leased secrets generated off of these newly created tokens.
- Templating - Allows rendering of user-supplied templates by Vault Agent, using the token generated by the Auto-Auth step.

### Token Accessors

When tokens are created, a token accessor is also created and returned. This accessor is a value that acts as a reference to a token and can only be used to perform limited actions:

  - Look up a token's properties (not including the actual token ID)
  - Look up a token's capabilities on a path
  - Renew the token
  - Revoke the token

### Token Lookup
To view information about a token, the command vault token lookup can be used on the CLI. This command will display lots of information and metadata associated with a particular token. This information includes TTL, number of uses, type of token, policies, and more.

There are two different ways you can use the vault token lookup command. If you are logged into Vault and want to check the current token being used, you can just use vault token lookup. If you want to check a different token, you can use vault token lookup <token>. You can also use -accessor flag if you only know the accessor and not the token.


### Vault DR
There are two types of replication that are available to Vault Enterprise customers:

    * Disaster Recovery Replication

    * Performance Replication

The big differences between the two types of replication include:

  * DR replication will replicate all tokens and leases from the primary cluster to the secondary. This means tokens that were valid for the primary cluster are valid for the secondary cluster when it is promoted. However, a DR replication cluster does NOT respond to clients unless it is promoted to a primary.

  * Performance replication can respond to client requests, but it handles its own tokens and leases. Any tokens or leases that are created on the primary cluster are NOT replicated to the secondary servers. Therefore if you failover to the secondary cluster, applications would need to re-authenticate because the existing tokens would not be valid on the secondary cluster.

### Understanding Vault Paths (sys/mount)
When you are using the UI, you will likely need to add additional LIST permissions to the mount (sys/mounts) and then LIST for every path up to the desired secret. For example, the following policy would provide LIST access to everything needed, including seeing the KV mount and all paths beneath it.

```
path "kv/apps/webapp01" {
  capabilities = ["read", "create", "update", "list"]
}
 
path "sys/mounts" {
  capabilities = ["list"]
}
 
path "kv/*" {
  capabilities = ["list"]
}
```


### Vault has two built-in policies:

The `root` policy is created by default – it provides superuser privileges with complete and full access to everything in Vault. You cannot change nor delete this policy. This policy is attached to all root tokens.

The `default` policy is created by default and provides common permissions for tokens. You can change this policy but it cannot be deleted. It is automatically attached to all non-root tokens by default (this behavior can be changed if needed)


The `vault operator step-down` forces the Vault server at the given address to step down from active duty. While the affected node will have a delay before attempting to acquire the leader lock again, if no other Vault nodes acquire the lock beforehand, it is possible for the same node to re-acquire the lock and become active again.


Vault has many secrets engines that can generate dynamic credentials, including AWS, Azure, and database secrets engines. The key/value secret engine is used to store data, the transit secret engine is used to encrypt data.


