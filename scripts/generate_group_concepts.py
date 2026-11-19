#!/usr/bin/env python3
"""Generate concept group frames (2800x2000) to review before choosing one.

Usage: python3 scripts/generate_group_concepts.py [--publish] [out_dir]   (default build/frame_concepts)
  --publish also installs the concepts that have publish metadata as real frames
  in assets/frames/personal/group/ and registers them in data.json.

Workflow: after a batch is reviewed, give the approved concepts a publish dict
(file, category, slot) and run with --publish: they become real frames and leave
the ideas tab. Delete the unapproved ones -- their function, their CONCEPTS entry
and, on the next run, their generated files.

For every concept it writes <name>_frame.png (the real transparent frame) and
<name>_preview.jpg (a sample photo placed under the frame), plus an index.html
to browse them on a phone. Nothing is registered in the app.
Reuses the helpers of generate_personal_frames.py.
"""
import math
import sys
from functools import partial
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_personal_frames as g  # noqa: E402

SS = g.SS
W, H = g.GROUP_SIZE
FONTS = g.INVITATION / "fonts"
PLAYFAIR = FONTS / "Playfair_Display" / "PlayfairDisplay-Regular.ttf"
PINYON = FONTS / "Pinyon_Script" / "PinyonScript-Regular.ttf"
CORINTHIA = FONTS / "Corinthia" / "Corinthia-Regular.ttf"
DECOR = g.INVITATION / "images" / "decor"
SAMPLE_PHOTO = g.INVITATION / "images" / "gallery" / "album_1.webp"  # stand-in group photo


def S(v):
    return round(v * SS)


def new_canvas(color):
    return Image.new("RGBA", (S(W), S(H)), tuple(color) + (255,))


def text_mid(draw, text, cx, cy, path, size, fill):
    draw.text((S(cx), S(cy)), text, font=g.font(path, size), fill=fill, anchor="mm")


def spaced_mid(draw, text, cx, cy, path, size, fill, spacing):
    fnt = g.font(path, size)
    box = draw.textbbox((0, 0), "Ag", font=fnt)
    g.draw_spaced(draw, text, cx, cy - (box[3] - box[1]) / SS / 2 - box[1] / SS, fnt, fill, spacing)


def punch(canvas, mask):
    """Make the white area of [mask] (L, canvas size) transparent."""
    alpha = canvas.getchannel("A")
    canvas.putalpha(Image.composite(Image.new("L", canvas.size, 0), alpha, mask))


def rrect_mask(box, radius, size=None):
    mask = Image.new("L", size or (S(W), S(H)), 0)
    x, y, w, h = box
    ImageDraw.Draw(mask).rounded_rectangle((S(x), S(y), S(x + w), S(y + h)), S(radius), fill=255)
    return mask


def shadow(canvas, mask, blur, offset=(0, 12), alpha=110):
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    layer.putalpha(mask.point(lambda a: int(a * alpha / 255)).filter(ImageFilter.GaussianBlur(S(blur))))
    shifted = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shifted.alpha_composite(layer, (S(offset[0]), S(offset[1])))
    canvas.alpha_composite(shifted)


def figures(canvas, groom, bride, scale, overlap):
    gb, bb = groom.getchannel("A").getbbox(), bride.getchannel("A").getbbox()
    groom_inner = 20 + (gb[2] - gb[0]) * scale + overlap
    bride_inner = W + 100 - (bb[2] - bb[0]) * scale - overlap
    g.place_figure(canvas, groom, scale, round(groom_inner), "left")
    g.place_figure(canvas, bride, scale, round(bride_inner), "right")


def outline(draw, box, radius, color, width, inset):
    x, y, w, h = box
    draw.rounded_rectangle(
        (S(x - inset), S(y - inset), S(x + w + inset), S(y + h + inset)),
        S(radius + inset), outline=color, width=S(width),
    )


# ---------------------------------------------------------------- concepts








