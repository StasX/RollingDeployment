import os
import boto3
from botocore.exceptions import ClientError
import subprocess
from pathlib import Path

AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
REGION = os.getenv("REGION", "us-east-1")
PROJECT_NAME = os.getenv("PROJECT_NAME")
BASE_DIR = Path(__file__).resolve().parent
INFRA_DIR = BASE_DIR / "infra"


def main():
    if not PROJECT_NAME:
        raise ValueError("Environment variable PROJECT_NAME must be set.")

    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY,
        aws_secret_access_key=AWS_SECRET_KEY,
        region_name=REGION,
    )
    s3_client = session.client("s3")

    try:
        s3_client.head_bucket(Bucket=PROJECT_NAME)
        print(f"Bucket '{PROJECT_NAME}' already exists.")

    except ClientError as e:
        error_code = e.response["Error"]["Code"]

        if error_code in ("404", "NotFound"):
            print(f"Bucket '{PROJECT_NAME}' not found. Creating it...")

            if REGION == "us-east-1":
                s3_client.create_bucket(Bucket=PROJECT_NAME)
            else:
                s3_client.create_bucket(
                    Bucket=PROJECT_NAME,
                    CreateBucketConfiguration={"LocationConstraint": REGION},
                )

            s3_client.put_bucket_versioning(
                Bucket=PROJECT_NAME,
                VersioningConfiguration={"Status": "Enabled"},
            )
            print(f"Successfully created '{PROJECT_NAME}' with versioning.")
        else:
            raise e

    subprocess.run([
        "terraform",
        f"-chdir={INFRA_DIR}",
        "init",
        f"-backend-config=bucket={PROJECT_NAME}",
        f"-backend-config=key=env/terraform.tfstate",
        f"-backend-config=region={REGION}",
        "-backend-config=use_lockfile=true",
    ],
        check=True)
    subprocess.run([
        "terraform",
        f"-chdir={INFRA_DIR}",
        "plan",
        "-out=tfplan"
    ],
        check=True)
    subprocess.run([
        "terraform",
        f"-chdir={INFRA_DIR}",
        "apply",
        "tfplan"
    ],
        check=True)


if __name__ == "__main__":
    main()
