"""Restrict outbound HTTP to image source hosts and Hugging Face model downloads."""

from __future__ import annotations

from urllib.parse import urlparse

import httpx
import requests

ALLOWED_MODEL_HOST_SUFFIXES = (
    "huggingface.co",
    "hf.co",
)

_original_session_request = requests.Session.request
_original_session_send = requests.Session.send
_original_httpx_request = httpx.Client.request
_original_httpx_send = httpx.Client.send
_policy: "NetworkPolicy | None" = None


class NetworkPolicyError(RuntimeError):
    pass


class NetworkPolicy:
    def __init__(self) -> None:
        self._allowed_image_hosts: set[str] = set()

    def allow_image_url(self, url: str) -> None:
        host = _host_from_url(url)
        if host:
            self._allowed_image_hosts.add(host)

    def check_url(self, url: str) -> None:
        host = _host_from_url(url)
        if not host:
            raise NetworkPolicyError(f"blocked outbound call with no host: {url}")
        if host in self._allowed_image_hosts:
            return
        if _host_allowed_for_model(host):
            return
        raise NetworkPolicyError(f"blocked outbound call to {host!r} ({url})")

    def install(self) -> None:
        global _policy
        _policy = self

        def guarded_request(session, method, url, **kwargs):  # type: ignore[no-untyped-def]
            if _policy is not None:
                _policy.check_url(url)
            return _original_session_request(session, method, url, **kwargs)

        def guarded_httpx_request(client, method, url, **kwargs):  # type: ignore[no-untyped-def]
            if _policy is not None:
                _policy.check_url(str(url))
            return _original_httpx_request(client, method, url, **kwargs)

        def guarded_session_send(session, request, **kwargs):  # type: ignore[no-untyped-def]
            if _policy is not None:
                _policy.check_url(request.url)
            return _original_session_send(session, request, **kwargs)

        def guarded_httpx_send(client, request, **kwargs):  # type: ignore[no-untyped-def]
            if _policy is not None:
                _policy.check_url(str(request.url))
            return _original_httpx_send(client, request, **kwargs)

        requests.Session.request = guarded_request  # type: ignore[method-assign]
        requests.Session.send = guarded_session_send  # type: ignore[method-assign]
        httpx.Client.request = guarded_httpx_request  # type: ignore[method-assign]
        httpx.Client.send = guarded_httpx_send  # type: ignore[method-assign]

    @staticmethod
    def remove() -> None:
        global _policy
        _policy = None
        requests.Session.request = _original_session_request  # type: ignore[method-assign]
        requests.Session.send = _original_session_send  # type: ignore[method-assign]
        httpx.Client.request = _original_httpx_request  # type: ignore[method-assign]
        httpx.Client.send = _original_httpx_send  # type: ignore[method-assign]


def _host_from_url(url: str) -> str | None:
    parsed = urlparse(url)
    host = parsed.hostname
    return host.lower() if host else None


def _host_allowed_for_model(host: str) -> bool:
    lowered = host.lower()
    return any(
        lowered == suffix or lowered.endswith(f".{suffix}")
        for suffix in ALLOWED_MODEL_HOST_SUFFIXES
    )

