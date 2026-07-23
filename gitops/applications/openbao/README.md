# OpenBao

This application runs one OpenBao 2.6.0 server with integrated Raft storage and
OCI KMS auto-unseal. It is intentionally a recoverable single instance, not an
HA service.

## Storage and cost boundary

The StatefulSet requests one `50Gi` claim from the dedicated `oci-bv-retain`
StorageClass. It uses OKE's CSI Block Volume driver with a paravirtualized
attachment because the worker pool encrypts volume traffic in transit. The
class also changes the reclaim policy from `Delete` to `Retain` and disables
expansion. With two 50 GB worker boot volumes, the tenancy provisions 150 GB in
total and keeps 50 GB of the Always Free 200 GB block-storage allowance unused.

The claim is retained if the StatefulSet is deleted or scaled, and deleting the
claim leaves the underlying OCI Block Volume available for manual recovery. The
StatefulSet and StorageClass also require explicit Argo prune confirmation.

## OCI KMS bootstrap

The repository contains no KMS OCIDs, endpoints, OCI private keys, recovery
keys, or OpenBao tokens. Before Argo creates the StatefulSet, run:

```console
bootstrap/openbao-prerequisites.sh
```

The script reads the non-secret KMS identifiers from existing Terraform state
and writes them directly to the `openbao-oci-kms` Kubernetes Secret without
displaying them. OpenBao then authenticates to KMS through the worker instance
principal; no OCI API key is stored in the cluster.

## First initialization

OCI KMS can unseal OpenBao only after it has been initialized. Initialization is
an explicit operator ceremony because it returns recovery keys and an initial
root token:

```console
kubectl --namespace openbao exec --stdin --tty openbao-0 -- bao operator init
```

Run that command and store the recovery material in
an offline password manager or encrypted offline medium. Never paste it into an
issue, chat, Git file, CI log, or shell history.

After initialization, deleting only the pod is a useful first recovery test. The
same PVC is reattached and the replacement pod should become ready without any
manual unseal command.

## Post-initialization setup

OpenBao is an empty safe immediately after initialization. With the tunnel open,
run `bootstrap/openbao-configure.sh` to add the first normal administrator,
configure Kubernetes service-account authentication, and enable a versioned
`secret/` KV store. The helper reads credentials interactively and never writes
them to Git or a Kubernetes Secret.

Once a separate administrator login works, run
`bootstrap/openbao-revoke-initial-root.sh` to remove the non-expiring bootstrap
credential. The recovery shares stay offline and can authorize generation of a
new root token for a future emergency.

Audit events are declared in the server configuration and written to the pod's
standard output with OpenBao's normal HMAC protection. Kubernetes bounds the
local container-log size; VictoriaLogs will become the durable destination when
the observability stack is added.

No general Kubernetes role is created. Each application will get its own role
later, bound to one service account and namespace and granting access only to
that application's secret path.

## Network boundary

OpenBao has only ClusterIP services and no Ingress, Gateway route, or UI Service.
Its namespace policy permits client traffic only from namespaces labeled
`openbao-client=true`. A Calico global policy blocks OCI link-local metadata for
non-system namespaces. Only pods carrying the OpenBao server labels and running
as the `openbao` service account receive the exception required for KMS
auto-unseal. The guardrail lives in Calico's higher-priority `platform` tier;
all non-metadata traffic passes onward to normal Kubernetes NetworkPolicies.
The namespace policy also allows the private OKE API subnet on TCP 6443 so
OpenBao's Kubernetes service registration can update its active-pod label.

Internal server TLS, per-application Kubernetes auth roles, durable audit
shipping, Raft snapshots, and secret-delivery controllers follow after this
bootstrap checkpoint.
