# K8s + ArgoCD Project Status

## Current Issue
File server deployment created but hostPath volume mounting from macOS to Colima K3s doesn't work. Path `/Users/matthewschwartz/.k8s-files` is not accessible in the pod.

## Root Cause
Colima mounts macOS filesystem into the VM, but K3s hostPath volumes don't have reliable access to those mounted directories. Attempted paths:
- `/tmp/files` - not mounted from macOS to VM
- `/Users/matthewschwartz/.k8s-files` - mounted in Colima but not accessible via hostPath in K3s

## Next Steps - Decision Needed
Before continuing, research and decide on best approach:
1. **ConfigMap + emptyDir** - Works but limited to 1MB total, excludes MP4 files (3.7MB + 161KB)
2. **Direct file creation in Colima VM** - Copy files into Colima's `/tmp/files` via `colima ssh`
3. **Use Persistent Volume + host mount** - More complex, may not work either
4. **PersistentVolume with external NFS/SMB** - Overkill for local dev

## File Server Manifest Status
- `manifests/fileserver-app.yaml` - Created with Flask app, currently broken due to hostPath issue
- ConfigMap `fileserver-files` - Contains small test files (readme.txt, data.json, document.txt)
- ConfigMap `fileserver-app` - Contains Flask application code
- Deployment runs on port 5000, exposed via LoadBalancer on 5555

## Files to Serve
- readme.txt, data.json, document.txt (small, can use ConfigMap)
- m2-res_480p.mp4 (3.7MB), sample.mp4 (161KB) - too large for ConfigMap

## UI Status
Dashboard at localhost:8888 includes file server link, but app not functional until mount resolved.
