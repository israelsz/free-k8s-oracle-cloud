# OCI Kubernetes infrastructure

This directory contains the Terraform code for an OKE cluster designed to stay
inside Oracle Cloud's Always Free limits. Kubernetes add-ons and applications
live in the GitOps part of the repository.

The goal is a $0 OCI bill. Free-tier limits, regional capacity, and pricing can
change, so check the plan before applying anything.

## Architecture

At the moment, Terraform creates:

- a protected project compartment;
- a dedicated VCN with separate subnets for the private Kubernetes API,
  workers, VCN-native pods, and a Kubernetes-managed public load balancer;
- an OKE Basic cluster with a private API endpoint;
- two private `VM.Standard.A1.Flex` workers using the reviewed ARM image;
- an OCI Bastion for temporary access to the private Kubernetes API;
- a least-privilege operator IAM group and policies;
- a software-protected OCI KMS key used only for OpenBao auto-unseal;
- a private, versioned workload-backup bucket with short retention;
- actual and forecast spending alerts for the project compartment;
- a cluster-principal IAM policy for creating and maintaining service
  load-balancer frontend NSGs in this project compartment.

The worker pool is fixed at two nodes. Each node gets 2 OCPUs, 12 GB of memory,
and a 50 GB boot volume. Terraform rejects larger or paid fallback shapes. This
uses the 3,000 A1 OCPU-hours and 18,000 GB-hours currently included with paid
tenancies, so the account must remain PAYG or another paid account type.

The network is divided by responsibility:

| CIDR | Purpose |
| --- | --- |
| `10.20.0.0/28` | Private OKE API and Bastion endpoint |
| `10.20.1.0/24` | Private worker nodes |
| `10.20.2.0/24` | VCN-native pod addresses |
| `10.20.3.0/24` | Kubernetes-managed public load balancer |

Envoy Gateway creates the load balancer from a Kubernetes Service and pins its
Flexible shape to 10 Mbps. OCI's cloud controller creates a frontend NSG from
that Service's Cloudflare-only source ranges and uses Terraform's worker NSG as
the default backend. This avoids placing live NSG identifiers in Git. The load
balancer itself is not a Terraform resource.

## Repository structure

```text
infra/terraform/
├── backend.tf
├── backend.hcl.example
├── versions.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
├── locals.tf
├── main.tf
├── checks.tf
├── outputs.tf
└── modules/
    ├── access/
    ├── cloudflare/
    ├── cost-guardrails/
    ├── data-protection/
    ├── identity/
    ├── network/
    └── oke/
```

All modules use the same state file. There is only one cluster and one
environment, so splitting the state would add work without helping much.

## Remote state

Terraform's native `oci` backend stores state in a private, versioned Object
Storage bucket and locks it during operations. The bucket is created manually
and kept outside Terraform, so destroying the cluster cannot also delete its
state bucket.

`backend.tf` contains only the partial backend declaration. Copy
`backend.hcl.example` to the ignored `backend.hcl` and provide the bucket,
namespace, region, and OCI profile. The default state object path is:

```text
prod/terraform.tfstate
```

Authentication uses an OCI CLI profile with `SecurityToken`; the native backend
does not require an S3-compatible Customer Secret Key.

## Configuration

Terraform 1.15.8 is pinned for the native OCI backend. The OCI and Cloudflare
provider versions are recorded in `.terraform.lock.hcl`.

Create local configuration files from the sanitized examples:

```sh
cd infra/terraform
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars
```

Replace every placeholder before initializing. Live OCIDs, profile names,
network addresses, and backend metadata belong only in the ignored local files.
Cloudflare credentials, when required, must be supplied through the provider's
environment variables rather than Terraform input variables.

Initialize and validate without contacting the backend:

```sh
terraform init -backend=false
terraform fmt -check -recursive .
terraform validate
```

Initialize the native OCI backend and review a production plan:

```sh
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
```

Only apply after reading the plan. The project compartment has
`prevent_destroy` enabled, so removing it requires an explicit code change.

## Security boundary

- Worker nodes and the Kubernetes API have no public addresses.
- Kubernetes API access uses short-lived Bastion port-forwarding sessions.
- Bastion clients are restricted to explicit administrator IPv4 `/32` ranges.
- Bastion IAM restricts port forwarding to the exact private API `/32` and
  TCP/6443.
- Worker instance principals can use only the OpenBao KMS key; they cannot
  manage the key or vault.
- The exact OKE cluster principal can manage load-balancer NSGs only inside
  this project compartment. Its VCN grant is limited to read, attach, and
  detach permissions rather than full VCN administration.
- The workload backup bucket is private and old data is expired automatically.
- OCI IAM grants access to the API boundary; Kubernetes RBAC separately decides
  what an authenticated identity may do inside the cluster.
- Credentials, real variable files, backend settings, state, plans, and
  kubeconfigs must never be committed.

This setup is for a portfolio and a few small workloads. It borrows the useful
parts of a production setup, but it is still a two-node free-tier cluster with
no paid SLA.
