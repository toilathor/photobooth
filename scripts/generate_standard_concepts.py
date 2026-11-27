#!/usr/bin/env python3
"""Concept frames for the personal "standard" layout (880x2650, 2 photo slots).

Used by generate_group_concepts.py (same ideas tab, same --publish workflow).
The default photo slots of FrameData.standard are (40,40,800,600) and
(40,660,800,600). A concept may return (canvas, slots) to place the photos
elsewhere: the slots (4:3, bleed included) are then written to data.json as
`slots` on publish, and the transparent holes must stay inside them.
"""
import math
import random
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


# ------------------------------------------------------ tờ lịch bloc ngày cưới
# Lịch bloc in bằng Times: font hệ thống của macOS, có đủ dấu tiếng Việt.
SYS_FONTS = Path("/System/Library/Fonts/Supplemental")
TIMES = SYS_FONTS / "Times New Roman.ttf"
TIMES_B = SYS_FONTS / "Times New Roman Bold.ttf"
TIMES_I = SYS_FONTS / "Times New Roman Italic.ttf"
TIMES_BI = SYS_FONTS / "Times New Roman Bold Italic.ttf"
RED, BLACK = (196, 30, 42, 255), (34, 31, 29, 255)
NEWSPRINT, BINDING = (247, 243, 233, 255), (122, 22, 30, 255)
# Âm lịch 28/11/2026, đối chiếu xemlicham.com và ngaydep.com. Các trang không
# thống nhất ngày này tốt hay xấu, nên tờ lịch không ghi gì về chuyện đó.
LUNAR = ["Ngày Bính Ngọ", "Tháng Kỷ Hợi", "Năm Bính Ngọ", "Tiết Tiểu tuyết"]
GIO_HOANG_DAO = "Tý · Sửu · Mão · Ngọ · Thân · Dậu"
# Ảnh khách nằm giữa tờ lịch (render 4:3, lỗ trong suốt lùi vào 20px).
CAL_SLOTS = [(50, 830, 780, 585), (50, 1440, 780, 585)]


def _spaced(d, text, x, y, path, size, fill, spacing=0, align="center"):
    """Letter-spaced text on baseline y, aligned left/center/right on x."""
    fnt = g.font(path, size)
    widths = [d.textlength(c, font=fnt) for c in text]
    total = sum(widths) + S(spacing) * (len(text) - 1)
    left = {"left": S(x), "center": S(x) - total / 2, "right": S(x) - total}[align]
    for c, w in zip(text, widths):
        d.text((left, S(y)), c, font=fnt, fill=fill, anchor="ls")
        left += w + S(spacing)


def _rule(d, y, x0=50, x1=W - 50, double=True):
    d.line((S(x0), S(y), S(x1), S(y)), fill=RED, width=S(4))
    if double:
        d.line((S(x0), S(y + 9), S(x1), S(y + 9)), fill=RED, width=S(1.5))


