### 2024-11-11  13:05
---------------------


1. The directories description [the project's stages] :
./01_simplest
##### A successful attempt to create two servers (bastion and backend) in the default VPC. But the question of interaction via SSH between them has not yet been resolved. Bastion jump server is in the public subnet and backend db server is in the private subnet.

./02_remote_access
##### The next attempt with the proper setup of the both above described servers. It is a successfull attempt to run on AWS three servers: Bastion [jump01], TomCat [app01], MySQL [db01]. 
##### Also it has 'bastion NAT' to connect backend with WAN.
##### This configuration was run on the default VPC with two subnets.

./03_five_vms
##### The more complicate variant with the next servers:
- Bastion [jump01]
- TomCat [app01]
- MySQL [db01]
- MemcacheD [mc01]
- RabbitMQ [rmq01]
##### Also it has 'bastion NAT' to connect backend with WAN.
##### This configuration was run on the default VPC with two subnets.


2. The deployment order using Terraform:
```bash
cd tfinfra
terraform init -backend-config=terreform.tfvars
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve -input=false
terraform state list
terraform show
terraform graph | dot -Tpng -o graph.png
terraform destroy -auto-approve -input=false
```


3. The simplest aws user's policy:
```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"iam:CreateRole",
				"iam:CreatePolicy",
				"iam:PutRolePolicy",
				"iam:AttachRolePolicy",
				"iam:PassRole",
				"iam:DeletePolicy",
				"iam:DeleteRole",
				"iam:DeleteRolePolicy",
				"iam:DetachRolePolicy",
				"iam:DeleteInstanceProfile",
				"iam:RemoveRoleFromInstanceProfile",
				"iam:CreateInstanceProfile",
				"iam:AddRoleToInstanceProfile",
				"iam:PassRole"
			],
			"Resource": "*"
		}
	]
}
```


4. The more complicate aws user's policy:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:PutRolePolicy",
                "iam:AttachRolePolicy",
                "iam:PassRole",
                "iam:DeleteRolePolicy",
                "iam:DeleteRole",
                "iam:CreatePolicy",
                "iam:PutRolePolicy"
            ],
            "Resource": [
                "arn:aws:iam::463470984495:role/EC2S3ReadOnlyRole",
                "arn:aws:iam::463470984495:role/EC2S3ReadOnlyRoleTF"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:DeleteInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::463470984495:instance-profile/EC2S3ReadOnlyProfile",
                "arn:aws:iam::463470984495:instance-profile/EC2S3ReadOnlyProfileTF"
            ]
        }
    ]
}
```


5. Опция `-out` для команды `terraform plan` позволяет сохранить результат выполнения команды в файл, который затем можно использовать для применения изменений с помощью команды `terraform apply`.
```bash
terraform plan -out=<имя_файла>
```

### Пример использования
```bash
terraform plan -out=myplan.tfplan
terraform apply myplan.tfplan
```

### Примечания
- Если вы не укажете имя файла, Terraform по умолчанию создаст файл с именем `terraform.tfplan`.
- Файл плана содержит информацию о том, какие изменения будут внесены в инфраструктуру, и его можно использовать для проверки перед применением.
- Если вы хотите удалить файл плана после его применения, вы можете сделать это вручную, так как Terraform не удаляет его автоматически.
