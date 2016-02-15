
startup_script = "
  add-apt-repository ppa:saltstack/salt
  apt-get update -y
  apt-get install salt-minion -y
  cp -rf /vagrant/salt/minion /etc/salt/minion
  service salt-minion restart
  rm -rf /vagrant/venv
  salt-call state.highstate
"

if ENV.has_key?('DO_TOKEN') && ENV.has_key?('RSA_PRIVATE_KEY_PATH')

    Vagrant.configure('2') do |config|
      config.vm.hostname = 'www.amfarrell.com'
      config.vm.box = 'digital_ocean'
      config.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      # Alternatively, use provider.name below to set the Droplet name. config.vm.hostname takes precedence.

      config.vm.define "www.amfarrell.com", primary: true do |machine|
        machine.vm.provider :digital_ocean do |provider, override|
            override.ssh.private_key_path = ENV.fetch('RSA_PRIVATE_KEY_PATH')
            provider.name = 'amfarrell_backup'
            override.vm.box = 'digital_ocean'
            override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
            provider.token = ENV.fetch('DO_TOKEN')
            provider.image = 'ubuntu-14-04-x64'
            provider.region = 'lon1'
            provider.size = '4gb'
          end

          startup_script += '
            echo "\n"
            echo "Visit http://$(curl http://169.254.169.254/latest/meta-data/public-ipv4 2> /dev/null )/admin"
            echo "\n"
          '

          machine.vm.provision :shell, inline: startup_script
      end
    end

else
  Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.box_url = "ubuntu/trusty64"

    config.vm.network :forwarded_port, guest: 80, host: 8017
    config.vm.network :forwarded_port, guest: 443, host: 8043
    config.vm.network :forwarded_port, guest: 8080, host: 8187

    startup_script += '
      echo "\n"
      echo "Visit http://0.0.0.0:8017/admin"
      echo "\n"
    '
    config.vm.provision :shell, inline: startup_script
  end
end
