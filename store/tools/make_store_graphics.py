#!/usr/bin/env python3
"""Render Flowsy's Play Store graphics with headless Chrome.

Outputs:
  store/graphics/feature-graphic.png      (1024x500, English)
  store/graphics/feature-graphic-ar.png   (1024x500, Arabic)
  store/screenshots/en|ar/01.png, 02.png   (hero scene split across two images)
  store/screenshots/en|ar/03.png ... 07.png (features, 1080x1920)
  store/screenshots/tablet-en|tablet-ar/01.png ... 05.png (2560x1600)

Put your real phone screenshots in store/screenshots/raw/en/01.png ... 05.png
and store/screenshots/raw/ar/01.png ... 05.png. Tablet captures go in
raw/tablet-en and raw/tablet-ar with the same names. Then run:
  python3 store/tools/make_store_graphics.py
Missing raw screenshots are drawn as a grey placeholder.
"""
import base64, pathlib, subprocess, tempfile, html

ROOT = pathlib.Path(__file__).resolve().parents[1]
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
ICON = ROOT / "graphics" / "play-icon-512.png"

FONTS = ('<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;700;800'
         '&family=Cairo:wght@500;700;900&display=swap" rel="stylesheet">')

SHOTS = [
    # (raw file, en title, en subtitle, ar title, ar subtitle, background)
    ("01.png", "All your money.<br>One screen.",
     "InstaPay, Vodafone Cash, bank or cash at home. Every wallet in one place.",
     "كل فلوسك<br>في شاشة واحدة",
     "إنستاباي، فودافون كاش، البنك أو الكاش. كله في مكان واحد.", "green"),
    ("02.png", "Know what's<br><em>really</em> left.",
     "In account, I will spend, so I have. Flowsy does the math.",
     "اعرف فاضلك<br><em>كام بجد</em>",
     "في الحساب، هصرف، فاضل معايا. فلوسي بيحسبها لك.", "mint"),
    ("03.png", "Log spending<br>in seconds.",
     "Money in, money out, full history for every wallet.",
     "سجّل مصروفك<br>في ثواني",
     "فلوس دخلت وفلوس خرجت، وسجل كامل لكل محفظة.", "dark"),
    ("04.png", "Locked to you.<br>Reminded daily.",
     "Open with your fingerprint. Get a nudge at 5 PM and 9 PM.",
     "مقفول عليك انت.<br>ومفكرك كل يوم.",
     "افتحه ببصمتك، وهيفكرك الساعة ٥ و ٩ بالليل.", "green"),
    ("05.png", "Your language.<br>Your theme.",
     "Arabic and English, light and dark. No ads, ever.",
     "لغتك.<br>وشكلك المفضل.",
     "عربي وإنجليزي، فاتح وداكن. ومن غير إعلانات خالص.", "mint"),
]

BG = {
    "green": ("linear-gradient(160deg,#1DB86A 0%,#0E8A4E 55%,#07663A 100%)", "#fff", "rgba(255,255,255,.82)", "#F6C343"),
    "mint":  ("linear-gradient(160deg,#EAFBF1 0%,#CFF3DE 100%)", "#0B3D25", "#2F5B45", "#0E8A4E"),
    "dark":  ("linear-gradient(160deg,#16201B 0%,#0B110E 100%)", "#fff", "rgba(255,255,255,.72)", "#2BD483"),
}


def data_uri(path):
    return "data:image/png;base64," + base64.b64encode(path.read_bytes()).decode()


def render(html_doc, out, w, h):
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as f:
        f.write(html_doc)
        src = f.name
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    "--force-device-scale-factor=1", f"--window-size={w},{h}",
                    "--virtual-time-budget=8000", f"--screenshot={out}", f"file://{src}"],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    pathlib.Path(src).unlink()
    print("wrote", out.relative_to(ROOT.parent))


