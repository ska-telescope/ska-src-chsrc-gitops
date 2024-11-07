# Sharing PVCs across namespaces

Kubernetes semantics entail that namespaced resources are isolated, and therefore by design PVCs are distinct resources that can not be shared across namespaces.

However, in certain cases it is necessary to share PVCs across namespaces.

For instance, in the **Science Platform**, which contains a skaha-system and a skaha-workload namespace, user workloads are run as pods
that run in the skaha-workload namespace, while services run in the skaha-system namespace. However, the PVCs referenced by both namespaces
need to point to the same underlying volume.

Similarly, when the **RSE** data store is deployed as a PVC, an easy way to share RSE data with services is to share the PVC across namespaces.

## Steps for sharing a PVC

The steps to create a shared PVC across namespaces is similar to [this Confluence doc](https://confluence.skatelescope.org/display/SRCSC/Sharing+storage+between+PVCs+across+namespaces),
except there are some caveats to make it work on our infrastructure. We're using ceph-csi while the linked instructions use Manila.

Let's say that we intend to clone the original PVC `original-pvc` in namespace `ns1` which is bound to the PV `original-pv`.
We'll be creating a new PVC, `new-pvc` in namespace `ns2`, bound to the PV `new-pv`, but that is actually pointing to the same underlying data location under the hood.

**Requirement**: The `original-pvc` MUST be of storageClass `ceph-corbo-cephfs-retain` and accessMode `ReadWriteMany`.

!!! Tip
    We tried and failed with RBD volumes, RWO and ROX modes, but the ceph driver will not be able to attach
    the rbd block device if it's already attached to another pod, even if `new-pv` is in ROX mode.

The detailed steps are as follows.

1. Take the original PV `original-pv` that the original PVC is referencing, and make a copy.
     * Change the *metadata.name* (e.g. from `original-pv` to `new-pv`).
     * Delete all *metadata.\** except for the name.
     * Delete the *spec.claimRef*.
     * Delete the *status*.
     * Do **not** change the volumeHandle.
1. Take the original PVC `original-pvc` and make a copy.
     * Change the *metadata.name* (e.g. from `original-pvc` to `new-pvc`).
     * Change the *metadata.namespace* (e.g. change `ns1` to `ns2`).
     * Delete all *metadata.\** except for name and metadata.
     * Add a `spec.volumeName: new-pv` pointing to the new PV.
1. On the application's pod that wants to access the shared data, add a volume that references the duplicate PVC.
If appropriate, set the volume mount as read-only.

```yaml
  volumes:
  - name: shared-data-volume
    persistentVolumeClaim:
      claimName: new-pvc
      readOnly: true
```

!!! Warning "Limitations"
    * If the original PV is deleted, the PV copies and all the respecting PVCs need to be redone manually.
    * Deletion order must be such that the original PV is the last one to be deleted.