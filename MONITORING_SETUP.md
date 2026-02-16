# Monitoring Stack: Prometheus + Grafana

You now have a complete monitoring stack running on your cluster!

## What You Have

### Prometheus (metrics collection)
- **URL:** http://localhost:9090
- **Job:** Scrapes metrics from K8s API, nodes, pods, etc.
- **Storage:** 2GB persistent volume, 7 day retention
- **Metrics collected:** 48,000+ time series (K8s internals, node stats, etc)

### Grafana (visualization)
- **URL:** http://localhost:3000
- **Credentials:** admin / admin
- **Datasource:** Pre-configured to query Prometheus

### Supporting Components
- **kube-state-metrics** - exports K8s object state as metrics
- **node-exporter** - exports node-level metrics (CPU, memory, disk, etc)
- **prometheus-pushgateway** - optional, for batch jobs to push metrics

## What Prometheus Is Scraping

Out of the box, it's collecting:

1. **K8s API Server** - request rates, latencies, errors
2. **etcd** - database performance
3. **Kubelet** - node resource usage, pod stats
4. **Scheduler** - job scheduling metrics
5. **Node data** - CPU, memory, disk, network from node-exporter

## Next: Add Dashboards to Grafana

1. Log in to Grafana: http://localhost:3000 (admin/admin)
2. Click "+" → "Dashboard" → "Create"
3. Click "Add visualization"
4. Select "Prometheus" datasource
5. Example queries:
   ```
   # Node CPU usage
   100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

   # Pod memory usage
   container_memory_usage_bytes{pod!=""}

   # API server requests per second
   rate(apiserver_request_total[5m])
   ```

Or browse the [Grafana Dashboard Library](https://grafana.com/grafana/dashboards) for K8s dashboards to import.

## How It's Deployed

Both are deployed via ArgoCD Applications:
- `grafana-app.yaml` - Grafana Helm chart
- `prometheus-app.yaml` - Prometheus Helm chart

Changes to these files → git push → ArgoCD auto-syncs.

## Port-Forwarding Note

Two background processes are running:
```bash
# ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Prometheus (if you close/reopen terminal)
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
```

If you restart your terminal, you'll need to re-run the port-forward commands.

## Storage

- Prometheus: 2GB persistent volume (resets on deletion)
- Grafana: No persistent storage (dashboards reset on pod restart)
  - To keep dashboards: enable persistent storage in `grafana-app.yaml`

## Performance

- Prometheus uses ~300MB memory
- Grafana uses ~128MB memory
- node-exporter uses minimal resources
- Well within limits of a personal laptop

---

**Pro tip:** To see all scrape targets, visit http://localhost:9090/targets
