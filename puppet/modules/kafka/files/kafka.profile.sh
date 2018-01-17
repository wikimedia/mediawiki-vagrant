# NOTE: This file is managed by puppet.

# These environment variables are used by the kafka CLI
# so that you don't have to provide them as arguments
# every time you use it.
export KAFKA_ZOOKEEPER_URL=localhost:2181/kafka
export KAFKA_BOOTSTRAP_SERVERS=localhost:9092
export KAFKA_JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
