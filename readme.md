# Keiths Little Backup Container 

## About

This container is designed to provide really simple backups and store these backups in a remote S3 bucket. 

Current functionality:

- Connect to a mysql/mariadb database, backup to remote S3 bucket

To do:

- Retention options on remote storage
- File Backup
- Helm chart deployment

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

### K8s Job

It may be that you want to run a regular job in K8s to backup every x hours/days:

Create a config map to hold the non sensitive values (replace values with your own)

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
  namespace: wordpress
data:
  DB_HOST: "mariadb"
  DB_USER: "wordpress"
  DB_NAME: "wordpress"
  APP_DIR: "/data"
  AWS_DEFAULT_REGION: "LON1"
  AWS_HOST: "https://objectstore.lon1.civo.com"
  BUCKET: "wordpress-db" 
  PUB_PRIV: "private"
  S3_PATH: "wordpress-db"
```
> Example using K8s secrets, you may wish to replace with external secrets manager

Create the secret values using kubectl:

```
kubectl create secret generic my-secret -namespace YOUR_NAMESPACE \
  --from-literal=DB_PASSWORD=YOUR_DB_PASSWORD \
  --from-literal=AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY \
  --from-literal=AWS_SECRET_ACCESS_KEY=YOUR_SECRET_Key 
```

Create a job to run on a schedule:

> You will want to replace the schedule and also some other settings in the job to suit your requirements.

```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cronjob
  namespace: wordpress
spec:
  schedule: "*/1 * * * *"  # Cron expression for running the job every minute
  successfulJobsHistoryLimit: 3  # Keep up to 3 successful job completions
  failedJobsHistoryLimit: 3      # Keep up to 3 failed job completions
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup-container
            image: keithhubner/klbc:latest
            envFrom:
            - configMapRef:
                name: my-configmap
            - secretRef:
                name: my-secret                                                     
          restartPolicy: OnFailure  # Specifies what to do when the container exits
```

## Docker

Provide docker instructions here
