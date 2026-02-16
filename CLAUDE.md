# K8s + ArgoCD Project

## Guidelines for Claude Code

### Versioning & Releases
1. **Update RELEASES.md** with each PR (add to `[Unreleased]` section)
2. **When releasing:**
   - Move `[Unreleased]` changes to new version section (e.g., `[v0.3.0] - YYYY-MM-DD`)
   - Use semantic versioning: MAJOR.MINOR.PATCH
   - Create git tag: `git tag -a vX.Y.Z -m "release message"`
   - Push tag: `git push origin vX.Y.Z`
   - GitHub auto-creates release page from tag (can add release notes via GitHub UI or `gh release create`)

### Release Notes
- Add changes under `[Unreleased]` section during development
- Use standard categories: Added, Changed, Fixed, Removed, Security
- Keep notes brief and user-focused

### Documentation Strategy
- README.md: Tech stack summary + setup only
- RELEASES.md: Change history and feature tracking
- CLAUDE.md: Project instructions for Claude Code
- No separate human docs (Claude is the maintainer)

### Future Enhancements
- MCP server for Claude to query cluster state
- Automated deployment via ArgoCD itself

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
