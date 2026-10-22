import pytest
import requests

from case_photo_embedding.network_policy import NetworkPolicy, NetworkPolicyError


def test_blocks_unlisted_https_hosts():
    policy = NetworkPolicy()
    policy.install()
    try:
        with pytest.raises(NetworkPolicyError):
            requests.get("https://example.com/", timeout=1)
    finally:
        NetworkPolicy.remove()


def test_allows_registered_image_host():
    policy = NetworkPolicy()
    policy.allow_image_url("https://photos.example.org/victim.jpg")
    policy.install()
    try:
        with pytest.raises(requests.exceptions.RequestException):
            requests.get("https://photos.example.org/victim.jpg", timeout=1)
    finally:
        NetworkPolicy.remove()


def test_allows_huggingface_model_host():
    policy = NetworkPolicy()
    policy.install()
    try:
        response = requests.get("https://huggingface.co/", timeout=10)
        assert response.status_code < 500
    finally:
        NetworkPolicy.remove()