def feature_graphic(lang):
    ar = lang == "ar"
    icon = data_uri(ICON)
    if ar:
        brand, head = "فلوسي", "كل جنيه<br>في مكانه."
        sub = "قسّم فلوسك على محافظ، خطط لمصاريفك، واعرف فاضلك كام بجد."
        cards = [("إنستاباي", "٤٬٢٥٠ ج.م", "#1DB86A"), ("فودافون كاش", "١٬٨٠٠ ج.م", "#E53935"),
                 ("كاش في البيت", "٩٥٠ ج.م", "#F6C343")]
        left_label, stats = "فاضل معايا", "٣٬٤٠٠ ج.م"
    else:
        brand, head = "Flowsy", "Every pound,<br>in its place."
        sub = "Split your money into wallets, plan your spending, and see what's really left."
        cards = [("InstaPay", "EGP 4,250", "#1DB86A"), ("Vodafone Cash", "EGP 1,800", "#E53935"),
                 ("Cash at home", "EGP 950", "#F6C343")]
        left_label, stats = "So I have", "EGP 3,400"
    font = "'Cairo'" if ar else "'Plus Jakarta Sans'"
    card_html = "".join(
        f'<div class="card" style="--c:{c}"><span class="dot"></span><span class="n">{n}</span><span class="a">{a}</span></div>'
        for n, a, c in cards)
    doc = f"""<!doctype html><html dir="ltr"><head><meta charset="utf-8">{FONTS}<style>
*{{margin:0;box-sizing:border-box}} html{{overflow:hidden}}
body{{width:1024px;height:500px;overflow:hidden;font-family:{font},system-ui,sans-serif;
background:radial-gradient(circle at 85% 20%,#27D07E 0,transparent 45%),linear-gradient(135deg,#12A860 0%,#0B7A45 60%,#065C33 100%);color:#fff;position:relative}}
.blob{{position:absolute;border-radius:50%;background:rgba(255,255,255,.07)}}
.wrap{{position:absolute;inset:0;display:flex;align-items:center;padding:0 64px;gap:40px}}
.text{{flex:1.15}}
.brand{{display:flex;align-items:center;gap:14px;font-weight:800;font-size:30px;margin-bottom:22px}}
.brand img{{width:56px;height:56px;border-radius:14px;box-shadow:0 8px 20px rgba(0,0,0,.2)}}
h1{{font-size:{'58px' if ar else '54px'};line-height:{'1.25' if ar else '1.05'};font-weight:{'900' if ar else '800'};letter-spacing:{'0' if ar else '-1.5px'}}}
p{{margin-top:18px;font-size:21px;line-height:1.45;color:rgba(255,255,255,.85);max-width:430px;font-weight:500}}
.stack{{flex:1;position:relative;height:330px}}
.panel{{position:absolute;inset:0;background:rgba(255,255,255,.96);border-radius:28px;padding:24px;box-shadow:0 30px 60px rgba(0,0,0,.25);color:#10251A;transform:rotate({'3deg' if ar else '-3deg'})}}
.lbl{{font-size:15px;color:#5A6B62;font-weight:600}}
.big{{font-size:38px;font-weight:800;margin:4px 0 18px;color:#0B7A45}}
.card{{display:flex;align-items:center;gap:12px;background:#F2F7F4;border-radius:16px;padding:13px 16px;margin-top:10px;font-weight:700;font-size:17px}}
.dot{{width:14px;height:14px;border-radius:50%;background:var(--c)}}
.n{{flex:1}} .a{{color:#10251A}}
.chip{{position:absolute;{'left' if ar else 'right'}:-18px;top:-22px;background:#F6C343;color:#3A2A00;font-weight:800;font-size:15px;padding:10px 16px;border-radius:999px;box-shadow:0 10px 20px rgba(0,0,0,.2);transform:rotate({'-4deg' if ar else '4deg'})}}
</style></head><body>
<div class="blob" style="width:360px;height:360px;{'left' if ar else 'right'}:-120px;bottom:-190px"></div>
<div class="blob" style="width:220px;height:220px;{'right' if ar else 'left'}:38%;top:-150px"></div>
<div class="wrap" dir="{'rtl' if ar else 'ltr'}"><div class="text"><div class="brand"><img src="{icon}">{brand}</div><h1>{head}</h1><p>{sub}</p></div>
<div class="stack"><div class="panel"><div class="lbl">{left_label}</div><div class="big">{stats}</div>{card_html}</div>
<div class="chip">{'🔒 بالبصمة' if ar else '🔒 Fingerprint lock'}</div></div></div></body></html>"""
    name = "feature-graphic-ar.png" if ar else "feature-graphic.png"
    render(doc, ROOT / "graphics" / name, 1024, 500)


