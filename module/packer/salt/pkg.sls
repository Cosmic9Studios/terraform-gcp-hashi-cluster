npm:
  pkg.installed

unzip: 
  pkg.latest

pm2:
  npm.installed:
    - require:
      - pkg: npm

