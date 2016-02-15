{% set base_path='/home/vagrant' %}
{% set blog_path=base_path+'/blog' %}
{% set app_path=base_path+'/restcomments' %}

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

clone-comments-server:
  git.latest:
    - name: git@github.com:amfarrell/restcomments.git
    - identity: /vagrant/id_rsa
    - target: {{ app_path }}
    - require:
      - pkg: install-git
