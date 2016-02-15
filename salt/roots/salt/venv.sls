{% from 'git.sls' import base_path %}
{% from 'git.sls' import app_path %}
{% from 'git.sls' import blog_path %}

{% set venv_path= base_path+'/venv' %}

install-virtualenv:
  pkg.installed:
  - name: python-virtualenv

create-virtualenv:
  virtualenv.managed:
  - name: {{ venv_path }}
  - python: /usr/bin/python3.5
  - require:
    - pkg: install-virtualenv
    - sls: db
    - sls: py35

install-django-reqs:
  pip.installed:
    - requirements: '{{ app_path }}/requirements.txt'
    - cwd: {{ base_path }}
    - bin_env: {{ venv_path }}/bin/pip
    - upgrade: True
    - require:
      - virtualenv: create-virtualenv

install-blog-reqs:
  pip.installed:
    - requirements: '{{ blog_path }}/requirements.txt'
    - cwd: {{ base_path }}
    - bin_env: {{ venv_path }}/bin/pip
    - upgrade: True
    - require:
      - virtualenv: create-virtualenv
