from typing import Any

import requests


def get(url: str, timeout_sec: int) -> dict[str, Any]:
    r = requests.get(url)

    if r.status_code != 200:
        raise Exception("Bad status code")

    r.json()
    # validate json here

    return r.json()
