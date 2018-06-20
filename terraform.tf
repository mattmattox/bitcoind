variable "app_name" { default = "bitoind" }

provider "aws" {
  region     = "us-east-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

variable "vpc_id" {}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${var.vpc_id}"
}

data "template_file" "userdata" {
  template       = "${file("userdata.tpl")}"
}

resource "aws_launch_configuration" "daemon_lc" {
  name_prefix   = "${var.app_name}-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.large"

  associate_public_ip_address = true

  user_data            = "${data.template_file.userdata.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bitcoind" {
  name_prefix          = "${var.app_name}-"
  vpc_zone_identifier  = [ "${data.aws_subnet_ids.subnets.0.ids}" ]
  min_size             = 2
  max_size             = 5

  launch_configuration = "${aws_launch_configuration.daemon_lc.id}"

  lifecycle {
    create_before_destroy = true
  }
}
