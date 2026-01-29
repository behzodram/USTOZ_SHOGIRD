@echo off
REM make.bat - fayl va papkalarni yaratadi

REM Papkalarni yaratish
mkdir app
mkdir systemd

REM Project Name
cd /d %~dp0
for %%I in ("%~dp0.") do set PROJECT_NAME=%%~nxI
echo Loyiha nomi: %PROJECT_NAME%

REM app papkasi ichidagi fayllarni yaratish
echo BOT_TOKEN = "xxxxxx" > app\config.py

echo. > app\main.py
(   echo C:\Users\Behzod\AppData\Local\Programs\Python\Python313\python.exe main.py 
    echo pause ) > app\run.bat

REM systemd papkasi ichidagi faylni yaratish
(   echo [Unit]
    echo Description=%PROJECT_NAME% Telegram Bot
    echo After=network.target
    echo.
    echo [Service]
    echo Type=simple
    echo User=ubuntu
    echo WorkingDirectory=/home/ubuntu/behzod/github/%PROJECT_NAME%/app
    echo ExecStart=/home/ubuntu/behzod/github/%PROJECT_NAME%/venv/bin/python main.py
    echo Restart=always
    echo.
    echo [Install]
    echo WantedBy=multi-user.target) > systemd\%PROJECT_NAME%.service

REM Boshqa fayllar
(   echo make.bat
    echo __pycache__/
    echo *.pyc
    echo venv/
    echo config.py
    echo run.bat ) > .gitignore

REM deploy.sh faylini yaratish
>deploy.sh echo #!/bin/bash
>>deploy.sh echo set -e  ^# Xato bo‘lsa darhol to‘xtaydi
>>deploy.sh echo.
>>deploy.sh echo # --- CONFIGURATION ---
>>deploy.sh echo # Bot nomi (repo nomi bilan bir xil bo‘lsa yaxshi)
>>deploy.sh echo SERVICE_NAME="%PROJECT_NAME%"  ^# Bu botning systemd service nomi
>>deploy.sh echo APP_DIR="$(pwd)"  ^# Script ishlayotgan papka = repo root
>>deploy.sh echo BRANCH="main"  ^# Git branch
>>deploy.sh echo PYTHON="$APP_DIR/venv/bin/python"  ^# Virtualenv python
>>deploy.sh echo.
>>deploy.sh echo # --- Virtualenv yaratish (agar mavjud bo'lmasa) ---
>>deploy.sh echo if [ ! -d "$APP_DIR/venv" ]; then
>>deploy.sh echo     echo "🌿 Virtualenv topilmadi, yaratilmoqda..."
>>deploy.sh echo     python3 -m venv "$APP_DIR/venv"
>>deploy.sh echo fi
>>deploy.sh echo.
>>deploy.sh echo # --- DEPLOY START ---
>>deploy.sh echo echo "🚀 Deploy boshlanmoqda: $SERVICE_NAME"
>>deploy.sh echo echo "📁 Papka: $APP_DIR"
>>deploy.sh echo echo "🌿 Branch: $BRANCH"
>>deploy.sh echo.
>>deploy.sh echo # 1️⃣ Git pull
>>deploy.sh echo echo "📥 Git pull..."
>>deploy.sh echo git fetch origin "$BRANCH"
>>deploy.sh echo git reset --hard "origin/$BRANCH"
>>deploy.sh echo.
>>deploy.sh echo # 2️⃣ Dependency tekshirish
>>deploy.sh echo echo "📦 Dependency tekshirilmoqda..."
>>deploy.sh echo if [ -f "$APP_DIR/requirements.txt" ]; then
>>deploy.sh echo     "$PYTHON" -m pip install -r "$APP_DIR/requirements.txt"
>>deploy.sh echo fi
>>deploy.sh echo.
>>deploy.sh echo # 3️⃣ systemd service yangilash
>>deploy.sh echo echo "⚙️ systemd service yangilanmoqda..."
>>deploy.sh echo if [ -f "$APP_DIR/systemd/$SERVICE_NAME.service" ]; then
>>deploy.sh echo     sudo cp "$APP_DIR/systemd/$SERVICE_NAME.service" /etc/systemd/system/
>>deploy.sh echo     sudo systemctl daemon-reload
>>deploy.sh echo     sudo systemctl enable "$SERVICE_NAME"
>>deploy.sh echo     sudo systemctl restart "$SERVICE_NAME"
>>deploy.sh echo else
>>deploy.sh echo     echo "❌ $SERVICE_NAME.service topilmadi systemd papkada!"
>>deploy.sh echo     exit 1
>>deploy.sh echo fi
>>deploy.sh echo.
>>deploy.sh echo echo "✅ Deploy tugadi: $SERVICE_NAME"

echo.> README.md
echo.> requirements.txt

echo Strukturaviy fayllar va papkalar yaratildi.
pause
