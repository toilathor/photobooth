#!/usr/bin/env python3
"""Concept frames for the personal "standard" layout (880x2650, 2 photo slots).

Used by generate_group_concepts.py (same ideas tab, same --publish workflow).
Photo slots are fixed by FrameData.standard: (40,40,800,600) and (40,660,800,600)
in the app, so every transparent hole stays inside those rectangles.
"""
import math
import sys
from functools import partial
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_group_concepts as gc  # noqa: E402
import generate_personal_frames as g  # noqa: E402

SS = g.SS
W, H = 880, 2650
SLOTS = [(40, 40, 800, 600), (40, 660, 800, 600)]
HOLES = [(60, 60, 760, 560), (60, 680, 760, 560)]
SAMPLE_PHOTOS = ["album_1.webp", "album_5.webp"]  # stand-ins for the guests' photos
PLAYFAIR, PINYON = gc.PLAYFAIR, gc.PINYON
DECOR = gc.DECOR


def S(v):
    return round(v * SS)


def canvas(color):
    return Image.new("RGBA", (S(W), S(H)), tuple(color) + (255,))


def rr(box, radius):
    mask = Image.new("L", (S(W), S(H)), 0)
    x, y, w, h = box
    ImageDraw.Draw(mask).rounded_rectangle((S(x), S(y), S(x + w), S(y + h)), S(radius), fill=255)
    return mask


def punch(cv, mask):
    cv.putalpha(Image.composite(Image.new("L", cv.size, 0), cv.getchannel("A"), mask))


def holes_mask(radius=36):
    mask = Image.new("L", (S(W), S(H)), 0)
    d = ImageDraw.Draw(mask)
    for x, y, w, h in HOLES:
        d.rounded_rectangle((S(x), S(y), S(x + w), S(y + h)), S(radius), fill=255)
    return mask


def text_mid(d, text, cx, cy, path, size, fill):
    d.text((S(cx), S(cy)), text, font=g.font(path, size), fill=fill, anchor="mm")


def spaced_mid(d, text, cx, cy, path, size, fill, spacing):
    fnt = g.font(path, size)
    box = d.textbbox((0, 0), "Ag", font=fnt)
    g.draw_spaced(d, text, cx, cy - (box[3] - box[1]) / SS / 2 - box[1] / SS, fnt, fill, spacing)


def paste_cover(cv, name, box, mask, focus=(0.5, 0.5)):
    x, y, w, h = box
    base = g.INVITATION / "images" / name
    photo = gc.cover_focus(Image.open(base).convert("RGB"), S(w), S(h), *focus).convert("RGBA")
    layer = Image.new("RGBA", cv.size, (0, 0, 0, 0))
    layer.paste(photo, (S(x), S(y)))
    layer.putalpha(Image.composite(layer.getchannel("A"), Image.new("L", cv.size, 0), mask))
    cv.alpha_composite(layer)


def perforate(d, box, r, step, fill):
    x, y, w, h = box
    for i in range(int(w // step) + 1):
        cx = x + i * step + (w % step) / 2
        for cy in (y, y + h):
            d.ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), fill=fill)
    for j in range(int(h // step) + 1):
        cy = y + j * step + (h % step) / 2
        for cx in (x, x + w):
            d.ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), fill=fill)


# ------------------------------------------------------------------ concepts
INK, PAPER, PM = (96, 72, 52, 255), (248, 242, 229, 255), (140, 70, 60, 255)


def _postcard_base():
    """Kraft background, cream card, the two photo holes with stamp perforations."""
    cv = canvas((212, 188, 148))
    d = ImageDraw.Draw(cv)
    d.rectangle((S(34), S(34), S(W - 34), S(H - 34)), fill=PAPER)
    punch(cv, holes_mask(4))
    d = ImageDraw.Draw(cv)
    for hx, hy, hw, hh in HOLES:
        perforate(d, (hx, hy, hw, hh), 12, 44, PAPER)
    inner = Image.new("L", cv.size, 0)
    di = ImageDraw.Draw(inner)
    for hx, hy, hw, hh in HOLES:
        di.rounded_rectangle((S(hx + 12), S(hy + 12), S(hx + hw - 12), S(hy + hh - 12)), S(4), fill=255)
    punch(cv, inner)
    return cv


