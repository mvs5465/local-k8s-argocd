# Grafana Dashboards: Pre-Built Cluster Stats

You now have 3 pre-built Kubernetes dashboards loaded automatically. No UI configuration needed—they were provisioned via Helm chart.

## The 3 Dashboards

### 1. **Kubernetes Cluster** (gnetId: 7249)
Shows overall cluster health:
- Node CPU, memory, disk usage
- Pod count by namespace
- Container restarts
- Network I/O
- Top consumers by namespace

**Use this for:** Quick cluster health check

### 2. **Kubernetes Pods** (gnetId: 6417)
Detailed pod-level metrics:
- Pod CPU & memory usage (per namespace)
- Pod request vs actual usage
- Network I/O per pod
- Restart counts
- Pod status overview

**Use this for:** Identifying resource hogs, finding expensive pods

### 3. **Cluster Monitoring** (gnetId: 8588)
Deep cluster dive:
- kube-apiserver latency
- etcd performance
- Kubelet metrics
- Container runtime stats
- Persistent volume usage

**Use this for:** Troubleshooting cluster issues

## How to Access

1. Go to http://localhost:3000
2. Log in: admin / admin
3. Click the hamburger menu (top left)
4. Select "Dashboards"
5. Click any of the 3 dashboards

Or go directly:
- http://localhost:3000/d/kubernetes-cluster
- http://localhost:3000/d/kubernetes-pods
- http://localhost:3000/d/cluster-monitoring

## How It Works (The Codified Way)

In `manifests/grafana-app.yaml`:

```yaml
dashboards:
  default:
    kubernetes-cluster:
      gnetId: 7249        # Grafana.com dashboard ID
      revision: 1
      datasource: Prometheus
    kubernetes-pods:
      gnetId: 6417
      revision: 1
      datasource: Prometheus
    cluster-monitoring:
      gnetId: 8588
      revision: 1
      datasource: Prometheus
```

When Grafana starts:
1. Init container runs (curlimages/curl)
2. Downloads JSON from grafana.com API
3. Stores in `/var/lib/grafana/dashboards/default`
4. Grafana provisioner loads them
5. Available in UI

If you add a new dashboard:
```yaml
my-custom-dashboard:
  gnetId: XXXX
  revision: 1
  datasource: Prometheus
```

Push to git → ArgoCD syncs → Grafana auto-loads within seconds.

## Adding More Dashboards

1. Find a dashboard on [grafana.com/grafana/dashboards](https://grafana.com/grafana/dashboards)
2. Note the dashboard ID (URL: `https://grafana.com/grafana/dashboards/{ID}`)
3. Add to `manifests/grafana-app.yaml`:

```yaml
dashboards:
  default:
    kubernetes-cluster:
      gnetId: 7249
      revision: 1
      datasource: Prometheus
    my-new-dashboard:          # <-- add this
      gnetId: 12345            # <-- new dashboard ID
      revision: 1
      datasource: Prometheus
```

4. Commit and push
5. Within 3 minutes, ArgoCD syncs and dashboard is auto-loaded

## Customizing Dashboards

The dashboards are read-only by default (provisioned, not editable in UI).

To make them editable in the UI:
```yaml
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'default'
      disableDeletion: false
      editable: true          # <-- set to true
```

Then edit in UI, but changes won't persist across restarts.

## Dashboard Data Source

All three dashboards query **Prometheus** at `http://prometheus:9090`.

The Helm chart automatically:
- Replaces all datasources with "Prometheus" (the one you configured)
- Maps to the correct Prometheus service in the cluster
- Works because both are in the `monitoring` namespace

## What These Dashboards Need

They require:
- ✅ Prometheus (you have it)
- ✅ kube-state-metrics (deployed with Prometheus)
- ✅ node-exporter (deployed with Prometheus)

Everything is already there!

## If Dashboards Don't Show

Check:
1. Prometheus is running: `kubectl get pods -n monitoring | grep prometheus-server`
2. Grafana pod is ready: `kubectl get pods -n monitoring | grep grafana`
3. Check Grafana logs: `kubectl logs -n monitoring -l app.kubernetes.io/name=grafana`
4. Check init container logs: `kubectl logs -n monitoring -l app.kubernetes.io/name=grafana -c download-dashboards`

Common issues:
- **Dashboards don't appear:** Wait 30 seconds for provisioning to finish
- **Dashboard data is empty:** Prometheus hasn't scraped yet (wait 2 minutes)
- **TLS error:** Might be firewalled, check `curl https://grafana.com/api/dashboards/7249/revisions/1/download`

## Next Steps

- Explore the dashboards, see what metrics are available
- Try filtering by namespace, pod, node
- Create custom dashboards in the UI
- Set up alerts in Prometheus (optional)
