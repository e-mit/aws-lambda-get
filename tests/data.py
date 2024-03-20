"""Test data: json_string produces data after json decoding."""

json_string = ('{"data": [{"from": "2024-03-11T15:30Z", '
               '"to": "2024-03-11T16:00Z", "intensity": '
               '{"forecast": 247, "actual": 242, "index": "high"}}]}')

data = {'data': [{'from': '2024-03-11T15:30Z',
                  'intensity': {'actual': 242, 'forecast': 247,
                                'index': 'high'},
                  'to': '2024-03-11T16:00Z'}]}
