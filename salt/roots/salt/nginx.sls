{% from 'git.sls' import base_path %}
{% from 'git.sls' import blog_path %}

{% from 'certs.sls' import fullchain_path %}
{% from 'certs.sls' import key_path %}
{% from 'certs.sls' import chain_path %}
{% from 'certs.sls' import cert_path %}
{% from 'certs.sls' import dhparam_path %}

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
