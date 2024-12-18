### 2024-10-30  10:35
---------------------

**План работы над проектом vpro** _по принципу ручного запуска и остановки ресурсов скриптами_

1. Создать директорию aws-infra и переместить туда Bash скрипты, которые будут служить модулями для развертывания инфорастуктуры
2. Создать модули Bash для запуска серверов db01, mc01 и rmq01 и жестко присвоить им IP
3. Слить ветку aws-man веткой main.
4. Создать новую ветку aws-bash, которая должна отделяться от ветки main.
    В новую ветку aws-bash скопировать файлы из aws-man.
5. Создать основной скрипт Bash для развертывания инфраструктуры, считая, что Cloud Storage уже создано именяться не должно. На данном этапе отдать предпочтение неструктурированному Cloud Storage.
6. Отредактировать основной скрипт Bash для развертывания инфраструктуры таким образом, чтобы:
    - была выдержка 15 минут перед автоматическим удалением развернутой инфраструктуры;
    - создавались VPC, subnets и все, что с этим связано;
    - запускались все четыре экземляра серверов;
    - выполнялся пинг запущенных серверов.
7. Создать модули terraform для запуска серверов db01, mc01 и rmq01 и жестко присвоить им IP
8. Создать модуль terraform для запуска сервера app01, а затем разработать модуль для создания шаблона app01.
9. Отредактировать основной скрипт для развертывания инфраструктуры таким образом, чтобы:
    - была выдержка 15 минут перед автоматическим удалением развернутой инфраструктуры;
    - создавались VPC, subnets и все, что с этим связано;
    - запускались все четыре экземляра серверов;
    - выполнялся пинг запущенных серверов.


### 2024-11-03  21:45
---------------------
Несколько дней работаю над веткой aws-man.
Вчера запустил серверы app01 и db01 в дефолтной VPC.
Данные о проделанной работе - см. директорию ./aws-man/aws-default-vpc-infra/
Подробнее - см. коммит 605886274106ea948c3ae677ef3318efc985d715

Актуальное состояние требует работы над правилами доступа к облачному хранилищу AWS S3.
Решил следующее:
+ создать роль для доступа к AWS S3 bucket
+ доработать скрипты создания AWS S3 bucket и экземпляров всех серверов таким образом, чтобы они могли загрузить файлы из AWS S3 bucket
- запустить экземпляр сервера фронтенда app01 в дефолтной подсети и проверить коннект к AWS S3 bucket
        FRONTEND_CIDR="172.31.48.0/20"
- в подсети 172.31.48.0/20 создать Autoscaling Group
- запустить по одному экземпляру серверов db01, mc01 и rmq01 в дефолтной подсети и проверить коннект к AWS S3 bucket
        BACKEND_CIDR="172.31.64.0/20"
- создать Security Groups, которые сделают подсеть 172.31.64.0/20 приватной, доступной только из 172.31.48.0/20 (далее BACKEND_SUBNET и FRONTEND_SUBNET соответственно)
- разработать скрипт bash верхнего уровня для запуска тестовой среды с четырьмя серверами (без автомасштабирования);
- разработать конфигурацию terraform для того, чтобы развернуть такую же инфраструктуру.

#### Шаги для предоставления необходимых прав:
1. *Перейди в консоль AWS IAM*:
   - Зайди в [консоль AWS IAM](https://console.aws.amazon.com/iam/home).
2. *Найди пользователя*:
   - В левой панели выберите "Users" (Пользователи).
   - Найди и выберите пользователя.
3. *Добавь необходимые разрешения*:
   - Перейди на вкладку "Permissions" (Разрешения).
   - Нажми на кнопку "Add permissions" (Добавить разрешения).
   - Выберите "Attach existing policies directly" (Присоединить существующие политики напрямую).
4. *Выбери необходимые политики*:
   - *AmazonS3FullAccess*: Полная политика доступа к AWS S3.
   - *IAMFullAccess*: Полный доступ к IAM (включая создание ролей).
   - *IAMReadOnlyAccess*: Чтение информации о IAM (необходима только для просмотра, но не для создания).
   - создать специальную политику (например 'devops-lab-policy') для разрешения EC2 экземпляров серверов и для роли <EC2S3ReadOnlyRole>:

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
                "iam:DeleteRole"
            ],
            "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/<EC2S3ReadOnlyRole>"
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
            "Resource": "arn:aws:iam::<ACCOUNT_ID>:instance-profile/<EC2S3ReadOnlyProfile>"
        }
    ]
}
```
6. *Сохранить изменения*

7. Проверить профили политик безопасности
```bash
aws iam list-instance-profiles
# OR
aws iam get-instance-profile --instance-profile-name "<EC2S3ReadOnlyProfile>"
```
```json
{
    "InstanceProfiles": [
        {
            "Path": "/",
            "InstanceProfileName": "<EC2S3ReadOnlyProfile>",
            "InstanceProfileId": "AIPAWX2IF7UXVWEUQATS4",
            "Arn": "arn:aws:iam::<ACCOUNT_ID>:instance-profile/<EC2S3ReadOnlyProfile>",
            "CreateDate": "2024-11-04T09:06:55+00:00",
            "Roles": [
                {
                    "Path": "/",
                    "RoleName": "EC2S3ReadOnlyRole",
                    "RoleId": "AROAWX2IF7UX3PDDGVLWR",
                    "Arn": "arn:aws:iam::<ACCOUNT_ID>:role/<EC2S3ReadOnlyRole>",
                    "CreateDate": "2024-11-04T09:05:07+00:00",
                    "AssumeRolePolicyDocument": {
                        "Version": "2012-10-17",
                        "Statement": [
                            {
                                "Effect": "Allow",
                                "Principal": {
                                    "Service": "ec2.amazonaws.com"
                                },
                                "Action": "sts:AssumeRole"
                            }
                        ]
                    }
                }
            ]
        }
    ]
}
```

8. Проверить текущего активного пользователя AWS через awscli:
```bash
aws sts get-caller-identity
```
9. Читать подробнее
https://repost.aws/knowledge-center/ec2-instance-access-s3-bucket