consul_files:
  file.managed:
    - makedirs: True
    - names:
      - /etc/consul.d/{{ saltenv }}.json:
        - source: salt://files/{{ saltenv }}.json
      - /scripts/consul.sh:
        - source: salt://files/consul.sh

# Download
curl -o consul.zip https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip:
  cmd.run:
    - creates: /usr/bin/consul

# Place in bin directory
unzip consul.zip:
  cmd.run:
    - creates: /usr/bin/consul

sudo mv consul /usr/bin:
  cmd.run: 
    - creates: /usr/bin/consul

rm -rf consul.zip:
  cmd.run:
    - creates: /usr/bin/consul