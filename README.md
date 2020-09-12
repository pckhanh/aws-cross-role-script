# prerequisite
- Setup Cross-Role named "MY-CROSS-ROLE" with "Trust Relationships" from all child aws accounts and pointing to "HUB-ACCOUNT-ID" in below

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::HUB-ACCOUNT-ID:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

- Setup IAM User or Identity Provider and federation (IDP) into AWS Hub Account and assume this above role "MY-CROSS-ROLE".

  + Login with IDP setup
    https://www.npmjs.com/package/aws-azure-login
    https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html
    
  + Login with IAM User and assume policy with all child account "CHILD-ACCOUNT-ID01", "CHILD-ACCOUNT-ID02" etc.
  
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": [
            "arn:aws:iam::CHILD-ACCOUNT-ID01:role/MY-CROSS-ROLE",
            "arn:aws:iam::CHILD-ACCOUNT-ID02:role/MY-CROSS-ROLE"
        ]
    }
}
  

# aws-cross-role-script
Cross Account Role
