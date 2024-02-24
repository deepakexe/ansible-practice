#data call to fetch the ami id
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # AMAZON's AWS account ID for official Amaon linux 2023 AMIs

  filter {
    name   = "name"
    values = ["al2023-ami-2023.2.20231016.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



#aws ec2 instance
resource "aws_instance" "main" {

    ami           = data.aws_ami.amazon_linux.id
    instance_type = var.ec2_conf.instance_type
    subnet_id     = var.ec2_subnet_id
    iam_instance_profile = aws_iam_instance_profile.test_profile.name
    vpc_security_group_ids = [aws_security_group.main.id]
    tags = {
        Name =  var.ec2_conf.name
    }
}


#security group
resource "aws_security_group" "main" {
  name        = var.ec2_conf.sg.name
  description = var.ec2_conf.sg.description
  vpc_id      = var.vpc_id

  egress {
    from_port        = var.ec2_conf.sg.egress.from_port
    to_port          = var.ec2_conf.sg.egress.to_port
    protocol         = var.ec2_conf.sg.egress.protocol
    cidr_blocks      = var.ec2_conf.sg.egress.cidr_blocks
  }

  tags = {
    Name = var.ec2_conf.sg.name
  }
}


#IAM Role
resource "aws_iam_role" "test_role" {
  name = var.ec2_conf.iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

#instance profile
resource "aws_iam_instance_profile" "test_profile" {
  name = var.ec2_conf.iam_instance_profile_name
  role = "${aws_iam_role.test_role.name}"
}

#policy attchment
resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  role       = "${aws_iam_role.test_role.name}"
  count      = "${length(var.ec2_conf.iam_policy_arn)}"
  policy_arn = "${var.ec2_conf.iam_policy_arn[count.index]}"
}