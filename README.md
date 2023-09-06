# vault-infrastructure-aws
Deploy Hashicorp Vault+Consul to dynamically generate short-lived credentials per pod.


### Vault Agent is a client daemon that provides the following features:

- Auto-Auth - Automatically authenticate to Vault and manage the token renewal process for locally-retrieved dynamic secrets.
- Caching - Allows client-side caching of responses containing newly created tokens and responses containing leased secrets generated off of these newly created tokens.
- Templating - Allows rendering of user-supplied templates by Vault Agent, using the token generated by the Auto-Auth step.
