## allure helm chart

Install allure helm chart.

Based on an upstream allure project that repackages [Allure](https://github.com/allure-framework/allure2/releases/)

- https://github.com/fescobar/allure-docker-service

Install from source chart
```bash
helm upgrade myallure --set security.user=admin --set security.password=changeme --create-namespace --namespace=allure --install .
```
