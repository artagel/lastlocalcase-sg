import boto3
import time
import os

def handle_s3_change(event, context):
    paths = []
    for items in event["Records"]:
        key = items["s3"]["object"]["key"]
        if key.endswith("index.html"):
            paths.append("/" + key[:-10])
        paths.append("/" + key)
    print("Invalidating " + str(paths))

    client = boto3.client('cloudfront')
    batch = {
        'Paths': {
            'Quantity': len(paths),
            'Items': paths
        },
        'CallerReference': str(time.time())
    }
    invalidation = client.create_invalidation(
        DistributionId="E3INA79U1U2Q7W",
        InvalidationBatch=batch,
    )
    return batch