def c_postcard(groom, bride):
    """Bưu thiếp: viền tem răng cưa, dấu bưu điện."""
    cv = new_canvas((212, 188, 148))
    d = ImageDraw.Draw(cv)
    d.rectangle((S(70), S(70), S(W - 70), S(H - 70)), fill=(248, 242, 229, 255))
    hole = (600, 300, 1500, 1125)
    x, y, w, h = hole
    # Perforated edge: cream circles biting into the photo area.
    punch(cv, rrect_mask(hole, 6))
    d = ImageDraw.Draw(cv)
    step, r = 58, 17
    for i in range(int(w // step) + 1):
        cx = x + i * step + (w % step) / 2
        for cy in (y, y + h):
            d.ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), fill=(248, 242, 229, 255))
    for j in range(int(h // step) + 1):
        cy = y + j * step + (h % step) / 2
        for cx in (x, x + w):
            d.ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), fill=(248, 242, 229, 255))
    # The perforation circles must not stay opaque over the hole interior: re-punch.
    inner = rrect_mask((x + r, y + r, w - 2 * r, h - 2 * r), 6)
    punch(cv, inner)
    # Postmark + cancellation lines.
    pm = (140, 70, 60, 255)
    cx, cy = 2330, 330
    d.ellipse((S(cx - 150), S(cy - 150), S(cx + 150), S(cy + 150)), outline=pm, width=S(5))
    d.ellipse((S(cx - 118), S(cy - 118), S(cx + 118), S(cy + 118)), outline=pm, width=S(3))
    text_mid(d, "28.11.26", cx, cy, PLAYFAIR, 44, pm)
    for k in range(4):
        yy = cy - 60 + k * 40
        pts = [(S(cx - 160 - t), S(yy + 14 * math.sin(t / 22))) for t in range(0, 420, 6)]
        d.line(pts, fill=pm, width=S(4))
    text_mid(d, "Gửi bạn,", 1500, 1560, PINYON, 110, (96, 72, 52, 255))
    text_mid(d, g.NAMES, 1500, 1730, PINYON, 140, (96, 72, 52, 255))
    figures(cv, groom, bride, 0.8, 130)
    return cv, hole, 0




# ----------------------------------------------- concepts with the couple together
IMAGES = g.INVITATION / "images"


def cover_focus(img, w, h, fx=0.5, fy=0.5):
    """Like g.cover, but the crop is placed by (fx, fy) in 0..1 instead of centered."""
    scale = max(w / img.width, h / img.height)
    img = img.resize((round(img.width * scale), round(img.height * scale)), Image.LANCZOS)
    left, top = round((img.width - w) * fx), round((img.height - h) * fy)
    return img.crop((left, top, left + w, top + h))


def paste_photo(canvas, name, box, mask, focus=(0.5, 0.5)):
    """Cover-fit a photo from wedding-invitation/images into box (x,y,w,h) clipped by mask.
    [focus] (0..1) picks which part of the photo is kept when it is cropped."""
    x, y, w, h = box
    photo = cover_focus(Image.open(IMAGES / name).convert("RGB"), S(w), S(h), *focus).convert("RGBA")
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    layer.paste(photo, (S(x), S(y)))
    layer.putalpha(Image.composite(layer.getchannel("A"), Image.new("L", canvas.size, 0), mask))
    canvas.alpha_composite(layer)


def perforate(draw, box, r, step, fill):
    x, y, w, h = box
    for i in range(int(w // step) + 1):
        cx = x + i * step + (w % step) / 2
        for cy in (y, y + h):
            draw.ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), fill=fill)
    for j in range(int(h // step) + 1):
        cy = y + j * step + (h % step) / 2
        for cx in (x, x + w):
            draw.ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), fill=fill)








def c_diagonal(groom, bride, photo="couple/banner_left.webp", focus=(0.5, 0.5)):
    """Poster cắt chéo: ảnh cặp đôi bên trái, thẻ ảnh nhóm nghiêng đè lên đường chéo."""
    gold = (214, 190, 140, 255)
    cv = new_canvas((44, 60, 43))
    poly = Image.new("L", cv.size, 0)
    ImageDraw.Draw(poly).polygon([(0, 0), (S(1300), 0), (S(980), S(H)), (0, S(H))], fill=255)
    paste_photo(cv, photo, (0, 0, 1300, H), poly, focus)
    d = ImageDraw.Draw(cv)
    d.line((S(1300), 0, S(980), S(H)), fill=gold, width=S(4))
    d.line((S(1340), 0, S(1020), S(H)), fill=gold, width=S(2))
    return _diagonal_card(cv, d, gold)




def c_diag_split(groom, bride, left="couple/groom.webp", right="couple/bride.webp"):
    """Poster chéo với hai chân dung: chú rể bên trái, cô dâu bên phải trong dải chéo."""
    gold = (214, 190, 140, 255)
    cv = new_canvas((44, 60, 43))
    poly = Image.new("L", cv.size, 0)
    ImageDraw.Draw(poly).polygon([(0, 0), (S(1300), 0), (S(980), S(H)), (0, S(H))], fill=255)
    half = Image.new("L", cv.size, 0)
    ImageDraw.Draw(half).rectangle((0, 0, S(640), S(H)), fill=255)
    left_mask = Image.composite(poly, Image.new("L", cv.size, 0), half)
    right_mask = Image.composite(poly, Image.new("L", cv.size, 0), ImageChops.invert(half))
    paste_photo(cv, left, (0, 0, 640, H), left_mask, (0.6, 0.0))
    paste_photo(cv, right, (640, 0, 700, H), right_mask, (0.62, 0.0))
    d = ImageDraw.Draw(cv)
    d.line((S(640), 0, S(640), S(H)), fill=gold, width=S(3))
    d.line((S(1300), 0, S(980), S(H)), fill=gold, width=S(4))
    d.line((S(1340), 0, S(1020), S(H)), fill=gold, width=S(2))
    return _diagonal_card(cv, d, gold)