def _stamp(cv, photo, box, focus=(0.5, 0.5), border=28, step=42):
    """A perforated stamp holding a photo."""
    x, y, w, h = box
    d = ImageDraw.Draw(cv)
    d.rectangle((S(x - border), S(y - border), S(x + w + border), S(y + h + border)), fill=(255, 253, 247, 255))
    sm = Image.new("L", cv.size, 0)
    ImageDraw.Draw(sm).rectangle((S(x), S(y), S(x + w), S(y + h)), fill=255)
    paste_cover(cv, photo, box, sm, focus)
    d = ImageDraw.Draw(cv)
    perforate(d, (x - border, y - border, w + 2 * border, h + 2 * border), 12, step, PAPER)


def _postmark(cv, cx, cy, r=105, wave=420):
    d = ImageDraw.Draw(cv)
    d.ellipse((S(cx - r), S(cy - r), S(cx + r), S(cy + r)), outline=PM, width=S(4))
    d.ellipse((S(cx - r + 23), S(cy - r + 23), S(cx + r - 23), S(cy + r - 23)), outline=PM, width=S(2))
    text_mid(d, "28.11.26", cx, cy, PLAYFAIR, 32, PM)
    for k in range(4):
        yy = cy - 42 + k * 28
        d.line([(S(cx - 110 - t), S(yy + 10 * math.sin(t / 18))) for t in range(0, wave, 6)], fill=PM, width=S(3))


def s_postcard(photo="couple/banner_left.webp"):
    """Bưu thiếp dọc: hai ảnh viền tem, tem cặp đôi lớn ở dưới, dấu bưu điện."""
    cv = _postcard_base()
    _stamp(cv, photo, (150, 1340, 580, 800))
    _postmark(cv, 690, 1340)
    d = ImageDraw.Draw(cv)
    text_mid(d, "Gửi bạn,", 440, 2290, PINYON, 90, INK)
    text_mid(d, g.NAMES, 440, 2420, PINYON, 78, INK)
    spaced_mid(d, "28 . 11 . 2026", 440, 2530, PLAYFAIR, 30, (140, 112, 84, 255), 12)
    return cv


def s_postcard_stamps(stamps, caption, text_y=2290):
    """Bưu thiếp dọc với nhiều tem nhỏ ở dưới. stamps: [(ảnh, (x, y, w, h), focus)]."""
    cv = _postcard_base()
    for photo, box, focus in stamps:
        _stamp(cv, photo, box, focus, border=22, step=36)
    _postmark(cv, 700, 1300 + 0, r=95, wave=300)
    d = ImageDraw.Draw(cv)
    text_mid(d, caption, 440, text_y, PINYON, 82, INK)
    text_mid(d, g.NAMES, 440, text_y + 130, PINYON, 78, INK)
    spaced_mid(d, "28 . 11 . 2026", 440, text_y + 240, PLAYFAIR, 30, (140, 112, 84, 255), 12)
    return cv


def s_diagonal(photo="couple/banner_left.webp", focus=(0.5, 0.5), dim_max=215):
    """Poster cắt chéo dọc: ảnh cặp đôi dưới cùng cắt chéo, đường chéo vàng."""
    gold = (214, 190, 140, 255)
    cv = canvas((44, 60, 43))
    poly = Image.new("L", cv.size, 0)
    ImageDraw.Draw(poly).polygon([(0, S(1560)), (S(W), S(1300)), (S(W), S(H)), (0, S(H))], fill=255)
    paste_cover(cv, photo, (0, 1250, W, H - 1250), poly, focus)
    d = ImageDraw.Draw(cv)
    d.line((0, S(1560), S(W), S(1300)), fill=gold, width=S(4))
    d.line((0, S(1600), S(W), S(1340)), fill=gold, width=S(2))
    # Dim the bottom for the text.
    dim = Image.new("RGBA", cv.size, (0, 0, 0, 0))
    dd = ImageDraw.Draw(dim)
    for y in range(760):
        dd.line((0, S(H - 760 + y), S(W), S(H - 760 + y)), fill=(0, 0, 0, int(dim_max * (y / 760) ** 0.8)))
    cv.alpha_composite(dim)
    d = ImageDraw.Draw(cv)
    text_mid(d, g.GROOM_NAME, 440, 2405, PINYON, 105, (244, 238, 224, 255))
    text_mid(d, f"& {g.BRIDE_NAME}", 440, 2500, PINYON, 105, (244, 238, 224, 255))
    spaced_mid(d, "28 . 11 . 2026", 440, 2605, PLAYFAIR, 28, gold, 14)
    punch(cv, holes_mask())
    return cv


