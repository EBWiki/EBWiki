"""Load SigLIP 2 once and embed PIL images on CPU."""

from __future__ import annotations

import io
import logging
from typing import TYPE_CHECKING

import requests
import torch
from PIL import Image
from transformers import AutoModel, AutoProcessor

from . import EMBEDDING_DIMENSIONS, MODEL_ID
from .network_policy import NetworkPolicy

if TYPE_CHECKING:
    from collections.abc import Sequence

logger = logging.getLogger(__name__)


class SiglipEmbedder:
    def __init__(self, model_id: str = MODEL_ID) -> None:
        self.model_id = model_id
        logger.info("loading SigLIP model %s on CPU", model_id)
        self.processor = AutoProcessor.from_pretrained(model_id)
        self.model = AutoModel.from_pretrained(model_id)
        self.model.eval()

    def embed_pil_image(self, image: Image.Image) -> list[float]:
        inputs = self.processor(images=image, return_tensors="pt")
        with torch.no_grad():
            features = self.model.get_image_features(**inputs)
        features = _as_feature_tensor(features)
        vector = torch.nn.functional.normalize(features, p=2, dim=-1)
        values: Sequence[float] = vector[0].tolist()
        if len(values) != EMBEDDING_DIMENSIONS:
            raise ValueError(
                f"expected {EMBEDDING_DIMENSIONS} dimensions, got {len(values)}"
            )
        return list(values)

    def embed_image_url(self, url: str, policy: NetworkPolicy) -> list[float]:
        policy.allow_image_url(url)
        response = requests.get(url, timeout=60)
        response.raise_for_status()
        image = Image.open(io.BytesIO(response.content)).convert("RGB")
        return self.embed_pil_image(image)


def _as_feature_tensor(features: object) -> torch.Tensor:
    if isinstance(features, torch.Tensor):
        return features
    if hasattr(features, "pooler_output") and features.pooler_output is not None:
        return features.pooler_output
    if hasattr(features, "last_hidden_state"):
        return features.last_hidden_state[:, 0, :]
    raise TypeError(f"unexpected feature type: {type(features)!r}")
