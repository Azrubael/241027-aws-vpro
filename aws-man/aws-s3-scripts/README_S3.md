### 2024-11-01  17:44
---------------------

```bash
    $ ls
s3check_Mb.sh               # Check existing AWS S3 buckets
s3content.sh [bucket_name]  # List of the content in exact AWS S3 bucket
s3create.sh                 # Create an AWS S3 bucket with the predefined name
s3delete_empty.sh [bucket_name]          # Delete the exact AWS S3 bucket 
s3upload.sh [bucket_name]   # Upload predefined files to AWS S3 [bucket_name]
                            # and arrange files into directories
s3upload_flat.sh            # Upload predefined files to AWS S3 [bucket_name]
                            # but don't arrange files into directories
s3role_create.py            # Python3 script to create AWS S3 bucket
                            # with IAM policy and IAM role
s3role_delete.py [bucket_name]           # Python3 script to delete AWS S3
                            # and after that delete IAM policy and IAM role
```