def s_film(photo="couple/banner_left.webp", focus=(0.5, 0.5)):
    """Dải phim: hai ảnh là hai khung phim, khung thứ ba là ảnh cặp đôi."""
    return s_film_frames([(photo, (60, 1310, 760, 1000), focus)])


def s_film_frames(frames):
    """Dải phim với các khung phim bổ sung dưới hai ảnh. frames: [(ảnh, (x, y, w, h), focus)]."""
    cream, orange = (244, 238, 224, 255), (226, 160, 84, 255)
    cv = canvas((20, 20, 20))
    d = ImageDraw.Draw(cv)
    for i in range(36):
        y = 24 + i * 74
        for x in (18, W - 42):
            d.rounded_rectangle((S(x), S(y), S(x + 24), S(y + 38)), S(6), fill=(238, 234, 224, 255))
    for hx, hy, hw, hh in HOLES:
        d.rounded_rectangle((S(hx - 10), S(hy - 10), S(hx + hw + 10), S(hy + hh + 10)), S(44), outline=(70, 70, 70, 255), width=S(3))
    for photo, box, focus in frames:
        d.rounded_rectangle((S(box[0] - 10), S(box[1] - 10), S(box[0] + box[2] + 10), S(box[1] + box[3] + 10)), S(44), outline=(70, 70, 70, 255), width=S(3))
        paste_cover(cv, photo, box, rr(box, 36), focus)
    d = ImageDraw.Draw(cv)
    for i, (hx, hy, hw, hh) in enumerate(HOLES + [f[1] for f in frames]):
        text_mid(d, f"{i + 1}A", hx + 40, hy + hh + 34, PLAYFAIR, 22, orange)
        tx, ty = hx + hw - 30, hy + hh + 34
        d.polygon([(S(tx - 8), S(ty - 10)), (S(tx - 8), S(ty + 10)), (S(tx + 10), S(ty))], fill=orange)
    text_mid(d, g.NAMES, 440, 2440, PINYON, 78, cream)
    spaced_mid(d, "28 . 11 . 2026", 440, 2545, PLAYFAIR, 30, orange, 14)
    punch(cv, holes_mask())
    return cv


