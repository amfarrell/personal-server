{% from 'db.sls' import database, pg_user %}
{% from 'git.sls' import base_path %}
{% from 'git.sls' import app_path %}
{% from 'venv.sls' import venv_path %}

{% set manage_wrapper_path=app_path+'/manage-wrapper' %}
{% set app_port='8080' %}
{% set app_name='comments' %}
{% set app_static_path=app_path + '/static/' %}
{% if grains['virtual'] == 'VirtualBox' %}
  {% set gunicorn_user='vagrant' %}
{% else %}
  {% set gunicorn_user='ubuntu' %}
{% endif %}
{% set db_url="postgres://{}:{}@localhost:5432/{}".format(pg_user, pillar['database-password'], database) %}
{% set settings_module="{}.settings".format(app_name) %}

#TODO: use socket

create-user:
  user.present:
    - name: {{ gunicorn_user }}
    - gid_from_name: True
    - home: /home/{{ gunicorn_user }}
    - createhome: True

runserver-file:
  file.managed:
    - name: {{ base_path }}/runserver
    - source: salt://runserver
    - user: {{ gunicorn_user }}
    - group: {{ gunicorn_user }}
    - template: jinja
    - context:
      settings_module: {{ settings_module }}
      app_path: {{ app_path }}
      app_name: {{ app_name }}
      venv_path: {{ venv_path }}
      db_url: {{ db_url }}
      gunicorn_user: {{ gunicorn_user }}

gunicorn-upstart-file:
  file.managed:
    - name: /etc/init/{{ app_name }}.conf
    - source: salt://gunicorn.conf
    - user: root
    - group: root
    - mode: '744'
    - template: jinja
    - context:
      settings_module: {{ settings_module }}
      app_path: {{ app_path }}
      app_name: {{ app_name }}
      venv_path: {{ venv_path }}
      db_url: {{ db_url }}
      gunicorn_user: {{ gunicorn_user }}

gunicorn-running:
  service.running:
  - name: {{ app_name }}
  - watch:
    - file: gunicorn-upstart-file
  - require:
    - file: gunicorn-upstart-file
    - virtualenv: create-virtualenv

static-dir:
  file.directory:
  - name: '{{ app_static_path }}'
  - user: '{{ gunicorn_user }}'
  - group: '{{ gunicorn_user }}'
  - clean: True
  - force: True
  - dir_mode: 755

manage-wrapper:
  file.managed:
    - name: {{ manage_wrapper_path }}
    - source: salt://manage-wrapper
    - user: {{ gunicorn_user }}
    - group: {{ gunicorn_user }}
    - mode: '755'
    - template: jinja
    - require:
      - virtualenv: create-virtualenv
      - sls: db
    - context:
      settings_module: {{ settings_module }}
      app_path: {{ app_path }}
      venv_path: {{ venv_path }}
      db_url: {{ db_url }}

collectstatic:
  cmd.run:
  - name: '{{ manage_wrapper_path }} collectstatic --noinput --verbosity 3'
  - cwd: {{ base_path }}
  - user: '{{ gunicorn_user }}'
  - require:
    - virtualenv: create-virtualenv
    - file: static-dir

migrate:
  cmd.run:
  - name: '{{ venv_path }}/bin/python3.5 {{ app_path }}/manage.py migrate --verbosity 3'
  - name: '{{ manage_wrapper_path }} migrate --verbosity 3'
  - cwd: {{ base_path }}
  - user: '{{ gunicorn_user }}'
  - require:
    - virtualenv: create-virtualenv
    - sls: db

{% set email_fequency='31' %}
email-comments:
  cron.present:
  - name: "{{ manage_wrapper_path }} send_mail {{ email_fequency }}"
  - minute: "0,30"
  - user: {{ gunicorn_user }}
  - require:
    - file: manage-wrapper

cron-running:
  service.running:
  - name: cron
  - watch:
    - cron: email-comments
  - require:
    - cron: email-comments
