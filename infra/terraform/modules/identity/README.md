# Identity module

Currently owns the default-domain `israheck-operators` group, membership for one
explicit human user OCID, and its narrowly scoped access policy.

The operator group can:

- use the one project Bastion;
- create, connect to, and terminate only port-forwarding sessions targeting
  TCP/6443 on the exact private API endpoint `/32`;
- read the project VCN and subnet metadata required by Bastion;
- obtain a user-specific, short-lived OKE kubeconfig token.

It cannot manage OKE, Bastion, networks, compute, storage, or worker SSH. OCI IAM
authentication only reaches the API; Kubernetes authorization is granted later
through a reviewed Argo CD-managed RBAC binding.

OpenBao worker identity and KMS access live in the data-protection module. This
module must never grant broad tenancy administrator permissions.
