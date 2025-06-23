# Audio Extraction Service - Terraform Infrastructure

This project provides Terraform infrastructure for an AWS-based audio extraction service that processes video files to extract metadata and audio content.

## Architecture Overview

The system consists of the following AWS resources:

1. **S3 Buckets:**
   - Terraform state bucket (with versioning and encryption)
   - Video input bucket (for uploaded video files)
   - Audio output bucket (for extracted audio files)

2. **DynamoDB:**
   - Extraction state table (tracks processing status of video files)
   - Terraform locks table (for state locking)

3. **SQS:**
   - Video processing queue (receives S3 notifications)
   - Dead letter queue (for failed messages)

4. **Lambda:**
   - Metadata extractor function (uses ffprobe to extract video metadata)
   - FFmpeg layer (contains ffmpeg and ffprobe binaries)

5. **IAM:**
   - Lambda execution role with proper permissions
   - Policies for S3, DynamoDB, SQS, and CloudWatch Logs access

## FFmpeg Lambda Layer with S3 Storage

Due to size limitations of Lambda layers (250MB unzipped), the FFmpeg binaries are stored in a dedicated S3 bucket and referenced by the Lambda layer.

### Components:
- **S3 Bucket**: `ffmpeg-binaries-{environment}-{random-suffix}` - Stores the FFmpeg layer ZIP file
- **Lambda Layer**: References the ZIP file from S3 instead of local storage
- **IAM Permissions**: Lambda execution role has read access to the FFmpeg binaries bucket

### Deployment Steps:

1. **Prepare FFmpeg Binaries**: Place your FFmpeg binaries in `lambda-layers/ffmpeg/bin/` directory
2. **Deploy Infrastructure**: Run `terraform apply` - this will:
   - Create the S3 bucket for FFmpeg binaries
   - Package and upload the FFmpeg layer to S3
   - Create the Lambda layer referencing the S3 object
   - Set up proper IAM permissions

3. **Verify Deployment**: Check the outputs for bucket names and layer ARN

### Benefits of S3 Storage:
- **No Size Limitations**: S3 can store objects up to 5TB
- **Versioning**: Enabled versioning allows tracking of FFmpeg binary updates
- **Security**: Private bucket with encryption and proper IAM access controls
- **Cost Effective**: S3 storage is cheaper than keeping large objects in Lambda

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Python 3.12 (for Lambda function development)

## Project Structure

```
ffmpeg-service/
├── main.tf                    # Provider configuration and backend
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── data.tf                    # Data sources
├── s3.tf                      # S3 buckets and notifications
├── dynamodb.tf                # DynamoDB tables
├── sqs.tf                     # SQS queues and policies
├── iam.tf                     # IAM roles and policies
├── lambda.tf                  # Lambda function and layer
├── terraform.tfvars.example   # Example variables file
├── lambda/                    # Lambda function source code
│   ├── index.py               # Main Lambda handler
│   └── requirements.txt       # Python dependencies
├── lambda-layers/             # Lambda layers
│   └── ffmpeg/               # FFmpeg binaries directory
│       └── bin/              # Binary files location
└── README.md                 # This file
```

## Setup Instructions

### 1. Clone and Configure

```bash
git clone <repository-url>
cd ffmpeg-service

# Copy and edit the variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your desired values
```

### 2. Deployment Options

#### Option A: CI/CD Deployment (Recommended for Production)

For production deployments, use the GitHub Actions workflow:

1. **Setup GitHub Repository**:
   - Add AWS credentials to GitHub Secrets
   - Configure environment variables
   - See `DEPLOYMENT.md` for detailed setup

2. **Deploy via GitHub Actions**:
   - Push to `main` branch for production
   - Push to `develop` branch for development
   - Manual deployment via Actions tab

#### Option B: Local Development Deployment

For local development and testing:

```bash
# The GitHub Action automatically handles FFmpeg binary download
# For local development, you can manually download:
mkdir -p lambda-layers/ffmpeg/bin
wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
tar -xf ffmpeg-release-amd64-static.tar.xz
cp ffmpeg-*-amd64-static/ffmpeg lambda-layers/ffmpeg/bin/
cp ffmpeg-*-amd64-static/ffprobe lambda-layers/ffmpeg/bin/
chmod +x lambda-layers/ffmpeg/bin/*
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Apply

```bash
# Review the planned changes
terraform plan

