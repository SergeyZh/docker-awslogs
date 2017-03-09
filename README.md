## Dockerfile to run AWS CloudWatch Logs container

### Usage

This container is intended to upload logfiles to Amazon CloudWatch Logs service.
If you don't set any environment variables, container will start with the following config:

```
[/mnt/logs/access.log]
datetime_format = %d/%b/%Y:%H:%M:%S %z
file = /mnt/logs/access.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = nginx-server
```

### Environment variables

* `AWS_LOGFILE` default is "/mnt/logs/access.log"
* `AWS_LOGFORMAT` default is "%d/%b/%Y:%H:%M:%S %z"
* `AWS_DURATION` default is "5000"
* `AWS_GROUPNAME` default is "nginx-server"
* `AWS_STREAM_NAME` default is the instance_id
* `AWS_REGION` default is us-east-1 (region where logs are published)
* `AWS_INITIAL_POSITION` default is start-of-file (other option is end-of-file)

If you have not defined a role for this instance, then you will need to pass
the AWS keys
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`


### Example

```
# Run container with Nginx
docker run -d --name nginx -v /mnt/logs:/var/log/nginx -p 80:80 sergeyzh/centos6-nginx

# Run container with AWS CloudWatch logs uploader
docker run -d --name awslogs -e AWS_LOGFILE=/mnt/logs/access.log -e AWS_DURATION=10000 -v /mnt/logs:/mnt/logs sergeyzh/awslogs
```

Now you can see access logs of your Nginx at [AWS Console](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logs:).

NOTE: Of course you should run it on the Amazon EC2 and you should set IAM role for you instance according [manual](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/QuickStartEC2Instance.html).

If you do  not then run as follows

docker run -d --name awslogs -e AWS_LOGFILE=/var/log/applogs.log -e AWS_DURATION=5000 -e AWS_GROUPNAME=/ci/messaging -e AWS_LOGFORMAT="%Y-%m-%d %H:%M:%S" -v /var/lib/docker/log/myapp/:/var/log awslogs

### MAINTAINERS

* Ryuta Otaki <otaki.ryuta@classmethod.jp>
* Sergey Zhukov <sergey@jetbrains.com>
* David Rosenstark <drosenstark@gmail.com>
