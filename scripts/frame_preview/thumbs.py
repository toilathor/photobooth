#!/usr/bin/env python3
"""Small WebP thumbnails of every frame, so the preview page stays light.

Usage: thumbs.py <preview_dir> <frames_dir> [--watch]

Writes <preview_dir>/thumbs/<flavor>/<path with / as __>.webp and
<preview_dir>/thumbs/index.json (one file the page polls to know what changed).
With --watch it keeps running and refreshes thumbnails when a frame changes.
"""
import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from PIL import Image

WIDTH = {"standard": 340, "group": 640, "collected": 340}  # px, by frame folder


def thumb_name(flavor: str, rel: str) -> str:
    return f"{flavor}/{rel.replace('/', '__')}.webp"


def frames(frames_dir: Path):
    for flavor_dir in sorted(p for p in frames_dir.iterdir() if p.is_dir()):
        for png in sorted(flavor_dir.rglob("*.png")):
            rel = png.relative_to(flavor_dir).as_posix()
            if rel.startswith("thumbnails/"):
                continue
            yield flavor_dir.name, rel, png


def make(thumbs: Path, flavor: str, rel: str, src: Path) -> bool:
    out = thumbs / thumb_name(flavor, rel)
    if out.exists() and out.stat().st_mtime >= src.stat().st_mtime:
        return False
    out.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(src) as im:
        w = WIDTH.get(rel.split("/")[0], 340)
        im = im.convert("RGBA")
        im.thumbnail((w, w * 4), Image.LANCZOS)
        im.save(out, "WEBP", quality=78, method=4)
    return True


def sync(preview: Path, frames_dir: Path) -> int:
    thumbs = preview / "thumbs"
    thumbs.mkdir(parents=True, exist_ok=True)
    items = list(frames(frames_dir))
    with ThreadPoolExecutor(max_workers=6) as pool:
        made = sum(pool.map(lambda it: make(thumbs, *it), items))
    keep = {thumb_name(f, r) for f, r, _ in items}
    for old in thumbs.rglob("*.webp"):
        if old.relative_to(thumbs).as_posix() not in keep:
            old.unlink()
    stamps = {f"{f}/{r}": int(p.stat().st_mtime) for f, r, p in items}
    for data in frames_dir.glob("*/data.json"):
        stamps[f"{data.parent.name}/data.json"] = int(data.stat().st_mtime)
    (thumbs / "index.json").write_text(json.dumps(stamps, sort_keys=True), encoding="utf-8")
    return made


def main():
    preview, frames_dir = Path(sys.argv[1]), Path(sys.argv[2])
    start = time.time()
    made = sync(preview, frames_dir)
    print(f"thumbnails: {made} updated in {time.time() - start:.1f}s")
    if "--watch" in sys.argv:
        while True:
            time.sleep(2)
            sync(preview, frames_dir)


if __name__ == "__main__":
    main()
