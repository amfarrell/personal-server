{% set database = 'raffle' %}
{% set pg_user = database %}
{% set pg_version = '9.3' %}

install-postgres:
  pkg.installed:
  - name: postgresql-{{ pg_version }}

hba-conf:
  file.managed:
    - name: /etc/postgresql/{{ pg_version }}/main/pg_hba.conf
    - source: salt://pg_hba.conf
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - pkg: install-postgres

postgres-running:
  service.running:
    - name: postgresql
    - enable: True
    - watch:
      - file: hba-conf

create-pg-user:
  postgres_user.present:
  - name: {{ pg_user }}
  - createdb: True
  - encrypted: False
  - superuser: False
  - password: {{ pillar['database-password'] }}
  - login: True
  - db_user: postgres
  - require:
    - file: hba-conf

create-database:
  postgres_database.present:
  - name: {{ database }}
  - encoding: 'UTF8'
  - owner: {{ pg_user }}
  - db_user: postgres
  - require:
    - postgres_user: create-pg-user
