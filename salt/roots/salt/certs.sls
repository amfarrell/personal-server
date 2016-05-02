{% set fullchain_path = '/etc/letsencrypt/live/' + pillar['domain'] + '/fullchain.pem' %}
{% set key_path = '/etc/letsencrypt/live/' + pillar['domain'] + '/privkey.pem' %}
{% set chain_path = '/etc/letsencrypt/live/' + pillar['domain'] + '/chain.pem' %}
{% set cert_path = '/etc/letsencrypt/live/' + pillar['domain'] + '/cert.pem' %}
{% set dhparam_path = '/etc/nginx/dhparam.pem' %}
{% from 'git.sls' import base_path %}
{% from 'git.sls' import blog_path %}

{% set letsencrypt_path = base_path + '/letsencrypt' %}


letsencrypt-install:
  git.latest:
    - name: 'https://github.com/letsencrypt/letsencrypt'
    - target: {{ letsencrypt_path }}
    - require:
      - sls: git

remove-oldcerts1:
  file.absent:
    - name: '/etc/letsencrypt/live/{{ pillar['domain'] }}'
    - require:
      - git: letsencrypt-install

remove-oldcerts2:
  file.absent:
    - name: '/etc/letsencrypt/renewal/{{ pillar['domain'] }}.conf'
    - require:
      - git: letsencrypt-install

letsencrypt-getcerts:
  cmd.run:
    - name: '{{ letsencrypt_path }}/letsencrypt-auto certonly --webroot -w {{ blog_path }}/site -d {{ pillar['domain'] }} -d www.{{ pillar['domain'] }}'
    - require:
      - file: remove-oldcerts1
      - file: remove-oldcerts2
