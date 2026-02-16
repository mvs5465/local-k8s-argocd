# K8s + ArgoCD Project

## Cleanup Tasks (Code Quality Pass)

- [x] #1: Convert fileserver Pod to Deployment - PR #1 (in review)
- [ ] #2: Pin image tags (nginx:latest → specific versions)
- [ ] #3: Standardize labels (use app.kubernetes.io/* convention)
- [ ] #4: Fix GitHub/localhost hardcoding (make manifests portable)
- [ ] #5: Add SecurityContext (runAsNonRoot, readOnlyRootFilesystem)
- [ ] #6: Improve Ingress (TLS, auth - optional for local dev)
- [ ] #7: Remove bare Pods (ensure all workloads use Deployment/StatefulSet)
- [ ] #8: Host docs locally (instead of linking to GitHub)

## File Server - Final Approach
Nginx static file server using hostPath volume.

**Design:**
- Container: nginx
- Files location: `/tmp/files` on k3s node
- Volume: hostPath, read-only
- Pod: pinned to node with `nodeName: colima`
- Expose: NodePort 30080
- Manifest: `manifests/fileserver.yaml`

**Setup requirement:**
Files must be placed in `/tmp/files` inside Colima VM (via `colima ssh` or copied in)

**Discarded approaches:**
- Flask app + ConfigMaps (removed)
- PersistentVolume / NFS / SMB (too complex)
- Custom app logic (not needed)
