import unittest
import logging
from function import lambda_function

logger = logging.getLogger()

handler = lambda_function.lambda_handler


class TestFunction(unittest.TestCase):

    def test_function(self):
        event = "{'desc': 'Test event'}"
        logger.info(f'Test event: {event}')
        context = {'requestid': '1234'}
        result = handler(event, context)
        print(str(result))
        self.assertEqual(str(result), 'hello')


if __name__ == '__main__':
    unittest.main()
