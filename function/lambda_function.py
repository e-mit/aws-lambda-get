import logging
from typing import Any

import get_request

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context) -> dict[str, Any]:
    logger.info(f'Event: {event}')
    data = get_request.get('https://api.carbonintensity.org.uk/intensity', 6)
    logger.info(f'Response: {data}')
    return data