def _diagonal_card(cv, d, gold):
    card_w, card_h = 1560, 1230
    cx, cy = 1930, 960
    card_x, card_y = cx - card_w // 2, cy - card_h // 2
    hole = (card_x + 80, card_y + 80, 1400, 1050)
    card = Image.new("RGBA", cv.size, (0, 0, 0, 0))
    ImageDraw.Draw(card).rounded_rectangle((S(card_x), S(card_y), S(card_x + card_w), S(card_y + card_h)), S(18), fill=(252, 250, 245, 255))
    angle = 3.0
    center = (S(cx), S(cy))
    card = card.rotate(angle, center=center, resample=Image.BICUBIC)
    hmask = rrect_mask(hole, 10).rotate(angle, center=center, resample=Image.BICUBIC)
    shadow(cv, card.getchannel("A"), 26, (0, 22), 130)
    cv.alpha_composite(card)
    d = ImageDraw.Draw(cv)
    text_mid(d, g.NAMES, 2000, 1790, PINYON, 140, (244, 238, 224, 255))
    spaced_mid(d, "28 . 11 . 2026", 2000, 190, PLAYFAIR, 50, gold, 18)
    punch(cv, hmask)
    return cv, hole, (angle, (cx, cy))


def c_stamp_column(groom, bride, photos=("couple/timeline_1.webp", "couple/timeline_2.webp", "couple/timeline_3.webp")):
    """Bưu thiếp với ba tem dọc kể chuyện tình (ảnh ngày xưa) bên phải ảnh nhóm."""
    ink, paper, pm = (96, 72, 52, 255), (248, 242, 229, 255), (140, 70, 60, 255)
    cv = new_canvas((212, 188, 148))
    d = ImageDraw.Draw(cv)
    d.rectangle((S(70), S(70), S(W - 70), S(H - 70)), fill=paper)
    hole = (190, 270, 1560, 1170)
    x, y, w, h = hole
    punch(cv, rrect_mask(hole, 6))
    d = ImageDraw.Draw(cv)
    perforate(d, hole, 17, 58, paper)
    punch(cv, rrect_mask((x + 17, y + 17, w - 34, h - 34), 6))
    for i, photo in enumerate(photos):
        stamp = (2010, 190 + i * 470, 560, 400)
        d = ImageDraw.Draw(cv)
        d.rectangle((S(stamp[0] - 26), S(stamp[1] - 26), S(stamp[0] + stamp[2] + 26), S(stamp[1] + stamp[3] + 26)), fill=(255, 253, 247, 255))
        sm = Image.new("L", cv.size, 0)
        ImageDraw.Draw(sm).rectangle((S(stamp[0]), S(stamp[1]), S(stamp[0] + stamp[2]), S(stamp[1] + stamp[3])), fill=255)
        paste_photo(cv, photo, stamp, sm, (0.5, 0.35))
        d = ImageDraw.Draw(cv)
        perforate(d, (stamp[0] - 26, stamp[1] - 26, stamp[2] + 52, stamp[3] + 52), 12, 44, paper)
    cx, cy = 1900, 1560
    d.ellipse((S(cx - 130), S(cy - 130), S(cx + 130), S(cy + 130)), outline=pm, width=S(5))
    d.ellipse((S(cx - 102), S(cy - 102), S(cx + 102), S(cy + 102)), outline=pm, width=S(3))
    text_mid(d, "28.11.26", cx, cy, PLAYFAIR, 38, pm)
    for k in range(4):
        yy = cy - 54 + k * 36
        d.line([(S(cx - 140 - t), S(yy + 12 * math.sin(t / 22))) for t in range(0, 360, 6)], fill=pm, width=S(4))
    text_mid(d, "Chuyện của chúng mình,", 940, 1620, PINYON, 100, (140, 112, 84, 255))
    text_mid(d, g.NAMES, 940, 1800, PINYON, 150, ink)
    return cv, hole, 0


