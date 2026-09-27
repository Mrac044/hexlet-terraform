# Simple terraform manifests for yandex cloud

## Infrastructure descriprion

-

## Using

### Repository copying

Copy repo from github by url or ssh and move to the folder:

URL: `git clone https://github.com/Mrac044/hexlet-terraform.git && cd hexlet-terraform`
SSH: `git clone git@github.com:Mrac044/hexlet-terraform.git && cd hexlet-terraform`

### Terraform profider initialization

Init yandex-cloud terraform provider:

`terraform init`

### Terraform authorization

By yandex instruction, create a service account for terraform and get authorization key as a file. File path put into terraform manifest

`variable "service_account_key_file" {<your auth key>}`