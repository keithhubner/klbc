# Keiths Little Backup Container 

## About

This container is designed to provide really simple backups with the following features:

- Backup remote mariadb/mysql databases to S3 bucket

## Environment Variables

| Variable                | Description                          |
|-------------------------|--------------------------------------|
| DB_HOST                 | Hostname or IP address of the database server |
| DB_USER                 | Username for the database connection |
| DB_PASSWORD             | Password for the database connection |
| DB_NAME                 | Name of the database to backup |
| APP_DIR                 | Directory where the backup files will be stored |
| AWS_ACCESS_KEY_ID       | Access key ID for the AWS S3 bucket |
| AWS_SECRET_ACCESS_KEY   | Secret access key for the AWS S3 bucket |
| AWS_DEFAULT_REGION      | AWS region where the S3 bucket is located |
| AWS_HOST                | Hostname or IP address of the AWS S3 endpoint |
| BUCKET                  | Name of the AWS S3 bucket |
| PUB_PRIV                | Access level for the S3 bucket (public or private) |
| S3_PATH                 | Path within the S3 bucket to store the backup files |


# Examples

## K8s

### Simple Run

```
kubectl run backup --image=keithhubner/klbc:latest --env=DB_HOST=mariadb --env=DB_USER=wordpress --env=APP_DIR=/data --env=DB_PASSWORD=YOU_DB_PW --env=DB_NAME=YOUR_DB_NAME --env=AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY --env=AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY --env=AWS_DEFAULT_REGION=YOUR_AWS_REGION --env=AWS_HOST=YOUR_AWS_HOST --env=BUCKET=YOUR_BUCKET --env=PUB_PRIV=private --env=S3_PATH=YOUR_S3_PATH
```

### Example backing up wordpress db to Civo Object Store:

```
kubectl run backup --image=keithhubner/klbc:latest --env=DB_HOST=mariadb --env=DB_USER=wordpress --env=APP_DIR=/data --env=DB_PASSWORD=PASSWORD --env=DB_NAME=wordpress --env=AWS_ACCESS_KEY_ID=CIVO_KEY --env=AWS_SECRET_ACCESS_KEY=CIVO_SECRET --env=AWS_DEFAULT_REGION=LON1 --env=AWS_HOST=https://objectstore.lon1.civo.com --env=BUCKET=wordpress-db --env=PUB_PRIV=private --env=S3_PATH=wordpress-db -n wordpress
```

### K8s Manifest

```

```

## Docker

