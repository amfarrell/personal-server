{% from 'git.sls' import base_path %}
{% from 'git.sls' import blog_path %}


install-virtualenv:
  pkg.installed:
  - name: python-virtualenv


{% set blog_venv_path= base_path+'/venv' %}
create-virtualenv-blog:
  virtualenv.managed:
  - name: {{ blog_venv_path }}
  - python: /usr/bin/python3.5
  - require:
    - pkg: install-virtualenv
    - sls: db
    - sls: py35

install-blog-reqs:
  pip.installed:
    - requirements: '{{ blog_path }}/requirements.txt'
    - cwd: {{ base_path }}
    - bin_env: {{ blog_venv_path }}/bin/pip
    - upgrade: True
    - require:
      - virtualenv: create-virtualenv-blog

{% for app_name, data in pillar['django_apps'].items() %}
{% set venv_path=base_path+'/'+app_name+'_venv' %}

create-virtualenv-{{ app_name }}:
  virtualenv.managed:
  - name: {{ venv_path }}
  - python: /usr/bin/python3.5
  - require:
    - pkg: install-virtualenv
    - sls: db
    - sls: py35

install-gunicorn-{{ app_name }}:
  pip.installed:
    - name: gunicorn
    - cwd: {{ base_path }}
    - bin_env: {{ venv_path }}/bin/pip
    - upgrade: True
    - require:
      - virtualenv: create-virtualenv-{{ app_name }}

install-psycopg2-{{ app_name }}:
  pip.installed:
    - name: psycopg2
    - cwd: {{ base_path }}
    - bin_env: {{ venv_path }}/bin/pip
    - upgrade: True
    - require:
      - virtualenv: create-virtualenv-{{ app_name }}

install-reqs-{{ app_name }}:
  pip.installed:
    - requirements: '{{ base_path }}/{{ app_name }}/requirements.txt'
    - cwd: {{ base_path }}
    - bin_env: {{ venv_path }}/bin/pip
    - upgrade: True
    - require:
      - virtualenv: create-virtualenv-{{ app_name }}
{% endfor %}