def c_postcard_stamp(groom, bride, photo="couple/banner_left.webp"):
    """Bưu thiếp có tem cặp đôi: ảnh nhóm bên trái, tem dọc bên phải."""
    ink, paper, pm = (96, 72, 52, 255), (248, 242, 229, 255), (140, 70, 60, 255)
    cv = new_canvas((212, 188, 148))
    d = ImageDraw.Draw(cv)
    d.rectangle((S(70), S(70), S(W - 70), S(H - 70)), fill=paper)
    hole = (190, 270, 1560, 1170)
    x, y, w, h = hole
    punch(cv, rrect_mask(hole, 6))
    d = ImageDraw.Draw(cv)
    perforate(d, hole, 17, 58, paper)
    punch(cv, rrect_mask((x + 17, y + 17, w - 34, h - 34), 6))
    # Stamp with the couple.
    stamp = (1950, 200, 700, 900)
    d = ImageDraw.Draw(cv)
    d.rectangle((S(stamp[0] - 34), S(stamp[1] - 34), S(stamp[0] + stamp[2] + 34), S(stamp[1] + stamp[3] + 34)), fill=(255, 253, 247, 255))
    sm = Image.new("L", cv.size, 0)
    ImageDraw.Draw(sm).rectangle((S(stamp[0]), S(stamp[1]), S(stamp[0] + stamp[2]), S(stamp[1] + stamp[3])), fill=255)
    paste_photo(cv, photo, stamp, sm)
    d = ImageDraw.Draw(cv)
    perforate(d, (stamp[0] - 34, stamp[1] - 34, stamp[2] + 68, stamp[3] + 68), 15, 52, paper)
    # Postmark overlapping the stamp corner + cancellation lines.
    cx, cy = 2130, 1130
    d.ellipse((S(cx - 150), S(cy - 150), S(cx + 150), S(cy + 150)), outline=pm, width=S(5))
    d.ellipse((S(cx - 118), S(cy - 118), S(cx + 118), S(cy + 118)), outline=pm, width=S(3))
    text_mid(d, "28.11.26", cx, cy, PLAYFAIR, 44, pm)
    for k in range(4):
        yy = cy - 60 + k * 40
        pts = [(S(cx - 160 - t), S(yy + 14 * math.sin(t / 22))) for t in range(0, 520, 6)]
        d.line(pts, fill=pm, width=S(4))
    text_mid(d, "Gửi bạn,", 2300, 1420, PINYON, 100, ink)
    text_mid(d, g.GROOM_NAME, 2300, 1580, PINYON, 130, ink)
    text_mid(d, f"& {g.BRIDE_NAME}", 2300, 1740, PINYON, 130, ink)
    return cv, hole, 0


# ------------------------------------------------------ bản tin trực tiếp HỶ TV
PHUDU_B = FONTS / "Phudu" / "Phudu-Bold.ttf"
BE_VN = FONTS / "Be_Vietnam_Pro" / "BeVietnamPro-Regular.ttf"
SONGTI = Path("/System/Library/Fonts/Supplemental/Songti.ttc")  # chữ 囍 (font hệ thống macOS)
# Ảnh khách 4:3 phủ kín chiều cao khung; hai dải đen mỏng hai bên như TV phát hình 4:3.
TV_SLOT = [66.67, 0, 2666.67, 2000]
TV_LEFT, TV_RIGHT = TV_SLOT[0] + 20, TV_SLOT[0] + TV_SLOT[2] - 20  # vùng trong suốt
TV_WINE, TV_MOSS, TV_DEEP = (150, 30, 42, 255), (54, 69, 47, 238), (28, 37, 26, 245)
TV_GOLD, TV_PAPER, TV_INK, TV_WHITE = (214, 190, 140, 255), (250, 247, 240, 246), (30, 32, 28, 255), (255, 255, 255, 255)
TV_HEADLINE = "THỌ – HIỀN CHÍNH THỨC VỀ CHUNG MỘT NHÀ"
TV_SUBLINE = "Trực tiếp từ Thiết Trụ, Mễ Sở · Khách mời có mặt đông đủ"
TV_TICKER = ("Chú rể xác nhận: từ nay trong nhà có sếp", "Dự báo: độ ẩm hạnh phúc 100%",
             "Ban tổ chức khuyến cáo: không về sớm")
TV_PIP = ("couple/bank_cover.webp", (0.06, 0.17, 0.94, 0.64))  # kính râm, sâm panh, chiếc nơ
TICKER_Y, TICKER_H = 1872, 128
# Bản in khung nhóm chỉ rộng 10 cm (27.6 px/mm): chữ nhỏ nhất ~54 px (≈2 mm).


def _over(cv, paint):
    """Paint on a transparent layer, then blend it over the frame (keeps see-through parts)."""
    layer = Image.new("RGBA", cv.size, (0, 0, 0, 0))
    paint(ImageDraw.Draw(layer))
    cv.alpha_composite(layer)


def _bar(cv, box, fill):
    x, y, w, h = box
    _over(cv, lambda d: d.rectangle((S(x), S(y), S(x + w), S(y + h)), fill=fill))


