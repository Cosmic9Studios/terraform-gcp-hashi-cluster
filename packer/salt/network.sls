net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

sudo systemctl restart network:
  cmd.run