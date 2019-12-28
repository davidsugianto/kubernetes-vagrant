#!/bin/bash

echo "install prerequites"

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo apt-get remove -y kubelet kubeadm kubectl kubernetes-cni
sudo apt-get autoremove -y
sudo systemctl daemon-reload
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" 
sudo apt-get update -y 
sudo apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 19.03.5 | head -1 | awk '{print $3}')
sudo usermod -aG docker vagrant
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo systemctl enable kubelet && sudo systemctl start kubelet
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl enable docker && sudo systemctl start docker

docker info | grep overlay
docker info | grep systemd

echo "completed install prerequites"
