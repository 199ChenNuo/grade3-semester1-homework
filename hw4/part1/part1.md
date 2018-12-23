## Prepare a CI/CD environment

Use Jenkins in docker image to do CI/CD.
1. Download Jenkins image.
``` docker pull jenkins/jenkins:lts
```
2. Run container.
``` docker run --name jenkins7 -p 8087:8080 -p 50007:50000 --privileged=true -v /usr/local/bin/docker:/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock -d jenkins/jenkins:lts
```
Mount the host's docker cmd to the container.(optional)
3. Use localhost:8087 to config Jenkins.

### CI/CD Frontend
4. Set automatic Nodejs installations in the global tool configuration.
5. Config New Job.
Choose “创建一个自由风格的软件项目” -> Config Github URL -> Config Build Trigger(SCM) -> Config Build Environment(Provide Node & npm bin/ folder to PATH) -> Config Build(execute shell: npm install; npm run build)

### CI/CD backend
4. Set java_home in the global tool configuration.
/usr/lib/jvm/java-8-openjdk-amd64
5. Install Maven Integration Plugin in Jenkins.
6. Get into docker container and Download Maven, config maven's path in the global tool configuration.
``` docker exec -it <container-id> /bin/bash
    wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
    tar zxvf apache-maven-3.3.9-bin.tar.gz
```
7. Config New Job.
Choose “Create Maven Project” -> Config Github URL -> Config Build Trigger(SCM) -> Config Build(Goals and options: clean package)

## Prepare a web application build container images

Use Eat or Not as the example web application with react frontend, springboot backend and mysql database.

### Frontend
Use nginx to run react frontend.
1. Download nginx image 
``` docker pull nginx
```
2. Package frontend code
``` npm build
```
3. Create and edit **docker-compose.yml** to config docker-compose which automatically create and run container.
services:nginx:image configs the image to run.
services:nginx:port maps container's port to localhost port.
services:nginx:volumes: maps local's build folder to container's default static resource folder **/usr/share/nginx/html**.
4. Create and edit nginx.conf to support react-router.
5. Create and run contianer
``` docker-compose up -d
```

### Database
1. Download mysql image.(To avoid that cersion is not compatible, download the version which is same as the local one)
``` docker pull mysql:5.7
```
2. Run image
``` docker run -name mysqleatornot -e MYSQL_ROOT_PASSWORD=123456 -p 3306:3306 -d mysql:5.7
```
3. Get into container
``` docker exec -it mysqleatornot /bin/bash
```
4. Get into mysql
``` mysql -u root -p 123456
```
5. Config authorization for remote login
``` ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
    FLUSH PRIVILEGES;
```
6. Use MySQL Workbench to create schema and import data into the container

### Backend
1. Add maven's plugin **docker-maven-plugin** in pom.xml.
2. Use **maven package** to package the project => docker_spring_boot.jar (final name is configed in pom.xml).
3. Create and edit **Dockerfile**.
FROM: configs the image to run.
VOLUME: configs the mount path.
ADD: mounts the docker_spring_boot.jar as the app.jar in container.
ENTRYPOINT: configs the command line executed when running. 
4. Cd to the folder with **Dockerfile** and **docker_spring_boot.jar** then build the image.
``` docker build -t springboot/eatornot .
```
5. Run the image and link to the mysql container.
``` docker run -d -p 8080:8080 --link mysqleatornot:db springboot/eatornot
```
link maps mysqleatornot container's port to springboot/eatornot's and use db as alias in the container.
So changes the connection configuration in hibernate.cfg.xml(use the alias **db** instead of localhost):
``` <property name="connection.url">jdbc:mysql://db:3306/SummerProj?characterEncoding=UTF-8</property>
```

## Automatically build images after a PR

1. Install publish over SSH plugin in Jenkins
2. Get into docker container and generate public key and private key.
``` ssh-keygen
```
3. Copy public key(in /var/jenkins_home/.ssh/id_rsa.pub) into host's autherauthorized_keys.
4. Config Publish over SSH in Jenkins system settings, set **Path to key** as /var/jenkins_home/.ssh/id_rsa.
5. Add SSH Server.(I use my own pc as the SSH server.)
6. Run a private docker registry.
``` docker run -itd -p 5000:5000 -v <some_host_path>:/var/lib/registry --name registry registry:2.5
```

### Frontend
Add Post-build Actions: send build artifacts over SSH:
Transfer the **build** folder, **docker-compose.yml**, **nginx.conf** to a specific directory in the server.
Exec command：
``` cd <full remote directory path>
    /usr/local/bin/docker-compose down
    /usr/local/bin/docker-compose up -d
```

### Backend
Add Post-build Actions: send files or execute commands over SSH:
Transfer the jar package in target folder built by maven.
Exec command（docker.sh is the shell script in my remote server:
``` cd <full remote directory path>
    sh docker.sh $BUILD_NUMBER $GIT_COMMIT
```
The main content in docker.sh:
1. Stop and delete old container.
``` /usr/local/bin/docker stop $CONTAINER_NAME
    /usr/local/bin/docker rm $CONTAINER_NAME
    /usr/local/bin/docker rmi -f $IMAGE_ID
```
2. Build docker image by Dockerfile（Dockerfile can be in the server or sent by SSH).
``` /usr/local/bin/docker build --build-arg app=$JARNAME .  -t  $IMAGES_NAME:$BUILD_ID
```
3. Run container based on the built image.
``` /usr/local/bin/docker run -itd -p 8080:8080 --name $CONTAINER_NAME --link mysqleatornot:db $IMAGES_NAME:$BUILD_ID
```
4. Commit image to private docker registery.
``` /usr/local/bin/docker tag $IMAGES_NAME:$BUILD_ID <host_ip>:5000/$IMAGES_NAME:$BUILD_ID
    /usr/local/bin/docker push <host_ip>:5000/$IMAGES_NAME:$BUILD_ID
```






