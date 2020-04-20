import json
import urllib
from typing import Tuple

import boto3
from botocore.exceptions import ClientError


def find_pipeline(client: boto3.session.Session.client, name: str):
    pipelines = client.list_pipelines()["Pipelines"]

    for pipeline in pipelines:
        if pipeline["Name"] == name:
            return pipeline["Id"]


def parse_event(event: dict) -> Tuple[str, str]:
    key = event["Records"][0]["s3"]["object"]["key"]
    source_key = urllib.parse.unquote_plus(key)
    output_key = source_key[: source_key.rfind(".")]

    return (source_key, output_key)


def handler(event, context):
    source_key, output_key = parse_event(event)

    elastic_transcoder = boto3.client("elastictranscoder", "us-east-1")
    pipeline_id = find_pipeline(elastic_transcoder, "transcoder_pipeline")

    if pipeline_id is None:
        raise EnvironmentError("Missing transcoder pipeline")

    elastic_transcoder = boto3.client("elastictranscoder", "us-east-1")
    pipeline_id = find_pipeline(elastic_transcoder, "transcoder_pipeline")

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
            {
                "Key": f"{output_key}-720p.webm",
                "PresetId": "1351620000001-100240",
            },
            {
                "Key": f"{output_key}-400k.ts",
                "PresetId": "1351620000001-200050",
            },
        ],
    }

    try:
        response = elastic_transcoder.create_job(**transcoder_params)
        return json.dumps({"message": response})
    except ClientError as exc:
        return json.dumps({"error": str(exc)})
