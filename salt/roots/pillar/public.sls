setting: dev
domain: amfarrell.com
django_apps:
  restcomments:
    git_repo: git@github.com:amfarrell/restcomments.git
    app_port: 8081
    settings_module: restcomments.settings
    env_vars:
      - GITHUB_CLIENT_SECRET
      - SENDGRID_API_KEY
      - SECRET_KEY
    paths:
      - /comments/
      - /authenticate/
  pickhost:
    git_repo: git@github.com:amfarrell/pickhost.git
    app_port: 8080
    settings_module: pickhost.settings
    env_vars:
      - CITYMAPPER_API_KEY
      - SECRET_KEY
    paths:
      - /pickhost/
    project_path: 'src/pickhost'
