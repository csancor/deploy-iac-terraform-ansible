# Get Linux AMI ID using SSM Parameter Store endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-controller
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#############
# Key Pairs #
#############
#Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "controller-key" {
  provider   = aws.region-controller
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#######
# EC2 #
#######

#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "jenkins-controller" {
  provider                    = aws.region-controller
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.controller-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id

  provisioner "local-exec" {
    command = <<EOF
    aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-controller} --instance-ids ${self.id}
    ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-controller.yml
    EOF
  }

  tags = {
    Name = "jenkins_controller_tf"
  }

  depends_on = [aws_main_route_table_association.set-controller-default-rt-assoc]
}
