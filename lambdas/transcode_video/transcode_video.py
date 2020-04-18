import json
import urllib

import boto3
from botocore.exceptions import ClientError


def handler(event, context):
    key = event["Records"][0]["s3"]["object"]["key"]
    source_key = urllib.parse.unquote_plus(key)
    output_key = source_key[: source_key.rfind(".")]
    print(f"key: ", key, source_key, output_key)

    elastic_transcoder = boto3.client("elastictranscoder", "us-east-1")

    pipelines = elastic_transcoder.list_pipelines()["Pipelines"]
    pipeline_id = None

    for pipeline in pipelines:
        if pipeline["Name"] == "transcoder_pipeline":
            pipeline_id = pipeline["Id"]

    if pipeline_id is None:
        raise EnvironmentError("Missing transcoder pipeline")

    transcoder_params = {
        "PipelineId": pipeline_id,
        "OutputKeyPrefix": f"{output_key}/",
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

    try:
        response = elastic_transcoder.create_job(**transcoder_params)
        return json.dumps({"message": response})
    except ClientError as exc:
        return json.dumps({"error": str(exc)})
