"""An AWS Lambda to GET data from an HTTP endpoint."""

import logging
import os
from typing import Any

import requests

LOG_LEVEL = os.getenv('LOG_LEVEL', 'DEBUG')
GET_URL = os.getenv('GET_URL', '')
GET_TIMEOUT_SEC = float(os.getenv('GET_TIMEOUT_SEC', '5'))

logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)
logger.info('Getting %s with timeout=%s s', GET_URL, GET_TIMEOUT_SEC)


def lambda_handler(event: Any, _context_unused: Any) -> Any:
    """Define the lambda function."""
    logger.debug('Event: %s', event)

    response = requests.get(GET_URL, timeout=GET_TIMEOUT_SEC)
    if response.status_code != 200:
        logger.error('Get failed; response: %s', response)
        raise ValueError("Bad status code")

    response_json = response.json()
    logger.debug('Response: %s', response_json)
    return response_json
