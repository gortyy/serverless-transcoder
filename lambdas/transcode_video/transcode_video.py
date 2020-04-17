import json
import urllib

import boto3
from botocore.exceptions import ClientError


def handler(event, context):
    key = event["Records"][0]["s3"]["object"]["key"]
    source_key = urllib.parse.unquote_plus(key)
    output_key = source_key[: source_key.rfind(".")]
    print(f"key: ", key, source_key, output_key)

    transcoder_params = {
        "PipelineId": "1586883367960-0uo4tl",
        "OutputKeyPrefix": output_key + "/",
        "Input": {"Key": source_key},
        "Outputs": [
            {
                "Key": f"{output_key}-1080p.mp4",
                "PresetId": "1351620000001-000001",
            },
            {
                "Key": f"{output_key}-720p.mp4",
                "PresetId": "1351620000001-000010",
            },
            {
                "Key": f"{output_key}-web-720p.mp4",
                "PresetId": "1351620000001-100070",
            },
        ],
    }

    elastic_transcoder = boto3.client("elastictranscoder", "us-east-1")
    try:
        response = elastic_transcoder.create_job(**transcoder_params)
        return json.dumps({"message": response})
    except ClientError as exc:
        return json.dumps({"error": str(exc)})
