import unittest
import os
import sys
import importlib
from typing import Any
import time

import requests
import requests_mock

import data

sys.path.append("function")

from function import lambda_function  # noqa


class TestRealRequests(unittest.TestCase):

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
        result_obj = lambda_function.lambda_handler(self.event, self.context)
        self.assertIn('data', result_obj)
        self.assertEqual(len(result_obj['data']), 1)
        self.assertIn('intensity', result_obj['data'][0])

    def test_bad_get(self):
        self.GET_URL = 'dcdcscscscsc'
        self.reload()
        with self.assertRaises(Exception):
            lambda_function.lambda_handler(self.event, self.context)


@requests_mock.Mocker()
class TestMockRequests(unittest.TestCase):

    def reload(self) -> None:
        os.environ['LOG_LEVEL'] = self.LOG_LEVEL
        os.environ['GET_TIMEOUT_SEC'] = self.GET_TIMEOUT_SEC
        os.environ['GET_URL'] = self.GET_URL
        importlib.reload(lambda_function)

    def setUp(self) -> None:
        self.LOG_LEVEL = 'DEBUG'
        self.GET_TIMEOUT_SEC = '5'
        self.GET_URL = 'http://mock.com'
        self.event = "{'description': 'Test event'}"
        self.context = {'requestid': '1234'}
        return super().setUp()

    def test_get_ok(self, m):
        m.register_uri('GET', self.GET_URL, text=data.json_string,
                       status_code=200)
        self.reload()
        result_obj = lambda_function.lambda_handler(self.event, self.context)
        self.assertEqual(result_obj, data.data)

    def test_get_not_200(self, m):
        m.register_uri('GET', self.GET_URL, text=data.json_string,
                       status_code=404)
        self.reload()
        with self.assertRaises(ValueError):
            lambda_function.lambda_handler(self.event, self.context)

    def test_invalid_json(self, m):
        m.register_uri('GET', self.GET_URL, text='[bad json]',
                       status_code=200)
        self.reload()
        with self.assertRaises(requests.exceptions.JSONDecodeError):
            lambda_function.lambda_handler(self.event, self.context)

    def test_timeout(self, m):
        m.register_uri('GET', self.GET_URL, exc=requests.Timeout)
        self.reload()
        with self.assertRaises(requests.Timeout):
            lambda_function.lambda_handler(self.event, self.context)


if __name__ == '__main__':
    unittest.main()
