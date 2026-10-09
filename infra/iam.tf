resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.PROJECT_NAME}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.PROJECT_NAME}-ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.PROJECT_NAME}-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role" "app_role" {
  name = "${var.PROJECT_NAME}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "${var.PROJECT_NAME}-app-role"
  }
}

resource "aws_iam_role_policy_attachment" "app_ssm_policy" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

resource "aws_iam_role_policy" "app_s3_policy" {
  name = "${var.PROJECT_NAME}-app-s3-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.uploads.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.uploads.arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.PROJECT_NAME}-app-profile"
  role = aws_iam_role.app_role.name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy" "db_backup_policy" {
  name = "${var.PROJECT_NAME}-db-backup-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.db_backups.arn}/*"
      }
    ]
  })
}
