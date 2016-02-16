{% from 'git.sls' import base_path %}
{% from 'git.sls' import blog_path %}

{% set fullchain_path = '/etc/letsencrypt/live/' + pillar['domain'] + '/fullchain.pem' %}
{% set key_path = '/etc/letsencrypt/live/' + pillar['domain'] + '/privkey.pem' %}
{% set chain_path = '/etc/letsencrypt/live/' + pillar['domain'] + '/chain.pem' %}
{% set cert_path = '/etc/letsencrypt/live/' + pillar['domain'] + '/cert.pem' %}
{% set dhparam_path = '/etc/nginx/dhparam.pem' %}

nginx-install:
  pkg.installed:
  - name: nginx

nginx-forwarding:
  file.managed:
  - name: /etc/nginx/sites-enabled/default
  - source: salt://nginx.conf
  - template: jinja
  - context:
    domain: {{ pillar['domain'] }}
    blog_dir: {{ blog_path }}
    base_path: {{ base_path }}
    fullchain_path: {{ fullchain_path }}
    key_path: {{ key_path }}
    chain_path: {{ chain_path }}
    cert_path: {{ cert_path }}
    dhparam_path: {{ dhparam_path }}
  #TODO: move to /etc/nginx/conf.d/ so that multiple sites can exist.

nginx-running:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: nginx-forwarding

ssl-fullchain:
  file.managed:
  - name: {{ fullchain_path }}
  - source: salt://letsencrypt/fullchain1.pem
  - makedirs: True

ssl-key:
  file.managed:
  - name: {{ key_path }}
  - source: salt://letsencrypt/privkey1.pem
  - makedirs: True

ssl-chain:
  file.managed:
  - name: {{ chain_path }}
  - source: salt://letsencrypt/chain1.pem
  - makedirs: True

ssl-cert:
  file.managed:
  - name: {{ cert_path }}
  - source: salt://letsencrypt/cert1.pem
  - makedirs: True

dhparam:
  file.managed:
  - name: {{ dhparam_path }}
  - source: salt://letsencrypt/dhparam.pem
  - makedirs: True
