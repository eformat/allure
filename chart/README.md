## grafana helm chart

Install grafana using operator namespaced subscription.

Patches the Grfana Datasource with the bearer token to read user workload monitoring thanos querier.

Includes auth proxy to OpenShift.

Insatll from source chart
```bash
helm upgrade mygrafana --create-namespace --namespace=grafana-test --install --set createOg=true .
```

You can get the grafana admin creds from the generated secret
```bash
oc get secret grafana-admin-credentials -o=jsonpath='{.data.GF_SECURITY_ADMIN_USER}' | base64 -d; echo
oc get secret grafana-admin-credentials -o=jsonpath='{.data.GF_SECURITY_ADMIN_PASSWORD}' | base64 -d; echo
```
