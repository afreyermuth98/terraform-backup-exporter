

import boto3
import os
from datetime import datetime, timedelta, date
import csv
import sys
import logging

MODULE = sys.modules["__main__"].__file__
LOG_FORMAT = "[%(asctime)s][%(funcName)25s][%(levelname)8s] - %(message)s"
logger = logging.getLogger(MODULE)

header = ['Resource Type', 'State', 'Type', 'Backup Vault ARN', 'Creation', 'Completion']


def get_backups_rows(client, by_created_at):
    backup_response = client.list_backup_jobs(
        MaxResults=100,  # To have next token in response
        ByCreatedAfter=by_created_at,
    )

    backup_jobs = backup_response["BackupJobs"]
    rows = []
    for backup_job in backup_jobs:
        resource_type = backup_job["ResourceType"]
        creation_date = backup_job["CreationDate"]
        completion_date = backup_job["CompletionDate"].strftime("%Y-%m-%d %H:%M:%S")
        backup_vault_arn = backup_job["BackupVaultArn"].strftime("%Y-%m-%d %H:%M:%S")
        state = backup_job["State"]
        backup_type = "initial"
            
        rows.append([resource_type,state,backup_type,backup_vault_arn,creation_date,completion_date])

    # Until next token is present in response, we continue to get backups
    while "NextToken" in backup_response:
        backup_response = client.list_backup_jobs(
            MaxResults=100,
            ByCreatedAfter=by_created_at,
            NextToken=backup_response["NextToken"],
        )
        backup_jobs = backup_response["BackupJobs"]
        for backup_job in backup_jobs:
            resource_type = backup_job["ResourceType"]
            creation_date = backup_job["CreationDate"]
            completion_date = backup_job["CompletionDate"].strftime("%Y-%m-%d %H:%M:%S")
            backup_vault_arn = backup_job["BackupVaultArn"].strftime("%Y-%m-%d %H:%M:%S")
            state = backup_job["State"]
            backup_type = "backup"
            
            rows.append([resource_type,state,backup_type,backup_vault_arn,creation_date,completion_date])

    return rows

def get_copies_rows(client, by_created_at):
    copy_response = client.list_copy_jobs(
        MaxResults=100,  # To have next token in response
        ByCreatedAfter=by_created_at,
    )

    copy_jobs = copy_response["CopyJobs"]
    rows = []
    for copy_job in copy_jobs:
        resource_type = copy_job["ResourceType"]
        creation_date = copy_job["CreationDate"]
        completion_date = copy_job["CompletionDate"].strftime("%Y-%m-%d %H:%M:%S")
        backup_vault_arn = copy_job["BackupVaultArn"].strftime("%Y-%m-%d %H:%M:%S")
        state = copy_job["State"]
        backup_type = "copy"
            
        rows.append([resource_type,state,backup_type,backup_vault_arn,creation_date,completion_date])

    # Until next token is present in response, we continue to get backups
    while "NextToken" in copy_response:
        copy_response = client.list_copy_jobs(
            MaxResults=100,
            ByCreatedAfter=by_created_at,
            NextToken=copy_response["NextToken"],
        )
        copy_jobs = copy_response["BackupJobs"]
        for copy_job in copy_jobs:
            resource_type = copy_job["ResourceType"]
            creation_date = copy_job["CreationDate"]
            completion_date = copy_job["CompletionDate"].strftime("%Y-%m-%d %H:%M:%S")
            backup_vault_arn = copy_job["BackupVaultArn"].strftime("%Y-%m-%d %H:%M:%S")
            state = copy_job["State"]
            backup_type = "copy"
            
            rows.append([resource_type,state,backup_type,backup_vault_arn,creation_date,completion_date])

    return rows

def lambda_handler(event, context):
    days_to_retrieve = os.environ["DAYS_TO_RETRIEVE"]
    retrieve_date = datetime.now() - timedelta(days=int(days_to_retrieve))
    
    client = boto3.client('backup')
    s3 = boto3.resource('s3')
    bucket = os.environ["BUCKET"]
    
    backups_rows = get_backups_rows(client, retrieve_date)
    copies_rows = get_copies_rows(client, retrieve_date)


    with open('/tmp/report.csv', 'w', encoding='UTF-8') as f:
        writer = csv.writer(f)
        writer.writerow(header)

        for row in backups_rows:
            writer.writerow(row)
        for row in copies_rows:
            writer.writerow(row)

    filename = "backups-report-" + str(date.today())
    s3.meta.client.upload_file('/tmp/report.csv', bucket, filename)

    sns_client = boto3.client('sns')
    snsArn = os.environ['SNS_TOPIC_ARN']
    message = "A new report about last " + days_to_retrieve + " days backups and copies is available in your S3 bucket"  
    
    sns_client.publish(
        TopicArn = snsArn,
        Message = message ,
        Subject='Backups & Copies report was uploaded'
    )



    

