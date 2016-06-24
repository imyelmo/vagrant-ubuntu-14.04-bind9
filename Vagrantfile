# -*- mode: ruby -*-
# vi: set ft=ruby :

# get version
if File.file?('../version')
  version_file = open('../version', 'r')
  $env_version = (version_file.readline).strip
  version_file.close
else
  $env_version = "0.0.1-alpha"
end

# To enable rsync folder share change to false
# $ip_server="172.19.8.111"
$vb_mem = "4096"
$vb_gui = false

$descriptionString="
vagrant-ubuntu-14.04-bind9 v#{$env_version} based on Ubuntu 14.04
base image cxtlabs/vagrant-ubuntu-14.04
build for VirtualBox 5.0.22
- bind9
"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "cxtlabs/vagrant-ubuntu-14.04"
  config.vm.box_check_update=true

  # instance for bind9
  config.vm.define "ubuntu-14.04-bind9" do |ubuntubind9|
    hostname = "ubuntu-14-04-bind9"
    ubuntubind9.vm.provider "virtualbox" do |vb|
          vb.name = "vagrant-#{hostname}"
          vb.customize ["modifyvm", :id, "--description", $descriptionString]
          vb.memory = $vb_mem
          vb.gui = $vb_gui
    end

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    ubuntubind9.vm.network "forwarded_port", guest: 53, host: 53
    ubuntubind9.vm.network "private_network", ip: "192.168.96.111", virtualbox__intnet: "test_net"
    ubuntubind9.vm.hostname = hostname

    # Define ssh configuration
    ubuntubind9.ssh.insert_key = false

    # tty fix provisioner
    ubuntubind9.vm.provision "fix-no-tty", type: "shell" do |ttyfix|
        ttyfix.privileged = false
        ttyfix.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    end

    # Enable provisioning with a shell script. Additional provisioners such as
    # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
    # documentation for more information about their specific syntax and use.
    ubuntubind9.vm.provision "shell" do |cmd|
      cmd.path = "./provision_scripts/vagrant_provision.sh"
    end

  end

end
