# Open Liberty Containerizing Microservices

## 0. Content

Sure! Here's an index for the README.md:

1. [Introduction](#1-introduction)
   - 1.1 [What you'll learn](#11-what-youll-learn)
     - 1.1.1 [Service Containerization from development to production](#111-service-containerization-from-development-to-production)
     - 1.1.2 [Communication between services](#112-communication-between-services)
   - 1.2 [Prerequisites](#12-prerequisites)
   - 1.3 [Repository Structure](#13-repository-structure)
   - 1.4 [system service at high level](#14-system-service-at-high-level)
   - 1.5 [inventory service at high level](#15-inventory-service-at-high-level)
2. [Build & Run Liberty Services with Maven](#2-build--run-liberty-services-with-maven)
   - 2.1 [Test the running services](#21-test-the-running-services)
3. [Build & Run Liberty Services with Docker](#3-build--run-liberty-services-with-docker)
   - 3.1 [Defining Dockerfiles](#31-defining-dockerfiles)
     - 3.1.1 [What is Dockerfile?](#311-what-is-dockerfile)
     - 3.1.2 [Liberty base image used](#312-liberty-base-image-used)
   - 3.2 [Building services images](#32-building-services-images)
     - 3.2.1 [Maven package](#321-maven-package)
     - 3.2.2 [Dockerfiles](#322-dockerfiles)
   - 3.3 [Running your microservices in Docker containers](#33-running-your-microservices-in-docker-containers)
   - 3.4 [Checking docker running services](#34-checking-docker-running-services)
4. [Externalising server configuration](#4-externalising-server-configuration)

Please note that the last section is marked as "TODO" and requires further information. You can replace the "TODO" with the relevant content once it's available.

## 1. Introduction

### 1.1 What you'll learn

#### 1.1.1 Service Containerization from development to production

From development to production, and across your DevOps environments, you can deploy your microservices in a lightweight and portable manner by using containers. You can run a container from a container image. Each container image is a package of what you need to run your microservice or application, from the code to its dependencies and configuration.

You’ll learn how to build container images and run containers using Docker for your microservices. You’ll learn about the Open Liberty container images and how to use them for your containerized applications. You’ll construct `Dockerfile` files, create and run Docker images. 

#### 1.1.2 Communication between services

Comunication between services: The two microservices that you’ll be working with are called system and inventory. The system microservice returns the JVM system properties of the running container. The inventory microservice adds the properties from the system microservice to the inventory. This guide demonstrates how both microservices can run and communicate with each other in different Docker containers.

### 1.2 Prerequisites

- [x] Have linux environment --> In my cas wsl [How to install wsl](https://www.omgubuntu.co.uk/how-to-install-wsl2-on-windows-10)
- [x] Have mvn installed --> [How to install mvn in wsl](https://kontext.tech/article/630/install-maven-on-wsl)
- [x] Have Docker installed --> [How to install docker desktop in WSL](https://docs.docker.com/desktop/windows/wsl/)

### 1.3 Repository Structure

```
├── mvn_ready/ --> multi-module liberty mvn project ready to build and run with mvn
|    ├── inventory/ --> inventory microservice ready to build with liberty mvn
|    |    ├── src/main/ --> microservice code
|    |    |      ├── java/ --> app code
|    |    |      ├── liberty/config/ --> server.xml server cinfiguration
|    |    |      └── webapp/ --> web configuration template
|    |    ├── target/ --> compiled directory
|    |    └── pom.xml --> mvn file to compile the microservice
|    ├── system/main/ --> inventory microservice ready to build with liberty mvn
|    └── pom.xml --> pom.xml to compile both apps
├── docker_ready/ --> liberty apps ready to build and run with Docker
|    ├── inventory/
|    ├── system/
|    └── pom.xml
├── scripts/ --> unit testing for build and deploy steps 
├── README.md
└── ...
```

### 1.4 system service ay high level

Little java app which shows one time the system properties of the running JVM in `json` format.

- At port 9080 (managed by pom.xml and server.xml)
- At path: /system/properties (managed by jakarta.ws)

```
{"awt.toolkit":"sun.awt.X11.XToolkit","java.specification.version":"11","com.ibm.ws.beta.edition":"false","sun.jnu.encoding":"UTF-8","wlp.install.dir":"/opt/ol/wlp/","wlp.workarea.dir":"workarea/","sun.arch.data.model":"64","com.ibm.vm.bitmode":"64","java.vendor.url":"https://www.ibm.com/semeru-runtimes","server.output.dir":"/opt/ol/wlp/output/defaultServer/","sun.boot.library.path":"/opt/java/openjdk/lib/default:/opt/java/openjdk/lib",
...}
```

### 1.5 inventory service ay high level

More complex java app, based on MVC (Model-View-Controller) which serves an inventory of requests and creates this requests acceding to an end-point of the same server.

- At port 9081 (managed by pom.xml and server.xml)
- At path: /inventory/systems (managed by jakarta.ws)
    --> Returns the requests made
- At path: /inventory/systems/<system-ip-address> (managed by jakarta.ws)
    --> Add the <system-ip-address> request to inventory

To learn more about RESTful web services and how to build them, see [Restful Service with Open Liberty](https://openliberty.io/guides/rest-intro.html) for details about how to build the `system` service. The `inventory` service is built in a similar way.

## 2. Build & Run Liberty Services with Maven

Navigate to the `mvn_ready` directory to begin.

You can find the starting Java project in the mvn_ready directory. This project is a multi-module Maven project that is made up of the system and inventory microservices. Each microservice is located in its own corresponding directory, system and inventory.

To try out the microservices by using Maven, run the following Maven goal to build the system microservice and run it inside Open Liberty:

```bash
cd mvn_ready
```

```bash
mvn -pl system liberty:run
```

To try out the microservices by using Maven, open another command-line session and run the following Maven goal to build the inventory microservice and run it inside Open Liberty:

```bash
cd mvn_ready
```

```bash
mvn -pl inventory liberty:run
```

> After you see the following message in both command-line sessions, both of your services are ready:
>
>```
>The defaultServer server is ready to run a smarter planet.
>```

### 2.1 Test the running services

Now 2 liberty services are running on different ports on your localhost:

| Service | Port | Definition |
| ------------- | ------------- | ------------- |
| system  | 9080  | [mvn_ready/system/pom.xml](mvn_ready/system/pom.xml) & [mvn_ready/system/src/main/liberty/config/server.xml](mvn_ready/system/src/main/liberty/config/server.xml)  |
| inventory  | 9081  | [mvn_ready/inventory/pom.xml](mvn_ready/inventory/pom.xml) & [mvn_ready/inventory/src/main/liberty/config/server.xml](mvn_ready/inventory/src/main/liberty/config/server.xml)  |

* To acces main page of `system` see or curl http://localhost:9080

* To access the `system` service, which shows the system properties of the running JVM, see http://localhost:9080/system/properties
```bash
curl http://localhost:9080/system/properties
```

* To acces main page of `inventory` see or curl http://localhost:9081

* To access the `inventory` service, which displays the current contents of the inventory, see http://localhost:9081/inventory/systems

```bash
curl http://localhost:9081/inventory/systems
```

* You can add the system properties of your localhost to the `inventory` service at http://localhost:9081/inventory/systems/localhost

```bash
curl http://localhost:9081/inventory/systems/localhost
```

After you are finished checking out the microservices, stop the Open Liberty servers by pressing `CTRL+C` in the command-line sessions where you ran the servers. Alternatively, you can run the `liberty:stop` goal in another command-line session:

```
mvn -pl system liberty:stop
mvn -pl inventory liberty:stop
```

## 3. Build & Run Liberty Services with Docker

### 3.1 Defining Dockerfiles

#### 3.1.1 What is Dockerfile?

A Docker image is a binary file. It is made up of multiple layers and is used to run code in a Docker container. Images are built from instructions in `Dockerfile` to create a containerized version of the application.

Every `Dockerfile` begins with a parent or base image over which various commands are run. For example, you can start your image from scratch and run commands that download and install a Java runtime, or you can start from an image that already contains a Java installation.

Learn more about Docker on the [Official Docker page](https://www.docker.com/what-docker)

You will be creating two Docker images to run the inventory service and system service. The first step is to create Dockerfiles for both services.

#### 3.1.2 Liberty base image used

In this guide, you’re using an official image from the IBM Container Registry (ICR), `icr.io/appcafe/open-liberty:full-java11-openj9-ubi`, as your parent image. This image is tagged with the word full, meaning it includes all Liberty features. full images are recommended for development only because they significantly expand the image size with features that are not required by the application.

>:mega: **NOTA:**
>
>To minimize your image footprint in production, you can use one of the kernel-slim images, such as `icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi`. This image installs the basic server. You can then add all the necessary features for your application with the usage pattern that is detailed in the Open Liberty container image documentation. To use the default image that comes with the Open Liberty runtime, define the `FROM` instruction as `FROM icr.io/appcafe/open-liberty`. You can find all official images on the [Open Liberty container image repository](https://openliberty.io/docs/latest/container-images.html).

### 3.2 Building services images

### 3.2.1 Maven package

To build and run liberty services in docker, compiled java artifacts are needed (`JAR`, `WAR`, `EAR`). In order to have one of them, we need to use `mvn package`.

To package your microservices, run the Maven package goal to build the application .war files from the `mvn_ready` directory so that the .war files are in the system/target and inventory/target directories. This is needed to run them with Docker.

```
mvn package
```

>:mega: **NOTA:**
>
> Executing `mvn package` from directory `docker_ready` it stores the `.war` files into `inventory/target` and `system/target`.

### 3.2.2 Dockerfiles

Autoexplained with comments [docker_ready/inventory/Dockerfile](docker_ready/inventory/Dockerfile).

Autoexplained with comments [docker_ready/system/Dockerfile](docker_ready/inventory/Dockerfile).

Now that your microservices are packaged and you have written your Dockerfiles, you will build your Docker images by using the `docker build` command.

```bash
docker build -t system:1.0-SNAPSHOT system/.
```

```bash
docker build -t inventory:1.0-SNAPSHOT inventory/.
```

To verify that the images are built, run the docker images command to list all local Docker images:

```bash
docker images -f "label=org.opencontainers.image.authors=Your Name"
```

```
REPOSITORY    TAG             IMAGE ID        CREATED          SIZE
inventory     1.0-SNAPSHOT    08fef024e986    4 minutes ago    1GB
system        1.0-SNAPSHOT    1dff6d0b4f31    5 minutes ago    977MB
```

### 3.3 Running your microservices in Docker containers

Now that your two images are built, you will run your microservices in Docker containers:

``` bash
docker run -d --name system -p 9080:9080 system:1.0-SNAPSHOT
```

``` bash
docker run -d --name inventory -p 9081:9081 inventory:1.0-SNAPSHOT
```

Next, run the `docker ps` command to verify that your containers are started:

```
docker ps
```

```
CONTAINER ID    IMAGE                   COMMAND                  CREATED          STATUS          PORTS                                        NAMES
2b584282e0f5    inventory:1.0-SNAPSHOT  "/opt/ol/helpers/run…"   2 seconds ago    Up 1 second     9080/tcp, 9443/tcp, 0.0.0.0:9081->9081/tcp   inventory
99a98313705f    system:1.0-SNAPSHOT     "/opt/ol/helpers/run…"   3 seconds ago    Up 2 seconds    0.0.0.0:9080->9080/tcp, 9443/tcp             system
```

If a problem occurs and your containers exit prematurely, the containers don't appear in the container list that the `docker ps` command displays. Instead, your containers appear with an `Exited` status when they run the `docker ps -a` command. Run the `docker logs system` and `docker logs inventory` commands to view the container logs for any potential problems. Run the `docker stats system` and `docker stats inventory` commands to display a live stream of usage statistics for your containers. You can also double-check that your Dockerfiles are correct. When you find the cause of the issues, remove the faulty containers with the `docker rm system` and `docker rm inventory` commands. Rebuild your images, and start the containers again.

### 3.4 Checking docker running services

Exactly the same as [2.1 Test the running services](#21-test-the-running-services). 

With the add. To access the `inventory` service, which displays the current contents of the server inventory, see http://localhost:9081/inventory/systems

```bash
curl http://localhost:9081/inventory/systems
```

> An empty list is expected because no system properties are stored in the inventory yet.

Next, retrieve the system container’s IP address by running the following:

```bash
docker inspect -f "{{.NetworkSettings.IPAddress }}" system
```

Expected output:

```
172.17.0.2
```

In this case, the IP address for the `system` service is `172.17.0.2`. Take note of this IP address to construct the URL to view the system properties. 

Go to the http://localhost:9081/inventory/systems/<system-ip-address> URL by replacing `<system-ip-address>` with the IP address that you obtained earlier. You see a result in JSON format with the system properties of your local JVM. When you go to this URL, these system properties are automatically stored in the inventory. Go back to the http://localhost:9081/inventory/systems) URL and you see a new entry for `[system-ip-address]`.

Once your Docker containers are running, run the following command to see the list of required features installed by features.sh:

```bash
docker exec -it inventory /opt/ol/wlp/bin/productInfo featureInfo
```

Your list of Liberty features should be similar to the following:

```
jndi-1.0
servlet-5.0
cdi-3.0
concurrent-2.0
jsonb-2.0
jsonp-2.0
mpConfig-3.0
restfulWS-3.0
restfulWSClient-3.0
```

## 4 Externalising server configuration

As mentioned at the beginning of this guide, one of the advantages of using containers is that they are portable and can be moved and deployed efficiently across all of your DevOps environments. Configuration often changes across different environments, and by externalizing your server configuration, you can simplify the development process.

Imagine a scenario where you are developing an Open Liberty application on port 9081 but to deploy it to production, it must be available on port 9091. To manage this scenario, you can keep two different versions of the server.xml file; one for production and one for development. However, trying to maintain two different versions of a file might lead to mistakes. A better solution would be to externalize the configuration of the port number and use the value of an environment variable that is stored in each environment.

Imagine a scenario where you are developing an Open Liberty application on port 9081 but to deploy it to production, it must be available on port 9091. To manage this scenario, you can keep two different versions of the server.xml file; one for production and one for development. However, trying to maintain two different versions of a file might lead to mistakes. A better solution would be to externalize the configuration of the port number and use the value of an environment variable that is stored in each environment.

### 4.1 External configuration of the HTTP port number of the inventory service

In the [inventory/.../server.xml](docker_ready/inventory/src/main/liberty/config/server.xml) file, the default.http.port variable is declared and is used in the httpEndpoint element to define the service endpoint. The default value of the default.http.port variable is 9081. However, this value is only used if no other value is specified. You can replace this value in the container by using the `-e` flag for the `docker run command`.

Run the following commands to stop and remove the inventory container and rerun it with the default.http.port environment variable set:
```bash
docker stop inventory
```

```bash
docker rm inventory
```

```bash
docker run -d --name inventory -e default.http.port=9091 -p 9091:9091 inventory:1.0-SNAPSHOT
```

The -e flag can be used to create and set the values of environment variables in a Docker container. In this case, you are setting the default.http.port environment variable to 9091 for the inventory container.

Now, when the service is starting up, Open Liberty finds the default.http.port environment variable and uses it to set the value of the default.http.port variable to be used in the HTTP endpoint.

### 4.2 Test the changed port

The inventory service is now available on the new port number that you specified. You can see the contents of the inventory at the http://localhost:9091/inventory/systems URL. 

You can externalize the configuration of more than just the port numbers. To learn more about [Open Liberty server configuration](https://openliberty.io/docs/latest/reference/config/server-configuration-overview.html), check out the Server Configuration Overview docs.

## 5. Optimizing the image size

As mentioned previously, the base image that is used in each Dockerfile contains the kernel-slim tag which provides a bare minimum server with the ability to add the features required by the application, including all of the Liberty features. The full Open liberty server has the full tag, and this parent image is recommended for development, but while deploying to production it is recommended to use a slimmer image.

* Heavy Service Images:
    - [system/Dockerfile-full](docker_ready/system/Dockerfile-full)
    - [inventory/Dockerfile-full](docker_ready/inventory/Dockerfile-full)
* Slim Service Images:
    - [system/Dockerfile](docker_ready/system/Dockerfile)
    - [inventory/Dockerfile](docker_ready/inventory/Dockerfile)

## 6. Services Tests

You can test your microservices manually by hitting the endpoints or with automated tests included in the services development that check your running Docker containers.

* [system test](docker_ready/system/src/test/java/it/io/openliberty/guides/system/SystemEndpointIT.java)
* [inventory test](docker_ready/inventory/src/test/java/it/io/openliberty/guides/inventory/InventoryEndpointIT.java)

These tests use env vars configuration to check the correct function of the two services.

To run them:

```bash
mvn package
```

```bash
mvn failsafe:integration-test -Dsystem.ip=[system-ip-address] -Dinventory.http.port=9081 -Dsystem.http.port=9080
```

* **failsafe:** Run the Maven failsafe goal to test the services that are running in the Docker containers
* **-Dxxx:** env vars used to check the correct funcioning. Replace [system-ip-address] by your 

## 7. Include mvn package in Build Stage

We want to execute all build process in the build stage, following the Dockerfile instructions and avoiding the need for the development team to perform an mvn package. So, we have to include the order / orders in Dockerfile.

But, the parent liberty image, does not contains the binary mvn, so it is not possible to execute a mvn package

## TODO
- [x] Test all documented
- [ ] Externalizing more server configuration parameters, check [url](https://openliberty.io/docs/latest/reference/config/server-configuration-overview.html)
- [ ] execute mvn in one stage of Dockerfile
- [ ] Great work! You’re done!