def _label(cv, x, cy, text, path, size, fill, align="left", shadow=0):
    """Text with its capitals centred on cy; optional soft shadow for text over the photo.
    Returns the text width."""
    fnt = g.font(path, size)
    probe = ImageDraw.Draw(cv)
    cap = -probe.textbbox((0, 0), "H", font=fnt, anchor="ls")[1] / SS
    width = probe.textlength(text, font=fnt) / SS
    left = {"left": x, "center": x - width / 2, "right": x - width}[align]
    layer = Image.new("RGBA", cv.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).text((S(left), S(cy + cap / 2)), text, font=fnt, fill=fill, anchor="ls")
    if shadow:
        sh = Image.new("RGBA", cv.size, (0, 0, 0, 0))
        sh.putalpha(layer.getchannel("A").point(lambda a: a * shadow // 255).filter(ImageFilter.GaussianBlur(S(5))))
        cv.alpha_composite(sh, (S(2), S(4)))
    cv.alpha_composite(layer)
    return width


def _text_width(text, path, size):
    return ImageDraw.Draw(Image.new("L", (1, 1))).textlength(text, font=g.font(path, size)) / SS


def _hy_glyph(cv, cx, cy, r, ring=5):
    """囍 in a wine circle with a gold ring (skipped glyph if the macOS font is missing)."""
    m = Image.new("L", cv.size, 0)
    ImageDraw.Draw(m).ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), fill=255)
    shadow(cv, m, 8, (0, 5), 120)
    try:
        hy = ImageFont.truetype(str(SONGTI), S(r * 1.3), index=1)  # Songti SC Bold có chữ 囍
    except OSError:
        hy = None

    def paint(d):
        d.ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), fill=TV_WINE, outline=TV_GOLD, width=S(ring))
        if hy:
            d.text((S(cx), S(cy + r * 0.06)), "囍", font=hy, fill=TV_GOLD, anchor="mm")
    _over(cv, paint)


def _live_badge(cv, x, cy, h=108):
    text_w = _text_width("TRỰC TIẾP", PHUDU_B, 60)
    badge_w = 78 + text_w + 40
    _bar(cv, (x, cy - h / 2, badge_w, h), TV_WINE)
    _over(cv, lambda d: d.ellipse((S(x + 30), S(cy - 15), S(x + 60), S(cy + 15)), fill=TV_WHITE))
    _label(cv, x + 78, cy, "TRỰC TIẾP", PHUDU_B, 60, TV_WHITE)
    date_w = _text_width("28.11.2026", PHUDU_B, 54)
    _bar(cv, (x + badge_w, cy - h / 2, date_w + 72, h), (14, 16, 14, 200))
    _label(cv, x + badge_w + 36, cy, "28.11.2026", PHUDU_B, 54, TV_WHITE)


def _pip(cv, box, photo, crop, label="NHÂN VẬT CHÍNH", label_h=74):
    """Picture-in-picture of the couple, gold frame, wine caption strip."""
    x, y, w, h = box
    m = Image.new("L", cv.size, 0)
    ImageDraw.Draw(m).rectangle((S(x - 6), S(y - 6), S(x + w + 6), S(y + h + label_h + 6)), fill=255)
    shadow(cv, m, 16, (0, 10), 140)
    _bar(cv, (x - 6, y - 6, w + 12, h + label_h + 12), TV_GOLD)
    src = Image.open(IMAGES / photo).convert("RGB")
    l, t, r, b = crop
    src = src.crop((round(l * src.width), round(t * src.height), round(r * src.width), round(b * src.height)))
    cv.paste(g.cover(src, S(w), S(h)).convert("RGBA"), (S(x), S(y)))
    _bar(cv, (x, y + h, w, label_h), TV_WINE)
    _label(cv, x + w / 2, y + h + label_h / 2, label, PHUDU_B, 50, TV_WHITE, align="center")


def _lower_third(cv, left, right=2440):
    """TIN NÓNG tag, headline bar and subline, ending on top of the ticker."""
    sub_h, head_h, tag_h = 78, 126, 78
    sub_y = TICKER_Y - sub_h
    head_y = sub_y - head_h
    tag_w = _text_width("TIN NÓNG", PHUDU_B, 56) + 64
    _bar(cv, (left, head_y - tag_h, tag_w, tag_h), TV_WINE)
    _label(cv, left + 32, head_y - tag_h / 2, "TIN NÓNG", PHUDU_B, 56, TV_WHITE)
    _bar(cv, (left, head_y, right - left, head_h), TV_PAPER)
    _bar(cv, (left, head_y, right - left, 6), TV_GOLD)
    size = min(86, math.floor(86 * (right - left - 80) / _text_width(TV_HEADLINE, PHUDU_B, 86)))
    _label(cv, left + 40, head_y + 3 + head_h / 2, TV_HEADLINE, PHUDU_B, size, TV_INK)
    sub_size = min(54, math.floor(54 * (right - left - 80) / _text_width(TV_SUBLINE, BE_VN, 54)))
    sub_w = _text_width(TV_SUBLINE, BE_VN, sub_size) + 80
    _bar(cv, (left, sub_y, sub_w, sub_h), TV_MOSS)
    _label(cv, left + 40, sub_y + sub_h / 2, TV_SUBLINE, BE_VN, sub_size, TV_WHITE)


def _ticker(cv, label):
    _bar(cv, (0, TICKER_Y, W, TICKER_H), TV_DEEP)
    label_w = _text_width(label, PHUDU_B, 58) + 80
    _bar(cv, (TV_LEFT, TICKER_Y, label_w, TICKER_H), TV_GOLD)
    _label(cv, TV_LEFT + 40, TICKER_Y + TICKER_H / 2, label, PHUDU_B, 58, TV_INK)
    text = "   •   ".join(TV_TICKER + TV_TICKER[:1])  # chữ chạy tràn qua mép phải như đang chạy
    # 56 px: câu thứ hai ("... 100%") kết thúc trước chỗ app in mã QR ở góc phải dưới.
    _label(cv, TV_LEFT + label_w + 44, TICKER_Y + TICKER_H / 2, text, BE_VN, 56, TV_WHITE)


