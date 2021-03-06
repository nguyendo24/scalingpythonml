#!/bin/bash
set -eux
#tag::dlspark[]
if [ ! -f spark-3.0.1-bin-hadoop3.2.tgz ]; then
  axel https://ftp.wayne.edu/apache/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz
fi
if [ ! -d spark-3.0.1-bin-hadoop3.2 ]; then
  tar -xvf spark-3.0.1-bin-hadoop3.2.tgz
fi
#end::dlspark[]
cp ./notebook/* ./spark-3.0.1-bin-hadoop3.2
cp ./python-executor/Dockerfile ./spark-3.0.1-bin-hadoop3.2/PyDockerfile
# Fixed to do buildx push
cp ./docker-image-*.sh ./spark-3.0.1-bin-hadoop3.2/bin/
#tag::build_exec_containers[]
# Copy over python setup script so we can have matching pythons
cp pysetup.sh ./spark-3.0.1-bin-hadoop3.2/bin/
pushd spark-3.0.1-bin-hadoop3.2
SPARK_HOME=`pwd`
SPARK_ROOT="$SPARK_HOME"
./bin/docker-image-tool.sh  -r holdenk -t v3.0.1.2 -X -b java_image_tag=11-jre-slim -p PyDockerfile Dockerfile build
#end::build_exec_containers[]
#tag::build-notebook[]
docker buildx build -t holdenk/spark-notebook:v3.0.1.2  --platform linux/arm64,linux/amd64 --push .
#end::build-notebook[]
popd
