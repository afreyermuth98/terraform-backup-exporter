# Terraform Backup Exporter

This project contains base IaC to deploy a lambda that exports backups & restores informations into CSV and sends an email when this is done. By default, the lambda is triggered each day at 3pm

## Prerequisites
You must have AWS Backup enabled on your account / region

## Needs
You need to confirm the SNS subscription once the terraform is applied