def c_hy_tv(groom, bride, pip_top=False, pip=TV_PIP, pip_label="NHÂN VẬT CHÍNH"):
    """Bản tin trực tiếp HỶ TV: ảnh khách phủ kín khung như một cảnh đang lên sóng."""
    cv = Image.new("RGBA", (S(W), S(H)), (0, 0, 0, 0))
    d = ImageDraw.Draw(cv)
    d.rectangle((0, 0, S(TV_LEFT), S(H)), fill=(10, 12, 10, 255))
    d.rectangle((S(TV_RIGHT), 0, S(W), S(H)), fill=(10, 12, 10, 255))
    _live_badge(cv, TV_LEFT + 64, 150)
    if pip_top:
        # Biến thể: ô nhân vật chính lớn ở góc phải trên, logo kênh ở nhãn chữ chạy.
        _pip(cv, (TV_RIGHT - 64 - 600, 96, 600, 450), *pip, label=pip_label)
        _lower_third(cv, TV_LEFT + 64)
        _ticker(cv, "HỶ TV")
    else:
        _hy_glyph(cv, TV_RIGHT - 64 - 66, 150, 66)
        _label(cv, TV_RIGHT - 64 - 132 - 24, 150, "HỶ TV", PHUDU_B, 84, (255, 255, 255, 240), "right", shadow=170)
        pip_w, pip_h = 480, 390
        _pip(cv, (TV_LEFT + 50, TICKER_Y - 74 - pip_h - 6, pip_w, pip_h), *pip, label=pip_label)
        _lower_third(cv, TV_LEFT + 50 + pip_w + 46)
        _ticker(cv, "TIN VUI")
    return cv, (TV_LEFT, 0, TV_RIGHT - TV_LEFT, H), 0


