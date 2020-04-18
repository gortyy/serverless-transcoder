import json
import os
import subprocess as sp
import urllib

import boto3


s3 = boto3.client("s3")


def save_metadata_to_s3(file_name, bucket, key):
    print("Saving metadata to s3")
    s3.upload_file(file_name, bucket, key)


def extract_metadata(local_filename):
    print("Extracting metadata")
    sp.run(
        f"bin/ffprobe -v quiet -print_format json "
        f"-show_format {local_filename}",
        shell=True,
        check=True,
    )


def save_file_to_filesystem(bucket, key):
    print("Saving to filesystem")
    local_filename = os.path.jon("/tmp", key.split("/")[-1])
    with open(local_filename, "wb") as f:
        s3.download_fileobj(bucket, key, f)
    extract_metadata(local_filename)
    return local_filename


def handler(event, context):
    message = json.loads(event["Records"][0]["Sns"]["Message"])
    s3_info = message["Records"][0]["s3"]
    source_bucket = s3_info["bucket"]["name"]
    source_key = urllib.parse.unquote_plus(
        s3_info["object"]["key"].replace("+", " ")
    )

    local_filename = save_file_to_filesystem(source_bucket, source_key)
    save_metadata_to_s3(
        local_filename, source_bucket, f"{source_key.split('.')[0]}.json"
    )
