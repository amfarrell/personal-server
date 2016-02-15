
startup_script = "
  add-apt-repository ppa:saltstack/salt
  apt-get update -y
  apt-get install salt-minion -y
  cp -rf /vagrant/salt/minion /etc/salt/minion
  service salt-minion restart
  rm -rf /vagrant/venv
  salt-call state.highstate
"

Vagrant.configure('2') do |config|
  # Alternatively, use provider.name below to set the Droplet name. config.vm.hostname takes precedence.
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "ubuntu/trusty64"

  config.vm.define "www.amfarrell.com", primary: true do |machine|

    machine.vm.provider :virtualbox do |provider, override|
      override.vm.network :forwarded_port, guest: 80, host: 8019
      override.vm.network :forwarded_port, guest: 443, host: 8049
      override.vm.network :forwarded_port, guest: 8080, host: 8189
      startup_script += '
        echo "\n"
        echo "Visit http://0.0.0.0:8019/admin"
        echo "\n"
      '
    end
    
    machine.vm.provider :digital_ocean do |provider, override|
      begin
        file = File.open('./digital_ocean_data.yaml', 'r')
        data = YAML.load(file.read())
        digital_ocean_token = data['token']
        ssh_key_path = data['ssh_key_path']
      rescue SystemCallError
        $stderr.print("To use the digital_ocean provider,\n
                     Create a file named 'digital_ocean_data.yaml' in the same directory as Vagrantfile.\n
                     Put your digital ocean API token and the path to your ssh key in it.\n")
      end

      override.vm.hostname = 'www.amfarrell.com'
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      override.ssh.private_key_path = ssh_key_path

      provider.token = digital_ocean_token
      provider.name = 'amfarrell_backup2'
      provider.image = 'ubuntu-14-04-x64'
      provider.region = 'nyc1'
      provider.size = '512mb'

      startup_script += '
        echo "\n"
        echo "Visit http://$(curl http://169.254.169.254/latest/meta-data/public-ipv4 2> /dev/null )/admin"
        echo "\n"
      '
    end

    machine.vm.provision :shell, inline: startup_script
  end
end
