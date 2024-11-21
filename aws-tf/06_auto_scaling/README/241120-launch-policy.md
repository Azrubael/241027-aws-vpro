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


### 2024-11-21  13:50
---------------------

#### Applicatoin Autoscaling Group with Launch Configuration не удалось запустить.
Для Launch Template  пришлось создать и подключить к авторизованному пользователю AWS следующую политику:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateLaunchTemplate",
                "ec2:DescribeLaunchTemplates",
                "ec2:DeleteLaunchTemplate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::463470984495:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
                "arn:aws:iam::463470984495:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DeleteAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
```
#  === OR ===
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateLaunchTemplate",
                "ec2:DescribeLaunchTemplates",
                "ec2:DeleteLaunchTemplate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:PassRole"  // This may be needed if you are passing roles to the Auto Scaling Group
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DeleteAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
```

#### Это потребовалось для устранения следующй ошибки:
│ Error: creating Auto Scaling Group (terraform-20241121120105450900000004): operation error Auto Scaling: CreateAutoScalingGroup, https response error StatusCode: 403, RequestID: a1c221fa-84a3-4991-92a1-7a5dc5ae4b82, api error AccessDenied: The default Service-Linked Role for Auto Scaling could not be created.  com.amazonaws.services.identitymanagement.model.AmazonIdentityManagementException: User: arn:aws:iam::463470984495:user/devops is not authorized to perform: iam:CreateServiceLinkedRole on resource: arn:aws:iam::463470984495:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling because no identity-based policy allows the iam:CreateServiceLinkedRole action (Service: AmazonIdentityManagement; Status Code: 403; Error Code: AccessDenied; Request ID: c2bbce3f-bed3-4e05-9fdf-b1c214b728b3; Proxy: null)
│ 
│   with aws_autoscaling_group.tomcat_asg,
│   on autoscaler_with_template.tf line 37, in resource "aws_autoscaling_group" "tomcat_asg":
│   37: resource "aws_autoscaling_group" "tomcat_asg" {

