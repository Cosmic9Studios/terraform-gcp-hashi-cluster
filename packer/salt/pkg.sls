npm:
  pkg.installed

unzip: 
  pkg.latest

pm2@3.5.1:
  npm.installed:
    - require:
      - pkg: npm

