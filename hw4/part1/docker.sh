#!/bin/bash
cd /Users/myu/Documents/rr/docker/auto-docker
#rm -rf /Users/myu/Documents/rr/docker/auto-package/*
#jenkins job Id
BUILD_ID=$1
# git commit id 
COMMIT_ID=$2
#container name use the project name
CONTAINER_NAME=ingram
#image name 
IMAGES_NAME=ingram
# write log for build
echo "build_id:"$1" commit_id:"$2"  buildtime:"`date "+%Y-%m-%d %H:%M:%S"`>>build_version.log
# get file path and file name
FILENAME=docker_spring_boot.jar
JARNAME=${FILENAME##*/}
chmod  777 $JARNAME
if [ -z "$JARNAME" ]
then
    echo "not find :"$JARNAME
    exit
else
    echo "find app:"$JARNAME
fi
#stop and rm container and images 
/usr/local/bin/docker stop $CONTAINER_NAME
/usr/local/bin/docker rm $CONTAINER_NAME
# delete image
IMAGE_ID=$(/usr/local/bin/docker images | grep "$IMAGES_NAME" | awk '{print $3}')
echo "iam:"$IMAGE_ID
if [ -z "$IMAGE_ID" ]
then
    echo no images need del
else
    echo "rm images:" $IMAGE_ID
    /usr/local/bin/docker rmi -f $IMAGE_ID
fi
#编译docker file 并动态传入参数
echo $JARNAME
/usr/local/bin/docker build --build-arg app=$JARNAME .  -t  $IMAGES_NAME:$BUILD_ID
rm $JARNAME
# docker run  expose port 8181 
/usr/local/bin/docker run -itd -p 8080:8080 --name $CONTAINER_NAME --link mysqleatornot:db $IMAGES_NAME:$BUILD_ID
# docker tag and push registry
/usr/local/bin/docker tag $IMAGES_NAME:$BUILD_ID 192.168.0.10:5000/$IMAGES_NAME:$BUILD_ID
/usr/local/bin/docker push 192.168.0.10:5000/$IMAGES_NAME:$BUILD_ID
