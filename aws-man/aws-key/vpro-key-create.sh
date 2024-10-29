#!/bin/bash

KEY_NAME="vpro-key"

aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text > "../env/${KEY_NAME}.pem"

chmod 400 "../env/${KEY_NAME}.pem"

if [ $? -eq 0 ]; then
    echo "Пара ключей '$KEY_NAME' успешно создана и сохранена в файле '../env/${KEY_NAME}.pem'."
else
    echo "Ошибка при создании пары ключей '$KEY_NAME'."
fi
