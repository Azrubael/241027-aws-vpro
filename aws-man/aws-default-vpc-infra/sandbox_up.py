import subprocess

deploy_order = [
    'aws-s3-default/s3_provide_with_roles.py',
    'aws-sandbox-subnets/sandbox_subnets_tag.py',
    'aws-sandbox-subnets/sandbox_sg_create.py',
    'aws-default-backend/aws-mysql-run.sh',
    #'aws-default-backend/aws-memcache-run.sh',
    #'aws-default-backend/aws-rabbitmq-run.sh',
    'aws-default-frontend/aws-tomcat-run.sh'
]
interpreter = None

for script in deploy_order:
    if script.endswith('.py'):
        interpreter = 'python3'
    elif script.endswith('.sh'):
        interpreter = 'bash'
    else:
        print("Unknown script type:", script)
        exit(1)
    result = subprocess.run([interpreter, script], \
                capture_output=True, check=True, text=True)
    print(f"Script {script} output:\n", result.stdout)
    if result.stderr:
        print(f"Script {script} Error:\n", result.stderr)

print(" +++ The deployment of SANDBOX has completed. +++ ")
