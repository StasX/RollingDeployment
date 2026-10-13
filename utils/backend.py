from config.bucket import configure_bucket_security
from botocore.exceptions import ClientError


def prepare_backend(s3_client, PROJECT_NAME, REGION):
    try:
        s3_client.head_bucket(Bucket=PROJECT_NAME)
        print(f"Bucket '{PROJECT_NAME}' already exists.")

    except ClientError as error:
        error_code = error.response["Error"]["Code"]

        if error_code not in ("404", "NotFound"):
            raise

        print(f"Creating bucket '{PROJECT_NAME}'...")

        parameters = {"Bucket": PROJECT_NAME}

        if REGION != "us-east-1":
            parameters["CreateBucketConfiguration"] = {
                "LocationConstraint": REGION
            }

        s3_client.create_bucket(**parameters)

    # Enforce these settings for both new and existing buckets.
    configure_bucket_security(
        s3_client=s3_client,
        bucket_name=PROJECT_NAME,
    )
