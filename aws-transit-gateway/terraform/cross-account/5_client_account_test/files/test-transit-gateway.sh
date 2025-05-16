#!/bin/bash

set -e

usage() {
   echo "Usage: $0 redpanda_user_id redpanda_user_password"
}

if [ $# != 2 ]; then
   usage
   exit 1
fi

rp_user_id=$1
rp_user_password=$2

kafka_seed_url=${kafka_seed_url}
http_proxy_seed_url=${http_proxy_seed_url}
schema_registry_url=${schema_registry_url}
console_url=${console_url}

# The followings args are for mTLS tests if needed in the future.
kafka_cert=$3
kafka_key=$4

redpanda_proxy_cert=$5
redpanda_proxy_key=$6

schema_registry_cert=$7
schema_registry_key=$8

replication=3

bolds="\033[1m"
bolde="\033[0m"

test_rpk_produce_consume() {
   broker_url=$1
   index=`echo $broker_url | cut -d "-" -f 1`
   topic_name="tgw-topic-$$-$index"
   key="tgw-key-$$-$index"
   tls_crt=$2
   tls_key=$3
   auth_args="--user $rp_user_id --password $rp_user_password"
   if [ "$tls_crt" != "" ]; then
      auth_args="--tls-cert $tls_crt --tls-key $tls_key"
      test_kafka_cert_required
   fi
   echo ">>> `date`: auth args: $auth_args"
   echo ">>> `date`: Getting cluster info ......"
   rpk cluster info -v --tls-enabled $auth_args
   echo ">>> `date`: Creating topic $topic_name......"
   rpk topic create $topic_name -r $replication --tls-enabled $auth_args
   echo ">>> `date`: Producing message with $key to the topic $topic_name......"
   echo "message test $$" | rpk topic produce $topic_name -k "$key" --tls-enabled $auth_args
   echo ">>> `date`: Consuming message with $key from the topic $topic_name......"
   rpk topic consume $topic_name --tls-enabled -n 1 $auth_args
}

test_kafka_cert_required() {
   echo ">>> `date`: Testing Kafka API mTLS: certificate required......"
   set +e
   result=$(rpk cluster info -v --tls-enabled --user $rp_user_id --password $rp_user_password 2>&1)
   set -e
   cert_required=$(echo $result | grep "certificate required")
   [ "$cert_required" == "" ] && return 1
   echo -e "\n$bolds-- PASS --$bolde"
}

test_proxy_produce_consume() {
   export REDPANDA_BROKERS="$kafka_seed_url"
   proxy_url=$1
   topic_name="tgw-proxy-topic-$$"
   key="tgw-key-$$"
   tls_crt=$2
   tls_key=$3
   rpk_auth_args="--user $rp_user_id --password $rp_user_password"
   if [ "$tls_crt" != "" ]; then
      rpk_auth_args="--tls-cert $tls_crt --tls-key $tls_key"
      curl_tls_args="--cert $tls_crt --key $tls_key"
   fi
   echo ">>> `date`: Creating topic $topic_name......"
   rpk topic create $topic_name -r $replication --tls-enabled $rpk_auth_args
   echo ">>> `date`: Producing message with $key to the topic $topic_name......"
   curl -vv -u "$rp_user_id:$rp_user_password" $curl_tls_args -H "Content-Type: application/vnd.kafka.json.v2+json" --sslv2 --http2 -d '{"records":[{"value":"transit gateway proxy test"}]}' $proxy_url/$topic_name
   echo ">>> `date`: Consuming message with $key from the topic $topic_name......"
   curl -vv -u "$rp_user_id:$rp_user_password" $curl_tls_args -H "Accept: application/vnd.kafka.json.v2+json" --sslv2 --http2 "$proxy_url/$topic_name/partitions/0/records?offset=0&timeout=5000&max_bytes=100000"
}

test_proxy_mtls_cert_required() {
   proxy_url=$1
   echo ">>> `date`: Testing Redpanda proxy mTLS: certificate required......"
   set +e
   result=$(curl -sS -u "$rp_user_id:$rp_user_password" -H "Content-Type: application/vnd.kafka.json.v2+json" --sslv2 --http2 -d '{"records":[{"value":"transit gateway proxy test"}]}' $proxy_url/mtls 2>&1)
   set -e
   cert_required=$(echo $result | grep "certificate required")
   [ "$cert_required" == "" ] && return 1
   echo -e "\n$bolds-- PASS --$bolde"
}

findKafkaUrls() {
   tls_crt=$1
   tls_key=$2
   export REDPANDA_BROKERS="$kafka_seed_url"
   auth_args="--user $rp_user_id --password $rp_user_password"
   if [ "$tls_crt" != "" ]; then
      auth_args="--tls-cert $tls_crt --tls-key $tls_key"
   fi
   rpk cluster info -b --tls-enabled $auth_args | awk '/^[0-9]/ {print $2":"$3}'
}

# install rpk
/usr/local/bin/install-rpk.sh

kafka_broker_urls=$(findKafkaUrls $kafka_cert $kafka_key)

if [ -z "$"kafka_broker_urls ]; then
   echo ">>> $(date): Failed to get kafka broker urls"
   exit 1
fi

echo ">>> $(date): Kafka brokers discovered from seed: $kafka_broker_urls"

echo ">>> $(date): Testing Kafka API"
for broker_url in $kafka_broker_urls; do
   export REDPANDA_BROKERS="$broker_url"
   echo ">>> $(date): Testing Kafka API at $REDPANDA_BROKERS......"
   test_rpk_produce_consume $broker_url $kafka_cert $kafka_key
   echo -e "\n$bolds-- PASS --$bolde"
done

echo ">>> $(date): Testing Redpanda Proxy API at $http_proxy_seed_url......"
test_proxy_produce_consume $http_proxy_seed_url $redpanda_proxy_cert $redpanda_proxy_key
echo -e "\n$bolds-- PASS --$bolde"

echo ">>> `date`: Testing Schema Registry API at $schema_registry_url......"
if [ "$schema_registry_cert" != "" ]; then
   echo ">>> `date`: Testing Schema Registry mTLS: certificate required......"
   set +e
   result=$(curl -sS -u "$rp_user_id:$rp_user_password" -H "Content-Type: application/vnd.schemaregistry.v1+json" --sslv2 --http2 $schema_registry_url/subjects 2>&1)
   set -e
   echo $result | grep "certificate required"
   echo -e "\n$bolds-- PASS --$bolde"
   tls_args="--cert $schema_registry_cert --key $schema_registry_key"
fi

curl -vv -u "$rp_user_id:$rp_user_password" $tls_args -H "Content-Type: application/vnd.schemaregistry.v1+json" -d '{"schema": "{\"type\": \"string\"}" }' $schema_registry_url/subjects/tgw-$$-value/versions
curl -vv -u "$rp_user_id:$rp_user_password" $tls_args -H "Content-Type: application/vnd.schemaregistry.v1+json" --sslv2 --http2 $schema_registry_url/schemas/ids/1
curl -vv -u "$rp_user_id:$rp_user_password" $tls_args -H "Content-Type: application/vnd.schemaregistry.v1+json" --sslv2 --http2 $schema_registry_url/subjects
echo -e "\n$bolds-- PASS --$bolde"

if [ "$console_url" != "" ]; then
   echo ">>> `date`: Testing Console connection at $console_url......"
   curl -vv --connect-timeout 15  -w "%%{http_code}" $console_url
   http_status=$(curl -s -o /dev/null --connect-timeout 15  -w "%%{http_code}" $console_url)
   if [ $http_status = 200 ]; then
      echo -e "\n$bolds-- PASS --$bolde"
   else
      echo -e "\n$bolds-- FAIL: Expect 200 OK, got $http_status --$bolde"
      exit 1
   fi
fi

echo -e "\n$bolds-- SUCCESS --$bolde"

