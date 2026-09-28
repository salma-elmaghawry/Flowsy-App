#!/usr/bin/env python3
"""Render the Flowsy portfolio card covers (2600x1024) with headless Chrome.

Outputs:
  store/graphics/portfolio-card.png       four phones cropped at the bottom
  store/graphics/portfolio-card-full.png  five complete phones
  store/graphics/portfolio-card-modern.png  dark emerald hero with tilted phones
Run:    python3 store/tools/make_portfolio_card.py
"""
import pathlib

from make_store_graphics import CHROME, FONTS, ICON, ROOT, data_uri
import subprocess, tempfile

W, H, SCALE = 1300, 512, 2
RAW = ROOT / "screenshots" / "raw" / "en"
OUT = ROOT / "graphics" / "portfolio-card.png"
OUT_FULL = ROOT / "graphics" / "portfolio-card-full.png"
OUT_MODERN = ROOT / "graphics" / "portfolio-card-modern.png"

PHONES = [
    # (raw screen, left, top)
    ("01.png", 30, 150),
    ("02.png", 350, 222),
    ("04.png", 670, 212),
    ("05.png", 990, 132),
]


def phone(shot, left, top):
    return f'''
<div class="phone" style="left:{left}px;top:{top}px">
  <div class="screen"><img src="{data_uri(RAW / shot)}"><div class="notch"></div></div>
</div>'''


def build():
    phones = "".join(phone(*p) for p in PHONES)
    return f'''<!doctype html><html><head><meta charset="utf-8">{FONTS}<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{width:{W}px;height:{H}px;overflow:hidden;position:relative;font-family:'Plus Jakarta Sans',system-ui,sans-serif;
  background:radial-gradient(ellipse 60% 70% at 50% 30%,#FFFFFF 0%,#F3FAF6 55%,#E4F4EB 100%)}}
h1{{position:absolute;top:22px;left:0;right:0;text-align:center;color:#0E8A4E;font-size:29px;font-weight:700;letter-spacing:-.3px}}
.logo{{position:absolute;left:50%;top:70px;transform:translateX(-50%);display:flex;flex-direction:column;align-items:center}}
.glow{{position:absolute;top:-26px;width:170px;height:170px;border-radius:50%;
  background:radial-gradient(circle,rgba(29,184,106,.28) 0%,rgba(29,184,106,0) 70%)}}
.logo img{{position:relative;width:92px;height:92px;border-radius:24px;box-shadow:0 10px 24px rgba(14,138,78,.35)}}
.logo span{{position:relative;margin-top:8px;color:#0B5E36;font-size:22px;font-weight:800;letter-spacing:-.4px}}
.phone{{position:absolute;width:280px;height:640px;padding:9px;border-radius:44px;background:#15191A;
  box-shadow:0 0 0 2px #2A3130 inset,0 22px 44px rgba(10,60,35,.22)}}
.screen{{position:relative;width:100%;height:100%;border-radius:36px;overflow:hidden;background:#fff}}
.screen img{{width:100%;display:block}}
.notch{{position:absolute;top:9px;left:50%;transform:translateX(-50%);width:84px;height:22px;border-radius:12px;background:#0B0D0D}}
</style></head><body>
<h1>Budgeting &amp; Personal Finance App</h1>
{phones}
<div class="logo"><div class="glow"></div><img src="{data_uri(ICON)}"><span>Flowsy</span></div>
</body></html>'''


FULL_SHOTS = ["01.png", "02.png", "03.png", "04.png", "05.png"]


def build_full():
    screen_h = 394
    screen_w = round(screen_h * 1080 / 2424)
    phones = "".join(
        f'<div class="fp"><div class="fs"><img src="{data_uri(RAW / s)}"><div class="fn"></div></div></div>'
        for s in FULL_SHOTS)
    return f'''<!doctype html><html><head><meta charset="utf-8">{FONTS}<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{width:{W}px;height:{H}px;overflow:hidden;font-family:'Plus Jakarta Sans',system-ui,sans-serif;
  background:radial-gradient(ellipse 60% 70% at 50% 35%,#FFFFFF 0%,#F3FAF6 55%,#E4F4EB 100%)}}
.head{{height:78px;display:flex;align-items:center;justify-content:center;gap:14px}}
.head img{{width:44px;height:44px;border-radius:12px;box-shadow:0 6px 14px rgba(14,138,78,.3)}}
.head b{{color:#0B5E36;font-size:27px;font-weight:800;letter-spacing:-.4px}}
.head i{{width:6px;height:6px;border-radius:50%;background:#9CCDB2}}
.head span{{color:#0E8A4E;font-size:27px;font-weight:700;letter-spacing:-.3px}}
.row{{display:flex;justify-content:center;gap:38px;padding-top:6px}}
.fp{{padding:8px;border-radius:30px;background:#15191A;
  box-shadow:0 0 0 2px #2A3130 inset,0 18px 34px rgba(10,60,35,.22)}}
.fs{{position:relative;width:{screen_w}px;height:{screen_h}px;border-radius:23px;overflow:hidden;background:#fff}}
.fs img{{width:100%;height:100%;display:block}}
.fn{{position:absolute;top:6px;left:50%;transform:translateX(-50%);width:54px;height:14px;border-radius:8px;background:#0B0D0D}}
</style></head><body>
<div class="head"><img src="{data_uri(ICON)}"><b>Flowsy</b><i></i><span>Budgeting &amp; Personal Finance App</span></div>
<div class="row">{phones}</div>
</body></html>'''


