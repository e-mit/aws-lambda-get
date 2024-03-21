"""Simple tests of enqueued API data.

Data from https://api.carbonintensity.org.uk/intensity
"""

import sys
import json

data = json.load(sys.stdin)
assert len(data['Messages']) == 1
body = json.loads(data['Messages'][0]['Body'])
payload = body['responsePayload']

assert len(payload['data']) == 1
assert 'from' in payload['data'][0]
assert 'to' in payload['data'][0]
assert 'intensity' in payload['data'][0]

intensity = payload['data'][0]['intensity']
assert 'forecast' in intensity
assert 'actual' in intensity
assert 'index' in intensity
assert False
