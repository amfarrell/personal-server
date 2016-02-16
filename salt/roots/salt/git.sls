{% set base_path='/home/vagrant' %}
{% set blog_path=base_path+'/blog' %}

install-git:
  pkg.installed:
  - name: git

clone-personal-site:
  git.latest:
    - name: git@github.com:amfarrell/blog-clean.git
    - identity: /vagrant/id_rsa
    - target: {{ blog_path }}
    - require:
      - pkg: install-git

{% for app_name, data in pillar['django_apps'].items() %}
clone-{{ app_name }}:
  git.latest:
    - name: {{ data['git_repo']}}
    - identity: /vagrant/id_rsa
    - target: {{ base_path }}/{{ app_name }}
    - require:
      - pkg: install-git
{% endfor %}
