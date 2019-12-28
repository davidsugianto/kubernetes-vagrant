#!/bin/bash

MASTER_IP="$1"
POD_NW_CIDR="$2"
KUBE_TOKEN="$3"

echo "master configure started"

kubeadm reset
kubeadm init --apiserver-advertise-address=#{MASTER_IP} --pod-network-cidr=#{POD_NW_CIDR} --token #{KUBE_TOKEN} --token-ttl 0

mkdir -p $HOME/.kube
sudo cp -Rf /etc/kubernetes/admin.conf /$HOME/.kube/config
sudo chown ${id -u}:${id -g} $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "master configure completed"
