# Terraform layout
One integrated `dev` state keeps module outputs/dependencies explicit. `bootstrap` is a separate state. Each AWS service is an independent module with its own `.tf` files. Do not create separate states per service for this lab baseline.
