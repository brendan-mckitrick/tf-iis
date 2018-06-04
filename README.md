# Simple Terraform IIS exercise

This `README` details how to use this codebase, the overall requirements and aims of the exercise, and a _lot_ of notes for further consideration / development.


## To use:
1. Install terraform
2. Checkout this repo
3. Copy `environments/secrets.tfvars.example` to `/environments/secrets.tfvars` and enter the credentials as detailed
4. Fire up your command line and `cd` to the root of this repo
5. `terraform init accounts/papabravo`
6. `terraform plan -var-file=environments/papabravo/prod.tfvars -var-file=environments/secrets.tfvars accounts/papabravo/`
7. If all looks well, then `terraform apply -var-file=environments/papabravo/prod.tfvars -var-file=environments/secrets.tfvars accounts/papabravo/`
8. When finished, remove it all by running `terraform destroy -var-file=environments/papabravo/prod.tfvars -var-file=environments/secrets.tfvars accounts/papabravo/`. Or RIP credit card.


Common configuration details can be found in the following file:
* `/environments/papabravo/prod.tfvars`
* `/environments/secrets.tfvars`

Tested using the following:

```
~/P/tf-iis ❯❯❯ terraform --version                                                                                                                                                                 ✘ 130
Terraform v0.11.7
+ provider.aws v1.21.0
```


# Requirements of the exercise

## The stack

### Frontend application
* IIS
* .net4
* 4GB RAM
* 2 vCPU
* stateful

### Backend application
* IIS
* .net4
* 4GB RAM
* 2 vCPU
* requires database

### Database
* MS SQL aka SQL Server

## Aims
* frontend and backend applications are stateful
* business critical - highly available and performance
* best practice in architecture and security
* cost effective where possible


## Assumptions
* "not stateless" ; the applications aren't doing session handling. Needs application load balancers with sticky sessions enabled at both endpoints to cover this if HA is a firm requirement. 30 minutes is the assumed stickiness
* the load balancer accepts traffic on ports 80 (HTTP) and 443 (HTTPS) and handles SSL termination
* the frontend application accepts traffic on port 80 and queries the backend application on port 80
* the backend application accepts traffic on port 80
* the DB servers accept traffic on port 1443 from the backend application hosts only
* application and database hosts do not need access to internet
* AWS is the chosen provider
    * an IAM user ('terraform-prod-papabravo') is used which has the relevant API-only permissions.
    * we are using Ireland (eu-west-1)
    * application images are stored as pre-baked AMI's in AWS account, built via a separate pipeline process and uploaded to account ready for use
    * standard AWS scaffolding - enabling Cloudtrail, declaring IAM users/policies, Lambda functions for maintenance - are excluded from scope
    * DNS management is outside scope



## Solution
* one non-default VPC, two subnets per AZ ; one public, one private
* internet gateway attached to VPC
* frontend load balancer sits in public subnet, publicly exposed
* backend load balancer sits in private subnet
* application assets and RDS DB's sit in private subnet
* tag early, tag often (where appropriate & supported)



# The approach so far...
* for efficiency, both the frontend and backend applications could be co-located on the same host, with ALB target groups routing traffic to different ports on the same host ; this could be a sensible solution if the load of one application is light compared to the other whilst providing scaling options and sticky-session compatibility, although may present some security compromises
* for ease, the AMI names are specified in human-friendly format. Depending on the build and deploy method used this could change ; for example, a pipeline could create and publish a new AMI for the application(s), and then pass on the AMI ID as a command-line argument to Terraform
* for DNS, typically this would be combined with registering a friendly presentation name in route53 and assigning that to the public load balancer via an ALIAS record
* egress rules on security groups are set to internal subnets instead of the standard "security group" practice. This is due to a not-fully-fixed issue which occasionally pops up, presenting as the error below and needing manual intervention to fix. The impact of this is minor as ingress rules on the target security groups perform the relevant filtering in any case.

```
* aws_security_group_rule.backend_load_balancer_ingress: [WARN] A duplicate Security Group rule was found on (sg-91ecadec). This may be
a side effect of a now-fixed Terraform issue causing two security groups with
identical attributes but different source_security_group_ids to overwrite each
other in the state. See https://github.com/hashicorp/terraform/pull/2376 for more
information and instructions for recovery. Error message: the specified rule "peer: sg-ebbbfa96, TCP, from port: 80, to port: 80, ALLOW" already exists
```

* plenty of standard stuff has not been done so far in this exercise, including:
    * SSL!
    * DNS!
    * Multi-AZ support for the RDS server
    * A considered approach to HA; eg, care to ensure instances/traffic stick in aligned AZ's where possible
    * combining code into modules to keep it D.R.Y.
    * logs - cloudtrail, vpc flow, load balancer, etc
    * monitoring and scaling conditions
    * bastion hosts to provide SSH and/or RDP access to hosts, including client VPN connectivity (ie, OpenVPN or similar)
    * terraform state stored in S3 bucket
    * intensive testing and elimination of dependency conditions that make changing resources difficult (or impossible) without manual intervention
    * standardised naming and tagging conventions
    * consistent use of variables throughout state code to fully support separate environments
    * evaluation/configuration of maintenance/snapshot schedules, and approach to safety (eg, ensuring snapshots taken of RDS DB before deletion)
    * CDN and WAF features for assets facing DMZ
    * proper testing ; 'hello world' Apache instances on port 80 are the extend thus far




