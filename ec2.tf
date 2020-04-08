data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "allow_ssh" {
  description = "Allow ssh"
  vpc_id      = "${aws_vpc.myvpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
  description = "Allow ssh"
  vpc_id      = "${aws_vpc.myvpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public-proxy_1" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.public_subnet_1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]
  key_name               = "${aws_key_pair.deployer.id}"
}

resource "aws_instance" "public-proxy_2" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.public_subnet_2.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]
  key_name               = "${aws_key_pair.deployer.id}"
}

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.public_subnet_1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  key_name               = "${aws_key_pair.deployer.id}"
}

resource "aws_instance" "private-proxy_1" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.private_subnet_1.id}"
  key_name      = "${aws_key_pair.deployer.id}"
}

resource "aws_instance" "private-proxy_2" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.private_subnet_2.id}"
  key_name      = "${aws_key_pair.deployer.id}"
}
