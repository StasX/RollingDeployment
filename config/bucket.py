def configure_bucket_security(s3_client, bucket_name):
    s3_client.put_public_access_block(
        Bucket=bucket_name,
        PublicAccessBlockConfiguration={
            "BlockPublicAcls": True,
            "IgnorePublicAcls": True,
            "BlockPublicPolicy": True,
            "RestrictPublicBuckets": True,
        },
    )

    s3_client.put_bucket_versioning(
        Bucket=bucket_name,
        VersioningConfiguration={
            "Status": "Enabled"
        },
    )
