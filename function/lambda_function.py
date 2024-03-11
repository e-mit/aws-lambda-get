import logging
import os

import requests

LOG_LEVEL = os.environ['LOG_LEVEL']
GET_URL = os.environ['GET_URL']
GET_TIMEOUT_SEC = int(os.environ['GET_TIMEOUT_SEC'])

logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)
logger.info(f'Getting {GET_URL} with timeout={GET_TIMEOUT_SEC} s')


def lambda_handler(event, context) -> str:
    logger.debug(f'Event: {event}')

    response = requests.get(GET_URL, timeout=GET_TIMEOUT_SEC)
    if response.status_code != 200:
        try:
            logger.error(f'Get failed; response: {response}')
        except Exception:
            pass
        raise ValueError("Bad status code")

    logger.debug(f'Response: {response.text}')
    return response.text
