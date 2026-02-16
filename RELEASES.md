# Release Notes

## [Unreleased]

### Changed
- Implemented app-of-apps pattern: root application now points to manifests/argocd directory to auto-discover and manage child applications
- Simplified quick-start.sh: only apply appproject and root app; child applications are auto-created by root app

### Fixed
- fileserver pod mounting issue: /tmp/files directory must exist on colima node before deployment (setup requirement, not code issue)
- Grafana and Prometheus OutOfSync errors: AppProject now allows ClusterRole and ClusterRoleBinding resources required by Helm charts

## [v0.2.0] - 2026-02-16

### Added
- ArgoCD installation now codified in `manifests/argocd-install.yaml` via installer Job
- Architecture diagram in README showing cluster structure and port-forwarding
- SecurityContext to all containers (runAsNonRoot, readOnlyRootFilesystem, allowPrivilegeEscalation: false)
- emptyDir volumes for nginx /var/run and /var/cache directories

### Changed
- Simplified README to tech stack summary + setup only
- quick-start.sh now applies ArgoCD manifest instead of manual kubectl commands
- ArgoCD auth disabled for local development (no login required)
- Removed separate documentation files (GETTING_STARTED, SETUP, WORKFLOW, etc.)
- Removed docs-server pod and manifest
- Cleaned up broken Ingress resources (cluster-ingress)

### Fixed
- Standardized all labels to use `app.kubernetes.io/name` convention (Kubernetes recommended)
- Pinned nginx image tags from `latest` to `1.27.4-alpine` for reproducibility
- Removed orphaned/bare Pods from cluster (test-curl, fileserver bare pod)

### Removed
- docs-server deployment and ConfigMap
- Separate documentation files (moved to Claude Code maintenance)
- Manual Ingress resources (port-forwarding is sufficient for local dev)
- Login requirement for ArgoCD UI

## [v0.1.0] - Initial Release

### Added
- Local k3s cluster setup via Colima
- ArgoCD for GitOps deployments
- Prometheus for metrics collection
- Grafana for visualization
- Dashboard UI linking to all services
- File server using Nginx with hostPath volume
- quick-start.sh installation script

### Architecture
- k3s running in Colima with Docker
- 5 main services: ArgoCD, Grafana, Prometheus, Dashboard UI, File Server
- All exposed via port-forwarding to localhost
