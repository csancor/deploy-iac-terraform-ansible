# deploy-iac-terraform-ansible

É preciso ter conta na AWS com os privilégios necessários para criar, atualizar e remover recursos no EC2. Além de ter o acesso configurado localmente(ex: credentials Access Key Id e Secret Access Key).
Também é necessário possuir um domínio registrado no serviço Route53 da AWS.

## Cuidados

1. O código deste repositório admite que os usuários já possuam um nome de domínio Route53.
2. Seguir e implantar recursos na AWS, conforme ensinado por este código, INCORRERÁ EM TARIFAS!!! Certifique-se de destruir qualquer infraestrutura que você não precisa."

## Ferramentas e plataforma utilizada

* Ansible e Terraform rodando localmente pelo WSL *Ubuntu22.04 WSL no Windows 10*.

## Ferramentas instaladas no ambiente Linux ou pelo WSL usando Ubuntu 22.04

* Terraform
* Python 3
* pip3
* aws cli(v2)
* Ansible

### Ambiente da AWS

A AMI utilizada na AWS é a Amazon Linux 2 na região de us-east-1

## Principais etapas

Vamos utilizar a região us-east-1 para:

1. Criar uma VPC.
2. Estabelecer duas subnets públicas em us-east-1.
3. Anexar um Gateway de Internet.
4. Configurar um par de chaves SSH para acesso à instância.
5. Configurar o Jenkins no Application Load Balancer.
6. Obter um certificado HTTPS usando o AWS Certificate Manager (ACM) para * garantir comunicações seguras (HTTPS). Os detalhes serão explicados a seguir.
7. Utilizar o Route 53 para facilitar o acesso via DNS*. 

**O Route 53 é usado para simplificar o acesso aos recursos da infraestrutura por meio de nomes de domínio amigáveis, em vez de depender de endereços IP complexos*.

Nota: Pode ser necessário ajustar restrições ou políticas de segurança de acordo com o ambiente e/ou recomendações de segurança. Consulte a documentação da AWS IAM para obter orientações adicionais.

### Onde o Ansible atua nesse projeto?

O Ansible é utilizado durante a etapa de subida da instância onde o playbook é executado através de um provisioner que executa dois passos:
* Checar se a instância está pronta
* Quando a instância estiver pronta o ansible playbook **jenkins-controller.yml** entra em ação

```python

  provisioner "local-exec" {
    command = <<EOF
    aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-controller} --instance-ids ${self.id}
    ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-controller.yml
    EOF
  }
```

### S3 backend

Crie um bucket para o seu backend ou caso já possua, substitua o nome de bucket no arquivo backend.tf:

```python
terraform {
  required_providers {
    aws = ">=3.0.0"
  }
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraform-state-file"
    bucket  = "<NOME-DE-UM-BUCKET-EXISTENTE>" 
  }
}

```

## Configurar o DNS

Alterar o valor da variável dns-name.

```python
variable "dns-name" {
  type    = string  
  default = "<public-hosted-zone-terminada-com-ponto>" # ex: "mydns1234.info."
}
```

## Aplicando as alterações

* No diretório raiz, execute o comando `terraform init`
* Utilize `terraform validate` e corrija a configuração caso precise.
* Verifique as alterações que serão inseridas pelo o comando `terraform plan`
* Aplique as alterações com o comando `terraform apply`, confirmando com `yes`

## Como acessar o Jenkins

Após a etapa realizada pelo terraform apply, copie o output que apresenta a `url` e cole em seu browser.

Para acessar a instância e pegar a senha de administrador, copie o IP fornecido em `jenkins-controller-node-public-ip` e acesse a sua instância via SSH com o comando:

```bash
ssh ec2-user@JENKINS-IP
```

Vizualizar o admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

## Desfazer as alterações

Utilize o comando `terraform destroy` e confirme com `yes` ou se preferir passe a flag `--auto-approve`

### Comandos úteis - exemplos

* Criar um bucket no S3(não utilizar em produção, somente em testes e dev): `aws s3api create-bucket --bucket <bucket-name-12150045>`

* Listar hosted zones - Route53 `aws route53 list-hosted-zones`

* Checar sintaxe do playbook Ansible `ansible-playbook --syntax-check <playbook-filename>.yml`
