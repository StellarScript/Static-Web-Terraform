# Terraform

</br>

## Setup Terraform Cloud

### Repalce Terraform cloud organization & workspace

- in `apps/terraform/src/backend.tf` file replace organization & workspace with your workspace.
- run Terraform login then init commands to initialize your workspace.

</br>
</br>

## Terraform Commands

### login

```sh
terraform login
```

### Pull State

```sh
nx state-pull terraform
```

### Init

```sh
nx run-init terraform
```

### Plan

```sh
nx plan terraform
```

### apply

```sh
nx apply terraform
```
