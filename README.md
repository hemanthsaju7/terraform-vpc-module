# terraform-vpc-module

A group of standard configuration files in a specific directory make up a Terraform module. Terraform module allows you to group resources together and reuse this group later, possibly many times.

Here is a simple document on how to use Terraform to build an AWS VPC along with private/public Subnet and Network Gateway's for the VPC. We will be making 1 VPC with 6 Subnets: 3 Private and 3 Public, 1 NAT Gateways, 1 Internet Gateway, and 2 Route Tables
