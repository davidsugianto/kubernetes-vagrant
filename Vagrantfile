# -*- mode: ruby -*-
# vi: set ft=ruby :

NETWORK_BASE = "172.28.128"
INTEGRATION_START_SEGMENT = 101
NODE_COUNT = 2

VAGRANT_BOX = 'ubuntu/xenial64'

Vagrant.configure("2") do |config|
  config.vm.box = VAGRANT_BOX
  config.vm.box_check_update = false
  config.ssh.insert_key = false

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus   = "1"
  end

  config.vm.provision "file", source: "~/Research/OS/vm/kubernetes-vagrant/kubernetes-ssh/authorized_keys", destination: "/home/vagrant/.ssh/authorized_keys"
  config.vm.provision "shell", inline: <<-SHELL
    sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
    sudo systemctl restart sshd.service
    echo "finished ssh restarted"
  SHELL

  # Define master
  config.vm.define "master", primary: true do |master|
    master.vm.network "private_network", ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT}"
    master.vm.network "forwarded_port", guest: 8001, host: 8001
    master.vm.hostname = "kubernetes-master"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
    end
    master.vm.provision "file", source: "~/Research/OS/vm/kubernetes-vagrant/kubernetes-ssh/master.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
    master.vm.provision "file", source: "~/Research/OS/vm/kubernetes-vagrant/kubernetes-ssh/master", destination: "/home/vagrant/.ssh/id_rsa"
    master.vm.provision "shell", inline: <<-SHELL
      chmod 400 /home/vagrant/.ssh/id_rsa
      chmod 400 /home/vagrant/.ssh/id_rsa.pub
      echo "finished ssh key permission"
    SHELL
    master.vm.provision "ansible" do |ansible|
      ansible.playbook = "kubernetes-setup/master-playbook.yml"
      ansible.extra_vars = {
        node_ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT}"
      }
    end
  end

  # Define nodes
  (1..NODE_COUNT).each do |i|
    config.vm.define "node0#{i}" do |node|
      node.vm.network "private_network", ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT + i}"
      node.vm.hostname = "kubernetes-node0#{i}"
      node.vm.provision "file", source: "~/Research/OS/vm/kubernetes-vagrant/kubernetes-ssh/node.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
      node.vm.provision "file", source: "~/Research/OS/vm/kubernetes-vagrant/kubernetes-ssh/node", destination: "/home/vagrant/.ssh/id_rsa"
      node.vm.provision "shell", inline: <<-SHELL
        chmod 400 /home/vagrant/.ssh/id_rsa
        chmod 400 /home/vagrant/.ssh/id_rsa.pub
        echo "finished ssh key permission"
      SHELL
      node.vm.provision "shell", inline: <<-SHELL
        sudo --user=vagrant scp -o StrictHostKeyChecking=no vagrant@172.28.128.101:/home/vagrant/kubeadm_join_cmd.sh /home/vagrant/kubeadm_join_cmd.sh
      SHELL
      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "kubernetes-setup/node-playbook.yml"
        ansible.extra_vars = {
          node_ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT + i}"
        }
      end  
    end
  end
end
