provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "devops_tower" {
	ami = "ami-02ccb28830b645a41"
	instance_type = "t2.medium"
	availability_zone = local.availability_zone
	tags = {
		Name = "DevOps Tower",
    Role = "Management",
    Guru = "Zakaria Boualaid"
	}
	iam_instance_profile = "DevOpsTower"
  key_name = "admin-key"
	subnet_id = aws_subnet.subnet-neo-1.id
	security_groups = [aws_security_group.ingress-all.id]
	root_block_device {
		volume_size = 20
	}
  provisioner "remote-exec" {
		inline = ["echo 'hello neo'"]
		
		connection {
			type = "ssh"
			user = local.ssh_user
      host = aws_instance.devops_tower.public_ip
			private_key = file(local.private_key_path)
		}
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.devops_tower.public_ip} --private-key ${local.private_key_path} ../ansible/devops_tower.yml" 
  }
}

resource "aws_ebs_volume" "mgmt_srv_volume" {
	availability_zone = local.availability_zone
	size              = 30
	tags = {
		Name = "DevOps Tower EBS",
    Role = "Management",
    Guru = "Zakaria Boualaid"
	}
}

resource "aws_volume_attachment" "mgmt_srv_ebs_att" {
	device_name = "/dev/sdh"
 	volume_id   = aws_ebs_volume.mgmt_srv_volume.id
	instance_id = aws_instance.devops_tower.id
}

resource "aws_vpc" "neo" {
	cidr_block = "10.10.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support = true
	tags = {
		Name = "Neo"
		Guru = "Zakaria Boualaid"
	}
}

resource "aws_subnet" "subnet-neo-1" {
	cidr_block = cidrsubnet(aws_vpc.neo.cidr_block, 6, 1)
	vpc_id = aws_vpc.neo.id
	availability_zone = local.availability_zone
	map_public_ip_on_launch = true
}


resource "aws_security_group" "ingress-all" {
	name = "allow-all-sg"
	vpc_id = aws_vpc.neo.id
	ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
		from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 	}
}


