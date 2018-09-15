locals {
    #l_tfenv_name = "packerbuild"
    l_tfenv_cidr = "10.1.0.0/23"
    l_tfenv_cidr_prefix = "10.1.0"
    l_tfenv_aws_region = "us-east-2"
    l_tfenv_aws_profile = "terraform"
}

locals {
    l_tfenv_tags = "${map(
        "env", "packerbuild"
    )}"
}

provider "aws" {
    region = "${local.l_tfenv_aws_region}"
    profile = "${local.l_tfenv_aws_profile}"
}

module "tfmodpackerbuildenv" {
    source = "../donb.aws.tfmod.packerbuildenv"
    env_name = "${lookup(local.l_tfenv_tags, "env")}"
    vpc_cidr = "${local.l_tfenv_cidr}"
    vpc_cidr_prefix = "${local.l_tfenv_cidr_prefix}"
}