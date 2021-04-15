## Allure helm chart

Install allure helm chart.

Based on an upstream allure project that repackages [Allure](https://github.com/allure-framework/allure2/releases/)

- https://github.com/fescobar/allure-docker-service

Install from source chart
```bash
helm upgrade myallure --set security.user=admin --set security.password=changeme --create-namespace --namespace=allure --install .
```

## Sending test results

The scripts file can be used to send results from `target/allure-results` directory. It logs in to allure, creates a project called `my-app-name` and sends the test report results.

```bash
send_results.sh my-app-name `pwd` admin changme $ALLURE_H
```

Tested using the allure-maven plugin, but many languages are supported.