def screenshot(lang, idx, shot):
    ar = lang == "ar"
    raw_name, en_t, en_s, ar_t, ar_s, bg = shot
    grad, fg, sub_c, accent = BG[bg]
    title, sub = (ar_t, ar_s) if ar else (en_t, en_s)
    raw = ROOT / "screenshots" / "raw" / lang / raw_name
    if raw.exists():
        screen = f'<img src="{data_uri(raw)}">'
    else:
        screen = f'<div class="ph">{"حط سكرين شوت" if ar else "Add screenshot"}<br><small>raw/{lang}/{raw_name}</small></div>'
    font = "'Cairo'" if ar else "'Plus Jakarta Sans'"
    doc = f"""<!doctype html><html dir="ltr"><head><meta charset="utf-8">{FONTS}<style>
*{{margin:0;box-sizing:border-box}} html{{overflow:hidden}}
body{{width:1080px;height:1920px;overflow:hidden;background:{grad};font-family:{font},system-ui,sans-serif;position:relative}}
.glow{{position:absolute;width:900px;height:900px;border-radius:50%;background:radial-gradient(circle,{accent}33 0,transparent 65%);{'left' if ar else 'right'}:-300px;top:-250px}}
.head{{position:relative;padding:120px 90px 0;text-align:center}}
h1{{color:{fg};font-size:{'98px' if ar else '92px'};line-height:{'1.3' if ar else '1.05'};font-weight:{'900' if ar else '800'};letter-spacing:{'0' if ar else '-2.5px'}}}
h1 em{{font-style:normal;color:{accent}}}
p{{color:{sub_c};font-size:40px;line-height:1.4;margin:34px auto 0;max-width:860px;font-weight:500}}
.phone{{position:absolute;left:50%;transform:translateX(-50%);top:{'720px' if ar else '690px'};width:760px;height:1560px;background:#0D0F0E;border-radius:92px;padding:22px;box-shadow:0 60px 120px rgba(0,0,0,.35),0 0 0 3px rgba(255,255,255,.08) inset}}
.screen{{width:100%;height:100%;border-radius:72px;overflow:hidden;background:#F8F9FA;position:relative}}
.screen img{{width:100%;height:100%;object-fit:cover;object-position:top}}
.cam{{position:absolute;top:24px;left:50%;transform:translateX(-50%);width:26px;height:26px;border-radius:50%;background:#0D0F0E;z-index:2}}
.ph{{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#9AA59F;font-size:44px;font-weight:700;text-align:center;background:repeating-linear-gradient(45deg,#EEF2F0 0 30px,#E6ECE9 30px 60px)}}
.ph small{{font-size:28px;font-weight:500;margin-top:14px;direction:ltr}}
</style></head><body><div class="glow"></div>
<div class="head" dir="{'rtl' if ar else 'ltr'}"><h1>{title}</h1><p>{sub}</p></div>
<div class="phone"><div class="screen"><div class="cam"></div>{screen}</div></div></body></html>"""
    render(doc, ROOT / "screenshots" / lang / f"{idx:02d}.png", 1080, 1920)


