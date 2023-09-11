#Create SG for LB, only TCP/80,TCP/443 and outbound access
resource "aws_security_group" "lb-sg" {
  provider    = aws.region-controller
  name        = "lb-sg"
  description = "Allow 443 and traffic to Jenkins SG"
  vpc_id      = aws_vpc.vpc_controller.id
  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 80 from anywhere for redirection"
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

#########################
# Jenkins Controller SG #
#########################

#Create SG for allowing TCP/8080 from * and TCP/22 from your IP in us-east-1
resource "aws_security_group" "jenkins-sg" {
  provider    = aws.region-controller
  name        = "jenkins-sg"
  description = "Allow TCP/8080 & TCP/22"
  vpc_id      = aws_vpc.vpc_controller.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external-ip]
  }
  ingress {
    description     = "allow anyone on port 8080"
    from_port       = var.webserver-port
    to_port         = var.webserver-port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
