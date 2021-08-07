data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"] #From the EC2 console, AMI search

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "random_id" "mtc_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {  # This will force the random_id to change
    "key_name" = "var.key_name"
  }
}

resource "aws_key_pair" "mtc_auth" {
  key_name = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "namtc_nodee" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id
  tags = {
    "Name" = "mtc_node-${random_id.mtc_node_id[count.index].dec}"
  }

  key_name = aws_key_pair.mtc_auth.id 
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]
  user_data = templatefile(var.user_data_path,
    {
        nodename = "mtc_node-${random_id.mtc_node_id[count.index].dec}"
        db_endpoint = var.dbendpoint
        dbuser = var.dbuser
        dbpass = var.dbpassword
        dbname = var.dbname
    }
  )
  root_block_device {
    volume_size = var.volume_size
  }
}
