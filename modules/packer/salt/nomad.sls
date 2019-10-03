
nomad_files:
  file.managed:
    - makedirs: True
    - names:
      - /etc/nomad.d/{{ saltenv }}.hcl:
        - source: salt://files/{{ saltenv }}.hcl
      - /files/fabio.nomad:
        - source: salt://files/fabio.nomad
      - /scripts/nomad.sh:
        - source: salt://files/nomad.sh

# Download 
curl -o nomad.zip https://releases.hashicorp.com/nomad/0.9.5/nomad_0.9.5_linux_amd64.zip: 
  cmd.run:
    - creates: /usr/bin/nomad

# Place in bin directory
unzip nomad.zip:
  cmd.run: 
    - creates: /usr/bin/nomad

sudo mv nomad /usr/bin:
  cmd.run: 
    - creates: /usr/bin/nomad

rm -rf nomad.zip:
  cmd.run: 
    - creates: /usr/bin/nomad