def feature_graphic_open_wallet():
    """Arabic feature graphic: an open wallet with its contents fanned out."""
    icon = data_uri(ICON)
    doc = f"""<!doctype html><html dir="ltr"><head><meta charset="utf-8">{FONTS}<style>
*{{margin:0;box-sizing:border-box}} html{{overflow:hidden}}
body{{width:1024px;height:500px;overflow:hidden;font-family:'Cairo',system-ui,sans-serif;position:relative;
background:radial-gradient(circle at 25% 30%,#2BD483 0,transparent 42%),linear-gradient(135deg,#12A860 0%,#0B7A45 60%,#065C33 100%);color:#fff}}
.blob{{position:absolute;border-radius:50%;background:rgba(255,255,255,.07)}}
.text{{position:absolute;right:60px;top:0;bottom:0;width:430px;display:flex;flex-direction:column;justify-content:center;text-align:right}}
.brand{{display:flex;align-items:center;gap:14px;font-weight:900;font-size:30px;margin-bottom:14px}}
.brand img{{width:54px;height:54px;border-radius:14px;box-shadow:0 8px 20px rgba(0,0,0,.2)}}
h1{{font-size:56px;line-height:1.25;font-weight:900}}
h1 span{{color:#F6C343}}
p{{margin-top:14px;font-size:20px;line-height:1.55;color:rgba(255,255,255,.88);font-weight:500}}
.scene{{position:absolute;left:40px;top:0;width:500px;height:500px}}
.shadow{{position:absolute;left:70px;bottom:26px;width:380px;height:40px;border-radius:50%;background:rgba(0,0,0,.25);filter:blur(14px)}}
.back{{position:absolute;left:60px;bottom:52px;width:400px;height:200px;border-radius:30px;background:linear-gradient(180deg,#07482A,#0A5C35)}}
.item{{position:absolute;border-radius:18px;padding:14px 18px;box-shadow:0 12px 24px rgba(0,0,0,.25);direction:rtl;font-weight:800}}
.card{{width:188px;height:122px;color:#fff;display:flex;flex-direction:column;justify-content:space-between}}
.card .top{{display:flex;justify-content:space-between;align-items:center;font-size:17px}}
.chipi{{width:36px;height:26px;border-radius:6px;background:linear-gradient(135deg,#F9D66B,#D9A92A)}}
.card .amt{{font-size:22px;direction:rtl}}
.card .lab{{font-size:13px;opacity:.85;font-weight:600}}
.c1{{left:30px;top:168px;background:linear-gradient(135deg,#27C97A,#0E8A4E);transform:rotate(-14deg)}}
.c2{{left:168px;top:112px;background:linear-gradient(135deg,#EF5350,#B71C1C);transform:rotate(-2deg)}}
.cash{{left:330px;top:165px;width:160px;height:104px;background:linear-gradient(135deg,#E8F5D0,#C7E3A0);color:#2E4A12;transform:rotate(13deg);border:3px dashed rgba(46,74,18,.25);display:flex;flex-direction:column;justify-content:center;align-items:center}}
.cash .amt{{font-size:26px}} .cash .lab{{font-size:14px;font-weight:700;opacity:.8}}
.plan{{left:150px;top:150px;width:200px;background:#fff;color:#10251A;transform:rotate(-3deg);padding:12px 16px;font-size:15px}}
.plan b{{display:block;color:#0B7A45;font-size:16px;margin-bottom:4px}}
.plan div{{display:flex;justify-content:space-between;font-weight:700;color:#3C5046;line-height:1.7}}
.front{{position:absolute;left:52px;bottom:40px;width:416px;height:170px;border-radius:26px 26px 32px 32px;
background:linear-gradient(180deg,#14A35E,#0C7F47);box-shadow:0 -6px 18px rgba(0,0,0,.18) inset,0 16px 30px rgba(0,0,0,.25)}}
.front:before{{content:"";position:absolute;inset:12px;border:2px dashed rgba(255,255,255,.35);border-radius:18px}}
.clasp{{position:absolute;left:-6px;top:22px;width:90px;height:56px;border-radius:0 28px 28px 0;background:#0A6B3B;display:flex;align-items:center;justify-content:center}}
.clasp i{{width:26px;height:26px;border-radius:50%;background:#F6C343;box-shadow:0 0 0 5px rgba(246,195,67,.3)}}
.total{{position:absolute;left:100px;width:352px;bottom:66px;direction:rtl;display:flex;justify-content:space-between;color:#fff;text-align:center}}
.total div{{font-weight:900}} .total div.hi span{{color:#F6C343}}
.total small{{display:block;font-size:14px;font-weight:700;opacity:.85}}
.total span{{font-size:26px}} .total em{{font-style:normal;font-size:15px;font-weight:700;opacity:.8}}
.spark{{position:absolute;color:#F6C343;font-size:26px}}
</style></head><body>
<div class="blob" style="width:340px;height:340px;right:-130px;bottom:-200px"></div>
<div class="blob" style="width:200px;height:200px;left:46%;top:-130px"></div>
<div class="scene">
  <div class="shadow"></div><div class="back"></div>
  <div class="item cash"><div class="amt">٩٥٠ ج.م</div><div class="lab">كاش في البيت</div></div>
  <div class="item card c2"><div class="top"><span>فودافون كاش</span><span class="chipi"></span></div><div><div class="lab">في الحساب</div><div class="amt">١٬٨٠٠ ج.م</div></div></div>
  <div class="item card c1"><div class="top"><span>إنستاباي</span><span class="chipi"></span></div><div><div class="lab">في الحساب</div><div class="amt">٤٬٢٥٠ ج.م</div></div></div>
  <div class="front"><div class="clasp"><i></i></div></div>
  <div class="total"><div><small>في الحساب</small><span>٧٬٠٠٠</span></div><div><small>هصرف</small><span>٣٬٦٠٠</span></div><div class="hi"><small>فاضل معايا</small><span>٣٬٤٠٠</span> <em>ج.م</em></div></div>
  <div class="spark" style="left:120px;top:110px">✦</div><div class="spark" style="left:470px;top:120px;font-size:18px">✦</div>
</div>
<div class="text" dir="rtl"><div class="brand"><img src="{icon}">فلوسي</div>
<h1>افتح محفظتك<br>و<span>اعرف فيها إيه</span></h1>
<p>كل فلوسك متقسمة جوه محافظ، وفلوسي بيقولك هتصرف كام وفاضلك كام بجد.</p></div>
</body></html>"""
    render(doc, ROOT / "graphics" / "feature-graphic-ar-open-wallet.png", 1024, 500)


