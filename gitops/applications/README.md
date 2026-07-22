# Argo CD Applications

This directory is the self-contained application catalog watched by the catalog
Argo CD Application. Every deployed component gets one folder:

```text
applications/
├── argocd/
│   ├── application.yaml
│   ├── values.yaml
│   └── manifest/
├── cert-manager/
│   ├── application.yaml
│   ├── values.yaml
│   └── manifest/
└── portfolio/
    ├── application.yaml
    ├── values.yaml
    └── manifest/
```

Folder contents:

- `application.yaml`: the child Argo CD `Application`, including chart/source,
  target namespace, sync policy, and sync-wave annotation.
- `values.yaml`: overrides for an upstream Helm chart. Keep it as `{}` when the
  chart needs no overrides; omit it only for a manifest-only application.
- `manifest/`: optional Kubernetes resources that belong to the same component,
  such as a `ClusterIssuer`, `Gateway`, `NetworkPolicy`, dashboard, or alert.

For an upstream Helm chart plus local values/manifests, `application.yaml` uses
Argo CD multiple sources: the chart repository, this Git repository as the
values source, and the local `manifest/` path. For a manifest-only workload,
the Application points directly at its `manifest/` directory.

The catalog Application uses directory recursion with the include pattern
`*/application.yaml`. It therefore creates the child Applications without
mistaking `values.yaml` or the child manifests for catalog-level resources.

Dependency order is enforced by explicit Argo CD sync-wave annotations on each
`application.yaml`, not by directory names.

There is no `clusters/` level because this repository currently targets one OKE
cluster. If a second cluster is introduced later, we can add environment/cluster
selection then instead of carrying that abstraction now.

Argo CD is not an exception to this organization. Its ongoing desired state is
defined by `applications/argocd/application.yaml`, and both the first bootstrap
and later Argo CD reconciliation use `applications/argocd/values.yaml`.