def _calendar_page(top=56):
    """A page just torn from the pad: red binding above a ragged edge, grainy newsprint."""
    cv = canvas(BINDING[:3])
    rng = random.Random(2811)
    pts, x = [(0, S(top + 12))], 0.0
    while x < W:
        x = min(W, x + rng.uniform(4, 13))
        pts.append((S(x), S(top + 7 + rng.uniform(-6, 9) + 5 * math.sin(x / 41))))
    pts += [(S(W), S(H)), (0, S(H))]
    page = Image.new("L", cv.size, 0)
    ImageDraw.Draw(page).polygon(pts, fill=255)
    gc.shadow(cv, page, 5, (0, 3), 150)
    sheet = Image.new("RGBA", cv.size, NEWSPRINT)
    speck = Image.effect_noise(cv.size, 40).point(lambda v: min(255, max(0, v - 182) * 4))
    ink = Image.new("RGBA", cv.size, (118, 100, 76, 0))
    ink.putalpha(speck.point(lambda a: a * 34 // 255))
    sheet.alpha_composite(ink)
    cv.paste(sheet, (0, 0), page)
    d = ImageDraw.Draw(cv)
    for cx in (W * 0.28, W * 0.72):  # staples of the pad
        d.rounded_rectangle((S(cx - 44), S(top / 2 - 6), S(cx + 44), S(top / 2 + 6)), S(6), fill=(206, 202, 194, 255))
    return cv


def _photo_wells(cv, slots, inset=20, border=3):
    """Transparent holes inside the slots, with a thin printed frame line."""
    d = ImageDraw.Draw(cv)
    mask = Image.new("L", cv.size, 0)
    md = ImageDraw.Draw(mask)
    for x, y, w, h in slots:
        hx, hy, hw, hh = x + inset, y + inset, w - 2 * inset, h - 2 * inset
        d.rectangle((S(hx - border), S(hy - border), S(hx + hw + border), S(hy + hh + border)), fill=BLACK)
        md.rectangle((S(hx), S(hy), S(hx + hw), S(hy + hh)), fill=255)
    punch(cv, mask)


def _round_photo(cv, photo, cx, cy, r, crop):
    """Round couple photo; [crop] is the (left, top, right, bottom) part of the
    photo to show, as fractions of its size (a small circle needs the faces close)."""
    src = Image.open(g.INVITATION / "images" / photo).convert("RGB")
    l, t, rr_, b = crop
    src = src.crop((round(l * src.width), round(t * src.height), round(rr_ * src.width), round(b * src.height)))
    pic = g.cover(src, S(2 * r), S(2 * r)).convert("RGBA")
    mask = Image.new("L", pic.size, 0)
    ImageDraw.Draw(mask).ellipse((0, 0, pic.width - 1, pic.height - 1), fill=255)
    cv.paste(pic, (S(cx - r), S(cy - r)), mask)
    d = ImageDraw.Draw(cv)
    d.ellipse((S(cx - r - 9), S(cy - r - 9), S(cx + r + 9), S(cy + r + 9)), outline=RED, width=S(3))


COUPLE_ROUND = ("gallery/album_10.webp", (0.335, 0.25, 0.695, 0.75))  # hai bạn cùng cười


def _lunar_footer(cv, y0, photo, crop):
    """Âm lịch, giờ hoàng đạo, nên/kỵ và câu ca dao; góc phải dưới chừa cho mã QR."""
    d = ImageDraw.Draw(cv)
    _rule(d, y0)
    top = y0 + 22
    d.rectangle((S(50), S(top), S(300), S(top + 210)), outline=BLACK, width=S(3))
    _spaced(d, "ÂM LỊCH", 175, top + 42, TIMES_B, 28, BLACK, 5)
    d.text((S(175), S(top + 168)), "20", font=g.font(TIMES_B, 142), fill=BLACK, anchor="ms")
    _spaced(d, "THÁNG MƯỜI", 175, top + 198, TIMES_B, 26, BLACK, 3)
    for i, line in enumerate(LUNAR):
        d.text((S(326), S(top + 46 + i * 52)), line, font=g.font(TIMES, 36), fill=BLACK, anchor="ls")
    _round_photo(cv, photo, 728, top + 105, 92, crop)
    d = ImageDraw.Draw(cv)
    y = top + 260
    small, small_b = g.font(TIMES, 33), g.font(TIMES_B, 33)
    d.text((S(50), S(y)), "Giờ hoàng đạo: ", font=small_b, fill=BLACK, anchor="ls")
    lead = d.textlength("Giờ hoàng đạo: ", font=small_b)
    d.text((S(50) + lead, S(y)), GIO_HOANG_DAO, font=small, fill=BLACK, anchor="ls")
    d.text((S(50), S(y + 44)), "Giờ Thân (15–17h): giờ khai tiệc", font=g.font(TIMES_BI, 36), fill=RED, anchor="ls")
    for k, (label, text) in enumerate((("Nên: ", "cưới hỏi · chụp ảnh · nâng ly"), ("Kỵ: ", "về sớm"))):
        yy = y + 94 + k * 42
        d.text((S(50), S(yy)), label, font=small_b, fill=RED, anchor="ls")
        d.text((S(50) + d.textlength(label, font=small_b), S(yy)), text, font=small, fill=BLACK, anchor="ls")
    _rule(d, y + 160, x1=690, double=False)
    for k, line in enumerate(("Thuận vợ thuận chồng,", "tát biển Đông cũng cạn.")):
        d.text((S(370), S(y + 216 + k * 46)), line, font=g.font(TIMES_I, 40), fill=BLACK, anchor="ms")


def _calendar_header(d):
    _spaced(d, "THÁNG 11", 52, 140, TIMES_B, 46, RED, 5, "left")
    _spaced(d, "NĂM 2026", W - 52, 140, TIMES_B, 46, RED, 5, "right")
    _rule(d, 160)


def s_lich_bloc(couple=COUPLE_ROUND):
    """Tờ lịch bloc ngày cưới: số 28 đỏ, hai ảnh khách giữa tờ, âm lịch và ca dao ở dưới."""
    cv = _calendar_page()
    d = ImageDraw.Draw(cv)
    _calendar_header(d)
    d.text((S(W / 2), S(602)), "28", font=g.font(TIMES_B, 615), fill=RED, anchor="ms")
    _spaced(d, "THỨ BẢY", W / 2, 690, TIMES_B, 64, RED, 16)
    d.text((S(W / 2), S(762)), "Ngày cưới Quang Thọ – Thúy Hiền", font=g.font(TIMES_BI, 44), fill=BLACK, anchor="ms")
    _photo_wells(cv, CAL_SLOTS)
    _lunar_footer(cv, 2040, *couple)
    return cv, CAL_SLOTS


# Biến thể: số 28 khổng lồ làm nền, hai ảnh như ảnh in dán băng keo lên tờ lịch.
TAPED_SLOTS = [(170, 520, 680, 510), (30, 1480, 680, 510)]


def _tape(d, cx, cy, angle, length=124, width=44):
    """A strip of paper tape (semi-transparent) centred on (cx, cy)."""
    a = math.radians(angle)
    ux, uy, vx, vy = math.cos(a), math.sin(a), -math.sin(a), math.cos(a)
    rng = random.Random(round(cx * 7 + cy))
    pts = []
    for s in (-1, 1):  # torn, slightly ragged ends
        for k in range(7):
            t = -width / 2 + k * width / 6
            jag = rng.uniform(-4, 4)
            px = cx + s * (length / 2 + jag) * ux + t * vx * s
            py = cy + s * (length / 2 + jag) * uy + t * vy * s
            pts.append((S(px), S(py)))
    d.polygon(pts, fill=(233, 222, 194, 205))


def s_lich_bloc_nen(couple=COUPLE_ROUND):
    """Biến thể: số 28 đỏ khổng lồ xếp dọc làm nền, hai ảnh dán băng keo đè lên."""
    cv = _calendar_page()
    d = ImageDraw.Draw(cv)
    _calendar_header(d)
    big = g.font(TIMES_B, 1480)
    d.text((S(W / 2), S(1185)), "2", font=big, fill=RED, anchor="ms")
    d.text((S(W / 2), S(2235)), "8", font=big, fill=RED, anchor="ms")
    holes = Image.new("L", cv.size, 0)
    hd = ImageDraw.Draw(holes)
    for x, y, w, h in TAPED_SLOTS:
        mat = Image.new("L", cv.size, 0)
        ImageDraw.Draw(mat).rectangle((S(x - 6), S(y - 6), S(x + w + 6), S(y + h + 6)), fill=255)
        gc.shadow(cv, mat, 14, (6, 14), 120)
        ImageDraw.Draw(cv).rectangle((S(x - 6), S(y - 6), S(x + w + 6), S(y + h + 6)), fill=(253, 252, 248, 255))
        hd.rectangle((S(x + 20), S(y + 20), S(x + w - 20), S(y + h - 20)), fill=255)
    punch(cv, holes)
    # Tape on its own layer so it blends over the mat and stays see-through over the photo.
    tape = Image.new("RGBA", cv.size, (0, 0, 0, 0))
    td = ImageDraw.Draw(tape)
    for (x, y, w, h), tilt in zip(TAPED_SLOTS, (1, -1)):
        _tape(td, x + 42, y + 18, -38 * tilt)
        _tape(td, x + w - 42, y + 18, 38 * tilt)
    cv.alpha_composite(tape)
    d = ImageDraw.Draw(cv)
    # Chân trang: thứ, tên, âm lịch; góc phải dưới chừa cho mã QR.
    _rule(d, 2268)
    _round_photo(cv, couple[0], 148, 2420, 92, couple[1])
    d = ImageDraw.Draw(cv)
    _spaced(d, "THỨ BẢY", 268, 2352, TIMES_B, 56, RED, 10, "left")
    d.text((S(268), S(2408)), "Ngày cưới Quang Thọ – Thúy Hiền", font=g.font(TIMES_BI, 34), fill=BLACK, anchor="ls")
    d.text((S(268), S(2458)), "Âm lịch: 20 tháng Mười · Bính Ngọ", font=g.font(TIMES, 32), fill=BLACK, anchor="ls")
    d.text((S(268), S(2504)), "Giờ Thân (15–17h): giờ khai tiệc", font=g.font(TIMES_BI, 32), fill=RED, anchor="ls")
    for k, line in enumerate(("Thuận vợ thuận chồng,", "tát biển Đông cũng cạn.")):
        d.text((S(360), S(2568 + k * 40)), line, font=g.font(TIMES_I, 34), fill=BLACK, anchor="ms")
    return cv, TAPED_SLOTS


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
    # --- Tờ lịch bloc ngày cưới (chờ duyệt): ảnh khách nằm giữa tờ, publish kèm `slots`.
    ("W1_lich_bloc", "Tờ lịch bloc 28", "Tờ lịch xé đúng ngày cưới: số 28 đỏ, thứ Bảy, âm lịch 20 tháng Mười, giờ Thân khai tiệc, nên/kỵ và câu ca dao.",
     s_lich_bloc, {"file": "standard_18.png", "category": (107, "Lịch Bloc")}),
    ("W2_lich_bloc_nen", "Tờ lịch bloc · 28 làm nền", "Biến thể: số 28 khổng lồ xếp dọc làm nền, hai ảnh như ảnh in dán băng keo lên tờ lịch.",
     s_lich_bloc_nen, {"file": "standard_19.png", "category": (107, "Lịch Bloc")}),
    # --- Biến thể tờ lịch dùng ảnh khác trong wedding-invitation (chờ duyệt).
    ("X1_lich_nu_hon", "Tờ lịch bloc · ảnh nụ hôn dưới voan", "Ảnh tròn là khoảnh khắc chú rể hôn má cô dâu dưới tấm voan.",
     partial(s_lich_bloc, couple=("gallery/album_15.webp", (0.2, 0.18, 0.8, 0.56))), {"file": "standard_20.png", "category": (107, "Lịch Bloc")}),
    ("X3_lich_nen_voan", "Tờ lịch · 28 làm nền · ảnh cô dâu che voan", "Bản số 28 làm nền, ảnh tròn dùng ảnh cô dâu cười dưới voan bên chú rể.",
     partial(s_lich_bloc_nen, couple=("couple/banner_right.webp", (0.15, 0.16, 0.85, 0.54))), {"file": "standard_21.png", "category": (107, "Lịch Bloc")}),
]


def preview(frame, slots=SLOTS):
    """Two sample photos in the slots (straight, as in the app), frame on top."""
    base = Image.new("RGBA", (W, H), (30, 30, 30, 255))
    for (x, y, w, h), name in zip(slots, SAMPLE_PHOTOS):
        photo = g.cover(Image.open(g.INVITATION / "images" / "gallery" / name).convert("RGB"), round(w), round(h))
        base.paste(photo, (round(x), round(y)))
    base.alpha_composite(frame)
    return base.convert("RGB")
