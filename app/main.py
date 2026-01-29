import json
import re
from pathlib import Path

TXT_FILES = [f"add{i}.txt" for i in range(1, 13)]
OUTPUT_FILE = "output.json"

def parse_announcement(text):
    data = {}
    
    # Hashtaglar
    hashtags = re.findall(r"#(\S+)", text)
    if hashtags:
        data["hashtags"] = hashtags
    
    # Turini aniqlash
    if "Ish joyi kerak" in text:
        data["type"] = "xodim"
        x = re.search(r"👨‍💼 Xodim: (.+)", text)
        if x: data["xodim"] = x.group(1).strip()
    elif "Xodim kerak" in text:
        data["type"] = "ishjoyi"
        x = re.search(r"🏢 Idora: (.+)", text)
        if x: data["idora"] = x.group(1).strip()
    elif "Shogird kerak" in text:
        data["type"] = "ustoz"
        x = re.search(r"🎓 Ustoz: (.+)", text)
        if x: data["ustoz"] = x.group(1).strip()
    elif "Ustoz kerak" in text:
        data["type"] = "shogird"
        x = re.search(r"🎓 Shogird: (.+)", text)
        if x: data["shogird"] = x.group(1).strip()
    
    # Umumiy maydonlar
    y = re.search(r"Yosh: (\d+)", text)
    if y: data["yosh"] = int(y.group(1))
    
    t = re.search(r"📚 Texnologiya: (.+)", text)
    if t: data["texnologiya"] = [tech.strip() for tech in t.group(1).split(",")]
    
    tg = re.search(r"🇺🇿 Telegram: (\S+)", text)
    if tg: data["telegram"] = tg.group(1)
    
    a = re.search(r"📞 Aloqa: (.+)", text)
    if a: data["aloqa"] = a.group(1).strip()
    
    h = re.search(r"🌐 Hudud: (.+)", text)
    if h: data["hudud"] = h.group(1).strip()
    
    n = re.search(r"💰 Narxi: (.+)", text)
    if not n: n = re.search(r"💰 Maosh: (.+)", text)
    if n: data["narxi"] = n.group(1).strip()
    
    k = re.search(r"👨🏻‍💻 Kasbi: (.+)", text)
    if not k: k = re.search(r"✍️ Mas'ul: (.+)", text)
    if k: data["kasbi"] = k.group(1).strip()
    
    mv = re.search(r"🕰 Murojaat.*?: (.+)", text)
    if mv: data["murojaat_vaqti"] = mv.group(1).strip()
    
    iv = re.search(r"🕰 Ish vaqti: (.+)", text)
    if iv: data["ish_vaqti"] = iv.group(1).strip()
    
    m = re.search(r"🔎 Maqsad: (.+)", text, re.DOTALL)
    if not m: m = re.search(r"‼️ Qo`shimcha:\s*(.+)", text, re.DOTALL)
    if m: data["maqsad"] = m.group(1).strip()
    
    return data


def main():
    results = []
    
    for f in TXT_FILES:
        path = Path(f)
        if not path.exists():
            print(f"⚠️ File {f} not found, skipping.")
            continue
        text = path.read_text(encoding="utf-8")
        parsed = parse_announcement(text)
        results.append(parsed)
    
    with open(OUTPUT_FILE, "w", encoding="utf-8") as out:
        json.dump(results, out, ensure_ascii=False, indent=2)
    
    print(f"✅ Parsing completed. Output saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
    print("Script executed successfully.")
    
