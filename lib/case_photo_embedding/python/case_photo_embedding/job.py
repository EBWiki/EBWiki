"""Embed every shown case photo into Postgres (pgvector)."""

from __future__ import annotations

import json
import logging
import os
import sys
from typing import Any

import psycopg

from . import MODEL_ID
from .network_policy import NetworkPolicy
from .siglip_embedder import SiglipEmbedder

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger("case_photo_embedding.job")


def _database_url() -> str:
    url = os.environ.get("DATABASE_URL")
    if not url:
        raise RuntimeError("DATABASE_URL is required")
    return url


def _model_id() -> str:
    return os.environ.get("CASE_PHOTO_EMBEDDING_MODEL", MODEL_ID)


def _fetch_shown_cases(conn: psycopg.Connection) -> list[dict[str, Any]]:
    query = """
        SELECT id, photo_url
        FROM cases
        WHERE photo_status = 'shown'
          AND photo_url IS NOT NULL
          AND photo_url <> ''
        ORDER BY id
    """
    with conn.cursor() as cur:
        cur.execute(query)
        rows = cur.fetchall()
    return [{"id": row[0], "photo_url": row[1]} for row in rows]


def _store_embedding(
    conn: psycopg.Connection, case_id: int, vector: list[float]
) -> None:
    literal = "[" + ",".join(f"{v:.8f}" for v in vector) + "]"
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE cases SET photo_embedding = %s::vector WHERE id = %s",
            (literal, case_id),
        )
    conn.commit()


def run() -> dict[str, int]:
    policy = NetworkPolicy()
    policy.install()

    shown_cases = []
    embedded = 0
    errors = 0

    try:
        embedder = SiglipEmbedder(model_id=_model_id())
        with psycopg.connect(_database_url()) as conn:
            shown_cases = _fetch_shown_cases(conn)
            shown_count = len(shown_cases)
            logger.info("shown photos to embed: %s", shown_count)

            for row in shown_cases:
                case_id = row["id"]
                photo_url = row["photo_url"]
                try:
                    policy.allow_image_url(photo_url)
                    vector = embedder.embed_image_url(photo_url, policy)
                    _store_embedding(conn, case_id, vector)
                    embedded += 1
                    logger.info("embedded case_id=%s", case_id)
                except Exception:
                    errors += 1
                    logger.exception("failed case_id=%s url=%s", case_id, photo_url)

            summary = {
                "shown_count": shown_count,
                "embedded_count": embedded,
                "error_count": errors,
            }
            logger.info("summary %s", summary)
            if embedded != shown_count:
                logger.error(
                    "embedded_count %s does not match shown_count %s",
                    embedded,
                    shown_count,
                )
                sys.exit(1)
            print(json.dumps(summary))
            return summary
    finally:
        NetworkPolicy.remove()


if __name__ == "__main__":
    run()
