#!/bin/bash

cluster_id=$1

if [ $# -ne 1 ]; then
   echo "Error: Usage: $0 <redpanda-id>"
   exit 1
fi

if [ "$CLOUD_CLIENT_ID" = "" -o "$CLOUD_CLIENT_SECRET" = "" ]; then
   echo "Error: Missing the env variables CLOUD_CLIENT_ID and CLOUD_CLIENT_SECRET"
   exit 2
fi

PUBLIC_API_ENDPOINT=${PUBLIC_API_ENDPOINT:-"https://api.redpanda.com"}
PUBLIC_API_AUTH_ENDPOINT=${PUBLIC_API_AUTH_ENDPOINT:-"https://auth.prd.cloud.redpanda.com"}
PUBLIC_API_AUTH_AUDIENCE=${PUBLIC_API_AUTH_AUDIENCE:-"cloudv2-production.redpanda.cloud"}

token=`curl -s --request POST \
         --url $PUBLIC_API_AUTH_ENDPOINT/oauth/token \
         --header 'content-type: application/x-www-form-urlencoded' \
         --data grant_type=client_credentials \
         --data client_id=$CLOUD_CLIENT_ID \
         --data client_secret=$CLOUD_CLIENT_SECRET \
         --data audience=$PUBLIC_API_AUTH_AUDIENCE | jq .access_token | sed 's/"//g'`

get_cluster_response=`curl -s -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d "$cluster_post_body" $PUBLIC_API_ENDPOINT/v1/clusters/$cluster_id`

kafka_seed_url=`echo $get_cluster_response | jq .cluster.kafka_api.seed_brokers[0]`
http_proxy_seed_url=`echo $get_cluster_response | jq .cluster.http_proxy.url`
schema_registry_url=`echo $get_cluster_response | jq .cluster.schema_registry.url`
console_url=`echo $get_cluster_response | jq .cluster.redpanda_console.url`
region=`echo $get_cluster_response | jq .cluster.region`

echo "
{
  \"rp_id\": \"$cluster_id\",
  \"rp_kafka_seed_url\": $kafka_seed_url,
  \"rp_http_proxy_seed_url\": $http_proxy_seed_url,
  \"rp_schema_registry_url\": $schema_registry_url,
  \"rp_console_url\": $console_url,
  \"region\": $region
}"