STANDARD_CONCEPTS = [
    ("S1_buu_thiep", "Bưu thiếp dọc", "Hai ảnh viền tem răng cưa, tem cặp đôi lớn ở dưới, dấu bưu điện, lời 'Gửi bạn'.", s_postcard,
     {"file": "standard_3.png", "category": (104, "Bưu Thiếp")}),
    ("S2_cat_cheo", "Poster cắt chéo dọc", "Ảnh cặp đôi ở dưới cắt chéo với đường vàng, tên và ngày trên nền tối.", s_diagonal,
     {"file": "standard_4.png", "category": (105, "Poster Chéo")}),
    ("S3_dai_phim", "Dải phim", "Hai ảnh là hai khung phim, khung thứ ba là ảnh cặp đôi, có số khung và mũi tên.", s_film,
     {"file": "standard_5.png", "category": (106, "Dải Phim")}),
    # --- Phiên bản dùng ảnh khác trong wedding-invitation (chờ duyệt).
    ("V05_buu_thiep_hon", "Bưu thiếp dọc · ảnh nụ hôn", "Tem lớn dùng ảnh nụ hôn dưới voan.",
     partial(s_postcard, photo="gallery/album_15.webp"), {"file": "standard_6.png", "category": (104, "Bưu Thiếp")}),
    ("V06_buu_thiep_no", "Bưu thiếp dọc · ảnh đọc thư", "Tem lớn dùng ảnh hai người đọc thiệp bên chiếc nơ.",
     partial(s_postcard, photo="gallery/album_14.webp"), {"file": "standard_7.png", "category": (104, "Bưu Thiếp")}),
    ("V07_cheo_banner", "Poster chéo dọc · ảnh sóng đôi", "Poster chéo dùng ảnh hai người sóng đôi (bản khác).",
     partial(s_diagonal, photo="couple/banner_right.webp"), {"file": "standard_8.png", "category": (105, "Poster Chéo")}),
    ("V08_cheo_bac_thang", "Poster chéo dọc · ảnh bậc thang", "Poster chéo dùng ảnh hai người trên bậc thang đá.",
     partial(s_diagonal, photo="gallery/album_4.webp"), {"file": "standard_9.png", "category": (105, "Poster Chéo")}),
    ("V09_phim_no", "Dải phim · ảnh nơ lớn", "Khung phim thứ ba dùng ảnh cụng ly bên chiếc nơ.",
     partial(s_film, photo="couple/bank_cover.webp"), {"file": "standard_10.png", "category": (106, "Dải Phim")}),
    ("V10_phim_vom", "Dải phim · ảnh cổng vòm", "Khung phim thứ ba dùng ảnh nắm tay trước cổng vòm.",
     partial(s_film, photo="gallery/album_6.webp"), {"file": "standard_11.png", "category": (106, "Dải Phim")}),
    # --- Phiên bản dùng thêm ảnh còn lại trong wedding-invitation (chờ duyệt).
    ("V11_buu_thiep_tinh_yeu", "Bưu thiếp dọc · 3 tem chuyện tình", "Ba tem nhỏ: ảnh chụp tự sướng, nhẫn cầu hôn và ngày đám ngỏ.",
     partial(s_postcard_stamps, [
         ("couple/timeline_1.webp", (110, 1400, 400, 520), (0.4, 0.5)),
         ("couple/timeline_2.webp", (565, 1400, 205, 235), (0.5, 0.5)),
         ("couple/timeline_3.webp", (565, 1685, 205, 235), (0.5, 0.4)),
     ], "Chuyện của chúng mình,", text_y=2200), {"file": "standard_12.png", "category": (104, "Bưu Thiếp")}),
    ("V12_buu_thiep_doi", "Bưu thiếp dọc · tem chú rể & cô dâu", "Hai tem chân dung: chú rể bên trái, cô dâu bên phải.",
     partial(s_postcard_stamps, [
         ("couple/groom.webp", (95, 1380, 330, 560), (0.55, 0.15)),
         ("couple/bride.webp", (455, 1380, 330, 560), (0.62, 0.15)),
     ], "Gửi bạn,", text_y=2200), {"file": "standard_13.png", "category": (104, "Bưu Thiếp")}),
    ("V13_cheo_co_dau", "Poster chéo dọc · cô dâu", "Poster chéo dùng ảnh cô dâu cầm hoa giữa vườn.",
     partial(s_diagonal, photo="gallery/album_7.webp", focus=(0.5, 0.2)), {"file": "standard_14.png", "category": (105, "Poster Chéo")}),
    ("V14_cheo_khan_voan", "Poster chéo dọc · cô dâu che voan", "Poster chéo dùng ảnh cô dâu dưới voan.",
     partial(s_diagonal, photo="gallery/album_13.webp", focus=(0.5, 0.2)), {"file": "standard_15.png", "category": (105, "Poster Chéo")}),
    ("V15_phim_ngang_doi", "Dải phim · hai khung ngang", "Hai khung phim ngang cuối: hai ảnh cặp đôi trong vườn.",
     partial(s_film_frames, [
         ("gallery/album_8.webp", (60, 1310, 760, 480), (0.5, 0.5)),
         ("gallery/album_16.webp", (60, 1830, 760, 480), (0.5, 0.5)),
     ]), {"file": "standard_16.png", "category": (106, "Dải Phim")}),
    ("V16_phim_chan_dung", "Dải phim · ảnh cô dâu bên đài phun nước", "Khung phim cuối dùng ảnh cô dâu bên đài phun nước.",
     partial(s_film, photo="gallery/album_2.webp", focus=(0.5, 0.3)), {"file": "standard_17.png", "category": (106, "Dải Phim")}),
]


def preview(frame):
    """Two sample photos in the two slots (straight, as in the app), frame on top."""
    base = Image.new("RGBA", (W, H), (30, 30, 30, 255))
    for (x, y, w, h), name in zip(SLOTS, SAMPLE_PHOTOS):
        photo = g.cover(Image.open(g.INVITATION / "images" / "gallery" / name).convert("RGB"), w, h)
        base.paste(photo, (x, y))
    base.alpha_composite(frame)
    return base.convert("RGB")
