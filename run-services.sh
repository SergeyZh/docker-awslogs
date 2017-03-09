#!/bin/bash

shutdown_awslogs()
{
    echo "Stopping container..."
    kill $(pgrep -f /var/awslogs/bin/aws)
    exit 0
}

trap shutdown_awslogs INT TERM HUP


# [/mnt/logs/access.log]
# datetime_format = %d/%b/%Y:%H:%M:%S %z
# file = /mnt/logs/access.log
# buffer_duration = 5000
# log_stream_name = {instance_id}
# initial_position = start_of_file
# log_group_name = nginx-server

LOGFILE=${AWS_LOGFILE:-"/mnt/logs/access.log"}
LOGFORMAT=${AWS_LOGFORMAT:-"%d/%b/%Y:%H:%M:%S %z"}
DURATION=${AWS_DURATION:-"5000"}
GROUPNAME=${AWS_GROUPNAME:-"nginx-server"}
STREAM_NAME=${AWS_STREAM_NAME:-"{instance_id\}"}
INITIAL_POSITION=${AWS_INITIAL_POSITION:-"start-of-file"}
REGION=${AWS_REGION:-"us-east-1"}

cp -f /awslogs.conf.dummy /var/awslogs/etc/awslogs.conf

cat >> /var/awslogs/etc/awslogs.conf <<EOF
[${LOGFILE}]
datetime_format = ${LOGFORMAT}
file = ${LOGFILE}
buffer_duration = ${DURATION}
log_stream_name = ${STREAM_NAME} 
initial_position = ${INITIAL_POSITION} 
log_group_name = ${GROUPNAME}

EOF

cat > /var/awslogs/etc/aws.conf <<EOF
[plugins]
cwlogs = cwlogs
[default]
region = ${AWS_REGION}

EOF

if [ ! -z  ${AWS_ACCESS_KEY_ID} ]; then

mkdir /root/.aws
cat > /root/.aws/credentials <<EOF
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID} 
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

fi

/var/awslogs/bin/awslogs-agent-launcher.sh &

wait
