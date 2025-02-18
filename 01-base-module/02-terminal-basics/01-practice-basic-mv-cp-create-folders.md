# Практика 1

Цель: выполнить последовательность манипуляций с файлами и директориями

# Требования и реализация

1. В домашней директории создать директорию project
  - `mkdir ~/project`
2. Внутри создать создать под-директории src, docs, config, logs, backups
  - `cd ~/project && mkdir src docs config logs backups`
3. Создать `main.py` в `src/` и занести туда какой-то текст
  - два способа первый удобнее имхо (если не учитывать vim)
    ```bash
    # через heredoc записать сразу скрипт
    cd ~/project/src && cat > main.py << EOF
    # как иной вариант: echo "print('Hello')" > ~/project/src/main.py
    ```
4. Переместить файл в другую директорию (`docs/`)
  - `cd ~/project && mv src/main.py docs/`
5. Скопировать файл обратно в `src/`
  - `cd ~/project && cp docs/main.py src/`

