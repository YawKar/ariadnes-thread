# Практика 2

Цель: выполнить требования

# Требования и реализация

1. Создать группу developers и добавить текущего пользователя
  - `sudo addgroup developers`
  - `sudo adduser $(whoami) developers`
  - `groups yawkar | grep developers` (убеждаемся что в перечислении есть developers)
  - `reboot` (иначе ниже chgrp будет жаловаться operation not permitted при попытке `chgrp developers src`)
2. Установить различные права доступа:
  - `src/`: 770, а также установить group owner = developers
    - `chmod 770 src`
    - `chgrp developers src`
  - `logs/`: 750
    - `chmod 750 logs`
  - `config/`: 750, и выставить sticky bit
    - `chmod 750 config`
    - `chmod +t config`
  - `backups/`: 700, установить user owner = root
    - `chmod 700 backups`
    - `sudo chown root backups`
      - почему-то без sudo не дает, хотя казалось бы, отдать папку админу...
        может быть, конечно, это может быть консерном безопасности, если у админа какая-то джоба есть
        которая проходит по всем принадлежащим root условно скриптам и вызывает их, можно таким образом
        подложить бомбочку
3. Проверить правильность прав
  - `ll ~/projects` (сдампил в [02-ll-projects.txt](./02-ll-projects.txt))

