### 2024-11-20  18:50
---------------------

#### С целью экономии на затратах из-за создания образов, я решил пробовать создавать Launch Configuration вместо Launch Template для Applicatoin Autoscaling Group.
Для этого пришлось создать и подключить к авторизованному пользователю AWS следующую политику:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CreateLaunchConfiguration",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DeleteLaunchConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "arn:aws:iam::463470984495:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"
        }
    ]
}
```

#### Это потребовалось для устранения следующй ошибки:
```text
│ Error: creating Auto Scaling Launch Configuration (tomcat-launch-conf): operation error Auto Scaling: CreateLaunchConfiguration, https response error StatusCode: 400, RequestID: 55ea69ef-e6c7-4b8a-9700-7d923abe9ed2, api error UnsupportedOperation: The Launch Configuration creation operation is not available in your account. Use launch templates to create configuration templates for your Auto Scaling groups.
│ 
│   with aws_launch_configuration.tomcat_lc,
│   on autoscaler.tf line 2, in resource "aws_launch_configuration" "tomcat_lc":
│    2: resource "aws_launch_configuration" "tomcat_lc" {
│ 
```