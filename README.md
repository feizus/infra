# infra
Infra repository

# Homework 5 GCP & VPN

Генерим ssh-ключи:

```bash
ssh-keygen -t rsa -f ~/.ssh/astarot_dead -C astarot_dead -P ""
```

Подключаемся к bastion:
```bash
ssh -i ~/.ssh/astarot_dead astarot_dead@35.217.54.73
```

## Самостоятельное задание 1

_Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства_

Для подключения в одну команду можно использовать туннель до хоста, не имеющего прямого доступа, через открытый хост.
```bash
ssh -L 22:10.166.0.3:22 35.217.54.73
```

- Подробная статья на тему туннелирования - [Магия SSH](https://habr.com/ru/post/331348/)
- Примеры туннелирования - [SSH PORT FORWARDING EXAMPLE](https://www.ssh.com/ssh/tunneling/example)
- Полезные примеры использования ssh - [SSH Cheat Sheet](http://pentestmonkey.net/cheat-sheet/ssh-cheat-sheet)

### Дополнительное задание:
_Предложить вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost из локальной консоли рабочего устройства, чтобы подключение выполнялось по
алиасу someinternalhost_

Различные настройки ssh клиента можно задать в специальном конфигурационном файле, в том числе alias для подключения. 

```
~/.ssh/config
Host bastion
		Hostname 35.217.54.73
		User astarot_dead
		Port 22
		IdentityFile ~/.ssh/astarot_dead		
```

После создания такой конфигурации можно подключаться по имени:
```bash
ssh bastion
```

Используем Bastion host для сквозного подключения c SSH Agent Forwarding (-A):
```bash
ssh -i ~/.ssh/astarot_dead -A astarot_dead@35.217.54.73
```

```
@bastion:~/.ssh/config
#someinternalhost
Host inthost
	Hostname 10.166.0.3
```

```bash
ssh inthost
```

- Подробнов про конфигурирование ssh клиента - [SSH CONFIG FILE](https://www.ssh.com/ssh/config/)

## Дополнительное задание 2

Сейчас веб-интерфейс VPN-сервера Pritunl работает с самоподписанным сертификатом. И браузер постоянно ругается на это.
С помощью сервисов sslip.io xip.io и https://letsencrypt.org/ реализуйте использование валидного сертификата для панели управления VPN-сервера


## GCP VMs - bastion & internal
bastion_IP = 35.217.54.73 
someinternalhost_IP = 10.166.0.3

# Homework 6 GCP & cli

*Создание правила для firewall*
```bash
gcloud compute --project=infra-235119 firewall-rules create default-puma-server-1 --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server
```

*Создание виртуальной машины со скриптом запуска*

```bash
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=startup.sh
```

*Результат выполнения домашнего задания*

testapp_IP = 35.204.198.92
testapp_port = 9292

# Homework 7 Packer

- [Packer](https://www.packer.io/downloads.html)

Для проверки конфигурации можно использовать команду `validate` в том числе вместе с передачей файла с переменными.

```bash
packer validate -var-file variables.json ubuntu16.json
```

Данная команда проверит синтаксис, но не проверит параметры. При выполнении ДЗ я получил ошибки: пропущена запятая, не заполнен обязательный параметр.
Чтобы переменную сделать обязательной для заполнения нужно в блоке variables значение по умолчанию указать `null`.  Для задания массивов используется строка со списком значений через запятую.

```JSON
"variables" : {
    "project_id" : null,
    "source_image_family" : null,
    "machine_type" : null,
    "image_description" : "Reddit base app image with rupy and mongodb",
    "disk_size" : "10",
    "disk_type" : "pd-standard",
    "tags" : "puma-server"
  }
  ```
Ошибка некорректного заполнения значений будет найдена только при создании образа.

Синтаксис использования значений переменных в конфигурации `{{user ``var_name``}}`. Ссылка на массив не отличается синтаксически от ссылки на строку.

*Полезные ссылки*

- [Systemd за пять минут](https://habr.com/ru/company/southbridge/blog/255845/)
- [systemd: The Good Parts](https://www.hashicorp.com/resources/systemd-the-good-parts)