GRAIN = ("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'>"
         "<filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2' stitchTiles='stitch'/></filter>"
         "<rect width='100%' height='100%' filter='url(%23n)' opacity='.5'/></svg>")

FINGERPRINT = ('<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">'
               '<path d="M6.5 5.5A8 8 0 0 1 20 11"/><path d="M4 11a8 8 0 0 1 1-3.8"/>'
               '<path d="M8 20a14 14 0 0 1-1.5-6.5 5.5 5.5 0 0 1 11 0v1"/><path d="M12 13.5c0 3 .8 5.5 2.5 7.5"/>'
               '<path d="M17.5 17.5a18 18 0 0 1-.5 3.5"/><path d="M9.5 13.5a2.5 2.5 0 0 1 5 0"/></svg>')


def mphone(shot, cls):
    return (f'<div class="mp {cls}"><div class="ms"><img src="{data_uri(RAW / shot)}">'
            f'<div class="mn"></div></div></div>')


def build_modern():
    icon = data_uri(ICON)
    return f'''<!doctype html><html><head><meta charset="utf-8">{FONTS}<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{width:{W}px;height:{H}px;overflow:hidden;position:relative;font-family:'Plus Jakarta Sans',system-ui,sans-serif;color:#fff;
  background:linear-gradient(125deg,#06301D 0%,#0A5A34 38%,#0E8A4E 72%,#16B06A 100%)}}
.glow1{{position:absolute;left:760px;top:-160px;width:620px;height:620px;border-radius:50%;
  background:radial-gradient(circle,rgba(120,255,190,.35) 0%,rgba(120,255,190,0) 65%)}}
.glow2{{position:absolute;left:-180px;top:260px;width:520px;height:520px;border-radius:50%;
  background:radial-gradient(circle,rgba(246,195,67,.18) 0%,rgba(246,195,67,0) 65%)}}
.dots{{position:absolute;inset:0;background-image:radial-gradient(rgba(255,255,255,.10) 1px,transparent 1.4px);
  background-size:22px 22px;-webkit-mask-image:linear-gradient(90deg,#000 0%,transparent 55%)}}
.grain{{position:absolute;inset:0;background-image:url("{GRAIN}");opacity:.10;mix-blend-mode:overlay}}
.left{{position:absolute;left:70px;top:0;height:100%;width:520px;display:flex;flex-direction:column;justify-content:center}}
.brand{{display:flex;align-items:center;gap:14px;margin-bottom:26px}}
.brand img{{width:54px;height:54px;border-radius:15px;box-shadow:0 8px 20px rgba(0,0,0,.3),0 0 0 1px rgba(255,255,255,.2)}}
.brand b{{font-size:30px;font-weight:800;letter-spacing:-.5px}}
.brand small{{display:block;font-size:13px;font-weight:600;color:rgba(255,255,255,.65);letter-spacing:1.6px;text-transform:uppercase;margin-top:2px}}
h1{{font-size:56px;line-height:1.02;font-weight:800;letter-spacing:-2px}}
h1 em{{font-style:normal;color:#F6C343}}
p{{margin-top:18px;font-size:17px;line-height:1.55;color:rgba(255,255,255,.78);font-weight:500;max-width:440px}}
.tags{{display:flex;flex-wrap:wrap;gap:8px;margin-top:24px}}
.tags span{{font-size:13px;font-weight:700;padding:7px 12px;border-radius:999px;background:rgba(255,255,255,.10);
  border:1px solid rgba(255,255,255,.18);backdrop-filter:blur(6px)}}
.stage{{position:absolute;left:600px;top:0;width:700px;height:100%;perspective:1400px}}
.mp{{position:absolute;padding:8px;border-radius:32px;background:#101413;
  box-shadow:0 0 0 1.5px #2E3634 inset,0 30px 60px rgba(0,0,0,.45),0 8px 18px rgba(0,0,0,.25)}}
.ms{{position:relative;border-radius:25px;overflow:hidden;background:#fff}}
.ms img{{width:100%;height:100%;display:block}}
.mn{{position:absolute;top:7px;left:50%;transform:translateX(-50%);width:56px;height:15px;border-radius:8px;background:#0B0D0D}}
.back .ms{{width:160px;height:360px}}
.front .ms{{width:189px;height:424px}}
.l{{left:95px;top:92px;transform:rotateY(22deg) rotateZ(-4deg);filter:brightness(.92)}}
.c{{left:268px;top:44px;z-index:2}}
.r{{left:470px;top:92px;transform:rotateY(-22deg) rotateZ(4deg);filter:brightness(.92)}}
.float{{position:absolute;z-index:3;border-radius:18px;box-shadow:0 18px 40px rgba(0,0,0,.35)}}
.notif{{left:-20px;top:26px;width:278px;padding:12px 14px;display:flex;gap:11px;align-items:flex-start;
  background:rgba(255,255,255,.93);color:#10251A;backdrop-filter:blur(14px)}}
.notif img{{width:34px;height:34px;border-radius:9px;flex:none}}
.notif .meta{{font-size:11px;font-weight:700;color:#6B7A72;display:flex;justify-content:space-between}}
.notif b{{display:block;font-size:14px;margin-top:2px}}
.notif span{{display:block;font-size:12.5px;color:#3C5046;margin-top:1px;line-height:1.35}}
.left-chip{{left:36px;top:388px;padding:13px 16px;background:#fff;color:#10251A}}
.left-chip small{{display:block;font-size:12px;font-weight:700;color:#6B7A72}}
.left-chip b{{display:block;font-size:24px;font-weight:800;color:#0E8A4E;letter-spacing:-.5px}}
.lock{{left:452px;top:414px;padding:11px 15px 11px 11px;display:flex;align-items:center;gap:10px;
  background:rgba(12,24,18,.72);border:1px solid rgba(255,255,255,.16);backdrop-filter:blur(12px);font-weight:700;font-size:14px}}
.lock i{{width:32px;height:32px;border-radius:10px;background:#F6C343;color:#3A2A00;display:grid;place-items:center}}
.lock i svg{{width:20px;height:20px}}
.lock small{{display:block;font-size:11px;font-weight:600;color:rgba(255,255,255,.65)}}
</style></head><body>
<div class="glow1"></div><div class="glow2"></div><div class="dots"></div>
<div class="left">
  <div class="brand"><img src="{icon}"><div><b>Flowsy</b><small>Budgeting app</small></div></div>
  <h1>Every pound,<br><em>in its place.</em></h1>
  <p>Split your money into wallets, plan what each one covers, and always know what&rsquo;s really left.</p>
  <div class="tags"><span>Flutter</span><span>Firebase</span><span>Clean Architecture</span><span>Cubit</span><span>Arabic &middot; English</span></div>
</div>
<div class="stage">
  {mphone("02.png", "back l")}
  {mphone("01.png", "front c")}
  {mphone("05.png", "back r")}
  <div class="float notif"><img src="{icon}"><div style="flex:1"><div class="meta"><span>FLOWSY</span><span>9:00 PM</span></div>
    <b>Spent anything today?</b><span>Take a second to add today&rsquo;s spending in Flowsy.</span></div></div>
  <div class="float left-chip"><small>So I have</small><b>4,680 EGP</b></div>
  <div class="float lock"><i>{FINGERPRINT}</i><div>Unlocked<small>Fingerprint, face or PIN</small></div></div>
</div>
<div class="grain"></div>
</body></html>'''


def render(doc, out):
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as f:
        f.write(doc)
        src = f.name
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    f"--force-device-scale-factor={SCALE}", f"--window-size={W},{H}",
                    "--virtual-time-budget=8000", f"--screenshot={out}", f"file://{src}"],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    pathlib.Path(src).unlink()
    print("wrote", out.relative_to(ROOT.parent))


def main():
    render(build(), OUT)
    render(build_full(), OUT_FULL)
    render(build_modern(), OUT_MODERN)


if __name__ == "__main__":
    main()