HERO = {
    "en": dict(welcome="Welcome to", brand="Flowsy", slogan="Split. Plan. Track.",
               right="Every pound,<br>in its place", sub="Day and night, always know what's left."),
    "ar": dict(welcome="أهلاً بيك في", brand="فلوسي", slogan="قسّم. خطط. تابع.",
               right="كل جنيه<br>في مكانه", sub="بالليل والنهار، اعرف فاضلك كام."),
}


def hero(lang):
    """Two screenshots (01, 02) that join into one wide scene."""
    from PIL import Image
    ar = lang == "ar"
    t = HERO[lang]
    icon = data_uri(ICON)
    font = "'Cairo'" if ar else "'Plus Jakarta Sans'"
    tiles = [(330, 640, "💳", "#FFFFFF"), (190, 980, "🔒", "#F6C343"), (260, 1330, "🔔", "#2BD483"),
             (1930, 1560, "💰", "#FFFFFF"), (1990, 1060, "📊", "#F6C343")]
    tile_html = "".join(
        f'<div class="tile" style="left:{x}px;top:{y}px;--c:{c}"><div class="top">{e}</div></div>' for x, y, e, c in tiles)
    doc = f"""<!doctype html><html dir="ltr"><head><meta charset="utf-8">{FONTS}<style>
*{{margin:0;box-sizing:border-box}} html{{overflow:hidden}}
body{{width:2160px;height:1920px;overflow:hidden;position:relative;font-family:{font},system-ui,sans-serif;
background:radial-gradient(circle at 30% 35%,#E9FBF1 0,transparent 40%),radial-gradient(circle at 80% 70%,#C8F1DA 0,transparent 45%),linear-gradient(160deg,#DDF7E8 0%,#BDEBD2 100%)}}
.logo{{position:absolute;left:0;width:1080px;top:150px;display:flex;justify-content:center;align-items:center;gap:28px;font-weight:900;font-size:110px;color:#0B6B3D;letter-spacing:{'0' if ar else '-3px'}}}
.logo img{{width:140px;height:140px;border-radius:36px;box-shadow:0 20px 40px rgba(11,107,61,.3)}}
.slogan{{position:absolute;left:0;width:1080px;bottom:150px;text-align:center;font-size:64px;font-weight:800;color:#0B3D25}}
.right{{position:absolute;left:1080px;width:1080px;top:330px;padding:0 120px;text-align:{'right' if ar else 'left'};color:#0B3D25}}
.right h2{{font-size:96px;line-height:{'1.3' if ar else '1.05'};font-weight:900;letter-spacing:{'0' if ar else '-2px'}}}
.right p{{font-size:44px;margin-top:26px;color:#2F5B45;font-weight:600}}
.path{{position:absolute;inset:0}}
.stage{{position:absolute;left:1080px;top:1170px;width:0;height:0;perspective:3000px}}
.phone{{position:absolute;left:-400px;top:-770px;width:800px;height:1540px;border-radius:120px;background:#101412;padding:26px;
transform:rotateX(52deg) rotateZ(-38deg);transform-style:preserve-3d;box-shadow:-60px 90px 90px rgba(11,61,37,.35)}}
.screen{{width:100%;height:100%;border-radius:96px;overflow:hidden;position:relative;background:linear-gradient(170deg,#1DB86A 0%,#0B7A45 60%,#065C33 100%)}}
.screen .wave{{position:absolute;border-radius:50%}}
.screen .content{{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#fff;gap:30px;direction:{'rtl' if ar else 'ltr'}}}
.screen .content small{{font-size:70px;font-weight:600;opacity:.9}}
.screen .content b{{font-size:170px;font-weight:900}}
.screen .content img{{width:300px;height:300px;border-radius:70px;box-shadow:0 30px 60px rgba(0,0,0,.25)}}
.tile{{position:absolute;width:210px;height:210px;transform:translate(-50%,-50%)}}
.tile .top{{width:170px;height:170px;margin:auto;border-radius:36px;background:var(--c);display:flex;align-items:center;justify-content:center;font-size:96px;
transform:rotateX(52deg) rotateZ(-38deg);box-shadow:-18px 26px 0 rgba(11,107,61,.25),-30px 50px 50px rgba(11,61,37,.25)}}
</style></head><body>
<svg class="path" width="2160" height="1920"><path d="M120 1150 C 150 800, 250 620, 480 560 S 800 500, 900 640 M 1700 1850 C 1850 1750, 2000 1650, 1990 1180" fill="none" stroke="#0B7A45" stroke-opacity=".35" stroke-width="6" stroke-dasharray="4 22" stroke-linecap="round"/></svg>
<div class="logo" dir="{'rtl' if ar else 'ltr'}"><img src="{icon}">{t['brand']}</div>
<div class="stage"><div class="phone"><div class="screen">
<div class="wave" style="width:1200px;height:1200px;background:#F6C343;opacity:.9;left:-600px;bottom:-750px"></div>
<div class="wave" style="width:900px;height:900px;background:rgba(255,255,255,.12);right:-450px;top:-300px"></div>
<div class="content"><small>{t['welcome']}</small><img src="{icon}"><b>{t['brand']}</b></div></div></div></div>
{tile_html}
<div class="slogan" dir="{'rtl' if ar else 'ltr'}">{t['slogan']}</div>
<div class="right" dir="{'rtl' if ar else 'ltr'}"><h2>{t['right']}</h2><p>{t['sub']}</p></div>
</body></html>"""
    wide = ROOT / "screenshots" / lang / "hero-wide.png"
    render(doc, wide, 2160, 1920)
    im = Image.open(wide)
    left, right = im.crop((0, 0, 1080, 1920)), im.crop((1080, 0, 2160, 1920))
    # Play shows screenshots left to right in both languages, so the scene is split the same way.
    left.save(ROOT / "screenshots" / lang / "01.png")
    right.save(ROOT / "screenshots" / lang / "02.png")
    print("split into", lang, "01.png and 02.png")


