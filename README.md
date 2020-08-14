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
gcloud compute --project=infra-269512 firewall-rules create default-puma-server-1 --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server
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

Распакуйте скачанный архив и поместите бинарный файл в директорию, путь до которой содержится в переменной окружения PATH.

Проверить установку Packer можно командой:
```bash
$ packer -v
```

Создайте АDC:
```bash
$ gcloud auth application-default login
```

Для проверки конфигурации можно использовать команду `validate` в том числе вместе с передачей файла с переменными.

```bash
packer validate ubuntu16.json
packer validate -var-file variables.json ubuntu16.json
```

Если проверка на ошибки прошла успешно, то запустите build образа:

```bash
$ packer build ubuntu16.json
```

Синтаксис использования значений переменных в конфигурации `{{user ``var_name``}}`. Ссылка на массив не отличается синтаксически от ссылки на строку.

*Полезные ссылки*

- [Systemd за пять минут](https://habr.com/ru/company/southbridge/blog/255845/)
- [systemd: The Good Parts](https://www.hashicorp.com/resources/systemd-the-good-parts)

# Homework 8 Terraform

- [Terraform](https://www.terraform.io/downloads.html)

Распакуйте скачанный архив и поместите бинарный файл в директорию, путь до которой содержится в переменной окружения PATH.
В данном курсе мы используем версию 0.11.x. Версии 0.12 в курсе не поддерживаются.

Проверить установку Terraform можно командой:
```bash
$ terraform -v
```

Провайдеры Terraform являются загружаемыми модулями, начиная с версии 0.10. Для того чтобы загрузить провайдер и начать его использовать выполните следующую команду в директории terraform:

```bash
$ terraform init
```

Перед тем как дать команду terraform'у применить изменения, хорошей практикой является предварительно посмотреть, какие изменения terraform собирается произвести относительно состояния известных ему ресурсов (tfstate файл) 
Выполните команду планирования изменений в директории terraform:
```bash
$ terraform plan
```
Для того чтобы запустить инстанс VM, описание характеристик которого мы описали в конфигурационном файле main.tf, используем команду:
```bash
$ terraform apply
```
Чтобы удалить все созданные ресурсы:
```bash
$ terraform destroy
```

# Homework 10 Ansible

Нужен Python 2.7: 
```bash
$ python --version
```

Утановка pip:
```bash
apt install python-pip -y
```

При невозможности установить Ansible из pip:
```bash
pip install ansible>=2.4
```

Проверяем, что Ansible установлен:
```bash
$ ansible --version
ansible 2.4.x.x
```

Укажем значения по умолчанию для работы Ansible:
~/ansible/ansible.cfg
```
[defaults]
inventory = ./inventory
remote_user = appuser
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False
```

Создадим инвентори файл ansible/inventory, в котором укажем информацию о созданном инстансе приложения и параметры подключения к нему по SSH:
~/ansible/inventory:
```
[app] #Это название группы
appserver ansible_host=x.x.x.x #Cписок хостов в данной группе

[db]
dbserver ansible_host=y.y.y.y
```

Ping-модуль позволяет протестировать SSH-соединение, при этом ничего не изменяя на самом хосте.
```bash
$ ansible appserver -i ./inventory -m ping
```
- -m ping - вызываемый модуль
- -i ./inventory - путь до файла инвентори
- appserver - Имя хоста, которое указали в инвентори, откуда

Ansible yзнает, как подключаться к хосту вывод команды:
```
appserver | SUCCESS => {
"changed": false,
"ping": "pong"
}
```

Модуль command позволяет запускать произвольные команды на удаленном хосте.

Выполним команду uptime для проверки времени работы инстанса. Команду передадим как аргумент для данного модуля, использовав опцию -a:
```bash
$ ansible dbserver -m command -a uptime
dbserver | SUCCESS | rc=0 >>
07:47:41 up 24 min, 1 user, load average: 0.00, 0.00, 0.03
```

мы можем управлять не отдельными хостами, а целыми группами, ссылаясь на имя группы:
```bash
$ ansible app -m ping
appserver | SUCCESS => {
"changed": false,
"ping": "pong"
}
```
- app - имя группы
- -m ping - имя модуля Ansible
- appserver - имя сервера в группе, для которого применился модуль

Начиная с Ansible 2.4 появилась возможность использовать YAML для inventory.

- [Документация по inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)

Отличие форматов INI и YAML:
Обычный INI выглядит так:
```
mail.example.com

[webservers]
foo.example.com
bar.example.com

[dbservers]
one.example.com
two.example.com
three.example.com
```
Этот же инвентори в формате YAML:
```
all:
  hosts:
    mail.example.com:
  children:
    webservers:
      hosts:
        foo.example.com:
        bar.example.com:
    dbservers:
      hosts:
        one.example.com:
        two.example.com:
        three.example.com:
```

Создадим файл inventory.yml
~/ansible/inventory.yml 
```
app:
  hosts:
    appserver:
      ansible_host: x.x.x.x

db:
  hosts:
    dbserver:
      ansible_host: y.y.y.y
```

##Выполнение команд

Проверим с помощью модуля command, что на app сервере установлены компоненты для работы приложения (ruby и bundler):
```bash
$ ansible app -m command -a 'ruby -v'
appserver | SUCCESS | rc=0 >>
ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
$ ansible app -m command -a 'bundler -v'
appserver | SUCCESS | rc=0 >>
Bundler version 1.11.2
```

То же самое с помощью модуля shell:
```bash
$ ansible app -m shell -a 'ruby -v; bundler -v'
appserver | SUCCESS | rc=0 >>
ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
Bundler version 1.11.2
```

Модуль command выполняет команды, не используя оболочку (sh, bash), поэтому в нем не работают перенаправления потоков и нет доступа к некоторым переменным окружения.

Проверим на хосте с БД статус сервиса MongoDB с помощью модуля command или shell. (Эта операция аналогична запуску на хосте команды systemctl status mongod):
```bash
$ ansible db -m command -a 'systemctl status mongod'
dbserver | SUCCESS | rc=0 >>
● mongod.service - High-performance, schema-free document-oriented database
$ ansible db -m shell -a 'systemctl status mongod'
dbserver | SUCCESS | rc=0 >>
● mongod.service - High-performance, schema-free document-oriented database
```

А можем выполнить ту же операцию используя модуль systemd, который предназначен для управления сервисами:
```bash
$ ansible db -m systemd -a name=mongod
dbserver | SUCCESS => {
"changed": false,
"name": "mongod",
"status": {
"ActiveState": "active", ...
```

Или еще лучше с помощью модуля service, который более универсален и будет работать и в более старых ОС с init.dинициализацией:
```bash
$ ansible db -m service -a name=mongod
dbserver | SUCCESS => {
"changed": false,
"name": "mongod",
"status": {
"ActiveState": "active", ...
```

Используем модуль git для клонирования репозитория с приложением на app сервер:
```bash
$ ansible app -m git -a \
'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit'
appserver | SUCCESS => {
"after": "61a7f75b3d3e6f7a8f279896fb4e9f0556e1a70a",
"before": null,
"changed": true
}
```

И попробуем сделать то же самое с модулем command:
```bash
$ ansible app -m command -a \
'git clone https://github.com/express42/reddit.git /home/appuser/reddit'
appserver | SUCCESS | rc=0 >>
Cloning into '/home/appuser/reddit'...
```

Удалим:
```bash
ansible app -m command -a 'rm -rf ~/reddit'
```

##Напишем простой плейбук
Реализуем простой плейбук, который выполняет аналогичные действия (клонирование репозитория).

Создайте файл ansible/clone.yml
```
---
- name: Clone
  hosts: app
  tasks:
    - name: Clone repo
      git:
        repo: https://github.com/express42/reddit.git
        dest: /home/appuser/reddit
```

И выполните: 
```bash
$ ansible-playbook clone.yml
PLAY RECAP
***************************************************************************
appserver : ok=2 changed=0 unreachable=0 failed=0
```

- [Динамическое инвентори в Ansible](https://medium.com/@Nklya/%D0%B4%D0%B8%D0%BD%D0%B0%D0%BC%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B5-%D0%B8%D0%BD%D0%B2%D0%B5%D0%BD%D1%82%D0%BE%D1%80%D0%B8-%D0%B2-ansible-9ee880d540d6)
- [Ansible — GCP dynamic inventory 2.0](https://medium.com/@Temikus/ansible-gcp-dynamic-inventory-2-0-7f3531b28434)


# Homework 11 Ansible-2

Основной конфиг:
site.yml
```ansible
---
    - import_playbook: db.yml
    - import_playbook: app.yml
    - import_playbook: deploy.yml
```

Настройка инстанса DB:
db.yml
```ansible
---
    - name: Configure MongoDB # <-- Словесное описание сценария (name)
      hosts: db # <-- Для каких хостов будут выполняться описанные ниже таски (hosts)
      become: true # <-- Выполнить задание от root
      vars:
         mongo_bind_ip: 0.0.0.0 # <-- Переменная задается в блоке vars
      tasks: # <-- Блок тасков (заданий), которые будут выполняться для данных хостов
        - name: Change mongo config file # <-- Словесное описание сценария (name)
          template:
             src: templates/mongod.conf.j2 # <-- Выполнить задание от root
             dest: /etc/mongod.conf # <-- Путь на удаленном хосте
             mode: 0644 # <-- Права на файл, которые нужно установить
          notify: restart mongod
	  #tags: db-tag # <-- Список тэгов для задачи, нам больше не нужен
    
      handlers:
      - name: restart mongod
        service: name=mongod state=restarted
```
Шаблон конфига MongoDB:
templates/mongod.conf.j2
```j2
# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

# Where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
# Network interfaces
net:
  # default - один из фильтров Jinja2, он задает значение по умолчанию,
  # если переменная слева не определена
  port: {{ mongo_port | default('27017') }}
  bindIp: {{ mongo_bind_ip }} # <-- Подстановка значения переменной
```

Настройка инстанса приложения:
app.yml
```ansible
---
    - name: Configure App 
      hosts: app # <-- Для каких хостов будут выполняться описанные ниже таски (hosts)
      become: true # <-- Выполнить задание от root
      vars:
         db_host: 10.132.15.216 # <-- IP инстанса DB
      tasks: # <-- Блок тасков (заданий), которые будут выполняться для данных хостов
        - name: Add unit file for Puma
          copy:
             src: files/puma.service # <-- Выполнить задание от root
             dest: /etc/systemd/system/puma.service # <-- Путь на удаленном хосте
          notify: reload puma
    
        - name: Add config for DB connection
          template:
             src: templates/db_config.j2
             dest: /home/appuser/db_config
             owner: appuser
             group: appuser
    
        - name: enable puma
          systemd: name=puma enabled=yes
    
      handlers:
      - name: reload puma
        systemd: name=puma state=restarted
```
Деплой:
deploy.yml
```ansible
---
    - name: Deploy application
      hosts: app # <-- Для каких хостов будут выполняться описанные ниже таски (hosts)
      tasks: # <-- Блок тасков (заданий), которые будут выполняться для данных хостов
        - name: Fetch latest version of application code
          git:
             repo: 'https://github.com/express42/reddit.git'
             dest: /home/appuser/reddit
             version: monolith # <-- Указываем нужную ветку
          notify: restart puma

        - name: Bundle install
          bundler:
             state: present
             chdir: /home/appuser/reddit # <-- В какой директории выполнить команду bundle

      handlers:
        - name: restart puma
          become: true # <-- Выполнить задание от root
          systemd: name=puma state=restarted
```
- [Ansible — All modules](https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html)
- [Ansible — Manages apt-packages](https://docs.ansible.com/ansible/latest/modules/apt_module.html#apt-module)
- [Ansible — Add or remove an apt key](https://docs.ansible.com/ansible/latest/modules/apt_key_module.html#apt-key-module)
- [Ansible — Loops](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html)

Применение плейбука к хостам осуществляется при помощи
команды ansible-playbook.

--check — позволяет произвести "пробный прогон" плейбука.
--limit — ограничиваем группу хостов, для которых применить плейбук
--tags — ограничиваем группу тасков, для которых установлен нужный тег

```bash
ansible-playbook reddit_app.yml --check --limit app --tags app-tag
```

# Homework 12 Ansible-3

- [Ansible Galaxy](https://galaxy.ansible.com/)

Ansible имеет специальную команду для работы с Galaxy. Получить справку по этой команде можно на сайте или
использовав команду:
```bash
$ ansible-galaxy -h
```
Также команда ansible-galaxy init позволяет нам создать структуру роли в соответсвии с принятым на Galaxy форматом.
```bash
$ ansible-galaxy init app
$ ansible-galaxy init db
```

```bash
$ tree db
```
db
├── README.md
├── defaults # <-- Директория для переменных по умолчанию
│   └── main.yml
├── handlers
│   └── main.yml
├── meta # <-- Информация о роли, создателе и зависимостях
│   └── main.yml
├── tasks # <-- Директория для тасков
│   └── main.yml
├── tests
│   ├── inventory
│   └── test.yml
└── vars # <-- Директория для переменных, которые не должны
    └──main.yml # переопределяться пользователем

Если роль разрастается:

example-role
├── README.md
├── defaults
│   └── main.yml
├── tasks
│   ├── repository.yml
│   ├── install.yml
│   ├── configure.yml
│   ├── update.yml
│   └── main.yml
└── meta
    └──main.yml

example-role/tasks/main.yml
- include: repository.yml
- include: install.yml
- include: configure.yml

Кросс-платформенные роли:

example-role
├── README.md
├── defaults
│   └── main.yml
├── tasks
│   ├── linux.yml
│   ├── windows.yml
│   └── main.yml
└──meta
    └──main.yml

example-role/tasks/main.yml
- include: linux.yml
when: ansible_os_family == 'RedHat'
- include: windows.yml
when: ansible_os_family == 'Windows'

- [Пример ansible.cfg с описанием всех параметров доступен](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg)

Пример файла ansible.cfg:
[defaults]
roles_path = ./.imported_roles:./roles
timeout = 10
vault_password_file = vault.key
retry_files_enabled = False
[ssh_connection]
ssh_args=-o ForwardAgent=yes
[diff]
always = True
context = 5

Окружения в Ansible:
ansible.cfg
playbooks
environments
├── dev
│   ├── group_vars
│   │   ├── webservers
│   │   └── databases
│   ├── requirements.yml
│   ├── credentials.yml # У окружений отдельные файлы с зашифрованными переменными
│   └── inventory
└──prod
    ├── group_vars
    │   ├── webservers
    │   └── databases
    ├── requirements.yml
    ├── credentials.yml # У окружений отдельные файлы с зашифрованными переменными
    └──inventory

Типовые файлы с переменными окружений:
environments/<env_name>/group_vars
environments/<env_name>/host_vars
environments/<env_name>/credentials.yml

Например, чтобы задеплоить приложение на prod окружении мы должны теперь написать:
```bash
$ ansible-playbook -i environments/prod/inventory deploy.yml
```
Таким образом сразу видно, с каким окружением мы работаем.
В нашем случае, мы также определим окружение по умолчанию (stage), что упростит команду для тестового окружения.

Определим окружение по умолчанию в конфиге Ansible (файл ansible/ansible.cfg):
```
[defaults]
inventory = ./environments/stage/inventory # Inventory по-умолчанию задается здесь
remote_user = appuser
private_key_file = ~/.ssh/appuser
host_key_checking = False
```

Заодно улучшим наш ansible.cfg. Для этого приведем его к такому виду:
```
[defaults]
inventory = ./environments/stage/inventory
remote_user = appuser
private_key_file = ~/.ssh/appuser
# Отключим проверку SSH Host-keys (поскольку они всегда разные для новых инстансов)
host_key_checking = False
# Отключим создание *.retry-файлов (они нечасто нужны, но мешаются под руками)
retry_files_enabled = False
# Явно укажем расположение ролей (можно задать несколько путей через ; )
roles_path = ./roles
[diff]
# Включим обязательный вывод diff при наличии изменений и вывод 5 строк контекста
always = True
context = 5
```
Работа с Community-ролями:

Как мы уже говорили, коммьюнити-роли в основном находятся на портале Ansible Galaxy и работа с ними производится с помощью утилиты ansible-galaxy и файла requirements.yml
Хорошей практикой является разделение зависимостей ролей (requirements.yml) по окружениям.

1. Создадим файлы environments/stage/requirements.yml и environments/prod/requirements.yml
2. Добавим в них запись вида:
```
- src: jdauphant.nginx
version: v2.21.1
```
3. Установим роль:
```
ansible-galaxy install -r environments/stage/requirements.yml
```
4. Комьюнити-роли не стоит коммитить в свой репозиторий, для этого добавим в .gitignore запись: jdauphant.nginx

- [документация роли](https://github.com/jdauphant/ansible-role-nginx)

Работа с Ansible Vault:
Для безопасной работы с приватными данными (пароли, приватные ключи и т.д.) используется механизм. Данные сохраняются в зашифрованных файлах, которые при выполнении плейбука автоматически расшифровываются. Таким образом, приватные данные можно хранить в системе контроля версий. 
Для шифрования используется мастер-пароль (aka vault key). Его нужно передавать команде ansible-playbook при запуске, либо указать файл с ключом в ansible.cfg. Не допускайте хранения этого ключ-файла в Git! Используйте для разных окружений разный vault key.

Подготовим плейбук для создания пользователей, пароль пользователей будем хранить в зашифрованном виде в файле credentials.yml:
1. Создайте файл vault.key со произвольной строкой ключа
2. Изменим файл ansible.cfg, добавим опцию
vault_password_file в секцию [defaults]
[defaults]
...
vault_password_file = vault.key

❗ Обязательно добавьте в .gitignore файл vault.key. А еще лучше - храните его out-of-tree, аналогично ключам SSH (например, в папке ~/.ansible/vault.key)

Создадим файл с данными пользователей для каждого окружения
Файл для prod (ansible/environments/prod/credentials.yml):
```
---
credentials:
  users:
    admin:
      password: admin123
      groups: sudo
```
Файл для stage (ansible/environments/stage/credentials.yml):
```
---
credentials:
  users:
    admin:
      password: qwerty123
      groups: sudo
    qauser:
      password: test123
```

Работа с Ansible Vault
1. Зашифруем файлы используя vault.key (используем одинаковый для всех окружений):
```
$ ansible-vault encrypt environments/prod/credentials.yml
$ ansible-vault encrypt environments/stage/credentials.yml
```
2. Проверьте содержимое файлов, убедитесь что они зашифрованы
3. Добавьте вызов плейбука в файл site.yml и выполните его для stage окружения:

Для редактирования переменных нужно использовать команду ansible-vault edit <file>
А для расшифровки: ansible-vault decrypt <file>

Нюансы:
Загружаются все файлы в group_vars для хоста.
Ansible загружает все переменные хоста из файлов групп, которым он принадлежит в инвентори, даже если группа в плейбуке не участвует в сценарии.

Особенности синтаксиса ролей:
Директива import_role выполняется препроцессором, до запуска плейбука.
Это значит, что:
1. Не поддерживаются циклы (директива loop:)
2. Зато нормально работает директива delegate_to
3. Директива when: не имеет доступа к переменным групп хостов
4. Таски из роли всегда выполняются в playbook (но если есть условие when: мы просто увидим кучу [SKIPPED] тасков)

Директива include_role выполняется в процессе выполнения
сценария (аналог roles:).
Это значит, что:
1. Она имеет доступ к актуальному состоянию переменных и фактов
2. Если условие не выполняется, то задачи роли не будут запущены
3. Мы можем использовать цикл с директивой loop:
```
- include_role: name="{{ item }}"
when: ansible_local.reddit.is_host_provisioned == False
loop: ['jdauphant.nginx', 'mongodb', 'reddit-app']
```
Но... вот так - не работает:
```
- include_role:
name: nginx
delegate_to: balancer-1
```

delegate_to:, tags: и подобные атрибуты таска include_role -
не применяются для вложенных тасков.
