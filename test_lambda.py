import unittest
import os
import sys
import importlib
import json

import requests

sys.path.append("function")

from function import lambda_function  # noqa


class TestFunction(unittest.TestCase):

    def reload(self) -> None:
        os.environ['LOG_LEVEL'] = self.LOG_LEVEL
        os.environ['GET_TIMEOUT_SEC'] = self.GET_TIMEOUT_SEC
        os.environ['GET_URL'] = self.GET_URL
        importlib.reload(lambda_function)

    def setUp(self) -> None:
        self.LOG_LEVEL = 'DEBUG'
        self.GET_TIMEOUT_SEC = '5'
        self.GET_URL = ''
        self.event = "{'description': 'Test event'}"
        self.context = {'requestid': '1234'}
        return super().setUp()

    def test_get(self):
        self.GET_URL = 'https://api.carbonintensity.org.uk/intensity'
        self.reload()
        result = lambda_function.lambda_handler(self.event, self.context)
        result_obj = json.loads(result)
        self.assertIn('data', result_obj)
        self.assertEqual(len(result_obj['data']), 1)
        self.assertIn('intensity', result_obj['data'][0])

    def test_bad_get(self):
        self.GET_URL = 'dcdcscscscsc'
        self.reload()
        with self.assertRaises(Exception):
            lambda_function.lambda_handler(self.event, self.context)

    def test_timeout(self):
        self.GET_TIMEOUT_SEC = '0.000001'
        self.GET_URL = 'https://google.com'
        self.reload()
        with self.assertRaises(requests.Timeout):
            lambda_function.lambda_handler(self.event, self.context)


if __name__ == '__main__':
    unittest.main()
