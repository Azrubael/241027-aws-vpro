### 2024-11-02  19:50
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
<<<<<<< HEAD:aws-bucket/README_S3.md
s3role_delete.py            # Python3 script to delete AWS S3 bucket with files
=======
<<<<<<<< HEAD:aws-man/aws-infra/aws-s3-scripts/README_S3.md
s3role_delete.py            # Python3 script to delete AWS S3 bucket with files
========
s3role_delete.py [bucket_name]           # Python3 script to delete AWS S3
>>>>>>>> aws-man:s3-script-examples/README_S3.md
>>>>>>> aws-man:s3-script-examples/README_S3.md
                            # and after that delete IAM policy and IAM role
```