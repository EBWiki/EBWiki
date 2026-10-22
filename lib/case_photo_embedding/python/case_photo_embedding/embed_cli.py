"""Embed one local image file and print a JSON vector (for specs and debugging)."""

from __future__ import annotations

import json
import sys

from PIL import Image

from .siglip_embedder import SiglipEmbedder


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: python -m case_photo_embedding.embed_cli PATH")

    path = sys.argv[1]
    image = Image.open(path).convert("RGB")
    embedder = SiglipEmbedder()
    vector = embedder.embed_pil_image(image)
    print(json.dumps(vector))


if __name__ == "__main__":
    main()
