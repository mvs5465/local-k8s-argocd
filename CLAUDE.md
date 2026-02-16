# K8s + ArgoCD Project

## Cleanup Tasks (Code Quality Pass) - COMPLETED ✅

- [x] #1: Convert fileserver Pod to Deployment - PR #1
- [x] #2: Pin image tags (nginx:latest → specific versions) - PR #2
- [x] #3: Standardize labels (use app.kubernetes.io/* convention) - PR #3
- [x] #4: Remove docs-server and unnecessary documentation - PR #4
- [x] #5: Add SecurityContext (runAsNonRoot, readOnlyRootFilesystem) - PR #5
- [x] #6: Skip Ingress (port-forwarding sufficient for local dev)
- [x] #7: Remove bare Pods (ensure all workloads use Deployment/StatefulSet) - PR #6
- [x] #8: Codify ArgoCD (currently installed manually via quick-start.sh) - PR #7

## Docs Strategy

- Removed docs-server pod and all separate documentation files
- README.md now contains only tech stack summary and basic setup
- Documentation maintained by Claude Code, not humans
- Future: MCP server for Claude to query cluster state

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
