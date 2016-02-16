{% from 'git.sls' import base_path %}
{% from 'git.sls' import blog_path %}
{% from 'venv.sls' import blog_venv_path %}

{#
Do not try to run webpack as part of the build process.
It is just too finnicky.

install-node:
  pkg.installed:
    - name: node

install-npm:
  pkg.installed:
    - name: npm

js-deps:
  npm.bootstrap:
    - name: {{ blog_path }}
    - require:
      - pkg: install-node
      - pkg: install-npm

install-webpack:
  npm.installed:
    - name: webpack
    - require:
      - npm: js-deps

generate-commentsjs:
  cmd.run:
  - name: webpack
  - cwd: {{ blog_path }}
  - require:
    - npm: install-webpack
#}

mkdocs:
  cmd.run:
  - name: '{{ blog_venv_path }}/bin/mkdocs build --clean'
  - cwd: {{ blog_path }}
  - env:
    - 'LC_ALL': 'C.UTF-8'
    - 'LANG': 'C.UTF-8'
  - require:
    - virtualenv: create-virtualenv-blog
    - sls: git
