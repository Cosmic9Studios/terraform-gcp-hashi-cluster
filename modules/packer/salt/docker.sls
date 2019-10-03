
python2-pip: 
  pkg.installed 

yum-utils:
  pkg.installed

device-mapper-persistent-data:
  pkg.installed

lvm2:
  pkg.installed

download_repo:
  cmd.run: 
    - name: sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

docker: 
  pip.installed:
    - require:
        - pkg: python2-pip

docker-ce:
  pkg.installed

docker_services:
  service.running:  
    - name: docker
    - enable: True
    - init_delay: 20
    - require:
      - pkg: docker-ce