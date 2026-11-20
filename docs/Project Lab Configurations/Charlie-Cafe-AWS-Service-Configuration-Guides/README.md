# Charlie Cafe AWS Service Configuration Guides

This folder separates the master DevOps README into service-focused Markdown guides.

## Guides

- [Project overview & shared configuration](00-project-overview-and-shared-config.md)
- [AWS IAM](01-aws-iam.md)
- [Amazon VPC & Networking](02-amazon-vpc-networking.md)
- [Amazon EC2](03-amazon-ec2.md)
- [Amazon RDS](04-amazon-rds.md)
- [AWS Secrets Manager](05-aws-secrets-manager.md)
- [Amazon S3](06-amazon-s3.md)
- [AWS Lambda](07-aws-lambda.md)
- [Amazon SQS](08-amazon-sqs.md)
- [Amazon API Gateway](09-amazon-api-gateway.md)
- [Amazon Cognito](10-amazon-cognito.md)
- [Amazon DynamoDB](11-amazon-dynamodb.md)
- [Amazon ECR](12-amazon-ecr.md)
- [Amazon ECS](13-amazon-ecs.md)
- [Elastic Load Balancing (ALB)](14-elastic-load-balancing.md)
- [Amazon CloudFront](15-amazon-cloudfront.md)
- [Amazon CloudWatch](16-amazon-cloudwatch.md)
- [AWS CodeDeploy](17-aws-codedeploy.md)
- [AWS Certificate Manager (ACM)](18-aws-certificate-manager.md)
- [GitHub Actions & CI/CD](19-github-actions-cicd.md)

## Notes

- Content is reorganized from the supplied master README; it is not an independent technical audit.
- Cross-service sections may be repeated in multiple guides to keep each guide usable on its own.
- Review security-sensitive examples before deployment. The source contains broad permissions and example credentials/account identifiers; replace placeholders and rotate any real credentials before use.
- The original master README is included in the ZIP as `AWS Charlie Cafe Project README.md` for reference.
