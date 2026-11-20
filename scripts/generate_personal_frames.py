#!/usr/bin/env python3
"""Generate the personal wedding frames (transparent holes).

  - 2-photo strip frames, 880x2650 -> standard/
  - group frames, 2800x2000        -> group/

Usage: python3 scripts/generate_personal_frames.py [couple_photo]
  couple_photo: photo for the strip frames (default couple/banner_left.webp)
  The group frames use the cut-outs in scripts/frame_sources/ (made with
  scripts/cutout_subject.swift from couple/groom.webp and couple/bride.webp).

Layout (see docs/frame_design_guidelines.md, "Frame 2 ảnh"):
  - 2 rounded holes 760x560 at (60,60) and (60,680)
  - colored panel on the top 1300px, couple photo on the bottom 1350px
Group layout: groom/bride cut-outs (scale FIG_SCALE) standing at the bottom
corners, a centered 4:3 rounded hole between them (printed as "group hole" and
"slot" when generating; keep FrameData.group in lib/models/frame_data.dart in
sync with the slot), date in the top band and names in the bottom band.
Requires Pillow. Fonts and the default photo come from ../wedding-invitation.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
INVITATION = ROOT.parent / "wedding-invitation" / "src" / "assets"
OUT_DIR = ROOT / "assets" / "frames" / "personal" / "standard"

W, H = 880, 2650
SS = 2  # supersampling factor for smooth rounded corners
HOLES = [(60, 60, 760, 560), (60, 680, 760, 560)]
HOLE_RADIUS = 36
PANEL_BOTTOM = 1300
CREAM = (244, 238, 224)

DATE = "28.11.26"
GROOM_NAME = "Quang Thọ"
BRIDE_NAME = "Thúy Hiền"
NAMES = f"{GROOM_NAME} & {BRIDE_NAME}"

GROUP_SIZE = (2800, 2000)
GROUP_RADIUS = 90
GROUP_BLEED = (30, 22.5)  # photo is rendered this much larger than the hole
SOURCES = ROOT / "scripts" / "frame_sources"  # cut-outs, see cutout_subject.swift
# Both people stand at the bottom corners at the same scale, with as much of the
# body as possible visible. The hole is the largest centered 4:3 rectangle that
# fits between them, and they stand in front of it by FIG_OVERLAP.
FIG_SCALE = 0.85
GROOM_LEFT = 20  # canvas x of the groom's left-most edge
BRIDE_RIGHT = GROUP_SIZE[0] + 100  # bride's veil may be cropped by the edge
FIG_OVERLAP = 140
GROUP_OUT_DIR = ROOT / "assets" / "frames" / "personal" / "group"
GROUP_PHOTO_BG_NAME = "group_3.png"
GROUP_VARIANTS = {
    "group_1.png": (54, 69, 47),
    "group_2.png": (110, 36, 39),
}

VARIANTS = {
    "standard_1.png": (54, 69, 47),  # moss green
    "standard_2.png": (110, 36, 39),  # wine red
}


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size * SS)


def draw_spaced(draw, text, center_x, y, fnt, fill, spacing):
    widths = [draw.textlength(c, font=fnt) for c in text]
    total = sum(widths) + spacing * SS * (len(text) - 1)
    x = center_x * SS - total / 2
    for c, w in zip(text, widths):
        draw.text((x, y * SS), c, font=fnt, fill=fill)
        x += w + spacing * SS


def cover(img: Image.Image, w: int, h: int) -> Image.Image:
    scale = max(w / img.width, h / img.height)
    img = img.resize((round(img.width * scale), round(img.height * scale)), Image.LANCZOS)
    left, top = (img.width - w) // 2, (img.height - h) // 2
    return img.crop((left, top, left + w, top + h))


def build(color, photo: Image.Image) -> Image.Image:
    canvas = Image.new("RGBA", (W * SS, H * SS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # Couple photo (bottom) then colored panel (top).
    photo_h = H - PANEL_BOTTOM
    canvas.paste(cover(photo, W * SS, photo_h * SS).convert("RGBA"), (0, PANEL_BOTTOM * SS))
    draw.rectangle((0, 0, W * SS, PANEL_BOTTOM * SS), fill=color + (255,))

    # Soft fade from panel color into the photo.
    fade_h = 90 * SS
    fade = Image.new("RGBA", (W * SS, fade_h))
    for y in range(fade_h):
        a = int(255 * (1 - y / fade_h) ** 1.6)
        ImageDraw.Draw(fade).line((0, y, W * SS, y), fill=color + (a,))
    canvas.alpha_composite(fade, (0, PANEL_BOTTOM * SS))

    # Transparent rounded holes for the photos.
    mask = Image.new("L", canvas.size, 255)
    mdraw = ImageDraw.Draw(mask)
    for x, y, w, h in HOLES:
        mdraw.rounded_rectangle(
            (x * SS, y * SS, (x + w) * SS, (y + h) * SS), HOLE_RADIUS * SS, fill=0
        )
    canvas.putalpha(Image.composite(canvas.getchannel("A"), Image.new("L", canvas.size, 0), mask))

    # Texts.
    draw = ImageDraw.Draw(canvas)
    fonts = INVITATION / "fonts"
    draw_spaced(
        draw, DATE, W / 2, 14,
        font(fonts / "Playfair_Display" / "PlayfairDisplay-Regular.ttf", 26),
        CREAM + (255,), 6,
    )
    names_font = font(fonts / "Pinyon_Script" / "PinyonScript-Regular.ttf", 78)
    box = draw.textbbox((0, 0), NAMES, font=names_font)
    draw.text(
        ((W * SS - (box[2] - box[0])) / 2 - box[0], (PANEL_BOTTOM + 70) * SS),
        NAMES, font=names_font, fill=CREAM + (255,),
    )
    return canvas.resize((W, H), Image.LANCZOS)


def place_figure(canvas, cutout: Image.Image, scale: float, inner_x: int, side: str):
    """Stand a cut-out person on the bottom edge, next to the photo hole.

    inner_x is where the edge of the person facing the hole lands (it may sit a
    little inside the hole so the person stands in front of the photo). The
    outer side is cropped by the canvas edge. A soft shadow adds depth.
    """
    gw, gh = GROUP_SIZE
    bbox = cutout.getchannel("A").getbbox()
    w, h = round(cutout.width * scale), round(cutout.height * scale)
    figure = cutout.resize((w * SS, h * SS), Image.LANCZOS)
    edge = (bbox[2] if side == "left" else bbox[0]) * scale
    x = round(inner_x - edge)
    y = gh - h

    shadow = Image.new("RGBA", figure.size, (0, 0, 0, 0))
    shadow.putalpha(figure.getchannel("A").point(lambda a: int(a * 0.45)))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14 * SS))
    canvas.alpha_composite(shadow, (x * SS, y * SS)) if x >= 0 else _paste_clipped(
        canvas, shadow, x * SS, y * SS
    )
    _paste_clipped(canvas, figure, x * SS, y * SS)


def _paste_clipped(canvas, layer, x, y):
    """alpha_composite that tolerates a layer hanging over the canvas edge."""
    left, top = max(0, -x), max(0, -y)
    right = min(layer.width, canvas.width - x)
    bottom = min(layer.height, canvas.height - y)
    if right <= left or bottom <= top:
        return
    canvas.alpha_composite(layer.crop((left, top, right, bottom)), (x + left, y + top))


def garden_half(photo: Image.Image, width: int, height: int) -> Image.Image:
    """The original photo cover-fitted to width x height and blurred into a bokeh
    background (the people in it are simply blurred too)."""
    small = photo.convert("RGB").resize((photo.width // 4, photo.height // 4), Image.LANCZOS)
    scale = max(width / small.width, height / small.height)
    small = small.resize((round(small.width * scale), round(small.height * scale)), Image.BICUBIC)
    left, top = (small.width - width) // 2, (small.height - height) // 2
    return small.crop((left, top, left + width, top + height)).filter(ImageFilter.GaussianBlur(16))


def garden_background(groom_photo, bride_photo) -> Image.Image:
    """Groom's garden on the left blended into the bride's garden on the right,
    dimmed so the cream text stays readable."""
    gw, gh = GROUP_SIZE
    half = gw // 2 + 300
    left = garden_half(groom_photo, half, gh)
    right = garden_half(bride_photo, half, gh)

    bg = Image.new("RGB", (gw, gh))
    bg.paste(left, (0, 0))
    mask = Image.new("L", (gw, gh), 0)
    ramp = ImageDraw.Draw(mask)
    for x in range(half, gw):
        ramp.line((x, 0, x, gh), fill=255)
    blend_start, blend_w = gw // 2 - 300, 600
    for i in range(blend_w):
        ramp.line((blend_start + i, 0, blend_start + i, gh), fill=int(255 * i / blend_w))
    bg.paste(right, (gw - half, 0), mask.crop((gw - half, 0, gw, gh)))

    # Dim overall, extra at the top and bottom where the text sits.
    dim = Image.new("L", (gw, gh), 55)
    d = ImageDraw.Draw(dim)
    for y in range(420):
        d.line((0, y, gw, y), fill=55 + int(95 * (1 - y / 420)))
        d.line((0, gh - 1 - y, gw, gh - 1 - y), fill=55 + int(95 * (1 - y / 420)))
    return Image.composite(Image.new("RGB", (gw, gh), (0, 0, 0)), bg, dim)


def group_layout(groom: Image.Image, bride: Image.Image):
    """Returns (groom_inner_x, bride_inner_x, hole) where hole is (x, y, w, h)."""
    gw, gh = GROUP_SIZE
    gb = groom.getchannel("A").getbbox()
    bb = bride.getchannel("A").getbbox()
    groom_inner = GROOM_LEFT + (gb[2] - gb[0]) * FIG_SCALE
    bride_inner = BRIDE_RIGHT - (bb[2] - bb[0]) * FIG_SCALE
    half = min(gw / 2 - (groom_inner - FIG_OVERLAP), (bride_inner + FIG_OVERLAP) - gw / 2)
    w = int(2 * half) // 4 * 4
    h = w * 3 // 4
    hole = (gw // 2 - w // 2, (gh - h) // 2, w, h)
    return round(groom_inner), round(bride_inner), hole


def build_group(color, groom: Image.Image, bride: Image.Image, background=None) -> Image.Image:
    gw, gh = GROUP_SIZE
    groom_inner, bride_inner, GROUP_HOLE = group_layout(groom, bride)
    print("group hole", GROUP_HOLE, "slot", (
        GROUP_HOLE[0] - GROUP_BLEED[0], GROUP_HOLE[1] - GROUP_BLEED[1],
        GROUP_HOLE[2] + 2 * GROUP_BLEED[0], GROUP_HOLE[3] + 2 * GROUP_BLEED[1]))
    if background is not None:
        canvas = background.resize((gw * SS, gh * SS), Image.BICUBIC).convert("RGBA")
    else:
        canvas = Image.new("RGBA", (gw * SS, gh * SS), color + (255,))
    hx, hy, hw, hh = GROUP_HOLE
    draw = ImageDraw.Draw(canvas)

    # Thin cream outline around the photo, in the bleed area under the frame.
    inset = 22
    draw.rounded_rectangle(
        ((hx - inset) * SS, (hy - inset) * SS, (hx + hw + inset) * SS, (hy + hh + inset) * SS),
        (GROUP_RADIUS + inset) * SS, outline=CREAM + (255,), width=3 * SS,
    )

    # Transparent rounded hole.
    mask = Image.new("L", canvas.size, 255)
    ImageDraw.Draw(mask).rounded_rectangle(
        (hx * SS, hy * SS, (hx + hw) * SS, (hy + hh) * SS), GROUP_RADIUS * SS, fill=0
    )
    canvas.putalpha(mask)

    draw = ImageDraw.Draw(canvas)
    fonts = INVITATION / "fonts"
    # Center each text in the band left between the canvas edge and the outline.
    top_end = hy - inset
    bottom_start = hy + hh + inset
    date_font = font(fonts / "Playfair_Display" / "PlayfairDisplay-Regular.ttf", 54)
    box = draw.textbbox((0, 0), DATE, font=date_font)
    draw_spaced(
        draw, DATE, gw / 2,
        (top_end * SS - (box[3] - box[1])) / 2 / SS - box[1] / SS,
        date_font, CREAM + (255,), 16,
    )
    names_font = font(fonts / "Pinyon_Script" / "PinyonScript-Regular.ttf", 108)
    box = draw.textbbox((0, 0), NAMES, font=names_font)
    draw.text(
        ((gw * SS - (box[2] - box[0])) / 2 - box[0],
         bottom_start * SS + ((gh - bottom_start) * SS - (box[3] - box[1])) / 2 - box[1]),
        NAMES, font=names_font, fill=CREAM + (255,),
    )
    # Groom on the left and bride on the right, facing the photo. Drawn last so
    # they stand in front of the (transparent) photo hole.
    place_figure(canvas, groom, FIG_SCALE, groom_inner, "left")
    place_figure(canvas, bride, FIG_SCALE, bride_inner, "right")
    return canvas.resize((gw, gh), Image.LANCZOS)


def main_photo_bg(out: Path) -> None:
    """Preview: group frame whose background is the original photo garden."""
    couple_dir = INVITATION / "images" / "couple"
    groom = Image.open(SOURCES / "groom_cutout.png").convert("RGBA")
    bride = Image.open(SOURCES / "bride_cutout.png").convert("RGBA")
    groom_photo = Image.open(couple_dir / "groom.webp")
    bride_photo = Image.open(couple_dir / "bride.webp")
    bg = garden_background(groom_photo, bride_photo)
    out.parent.mkdir(parents=True, exist_ok=True)
    build_group((0, 0, 0), groom, bride, bg).save(out)
    print("wrote", out)


def main() -> None:
    if len(sys.argv) > 2 and sys.argv[1] == "--photo-bg":
        return main_photo_bg(Path(sys.argv[2]))
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else INVITATION / "images" / "couple" / "banner_left.webp"
    photo = Image.open(src).convert("RGB")
    groom = Image.open(SOURCES / "groom_cutout.png").convert("RGBA")
    bride = Image.open(SOURCES / "bride_cutout.png").convert("RGBA")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, color in VARIANTS.items():
        build(color, photo).save(OUT_DIR / name)
        print("wrote", OUT_DIR / name)
    GROUP_OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, color in GROUP_VARIANTS.items():
        build_group(color, groom, bride).save(GROUP_OUT_DIR / name)
        print("wrote", GROUP_OUT_DIR / name)
    # Extra variant: the original garden of the photos instead of a flat color.
    main_photo_bg(GROUP_OUT_DIR / GROUP_PHOTO_BG_NAME)


if __name__ == "__main__":
    main()
