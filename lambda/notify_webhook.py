import json
import urllib.request
import os

def lambda_handler(event, context):
    webhook_url = os.environ['WEBHOOK_URL']
    for record in event['Records']:
        s3_info = {
            'bucket': record['s3']['bucket']['name'],
            'object': record['s3']['object']['key']
        }
        data = json.dumps(s3_info).encode('utf-8')
        req = urllib.request.Request(webhook_url, data=data, headers={'Content-Type': 'application/json'})
        urllib.request.urlopen(req)
    return {'status': 'ok'} 