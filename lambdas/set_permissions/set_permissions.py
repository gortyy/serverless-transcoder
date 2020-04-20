import json
from typing import Tuple

import boto3
from botocore.exceptions import ClientError


def parse_event(event: dict) -> Tuple[str, str]:
    message = event["Records"][0]
    source_bucket = message["s3"]["bucket"]["name"]
    source_key = message["s3"]["object"]["key"].replace("+", " ")

    return (source_bucket, source_key)


def handler(event, context):
    source_key, source_bucket = parse_event(event)

    s3 = boto3.resource("s3")
    try:
        response = (
            s3.Object(source_bucket, source_key).Acl().put(ACL="public-read")
        )
        return json.dumps({"message": response})
    except ClientError as exc:
        return json.dumps({"error": str(exc)})
