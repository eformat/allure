## allure helm chart

Install allure helm chart

Insatll from source chart
```bash
helm upgrade myallure --set security.user=admin --set security.password=changeme --create-namespace --namespace=allure --install .
```
