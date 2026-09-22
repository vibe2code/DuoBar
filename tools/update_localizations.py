#!/usr/bin/env python3
import os

NEW_STRINGS = {
    "en": {
        "Show password": "Show password",
        "Hide password": "Hide password",
        "Save password": "Save password",
        "Saved in Keychain": "Saved in Keychain",
        "Checking Keychain…": "Checking Keychain…",
        "Updates": "Updates",
        "Automatically check for updates": "Automatically check for updates",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Keep ReDuoBar up to date with new features and bug fixes.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Install ReDuoBar to Applications to enable Launch at Login.",
        "Install to Applications": "Install to Applications"
    },
    "ru": {
        "Show password": "Показать пароль",
        "Hide password": "Скрыть пароль",
        "Save password": "Сохранить пароль",
        "Saved in Keychain": "Сохранён в Связке ключей",
        "Checking Keychain…": "Проверка Связки ключей…",
        "Updates": "Обновления",
        "Automatically check for updates": "Автоматически проверять обновления",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Поддерживайте ReDuoBar в актуальном состоянии с новыми функциями и исправлениями.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Установите ReDuoBar в папку «Программы» для работы автозапуска.",
        "Install to Applications": "Установить в Программы"
    },
    "uk": {
        "Show password": "Показати пароль",
        "Hide password": "Сховати пароль",
        "Save password": "Зберегти пароль",
        "Saved in Keychain": "Збережено у В'язці ключів",
        "Checking Keychain…": "Перевірка В'язки ключів…",
        "Updates": "Оновлення",
        "Automatically check for updates": "Автоматично перевіряти оновлення",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Підтримуйте ReDuoBar в актуальному стані.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Встановіть ReDuoBar у папку «Програми» для роботи автозапуску.",
        "Install to Applications": "Встановити в Програми"
    },
    "de": {
        "Show password": "Passwort einblenden",
        "Hide password": "Passwort ausblenden",
        "Save password": "Passwort speichern",
        "Saved in Keychain": "Im Schlüsselbund gespeichert",
        "Checking Keychain…": "Schlüsselbund prüfen…",
        "Updates": "Updates",
        "Automatically check for updates": "Automatisch nach Updates suchen",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Halten Sie ReDuoBar mit neuen Funktionen auf dem neuesten Stand.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Installieren Sie ReDuoBar unter Programme, um den Autostart zu aktivieren.",
        "Install to Applications": "In Programme installieren"
    },
    "fr": {
        "Show password": "Afficher le mot de passe",
        "Hide password": "Masquer le mot de passe",
        "Save password": "Mémoriser le mot de passe",
        "Saved in Keychain": "Enregistré dans le trousseau",
        "Checking Keychain…": "Vérification du trousseau…",
        "Updates": "Mises à jour",
        "Automatically check for updates": "Rechercher automatiquement les mises à jour",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Maintenez ReDuoBar à jour avec les dernières améliorations.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Installez ReDuoBar dans Applications pour activer le lancement au démarrage.",
        "Install to Applications": "Installer dans Applications"
    },
    "es": {
        "Show password": "Mostrar contraseña",
        "Hide password": "Ocultar contraseña",
        "Save password": "Guardar contraseña",
        "Saved in Keychain": "Guardado en Llavero",
        "Checking Keychain…": "Comprobando Llavero…",
        "Updates": "Actualizaciones",
        "Automatically check for updates": "Buscar actualizaciones automáticamente",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Mantén ReDuoBar actualizado con las últimas funciones.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Instala ReDuoBar en Aplicaciones para activar el inicio al iniciar sesión.",
        "Install to Applications": "Instalar en Aplicaciones"
    },
    "it": {
        "Show password": "Mostra password",
        "Hide password": "Nascondi password",
        "Save password": "Salva password",
        "Saved in Keychain": "Salvato nel Portachiavi",
        "Checking Keychain…": "Verifica Portachiavi…",
        "Updates": "Aggiornamenti",
        "Automatically check for updates": "Controlla aggiornamenti automaticamente",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Mantieni ReDuoBar aggiornato con nuove funzioni e correzioni.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Installa ReDuoBar in Applicazioni per abilitare l'avvio al login.",
        "Install to Applications": "Installa in Applicazioni"
    },
    "pt-BR": {
        "Show password": "Exibir senha",
        "Hide password": "Ocultar senha",
        "Save password": "Salvar senha",
        "Saved in Keychain": "Salvo nas Chaves",
        "Checking Keychain…": "Verificando Chaves…",
        "Updates": "Atualizações",
        "Automatically check for updates": "Buscar atualizações automaticamente",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Mantenha o ReDuoBar atualizado com novos recursos e correções.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Instale o ReDuoBar em Aplicativos para ativar a inicialização automática.",
        "Install to Applications": "Instalar em Aplicativos"
    },
    "ja": {
        "Show password": "パスワードを表示",
        "Hide password": "パスワードを非表示",
        "Save password": "パスワードを保存",
        "Saved in Keychain": "キーチェーンに保存済み",
        "Checking Keychain…": "キーチェーンを確認中…",
        "Updates": "アップデート",
        "Automatically check for updates": "アップデートを自動的に確認",
        "Keep ReDuoBar up to date with new features and bug fixes.": "ReDuoBarを常に最新の機能と修正で最新の状態に保ちます。",
        "Install ReDuoBar to Applications to enable Launch at Login.": "ログイン項目の有効化にはReDuoBarをアプリケーションにインストールしてください。",
        "Install to Applications": "アプリケーションにインストール"
    },
    "ko": {
        "Show password": "암호 보기",
        "Hide password": "암호 가리기",
        "Save password": "암호 저장",
        "Saved in Keychain": "키체인에 저장됨",
        "Checking Keychain…": "키체인 확인 중…",
        "Updates": "업데이트",
        "Automatically check for updates": "업데이트 자동 확인",
        "Keep ReDuoBar up to date with new features and bug fixes.": "ReDuoBar를 최신 기능 및 수정 사항으로 최신 상태로 유지합니다.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "로그인 시 자동 실행을 활성화하려면 ReDuoBar를 응용 프로그램 폴더에 설치하십시오.",
        "Install to Applications": "응용 프로그램에 설치"
    },
    "zh-Hans": {
        "Show password": "显示密码",
        "Hide password": "隐藏密码",
        "Save password": "存储密码",
        "Saved in Keychain": "已存储在钥匙串中",
        "Checking Keychain…": "正在检查钥匙串…",
        "Updates": "更新",
        "Automatically check for updates": "自动检查更新",
        "Keep ReDuoBar up to date with new features and bug fixes.": "保持 ReDuoBar 为最新版本，获取最新功能与修复。",
        "Install ReDuoBar to Applications to enable Launch at Login.": "请将 ReDuoBar 安装至“应用程序”文件夹以启用开机启动。",
        "Install to Applications": "安装至应用程序"
    },
    "zh-Hant": {
        "Show password": "顯示密碼",
        "Hide password": "隱藏密碼",
        "Save password": "儲存密碼",
        "Saved in Keychain": "已儲存在鑰匙圈中",
        "Checking Keychain…": "正在檢查鑰匙圈…",
        "Updates": "更新",
        "Automatically check for updates": "自動檢查更新項目",
        "Keep ReDuoBar up to date with new features and bug fixes.": "保持 ReDuoBar 為最新版本，獲取新功能與修復。",
        "Install ReDuoBar to Applications to enable Launch at Login.": "請將 ReDuoBar 安裝至「應用程式」以啟用登入時開機啟動。",
        "Install to Applications": "安裝至應用程式"
    },
    "ar": {
        "Show password": "إظهار كلمة المرور",
        "Hide password": "إخفاء كلمة المرور",
        "Save password": "حفظ كلمة المرور",
        "Saved in Keychain": "محفوظ في سلسلة المفاتيح",
        "Checking Keychain…": "التحقق من سلسلة المفاتيح…",
        "Updates": "التحديثات",
        "Automatically check for updates": "التحقق من التحديثات تلقائيًا",
        "Keep ReDuoBar up to date with new features and bug fixes.": "حافظ على تحديث ReDuoBar بأحدث الميزات والإصلاحات.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "ثبّت ReDuoBar في مجلد التطبيقات لتفعيل التشغيل عند تسجيل الدخول.",
        "Install to Applications": "تثبيت في التطبيقات"
    },
    "el": {
        "Show password": "Εμφάνιση κωδικού",
        "Hide password": "Απόκρυψη κωδικού",
        "Save password": "Αποθήκευση κωδικού",
        "Saved in Keychain": "Αποθηκεύτηκε στην Κλείδα",
        "Checking Keychain…": "Έλεγχος Κλείδας…",
        "Updates": "Ενημερώσεις",
        "Automatically check for updates": "Αυτόματος έλεγχος για ενημερώσεις",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Διατηρήστε το ReDuoBar ενημερωμένο.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Εγκαταστήστε το ReDuoBar στις Εφαρμογές για ενεργοποίηση της αυτόματης εκκίνησης.",
        "Install to Applications": "Εγκατάσταση στις Εφαρμογές"
    },
    "tr": {
        "Show password": "Parolayı göster",
        "Hide password": "Parolayı gizle",
        "Save password": "Parolayı kaydet",
        "Saved in Keychain": "Anahtar Zinciri'nde kayıtlı",
        "Checking Keychain…": "Anahtar Zinciri kontrol ediliyor…",
        "Updates": "Güncellemeler",
        "Automatically check for updates": "Güncellemeleri otomatik denetle",
        "Keep ReDuoBar up to date with new features and bug fixes.": "ReDuoBar'ı yeni özellikler ve hata düzeltmeleriyle güncel tutun.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Girişte başlatmayı etkinleştirmek için ReDuoBar'ı Uygulamalar klasörüne yükleyin.",
        "Install to Applications": "Uygulamalar'a Yükle"
    },
    "pl": {
        "Show password": "Pokaż hasło",
        "Hide password": "Ukryj hasło",
        "Save password": "Zapisz hasło",
        "Saved in Keychain": "Zapisano w pęku kluczy",
        "Checking Keychain…": "Sprawdzanie pęku kluczy…",
        "Updates": "Uaktualnienia",
        "Automatically check for updates": "Automatycznie sprawdzaj uaktualnienia",
        "Keep ReDuoBar up to date with new features and bug fixes.": "Utrzymuj ReDuoBar w najnowszej wersji.",
        "Install ReDuoBar to Applications to enable Launch at Login.": "Zainstaluj ReDuoBar w folderze Programy, aby włączyć uruchamianie przy logowaniu.",
        "Install to Applications": "Zainstaluj w Programach"
    },
    "hi": {
        "Show password": "पासवर्ड दिखाएं",
        "Hide password": "पासवर्ड छुपाएं",
        "Save password": "पासवर्ड सहेजें",
        "Saved in Keychain": "कीचेन में सहेजा गया",
        "Checking Keychain…": "कीचेन जांच रहे हैं…",
        "Updates": "अपडेट",
        "Automatically check for updates": "अपडेट के लिए स्वचालित रूप से जांचें",
        "Keep ReDuoBar up to date with new features and bug fixes.": "ReDuoBar को नई सुविधाओं और सुधारों के साथ अद्यतित रखें।",
        "Install ReDuoBar to Applications to enable Launch at Login.": "लॉगिन पर शुरू करने के लिए ReDuoBar को ऍप्लिकेशन्स में स्थापित करें।",
        "Install to Applications": "ऍप्लिकेशन्स में स्थापित करें"
    }
}

def parse_strings(path):
    keys = {}
    if not os.path.exists(path):
        return keys
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("\"") and "\" = \"" in line:
                parts = line.split("\" = \"", 1)
                k = parts[0].strip("\"")
                v = parts[1].rstrip("\";")
                keys[k] = v
    return keys

def main():
    base_dir = "ReDuoBar"
    for lang, mapping in NEW_STRINGS.items():
        filepath = f"{base_dir}/{lang}.lproj/Localizable.strings"
        existing = parse_strings(filepath)
        to_add = []
        for k, v in mapping.items():
            if k not in existing:
                to_add.append((k, v))
        
        if not to_add:
            print(f"[{lang}] All keys already present.")
            continue
        
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        if not content.endswith("\n"):
            content += "\n"
        
        addition = "\n/* Keychain, Updates & Installation */\n"
        for k, v in to_add:
            clean_v = v.replace("\"", "\\\"")
            clean_k = k.replace("\"", "\\\"")
            addition += f"\"{clean_k}\" = \"{clean_v}\";\n"
        
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content + addition)
        
        print(f"[{lang}] Added {len(to_add)} keys.")

if __name__ == "__main__":
    main()
