#!/usr/bin/env python3
"""Build Flowsy's 1920x1080 promo video from a raw emulator recording.

Input:  store/video/demo-raw.mp4 (adb screenrecord, 1080x2424)
Output: store/video/flowsy-demo.mp4
Scene start times below are in seconds of the raw recording.
"""
import pathlib, subprocess, sys
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from make_store_graphics import render, data_uri, ICON, FONTS

ROOT = pathlib.Path(__file__).resolve().parents[1]
VID = ROOT / "video"
WORK = VID / "build"
RAW = VID / "demo-raw.mp4"
INTRO, OUTRO = 3.0, 3.5

SCENES = [  # start, title, subtitle
    (0.0, "All your money.<br>One screen.", "InstaPay, Vodafone Cash, your bank card and cash at home."),
    (7.1, "Know what's<br><em>really</em> left.", "In account, I will spend, so I have."),
    (10.7, "Plan before<br>you spend.", "Add rent, gym or shopping, and Flowsy does the math."),
    (19.2, "Every pound,<br>tracked.", "Money in and money out, with a full history."),
    (23.8, "Light or dark.", "Pick the look that suits you."),
    (32.6, "Arabic and English.", "Full right-to-left support: <span dir='rtl'>عربي وإنجليزي</span>"),
]

# Phone placement in the 1920x1080 frame.
SX, SY, SW, SH = 1170, 60, 428, 960   # screen area (video goes here)
PAD, R_IN, R_OUT = 16, 46, 62

BASE_CSS = """*{margin:0;box-sizing:border-box} html{overflow:hidden}
body{width:1920px;height:1080px;overflow:hidden;position:relative;font-family:'Plus Jakarta Sans',system-ui,sans-serif;
background:radial-gradient(circle at 78% 45%,#2BD483 0,transparent 38%),linear-gradient(135deg,#12A860 0%,#0B7A45 55%,#065C33 100%);color:#fff}
.blob{position:absolute;border-radius:50%;background:rgba(255,255,255,.06)}"""


def ffmpeg(*args):
    subprocess.run(["ffmpeg", "-v", "error", "-y", *args], check=True)


def duration(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)],
                         capture_output=True, text=True, check=True)
    return float(out.stdout.strip())


def scene_bg(i, title, sub):
    icon = data_uri(ICON)
    dots = "".join(f'<span class="{"on" if k == i else ""}"></span>' for k in range(len(SCENES)))
    doc = f"""<!doctype html><html><head><meta charset="utf-8">{FONTS}<style>{BASE_CSS}
.brand{{position:absolute;left:150px;top:110px;display:flex;align-items:center;gap:18px;font-size:40px;font-weight:800}}
.brand img{{width:72px;height:72px;border-radius:18px;box-shadow:0 10px 24px rgba(0,0,0,.2)}}
h1{{position:absolute;left:150px;top:330px;width:900px;font-size:104px;line-height:1.04;font-weight:800;letter-spacing:-3px}}
h1 em{{font-style:normal;color:#F6C343}}
p{{position:absolute;left:150px;top:700px;width:820px;font-size:38px;line-height:1.4;color:rgba(255,255,255,.86);font-weight:500}}
p span{{font-family:'Cairo'}}
.dots{{position:absolute;left:150px;bottom:110px;display:flex;gap:14px}}
.dots span{{width:14px;height:14px;border-radius:7px;background:rgba(255,255,255,.35)}}
.dots span.on{{width:44px;background:#F6C343}}
</style></head><body>
<div class="blob" style="width:700px;height:700px;right:-220px;bottom:-360px"></div>
<div class="blob" style="width:380px;height:380px;left:44%;top:-230px"></div>
<div class="brand"><img src="{icon}">Flowsy</div><h1>{title}</h1><p>{sub}</p><div class="dots">{dots}</div>
</body></html>"""
    out = WORK / f"bg{i}.png"
    render(doc, out, 1920, 1080)
    return out


