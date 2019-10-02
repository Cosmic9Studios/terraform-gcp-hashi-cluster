sudo pm2 start /scripts/nomad.sh --wait-ready --listen-timeout 15000
sudo pm2 start /scripts/consul.sh --wait-ready --listen-timeout 15000
sudo nomad run /files/fabio.nomad