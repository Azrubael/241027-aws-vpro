### 2024-11-20    10:10
=====================

#### Это полностью работающая тестовая версия проекта VPRO.
#### При помощи конфигурации Терраформ запускаются пять серверов в одной субсути Sandbox:
- jump01 - бастион-сервер;
- app01 - собственно Java веб-приложение на базе TomCat;
- db01 - база данных MySQL;
- mc01 - MemcacheD сервер, его работу можнопроверить через меню администрирования веб-приложения;
- rmq01 - RabbitMQ сервер (обработка очередей).
#### Для тестирования работы сервера db01 можно воспользоваться скриптом:
```bash
cd /tmp/provis*
sudo -i
python3 mysql_check.py
```
#### Этот скрипт автоматически загружается при конфигурировании и jump01 и app01.


###### Примечания:
- ранее я пытался запустить данное приложение в двух субсетях. Это не удалось. Причина оказалась в особенностях синтаксиса шаблонов *.sh, которые корректно импортируют передаваемые переменные только для "${variable}";
- далее я предполагаю выполнить работы по рефакторингу на модули, запуск Auto Scaling group и перенос микросервисов бэкенда в приватную субсеть.