def tablet(lang, idx, shot):
    """Landscape 10-inch tablet screenshot, 2560x1600, headline above the device."""
    ar = lang == "ar"
    raw_name, en_t, en_s, ar_t, ar_s, bg = shot
    grad, fg, sub_c, accent = BG[bg]
    title = (ar_t if ar else en_t).replace("<br>", " ")
    raw = ROOT / "screenshots" / "raw" / f"tablet-{lang}" / raw_name
    screen = (f'<img src="{data_uri(raw)}">' if raw.exists() else
              f'<div class="ph">{"حط سكرين شوت التابلت" if ar else "Add tablet screenshot"}<br><small>raw/tablet-{lang}/{raw_name}</small></div>')
    font = "'Cairo'" if ar else "'Plus Jakarta Sans'"
    doc = f"""<!doctype html><html dir="ltr"><head><meta charset="utf-8">{FONTS}<style>
*{{margin:0;box-sizing:border-box}} html{{overflow:hidden}}
body{{width:2560px;height:1600px;overflow:hidden;background:{grad};font-family:{font},system-ui,sans-serif;position:relative}}
.glow{{position:absolute;width:1400px;height:1400px;border-radius:50%;background:radial-gradient(circle,{accent}33 0,transparent 65%);right:-400px;top:-500px}}
h1{{position:relative;text-align:center;padding-top:110px;color:{fg};font-size:{'104px' if ar else '100px'};font-weight:{'900' if ar else '800'};letter-spacing:{'0' if ar else '-2.5px'}}}
h1 em{{font-style:normal;color:{accent}}}
.tab{{position:absolute;left:50%;transform:translateX(-50%);top:360px;width:1900px;height:1213px;background:#0D0F0E;border-radius:70px;padding:34px;box-shadow:0 60px 120px rgba(0,0,0,.35)}}
.screen{{width:100%;height:100%;border-radius:40px;overflow:hidden;background:#F8F9FA}}
.screen img{{width:100%;height:100%;object-fit:cover;object-position:top}}
.ph{{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#9AA59F;font-size:60px;font-weight:700;background:repeating-linear-gradient(45deg,#EEF2F0 0 40px,#E6ECE9 40px 80px)}}
.ph small{{font-size:36px;font-weight:500;margin-top:16px;direction:ltr}}
</style></head><body><div class="glow"></div><h1 dir="{'rtl' if ar else 'ltr'}">{title}</h1>
<div class="tab"><div class="screen">{screen}</div></div></body></html>"""
    render(doc, ROOT / "screenshots" / f"tablet-{lang}" / f"{idx:02d}.png", 2560, 1600)


if __name__ == "__main__":
    import sys
    if "--open-wallet" in sys.argv:
        feature_graphic_open_wallet(); raise SystemExit
    for lang in ("en", "ar"):
        feature_graphic(lang)
        hero(lang)
        # Feature screenshots follow the two hero images: 03.png to 07.png.
        for i, shot in enumerate(SHOTS, 3):
            screenshot(lang, i, shot)
        for i, shot in enumerate(SHOTS, 1):
            tablet(lang, i, shot)