CONCEPTS = [
    ("05_buu_thiep", "Bưu thiếp", "Viền tem răng cưa, dấu bưu điện ngày cưới, lời 'Gửi bạn'.", c_postcard,
     {"file": "group_4.png", "category": (104, "Bưu Thiếp"), "slot": [570, 277.5, 1560, 1170]}),
    ("10_cat_cheo", "Poster cắt chéo", "Ảnh cặp đôi cắt chéo bên trái, thẻ ảnh nhóm nghiêng đè lên đường chéo.", c_diagonal,
     {"file": "group_5.png", "category": (105, "Poster Chéo"), "slot": [1178, 386, 1504, 1128]}),
    ("12_buu_thiep_tem", "Bưu thiếp + tem cặp đôi", "Biến thể của bưu thiếp đã duyệt: ảnh nhóm lớn bên trái, tem có ảnh cặp đôi bên phải.", c_postcard_stamp,
     {"file": "group_6.png", "category": (104, "Bưu Thiếp"), "slot": [160, 247.5, 1620, 1215]}),
    # --- Phiên bản dùng ảnh khác trong wedding-invitation (chờ duyệt).
    ("V01_cheo_ban_cuoi", "Poster chéo · ảnh khăn voan", "Poster chéo với ảnh cặp đôi dưới voan trong vườn.",
     partial(c_diagonal, photo="gallery/album_12.webp"), {"file": "group_7.png", "category": (105, "Poster Chéo"), "slot": [1178, 386, 1504, 1128]}),
    ("V02_cheo_no", "Poster chéo · ảnh nơ lớn", "Poster chéo với ảnh cụng ly bên chiếc nơ lớn.",
     partial(c_diagonal, photo="couple/bank_cover.webp"), {"file": "group_8.png", "category": (105, "Poster Chéo"), "slot": [1178, 386, 1504, 1128]}),
    ("V03_tem_can_canh", "Bưu thiếp tem · ảnh cận cảnh", "Tem cặp đôi dùng ảnh cận cảnh hai người cười.",
     partial(c_postcard_stamp, photo="gallery/album_9.webp"), {"file": "group_9.png", "category": (104, "Bưu Thiếp"), "slot": [160, 247.5, 1620, 1215]}),
    ("V04_tem_doc_thu", "Bưu thiếp tem · ảnh đọc thư", "Tem cặp đôi dùng ảnh hai người đọc thiệp bên chiếc nơ.",
     partial(c_postcard_stamp, photo="gallery/album_14.webp"), {"file": "group_10.png", "category": (104, "Bưu Thiếp"), "slot": [160, 247.5, 1620, 1215]}),
    # --- Phiên bản dùng thêm ảnh còn lại trong wedding-invitation (chờ duyệt).
    ("V17_cheo_hai_chan_dung", "Poster chéo · hai chân dung", "Dải chéo chia đôi: chú rể bên trái, cô dâu bên phải.",
     c_diag_split, {"file": "group_11.png", "category": (105, "Poster Chéo"), "slot": [1178, 386, 1504, 1128]}),
    ("V18_cheo_doi_dung", "Poster chéo · ảnh đứng đối diện", "Poster chéo với ảnh chú rể và cô dâu đứng đối diện nhau.",
     partial(c_diagonal, photo="gallery/album_11.webp", focus=(0.5, 0.3)), {"file": "group_12.png", "category": (105, "Poster Chéo"), "slot": [1178, 386, 1504, 1128]}),
    ("V19_cheo_co_dau", "Poster chéo · ảnh cô dâu", "Poster chéo với ảnh cô dâu cầm hoa trong vườn.",
     partial(c_diagonal, photo="gallery/album_7.webp", focus=(0.5, 0.2)), {"file": "group_13.png", "category": (105, "Poster Chéo"), "slot": [1178, 386, 1504, 1128]}),
    ("V20_tem_chuyen_tinh", "Bưu thiếp · 3 tem chuyện tình", "Ba tem dọc: ảnh tự sướng, nhẫn cầu hôn và ngày đám ngỏ.",
     c_stamp_column, {"file": "group_14.png", "category": (104, "Bưu Thiếp"), "slot": [160, 247.5, 1620, 1215]}),
    ("V21_tem_ben_phun_nuoc", "Bưu thiếp tem · ảnh bên đài phun nước", "Tem cặp đôi dùng ảnh cô dâu bên đài phun nước.",
     partial(c_postcard_stamp, photo="gallery/album_2.webp"), {"file": "group_15.png", "category": (104, "Bưu Thiếp"), "slot": [160, 247.5, 1620, 1215]}),
    # --- Bản tin trực tiếp HỶ TV (chờ duyệt): ảnh khách phủ kín khung, publish kèm "slot": TV_SLOT.
    ("T1_hy_tv", "Bản tin trực tiếp HỶ TV", "Ảnh khách phủ kín khung như cảnh đang lên sóng: nhãn TRỰC TIẾP, logo HỶ TV, thanh TIN NÓNG, chữ chạy, ô 'Nhân vật chính' ở góc dưới.",
     c_hy_tv, {"file": "group_16.png", "category": (108, "Bản Tin"), "slot": TV_SLOT}),
    ("T2_hy_tv_pip_tren", "HỶ TV · nhân vật chính góc trên", "Biến thể: ô 'Nhân vật chính' to ở góc phải trên kiểu màn hình chia đôi, logo kênh ở nhãn chữ chạy.",
     partial(c_hy_tv, pip_top=True), {"file": "group_17.png", "category": (108, "Bản Tin"), "slot": TV_SLOT}),
    # --- Biến thể HỶ TV dùng ảnh khác trong wedding-invitation (chờ duyệt).
    ("Y1_tv_doc_loi_the", "HỶ TV · ảnh đọc lời thề", "Ô 'Nhân vật chính' dùng ảnh hai người đọc lời thề bên chiếc nơ.",
     partial(c_hy_tv, pip=("gallery/album_14.webp", (0.06, 0.17, 0.94, 0.64))), {"file": "group_18.png", "category": (108, "Bản Tin"), "slot": TV_SLOT}),
    ("Y2_tv_nu_hon", "HỶ TV góc trên · ảnh nụ hôn dưới voan", "Ô lớn góc trên dùng ảnh chú rể hôn má cô dâu dưới tấm voan.",
     partial(c_hy_tv, pip_top=True, pip=("gallery/album_15.webp", (0.05, 0.15, 0.95, 0.62))), {"file": "group_19.png", "category": (108, "Bản Tin"), "slot": TV_SLOT}),
]