def bezel():
    # Opaque phone body with a rounded transparent hole where the recording shows.
    doc = f"""<!doctype html><html><head><meta charset="utf-8"><style>
*{{margin:0}} html,body{{width:1920px;height:1080px;background:transparent;overflow:hidden}}
.phone{{position:absolute;left:{SX-PAD}px;top:{SY-PAD}px;width:{SW+2*PAD}px;height:{SH+2*PAD}px;border-radius:{R_OUT}px;
box-shadow:0 0 0 3px rgba(255,255,255,.08) inset;
background:radial-gradient(circle at 0 0,transparent 0,transparent 0) ;}}
</style></head><body>
<svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
<defs><mask id="m"><rect x="{SX-PAD}" y="{SY-PAD}" width="{SW+2*PAD}" height="{SH+2*PAD}" rx="{R_OUT}" fill="#fff"/>
<rect x="{SX}" y="{SY}" width="{SW}" height="{SH}" rx="{R_IN}" fill="#000"/></mask></defs>
<rect x="{SX-PAD}" y="{SY-PAD}" width="{SW+2*PAD}" height="{SH+2*PAD}" rx="{R_OUT}" fill="#0D0F0E" mask="url(#m)"/>
<circle cx="{SX+SW//2}" cy="{SY+22}" r="9" fill="#0D0F0E"/>
</svg></body></html>"""
    out = WORK / "bezel.png"
    html = WORK / "bezel.html"
    html.write_text(doc)
    subprocess.run(["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "--headless=new", "--disable-gpu",
                    "--hide-scrollbars", "--force-device-scale-factor=1", "--window-size=1920,1080",
                    "--default-background-color=00000000", f"--screenshot={out}", f"file://{html}"],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return out


def card(name, title, sub):
    icon = data_uri(ICON)
    doc = f"""<!doctype html><html><head><meta charset="utf-8">{FONTS}<style>{BASE_CSS}
.c{{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center}}
.c img{{width:200px;height:200px;border-radius:50px;box-shadow:0 30px 60px rgba(0,0,0,.25)}}
h1{{margin-top:44px;font-size:120px;font-weight:800;letter-spacing:-3px}}
p{{margin-top:18px;font-size:44px;color:rgba(255,255,255,.88);font-weight:600}}
p b{{color:#F6C343}}
</style></head><body>
<div class="blob" style="width:760px;height:760px;right:-260px;bottom:-380px"></div>
<div class="blob" style="width:420px;height:420px;left:-140px;top:-160px"></div>
<div class="c"><img src="{icon}"><h1>{title}</h1><p>{sub}</p></div></body></html>"""
    out = WORK / f"{name}.png"
    render(doc, out, 1920, 1080)
    return out


def main():
    WORK.mkdir(parents=True, exist_ok=True)
    total = duration(RAW)
    bgs = [scene_bg(i, t, s) for i, (_, t, s) in enumerate(SCENES)]
    bz = bezel()
    intro = card("intro", "Flowsy", "Every pound, <b>in its place.</b>")
    outro = card("outro", "Get Flowsy", "Split. Plan. Track. <b>Free on Google Play.</b>")

    # Background track: each scene's card held for that scene's length.
    lst = WORK / "bg.txt"
    lines = []
    for i, (start, _, _) in enumerate(SCENES):
        end = SCENES[i + 1][0] if i + 1 < len(SCENES) else total
        lines += [f"file '{bgs[i]}'", f"duration {end - start:.3f}"]
    lines.append(f"file '{bgs[-1]}'")
    lst.write_text("\n".join(lines) + "\n")

    main_mp4 = WORK / "main.mp4"
    ffmpeg("-f", "concat", "-safe", "0", "-i", str(lst), "-i", str(RAW), "-i", str(bz),
           "-filter_complex",
           f"[0:v]fps=30,format=yuv420p[bg];[1:v]fps=30,scale={SW}:{SH}[ph];"
           f"[bg][ph]overlay={SX}:{SY}:shortest=1[a];[a][2:v]overlay=0:0,format=yuv420p[v]",
           "-map", "[v]", "-t", f"{total:.3f}", "-c:v", "libx264", "-crf", "18", "-preset", "slow", str(main_mp4))

    for name, img, d in (("intro", intro, INTRO), ("outro", outro, OUTRO)):
        ffmpeg("-loop", "1", "-i", str(img), "-t", str(d), "-vf", "fps=30,format=yuv420p",
               "-c:v", "libx264", "-crf", "18", str(WORK / f"{name}.mp4"))

    out = VID / "flowsy-demo.mp4"
    x = 0.6
    ffmpeg("-i", str(WORK / "intro.mp4"), "-i", str(main_mp4), "-i", str(WORK / "outro.mp4"),
           "-filter_complex",
           f"[0:v][1:v]xfade=transition=fade:duration={x}:offset={INTRO - x}[m];"
           f"[m][2:v]xfade=transition=fade:duration={x}:offset={INTRO + total - 2 * x}[v]",
           "-map", "[v]", "-c:v", "libx264", "-crf", "18", "-preset", "slow", "-pix_fmt", "yuv420p",
           "-movflags", "+faststart", str(out))
    print("wrote", out.relative_to(ROOT.parent), f"({duration(out):.1f}s)")


if __name__ == "__main__":
    main()
