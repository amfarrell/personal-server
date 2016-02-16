{% from 'db.sls' import database, pg_user %}
{% from 'git.sls' import base_path %}
{% from 'venv.sls' import venv_path %}

{% if grains['virtual'] == 'VirtualBox' %}
  {% set gunicorn_user='vagrant' %}
{% else %}
  {% set gunicorn_user='ubuntu' %}
{% endif %}

#TODO: use socket

create-user:
  user.present:
    - name: {{ gunicorn_user }}
    - gid_from_name: True
    - home: /home/{{ gunicorn_user }}
    - createhome: True

{% for app_name, data in pillar['django_apps'].items() %}
{% set static_app_path=base_path+'/static_'+app_name %}
{% set app_path=base_path+'/'+app_name %}
{% if data.get('project_path', False) %}
  {% set app_path=app_path+'/'+data.get('project_path') %}
{% endif %}
{% set venv_path=base_path+'/'+app_name+'_venv' %}
{% set db_url="postgres://{}:{}@localhost:5432/{}".format(pg_user, pillar['database-password'], app_name) %}
{% set manage_wrapper_path=base_path+'/manage_'+app_name %}
{# This is repeated. TODO: DRY #}


gunicorn-upstart-file-{{ app_name }}:
  file.managed:
    - name: /etc/init/{{ app_name }}.conf
    - source: salt://gunicorn.conf
    - user: root
    - group: root
    - mode: '744'
    - template: jinja
    - context:
      settings_module: {{ data['settings_module'] }}
      static_app_path: {{ static_app_path }}
      static_url: /static_{{ app_name }}/
      env_vars: {{ data['env_vars'] }}
      app_port: {{ data['app_port'] }}
      app_path: {{ app_path }}
      app_name: {{ app_name }}
      venv_path: {{ venv_path }}
      db_url: {{ db_url }}
      gunicorn_user: {{ gunicorn_user }}

gunicorn-running-{{ app_name }}:
  service.running:
  - name: {{ app_name }}
  - watch:
    - file: gunicorn-upstart-file-{{ app_name }}
  - require:
    - file: gunicorn-upstart-file-{{ app_name }}
    - pip: install-gunicorn-{{ app_name }}

static-dir-{{ app_name }}:
  file.directory:
  - name: '{{ static_app_path }}'
  - user: '{{ gunicorn_user }}'
  - group: '{{ gunicorn_user }}'
  - clean: True
  - force: True
  - dir_mode: 755

manage-wrapper-{{ app_name }}:
  file.managed:
    - name: {{ manage_wrapper_path }}
    - source: salt://manage-wrapper
    - user: {{ gunicorn_user }}
    - group: {{ gunicorn_user }}
    - mode: '755'
    - template: jinja
    - require:
      - virtualenv: create-virtualenv-{{ app_name }}
      - sls: db
    - context:
      manage_path: {{ data.get('manage_path', 'manage.py') }}
      settings_module: {{ data['settings_module'] }}
      env_vars: {{ data['env_vars'] }}
      app_path: {{ app_path }}
      static_app_path: {{ static_app_path }}
      static_url: /static_{{ app_name }}/
      venv_path: {{ venv_path }}
      db_url: {{ db_url }}

runserver-file-{{ app_name }}:
  file.managed:
    - name: {{ base_path }}/runserver_{{ app_name }}
    - source: salt://runserver
    - user: {{ gunicorn_user }}
    - group: {{ gunicorn_user }}
    - mode: '755'
    - template: jinja
    - context:
      manage_wrapper_path : {{ manage_wrapper_path }}
      app_port: {{ data['app_port'] }}

collectstatic-{{ app_name }}:
  cmd.run:
  - name: '{{ manage_wrapper_path }} collectstatic --noinput --verbosity 3'
  - cwd: {{ base_path }}
  - user: '{{ gunicorn_user }}'
  - require:
    - virtualenv: create-virtualenv-{{ app_name }}
    - file: static-dir-{{ app_name }}

migrate-{{ app_name }}:
  cmd.run:
  - name: '{{ venv_path }}/bin/python3.5 {{ app_path }}/manage.py migrate --verbosity 3'
  - name: '{{ manage_wrapper_path }} migrate --verbosity 3'
  - cwd: {{ base_path }}
  - user: '{{ gunicorn_user }}'
  - require:
    - pip: install-psycopg2-{{ app_name }}
    - sls: db

{% if 'restcomments'==app_name %}
{% set email_fequency='31' %}
email-comments:
  cron.present:
  - name: "{{ manage_wrapper_path }} send_mail {{ email_fequency }}"
  - minute: "0,30"
  - user: {{ gunicorn_user }}
  - require:
    - file: manage-wrapper-{{ app_name }}

cron-running:
  service.running:
  - name: cron
  - watch:
    - cron: email-comments
  - require:
    - cron: email-comments
{% endif %}
{% endfor %}
