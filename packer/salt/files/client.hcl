datacenter = "dc1"
data_dir = "/etc/nomad.d"

client {
  enabled = true
  server_join {
    retry_join = ["provider=gce tag_value=consul-join"]
    retry_interval = "15s"
  }
}

