#!/bin/sh
set -e
export LC_ALL="en_US.UTF-8"

echo "= Doing the MongoDB backup to S3"

HOST=<insert_mongodbhost_here>
PORT=<insert_mongodbport_here>
DB=<insert_dbname_here>
USERNAME=<insert_user_here>
PASSWORD=<insert_password_here>

S3PATH="s3://dbbackups/"
S3GZIPED=`date +"%Y%m%d_%H%M%S"`.dump.gz
S3BACKUP=$S3PATH$S3GZIPED
S3LATEST=$S3PATH"latest".dump.gz

echo "S3BACKUP=$S3BACKUP"
echo "S3LATEST=$S3LATEST"

# echo "== Creating the path for the db..."
# aws s3 mb $S3PATH
echo "== Dumping the DB and creating archive..."
mongodump -v --gzip --archive=$S3GZIPED -h $HOST:$PORT -u "$USERNAME" -p "$PASSWORD" --authenticationDatabase admin --db $DB
echo "== Backing up on S3..."
aws s3 cp $S3GZIPED $S3BACKUP
aws s3 cp $S3BACKUP $S3LATEST

echo "= Done!"

# Restore
# echo -n "Restore: "
# echo -n "aws s3 cp $S3LATEST - | gzip -d  | mongorestore --host $HOST --db $DB - "
