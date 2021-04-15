## Allure image

Keep a version in quay.io

Also need to store the swagger to copy into a PVC later. we could do this from the image itself.

When security turned on, the app.py writes to disk which breaks in OpenShift, hence the need to use storage.
