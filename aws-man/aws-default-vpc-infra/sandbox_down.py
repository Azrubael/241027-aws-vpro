import subprocess

clean_order = [
    'aws-default-frontend/aws-tomcat-terminate.sh',
    'aws-default-backend/aws-mysql-terminate.sh',
    #'aws-default-backend/aws-memcache-terminate.sh',
    #'aws-default-backend/aws-rabbitmq-terminate.sh',
    'aws-sandbox-subnets/sandbox_sg_delete.py'
]
interpreter = None

for script in clean_order:
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

print("\n --- Cleaning of SANDBOX finished --- ")