# Apply the infrastructure
terraform apply
```

**Note:** On the first run, the S3 backend configuration is commented out in `main.tf`. After the initial deployment:

1. Uncomment the backend configuration in `main.tf`
2. Update the bucket name with the actual created bucket name
3. Run `terraform init` again to migrate state to S3

### 5. Configure Remote State (Optional but Recommended)

After the initial deployment:

```bash
# Edit main.tf and uncomment the backend configuration
# Update with your actual bucket name from the output

terraform init
# Answer 'yes' when prompted to migrate state to S3
```

## Usage

### Upload Video Files

Upload video files to the video input S3 bucket. The system supports:
- `.mp4`
- `.mov`
- `.avi`
- `.mkv`

### Monitor Processing

1. **CloudWatch Logs:** Check Lambda function logs
2. **DynamoDB:** Query the extraction state table for job status
3. **SQS:** Monitor queue metrics in CloudWatch

### Query Job Status

Use AWS CLI to check job status:

```bash
# List all jobs
aws dynamodb scan --table-name audio-extraction-extraction-state-dev

# Query by status
aws dynamodb query \
  --table-name audio-extraction-extraction-state-dev \
  --index-name status-index \
  --key-condition-expression "status = :status" \
  --expression-attribute-values '{":status":{"S":"completed"}}'
```

## Configuration Options

### Variables

Key variables you can customize in `terraform.tfvars`:

- `aws_region`: AWS region for deployment
- `environment`: Environment name (dev, staging, prod)
- `lambda_timeout`: Lambda function timeout (seconds)
- `lambda_memory_size`: Lambda memory allocation (MB)
- `enable_s3_notifications`: Enable/disable S3 to SQS notifications
- `dynamodb_read_capacity`: DynamoDB read capacity units
- `dynamodb_write_capacity`: DynamoDB write capacity units

### DynamoDB Schema

The extraction state table uses the following schema:

**Primary Key:**
- `job_id` (String): Unique job identifier
- `timestamp` (String): ISO 8601 timestamp

**Attributes:**
- `status`: Job status (processing, completed, failed)
- `video_key`: S3 object key of the video file
- `video_bucket`: S3 bucket name
- `video_size_bytes`: File size in bytes
- `metadata`: Extracted video metadata (JSON)
- `error_message`: Error message if failed
- `ttl`: Time-to-live (auto-deletion after 30 days)

**Global Secondary Indexes:**
- `status-index`: Query by status
- `video-key-index`: Query by video file

## Security Features

- All S3 buckets have public access blocked
- Server-side encryption enabled for all S3 buckets
- DynamoDB tables encrypted at rest
- IAM roles follow least privilege principle
- Lambda functions use specific resource-based policies

## Cost Optimization

- DynamoDB uses provisioned capacity (can be changed to on-demand)
- Lambda functions use ARM64 architecture option available
- S3 lifecycle policies can be added for cost optimization
- CloudWatch log retention set to 14 days

## Troubleshooting

### Common Issues

1. **FFmpeg binaries not found:**
   - Ensure binaries are placed in `lambda-layers/ffmpeg/bin/`
   - Verify binaries are executable and Linux x86_64 compatible

2. **Lambda timeout errors:**
   - Increase `lambda_timeout` variable
   - Ensure SQS visibility timeout > Lambda timeout

3. **Permission errors:**
   - Check IAM policies in `iam.tf`
   - Verify resource ARNs are correct

4. **S3 notifications not working:**
   - Check SQS queue policy allows S3 to send messages
   - Verify bucket notification configuration

### Logs and Monitoring

- Lambda logs: CloudWatch Logs `/aws/lambda/audio-extraction-metadata-extractor-{env}`
- DynamoDB metrics: CloudWatch DynamoDB dashboard
- SQS metrics: CloudWatch SQS dashboard

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning:** This will delete all data including S3 buckets and DynamoDB tables. Ensure you have backups if needed.

## Extension Ideas

1. **Audio Extraction:** Add another Lambda function to extract audio from videos
2. **API Gateway:** Add REST API for job management
3. **Step Functions:** Orchestrate complex video processing workflows
4. **SNS Notifications:** Send notifications when jobs complete
5. **VPC:** Deploy Lambda in VPC for enhanced security
6. **Auto Scaling:** Use DynamoDB auto-scaling for variable workloads

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License. See LICENSE file for details. 