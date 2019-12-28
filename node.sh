#!/bin/bash

KUBE_TOKEN="$1"
MASTER_IP="$2"

echo "node configure started"

kubeadm reset
kubeadm join --token #{KUBE_TOKEN} #{MASTER_IP}:6443

echo "node configure completed"
