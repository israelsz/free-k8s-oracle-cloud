# Access module

Owns one free OCI-managed standard Bastion attached to the private Kubernetes
API subnet. It creates no VM jump host, permanent session, worker SSH path, or
public Kubernetes endpoint.

Security constraints are deliberate:

- only explicit administrator public IPv4 `/32` addresses are allowed;
- session lifetime is capped at one hour;
- FQDN/SOCKS5 proxy support is disabled;
- the subnet rules allow the Bastion private endpoint to reach only TCP/6443 in
  the API subnet;
- port-forwarding sessions and their ephemeral SSH keys are created locally and
  expire outside Terraform state.

Changing networks can change an administrator's public address. Update the
ignored production `terraform.tfvars` with the current public IPv4 `/32`, review
a plan, and apply the allow-list change instead of broadening the CIDR.
