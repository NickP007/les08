## Тиждень 8

### Створення скрипту для git pre-commit hook

Скрипт `pre-commit.sh` виконує перевірку наявності секретів, використовуючи gitleaks (https://github.com/gitleaks/gitleaks)

Для запуску скрипта методом "curl pipe sh" виконайте команду ` curl -sSfL https://raw.githubusercontent.com/NickP007/les08/main/pre-commit.sh| sh - ` в робочому каталозі репозиторію. Для Windows систем може знадобитися додатковий параметр ` -k `

#### Інсталяція

1. Загрузіть файл `pre-commit.sh` на локальний комп'ютер.

2. Зробіть файл виконуваним (для windows використовуйте Git Bash):

  ```bash
  chmod +x pre-commit.sh
  ```
  
3. Перемістіть файл до робочого репозиторію у папку `.git/hooks`

  ```bash
  mv pre-commit.sh /path/to/repo/.git/hooks/pre-commit
  ```

4. Налаштуйте конфігурацію для запуску скрипта:

  ```bash
  git config hooks.gitleaks enable
  ```

> Для відмови від автоматичної перевірки відключіть запуск скрипта за допомогою:
>
>  ```bash
>  git config hooks.gitleaks disable
>  ```

#### Використання

Зробіть комміт до репозиорію. Скрипт автоматично скачає файл перевірки [gitleaks](https://github.com/gitleaks/gitleaks) з вимогами до вашої ОС і архитектури, та запустить перевірку наявності секретів перед комітом у git. Якщо секрети в коді буде виявлено, скрипт повідомить про помилку та відхилить коміт.
