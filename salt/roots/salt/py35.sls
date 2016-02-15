add-py35-apt-repository:
  pkgrepo.managed:
    - ppa: fkrull/deadsnakes
    - refresh_db: True
    - require_in:
      - pkg: install-py35

install-py35:
  pkg.installed:
  - name: python3.5
  - refresh: True

install-py-dev:
  pkg.installed:
  - name: python3.5-dev
  - require:
    - pkg: install-py35

install-libpg:
  pkg.installed:
  - name: libpq-dev
