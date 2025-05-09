

# Generate TF inputs stored in aws.auto.tfvars.json
./scripts/generate_tf_var_input.sh d0dmca0c4e8sqqgqbr20 > aws.auto.tfvars.json

Sample content in aws.auto.tfvars.json
```
{
  "rp_id": "d0dmca0c4e8sqqgqbr20",
  "rp_kafka_seed_url": "seed-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.product.cloud.redpanda.com:9092",
  "rp_http_proxy_seed_url": "https://pandaproxy-c9b46fc1.d0dmca0c4e8sqqgqbr20.byoc.product.cloud.redpanda.com:30082",
  "rp_schema_registry_url": "https://schema-registry-56a88df9.d0dmca0c4e8sqqgqbr20.byoc.product.cloud.redpanda.com:30081",
  "rp_console_url": "https://console-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.product.cloud.redpanda.com",
  "region": "us-west-2"
}
```