def preview(frame, hole, angle, photo):
    """Sample photo under the frame (rotated with the polaroid card)."""
    x, y, w, h = hole
    ph = g.cover(photo.convert("RGB"), w + 40, h + 30).convert("RGBA")
    layer = Image.new("RGBA", (W, H), (30, 30, 30, 255))
    layer.alpha_composite(ph, (round(x - 20), round(y - 15)))
    if angle:
        ang, center = angle if isinstance(angle, tuple) else (angle, (W // 2, H // 2))
        layer = layer.rotate(ang, center=center, resample=Image.BICUBIC, fillcolor=(30, 30, 30, 255))
    layer.alpha_composite(frame)
    return layer.convert("RGB")


def publish(frame, meta):
    """Install an approved concept as a real personal frame and register it in data.json."""
    import json
    from datetime import datetime

    layout = meta.get("layout", "group")
    folder = "standard" if layout == "standard" else "group"
    dest = g.ROOT / "assets" / "frames" / "personal" / folder / meta["file"]
    frame.save(dest)
    data_path = g.ROOT / "assets" / "frames" / "personal" / "data.json"
    data = json.loads(data_path.read_text(encoding="utf-8"))
    now = datetime.now().isoformat()
    cat_id, cat_name = meta["category"]
    category = {"id": cat_id, "name": cat_name, "created_at": now, "updated_at": now}
    if not any(c["id"] == cat_id for c in data["categories"]):
        data["categories"].append(category)
    filename = f"{folder}/{meta['file']}"
    entry = next((i for i in data["images"] if i["filename"] == filename), None)
    if entry is None:
        entry = {
            "id": max([i["id"] for i in data["images"]] + [0]) + 1,
            "filename": filename,
            "name": meta["file"].replace(".png", ""),
            "frame": "square" if layout == "standard" else "group",
            "layout_type": layout,
            "created_at": now,
            "visible_locales": ["vn"],
        }
        data["images"].append(entry)
    entry.update({"updated_at": now, "category_id": str(cat_id), "category": category})
    if "slot" in meta:
        entry["slot"] = meta["slot"]
    if "slots" in meta:
        entry["slots"] = meta["slots"]
    data_path.write_text(json.dumps(data, indent=4, ensure_ascii=False) + "\n", encoding="utf-8")
    print("published", filename)


def main():
    publish_flag = "--publish" in sys.argv
    if publish_flag:
        sys.argv.remove("--publish")
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else g.ROOT / "build" / "frame_concepts"
    out.mkdir(parents=True, exist_ok=True)
    # Drop outputs of concepts that are gone or already approved (published).
    import generate_standard_concepts as st

    keep = {c[0] for c in CONCEPTS + st.STANDARD_CONCEPTS if not c[4]}
    for old in list(out.glob("*_frame.png")) + list(out.glob("*_preview.jpg")):
        if old.name.rsplit("_", 1)[0] not in keep:
            old.unlink()
            print("removed", old.name)
    groom = Image.open(g.SOURCES / "groom_cutout.png").convert("RGBA")
    bride = Image.open(g.SOURCES / "bride_cutout.png").convert("RGBA")
    photo = Image.open(SAMPLE_PHOTO)
    cards = []
    for name, title, desc, fn, approved in CONCEPTS:
        if approved:
            # Approved concepts are real frames: --publish regenerates them into
            # assets/frames, and they never show up in the ideas tab.
            if publish_flag:
                cv, *_ = fn(groom, bride)
                publish(cv.resize((W, H), Image.LANCZOS), approved)
            continue
        cv, hole, angle = fn(groom, bride)
        frame = cv.resize((W, H), Image.LANCZOS)
        frame.save(out / f"{name}_frame.png")
        prev = preview(frame, hole, angle, photo)
        prev.resize((1400, 1000), Image.LANCZOS).save(out / f"{name}_preview.jpg", quality=88)
        cards.append((name, title, desc, "group"))
        print("wrote", name)
    for name, title, desc, fn, approved in st.STANDARD_CONCEPTS:
        res = fn()
        # A concept may move the photos: it then returns (canvas, slots).
        cv, slots = res if isinstance(res, tuple) else (res, st.SLOTS)
        frame = cv.resize((st.W, st.H), Image.LANCZOS)
        if approved:
            if publish_flag:
                moved = {} if slots == st.SLOTS else {"slots": [list(s) for s in slots]}
                publish(frame, {**approved, "layout": "standard", **moved})
            continue
        frame.save(out / f"{name}_frame.png")
        st.preview(frame, slots).resize((600, round(600 * st.H / st.W)), Image.LANCZOS).save(out / f"{name}_preview.jpg", quality=88)
        cards.append((name, title, desc, "standard"))
        print("wrote", name)
    html = "".join(
        f'<figure><a href="{n}_frame.png"><img src="{n}_preview.jpg" loading="lazy"></a>'
        f"<figcaption><b>{t}</b><br>{d}</figcaption></figure>"
        for n, t, d, _ in cards
    )
    (out / "index.html").write_text(
        """<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Ý tưởng khung nhóm</title>
<style>:root{color-scheme:light dark}body{margin:0;font:15px/1.45 system-ui,sans-serif;background:#161616;color:#eee}
h1{font-size:17px;margin:0;padding:14px 16px;position:sticky;top:0;background:#161616;border-bottom:1px solid #333}
main{padding:12px;display:grid;gap:18px;max-width:900px;margin:auto}
figure{margin:0;background:#222;border-radius:12px;overflow:hidden}
img{width:100%;display:block}figcaption{padding:10px 14px}</style></head><body>
<h1>Ý tưởng khung nhóm (ảnh mẫu trong ô, chạm vào để xem khung gốc)</h1><main>"""
        + html + "</main></body></html>",
        encoding="utf-8",
    )
    import json
    (out / "manifest.json").write_text(
        json.dumps([{"name": n, "title": t, "desc": d, "layout": lay} for n, t, d, lay in cards], ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print("index:", out / "index.html")


if __name__ == "__main__":
    main()
