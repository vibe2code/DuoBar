#!/usr/bin/env python3
import os

TRANSLATIONS = {
    "ru": {
        "Wi-Fi": "Wi-Fi"
    },
    "de": {
        "Startup": "Start",
        "Interaction": "Interaktion",
        "Open on Hover": "Beim Zeigen öffnen",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "ReDuoBar öffnen, wenn der Zeiger über das Menüleistensymbol bewegt wird.",
        "Preview": "Vorschau",
        "Simulated Menu Bar": "Simulierte Menüleiste",
        "Appearance": "Erscheinungsbild",
        "Behavior": "Verhalten",
        "Battery & Power": "Batterie & Stromversorgung",
        "Color the battery ring green, yellow, or red based on charge level.": "Den Batteriering je nach Ladestand grün, gelb oder rot färben.",
        "About": "Über",
        "Lightweight, native status & monitor for your macOS menu bar.": "Leichtgewichtiger, nativer Status-Monitor für Ihre macOS-Menüleiste.",
        "Developer": "Entwickler",
        "Automatically launch ReDuoBar when you log into your Mac.": "ReDuoBar automatisch beim Anmelden an Ihrem Mac starten.",
        "Off": "Aus",
        "Unable to change Wi-Fi power": "WLAN konnte nicht ein-/ausgeschaltet werden",
        "Wi-Fi": "WLAN",
        "Wi-Fi control unavailable": "WLAN-Steuerung nicht verfügbar",
        "Wi-Fi power": "WLAN ein/aus"
    },
    "fr": {
        "Startup": "Démarrage",
        "Interaction": "Interaction",
        "Open on Hover": "Ouvrir au survol",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "Ouvrir ReDuoBar lorsque le pointeur survole l'icône de la barre des menus.",
        "Preview": "Aperçu",
        "Simulated Menu Bar": "Barre des menus simulée",
        "Appearance": "Apparence",
        "Behavior": "Comportement",
        "Battery & Power": "Batterie et alimentation",
        "Color the battery ring green, yellow, or red based on charge level.": "Colorer l'anneau de la batterie en vert, jaune ou rouge selon le niveau de charge.",
        "About": "À propos",
        "Lightweight, native status & monitor for your macOS menu bar.": "Moniteur d'état léger et natif pour votre barre des menus macOS.",
        "Developer": "Développeur",
        "Automatically launch ReDuoBar when you log into your Mac.": "Lancer automatiquement ReDuoBar à l'ouverture de session sur votre Mac.",
        "Off": "Désactivé",
        "Unable to change Wi-Fi power": "Impossible de modifier l'état du Wi-Fi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Contrôle du Wi-Fi non disponible",
        "Wi-Fi power": "Alimentation Wi-Fi"
    },
    "es": {
        "Startup": "Inicio",
        "Interaction": "Interacción",
        "Open on Hover": "Abrir al pasar el cursor",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "Abrir ReDuoBar cuando el puntero pase sobre el icono de la barra de menús.",
        "Preview": "Vista previa",
        "Simulated Menu Bar": "Barra de menús simulada",
        "Appearance": "Aspecto",
        "Behavior": "Comportamiento",
        "Battery & Power": "Batería y energía",
        "Color the battery ring green, yellow, or red based on charge level.": "Colorear el anillo de la batería en verde, amarillo o rojo según el nivel de carga.",
        "About": "Acerca de",
        "Lightweight, native status & monitor for your macOS menu bar.": "Monitor de estado nativo y ligero para la barra de menús de macOS.",
        "Developer": "Desarrollador",
        "Automatically launch ReDuoBar when you log into your Mac.": "Iniciar automáticamente ReDuoBar al iniciar sesión en el Mac.",
        "Off": "Desactivado",
        "Unable to change Wi-Fi power": "No se puede cambiar el estado de Wi-Fi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Control de Wi-Fi no disponible",
        "Wi-Fi power": "Encendido/Apagado de Wi-Fi"
    },
    "it": {
        "Startup": "Avvio",
        "Interaction": "Interazione",
        "Open on Hover": "Apri al passaggio del mouse",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "Apri ReDuoBar quando il puntatore si sposta sull'icona della barra dei menu.",
        "Preview": "Anteprima",
        "Simulated Menu Bar": "Barra dei menu simulata",
        "Appearance": "Aspetto",
        "Behavior": "Comportamento",
        "Battery & Power": "Batteria ed alimentazione",
        "Color the battery ring green, yellow, or red based on charge level.": "Colora l'anello della batteria di verde, giallo o rosso in base al livello di carica.",
        "About": "Info",
        "Lightweight, native status & monitor for your macOS menu bar.": "Monitor di stato leggero e nativo per la barra dei menu di macOS.",
        "Developer": "Sviluppatore",
        "Automatically launch ReDuoBar when you log into your Mac.": "Avvia automaticamente ReDuoBar al login del Mac.",
        "Off": "Non attivo",
        "Unable to change Wi-Fi power": "Impossibile modificare l'alimentazione Wi-Fi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Controllo Wi-Fi non disponibile",
        "Wi-Fi power": "Alimentazione Wi-Fi"
    },
    "pt-BR": {
        "Startup": "Inicialização",
        "Interaction": "Interação",
        "Open on Hover": "Abrir ao passar o cursor",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "Abrir o ReDuoBar quando o cursor passar sobre o ícone da barra de menus.",
        "Preview": "Pré-visualização",
        "Simulated Menu Bar": "Barra de Menus Simulada",
        "Appearance": "Aparência",
        "Behavior": "Comportamento",
        "Battery & Power": "Bateria e Alimentação",
        "Color the battery ring green, yellow, or red based on charge level.": "Colorir o anel da bateria em verde, amarelo ou vermelho conforme o nível de carga.",
        "About": "Sobre",
        "Lightweight, native status & monitor for your macOS menu bar.": "Monitor de status leve e nativo para a barra de menus do macOS.",
        "Developer": "Desenvolvedor",
        "Automatically launch ReDuoBar when you log into your Mac.": "Iniciar o ReDuoBar automaticamente ao iniciar a sessão no Mac.",
        "Off": "Desativado",
        "Unable to change Wi-Fi power": "Não foi possível alterar a alimentação do Wi-Fi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Controle de Wi-Fi indisponível",
        "Wi-Fi power": "Alimentação do Wi-Fi"
    },
    "pl": {
        "Startup": "Uruchamianie",
        "Interaction": "Interakcja",
        "Open on Hover": "Otwieraj po najechaniu kursorem",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "Otwórz ReDuoBar, gdy wskaźnik przesunie się nad ikonę paska menu.",
        "Preview": "Podgląd",
        "Simulated Menu Bar": "Symulowany pasek menu",
        "Appearance": "Wygląd",
        "Behavior": "Zachowanie",
        "Battery & Power": "Bateria i zasilanie",
        "Color the battery ring green, yellow, or red based on charge level.": "Zmieniaj kolor pierścienia baterii na zielony, żółty lub czerwony w zależności od naładowania.",
        "About": "Informacje",
        "Lightweight, native status & monitor for your macOS menu bar.": "Lekki, natywny monitor stanu dla paska menu systemu macOS.",
        "Developer": "Deweloper",
        "Automatically launch ReDuoBar when you log into your Mac.": "Automatycznie uruchamiaj ReDuoBar po zalogowaniu do Maca.",
        "Off": "Wył.",
        "Unable to change Wi-Fi power": "Nie można zmienić stanu Wi-Fi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Sterowanie Wi-Fi niedostępne",
        "Wi-Fi power": "Zasilanie Wi-Fi"
    },
    "uk": {
        "Startup": "Автозапуск",
        "Interaction": "Взаємодія",
        "Open on Hover": "Відкривати при наведенні",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "Відкривати ReDuoBar при наведенні курсора на іконку в рядку меню.",
        "Preview": "Перегляд",
        "Simulated Menu Bar": "Рядок меню",
        "Appearance": "Вигляд",
        "Behavior": "Поведінка",
        "Battery & Power": "Акумулятор і живлення",
        "Color the battery ring green, yellow, or red based on charge level.": "Фарбувати кільце в зелений, жовтий або червоний колір залежно від рівня заряду.",
        "About": "Про програму",
        "Lightweight, native status & monitor for your macOS menu bar.": "Компактний і нативний монітор стану для рядка меню macOS.",
        "Developer": "Розробник",
        "Automatically launch ReDuoBar when you log into your Mac.": "Автоматично запускати ReDuoBar під час входу в систему Mac.",
        "Off": "Вимк.",
        "Unable to change Wi-Fi power": "Не вдалося змінити стан живлення Wi-Fi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Керування Wi-Fi недоступне",
        "Wi-Fi power": "Живлення Wi-Fi"
    },
    "tr": {
        "Startup": "Başlangıç",
        "Interaction": "Etkileşim",
        "Open on Hover": "İşaretçiyle Üzerine Gelindiğinde Aç",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "İşaretçi menü çubuğu simgesinin üzerine geldiğinde ReDuoBar'ı aç.",
        "Preview": "Önizleme",
        "Simulated Menu Bar": "Simüle Edilen Menü Çubuğu",
        "Appearance": "Görünüş",
        "Behavior": "Davranış",
        "Battery & Power": "Pil ve Güç",
        "Color the battery ring green, yellow, or red based on charge level.": "Pil halkasını şarj düzeyine göre yeşil, sarı veya kırmızı olarak renklendir.",
        "About": "Hakkında",
        "Lightweight, native status & monitor for your macOS menu bar.": "macOS menü çubuğunuz için hafif, yerel durum monitörü.",
        "Developer": "Geliştirici",
        "Automatically launch ReDuoBar when you log into your Mac.": "Mac'inizde oturum açtığınızda ReDuoBar'ı otomatik olarak başlatın.",
        "Off": "Kapalı",
        "Unable to change Wi-Fi power": "Wi-Fi gücü değiştirilemedi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Wi-Fi denetimi kullanılamıyor",
        "Wi-Fi power": "Wi-Fi Gücü"
    },
    "el": {
        "Startup": "Έναρξη",
        "Interaction": "Αλληλεπίδραση",
        "Open on Hover": "Άνοιγμα με αιώρηση",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "Άνοιγμα του ReDuoBar όταν ο δείκτης μετακινείται πάνω από το εικονίδιο της γραμμής μενού.",
        "Preview": "Προεπισκόπηση",
        "Simulated Menu Bar": "Προσομοιωμένη γραμμή μενού",
        "Appearance": "Εμφάνιση",
        "Behavior": "Συμπεριφορά",
        "Battery & Power": "Μπαταρία & Τροφοδοσία",
        "Color the battery ring green, yellow, or red based on charge level.": "Χρωματισμός του δακτυλίου μπαταρίας σε πράσινο, κίτρινο ή κόκκινο ανάλογα με το επίπεδο φόρτισης.",
        "About": "Σχετικά",
        "Lightweight, native status & monitor for your macOS menu bar.": "Ελαφρύς, εγγενής έλεγχος κατάστασης για τη γραμμή μενού του macOS.",
        "Developer": "Προγραμματιστής",
        "Automatically launch ReDuoBar when you log into your Mac.": "Αυτόματη εκκίνηση του ReDuoBar κατά τη σύνδεση στο Mac.",
        "Off": "Ανενεργό",
        "Unable to change Wi-Fi power": "Αδυναμία αλλαγής ισχύος Wi-Fi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Ο έλεγχος Wi-Fi δεν είναι διαθέσιμος",
        "Wi-Fi power": "Ισχύς Wi-Fi"
    },
    "ja": {
        "Startup": "起動",
        "Interaction": "操作",
        "Open on Hover": "ホバーで開く",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "ポインタがメニューバーアイコンの上を通過したときにReDuoBarを開きます。",
        "Preview": "プレビュー",
        "Simulated Menu Bar": "シミュレートされたメニューバー",
        "Appearance": "外観",
        "Behavior": "動作",
        "Battery & Power": "バッテリーと電源",
        "Color the battery ring green, yellow, or red based on charge level.": "充電レベルに応じてバッテリーリングを緑、黄、赤に着色します。",
        "About": "情報",
        "Lightweight, native status & monitor for your macOS menu bar.": "macOSメニューバー用の軽量でネイティブなステータスモニター。",
        "Developer": "開発者",
        "Automatically launch ReDuoBar when you log into your Mac.": "MacにログインしたときにReDuoBarを自動的に起動します。",
        "Off": "オフ",
        "Unable to change Wi-Fi power": "Wi-Fiの電源状態を変更できません",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Wi-Fi制御は利用できません",
        "Wi-Fi power": "Wi-Fi電源"
    },
    "ko": {
        "Startup": "시작",
        "Interaction": "상호작용",
        "Open on Hover": "마우스 오버 시 열기",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "포인터가 메뉴 막대 아이콘 위로 이동할 때 ReDuoBar를 엽니다.",
        "Preview": "미리보기",
        "Simulated Menu Bar": "시뮬레이션된 메뉴 막대",
        "Appearance": "화면 모드",
        "Behavior": "동작",
        "Battery & Power": "배터리 및 전원",
        "Color the battery ring green, yellow, or red based on charge level.": "충전 수준에 따라 배터리 링을 녹색, 노란색 또는 빨간색으로 표시합니다.",
        "About": "정보",
        "Lightweight, native status & monitor for your macOS menu bar.": "macOS 메뉴 막대를 위한 가볍고 네이티브한 상태 모니터.",
        "Developer": "개발자",
        "Automatically launch ReDuoBar when you log into your Mac.": "Mac에 로그인할 때 ReDuoBar를 자동으로 실행합니다.",
        "Off": "끔",
        "Unable to change Wi-Fi power": "Wi-Fi 전원을 변경할 수 없습니다",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Wi-Fi 제어를 사용할 수 없습니다",
        "Wi-Fi power": "Wi-Fi 전원"
    },
    "ar": {
        "Startup": "بدء التشغيل",
        "Interaction": "التفاعل",
        "Open on Hover": "فتح عند التحويم",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "افتح ReDuoBar عندما يتحرك المؤشر فوق أيقونة شريط القوائم.",
        "Preview": "معاينة",
        "Simulated Menu Bar": "شريط القوائم المحاكى",
        "Appearance": "المظهر",
        "Behavior": "السلوك",
        "Battery & Power": "البطارية والطاقة",
        "Color the battery ring green, yellow, or red based on charge level.": "تلوين حلقة البطارية بالأخضر أو الأصفر أو الأحمر بناءً على مستوى الشحن.",
        "About": "حول",
        "Lightweight, native status & monitor for your macOS menu bar.": "مراقب حالة خفيف ومدمج لشريط قوائم macOS الخاص بك.",
        "Developer": "المطور",
        "Automatically launch ReDuoBar when you log into your Mac.": "تشغيل ReDuoBar تلقائيًا عند تسجيل الدخول إلى Mac.",
        "Off": "إيقاف",
        "Unable to change Wi-Fi power": "تعذر تغيير طاقة Wi-Fi",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "التحكم في Wi-Fi غير متوفر",
        "Wi-Fi power": "طاقة Wi-Fi"
    },
    "hi": {
        "Startup": "स्टार्टअप",
        "Interaction": "इंटरैक्शन",
        "Open on Hover": "होवर करने पर खोलें",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "जब पॉइंटर मेनू बार आइकन पर जाए तब ReDuoBar खोलें।",
        "Preview": "पूर्वावलोकन",
        "Simulated Menu Bar": "सिम्युलेटेड मेनू बार",
        "Appearance": "दिखावट",
        "Behavior": "व्यवहार",
        "Battery & Power": "बैटरी और पावर",
        "Color the battery ring green, yellow, or red based on charge level.": "चार्ज स्तर के आधार पर बैटरी रिंग को हरा, पीला या लाल रंग दें।",
        "About": "के बारे में",
        "Lightweight, native status & monitor for your macOS menu bar.": "आपके macOS मेनू बार के लिए हल्का, मूल स्टेटस मॉनिटर।",
        "Developer": "डेवलपर",
        "Automatically launch ReDuoBar when you log into your Mac.": "अपने Mac में लॉग इन करते ही ReDuoBar को स्वचालित रूप से शुरू करें।",
        "Off": "बंद",
        "Unable to change Wi-Fi power": "Wi-Fi पावर बदलने में असमर्थ",
        "Wi-Fi": "Wi-Fi",
        "Wi-Fi control unavailable": "Wi-Fi नियंत्रण अनुपलब्ध है",
        "Wi-Fi power": "Wi-Fi पावर"
    },
    "zh-Hans": {
        "Startup": "启动",
        "Interaction": "交互",
        "Open on Hover": "悬停时打开",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "当鼠标指针移到菜单栏图标上方时打开 ReDuoBar。",
        "Preview": "预览",
        "Simulated Menu Bar": "模拟菜单栏",
        "Appearance": "外观",
        "Behavior": "行为",
        "Battery & Power": "电池与电源",
        "Color the battery ring green, yellow, or red based on charge level.": "根据电量等级将电池圆环显示为绿色、黄色或红色。",
        "About": "关于",
        "Lightweight, native status & monitor for your macOS menu bar.": "适用于 macOS 菜单栏的原生轻量级状态监控工具。",
        "Developer": "开发者",
        "Automatically launch ReDuoBar when you log into your Mac.": "登录 Mac 时自动启动 ReDuoBar。",
        "Check for Updates…": "检查更新…",
        "Wi-Fi Settings…": "Wi-Fi 设置…",
        "Scanning…": "正在扫描…",
        "No networks found": "未找到网络",
        "Password": "密码",
        "Incorrect password": "密码不正确",
        "Cancel": "取消",
        "Join": "加入"
    },
    "zh-Hant": {
        "Startup": "啟動",
        "Interaction": "互動",
        "Open on Hover": "懸停時開啟",
        "Open ReDuoBar when the pointer moves over the menu bar icon.": "當指標移到選單列圖示上方時開啟 ReDuoBar。",
        "Preview": "預覽",
        "Simulated Menu Bar": "模擬選單列",
        "Appearance": "外觀",
        "Behavior": "行為",
        "Battery & Power": "電池與電源",
        "Color the battery ring green, yellow, or red based on charge level.": "根據電量等級將電池圓環顯示為綠色、黃色或紅色。",
        "About": "關於",
        "Lightweight, native status & monitor for your macOS menu bar.": "適用於 macOS 選單列的原生輕量級狀態監視工具。",
        "Developer": "開發者",
        "Automatically launch ReDuoBar when you log into your Mac.": "登入 Mac 時自動啟動 ReDuoBar。",
        "Check for Updates…": "檢查更新項目…",
        "Wi-Fi Settings…": "Wi-Fi 設定…",
        "Scanning…": "正在掃描…",
        "No networks found": "找不到網路",
        "Password": "密碼",
        "Incorrect password": "密碼不正確",
        "Cancel": "取消",
        "Join": "加入"
    }
}

def parse_strings(path):
    keys = {}
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
    for lang, mapping in TRANSLATIONS.items():
        filepath = f"{base_dir}/{lang}.lproj/Localizable.strings"
        existing = parse_strings(filepath)
        to_add = []
        for k, v in mapping.items():
            if k not in existing:
                to_add.append((k, v))
        
        if not to_add:
            print(f"[{lang}] No keys to add.")
            continue
        
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        if not content.endswith("\n"):
            content += "\n"
        
        addition = "\n/* New Features & Settings */\n"
        for k, v in to_add:
            # Escape internal quotes if any
            clean_v = v.replace("\"", "\\\"")
            clean_k = k.replace("\"", "\\\"")
            addition += f"\"{clean_k}\" = \"{clean_v}\";\n"
        
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content + addition)
        
        print(f"[{lang}] Added {len(to_add)} keys.")

if __name__ == "__main__":
    main()
