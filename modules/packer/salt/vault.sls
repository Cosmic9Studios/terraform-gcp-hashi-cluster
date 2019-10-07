vault_files:
  file.managed:
    - makedirs: True
    - names:
      - /etc/vault.d/vault.hcl:
        - source: salt://files/vault.hcl
      - /scripts/vault.sh:
        - source: salt://files/vault.sh

# Download
curl -o vault.zip https://releases.hashicorp.com/vault/1.2.3/vault_1.2.3_linux_amd64.zip:
  cmd.run:
    - creates: /usr/bin/vault

# Place in bin directory
unzip vault.zip:
  cmd.run:
    - creates: /usr/bin/vault

sudo mv vault /usr/bin:
  cmd.run: 
    - creates: /usr/bin/vault

rm -rf vault.zip:
  cmd.run:
    - creates: /usr/bin/vault
  
sudo setcap cap_ipc_lock=+ep /usr/bin/vault:
  cmd.run
