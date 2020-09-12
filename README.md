# prerequisite
- Setup Cross-Role named "MY-CROSS-ROLE" with "Trust Relationships" from all child aws accounts and pointing to "Hub-Account-ID" in below

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::Hub-Account-ID:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

- Setup IAM User or IDP into AWS Hub Account and assume this above role "MY-CROSS-ROLE".

# aws-cross-role-script
Cross Account Role
