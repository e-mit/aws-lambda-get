import logging
import os

import requests

LOG_LEVEL = os.getenv('LOG_LEVEL', 'DEBUG')
GET_URL = os.getenv('GET_URL', '')
GET_TIMEOUT_SEC = float(os.getenv('GET_TIMEOUT_SEC', '5'))

logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)
logger.info(f'Getting {GET_URL} with timeout={GET_TIMEOUT_SEC} s')


def lambda_handler(event, context) -> dict:
    logger.debug(f'Event: {event}')

    response = requests.get(GET_URL, timeout=GET_TIMEOUT_SEC)
    if response.status_code != 200:
        try:
            logger.error(f'Get failed; response: {response}')
        except Exception:
            pass
        raise ValueError("Bad status code")

    response_json = response.json()
    logger.debug(f'Response: {response_json}')
    return response_json
