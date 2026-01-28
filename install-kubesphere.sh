#!/bin/bash
set -e

# Variabel
BASE_URL="https://github.com/config-devops/Kubesphare-v4.1.3/releases/download/4.1.3"   # nanti bisa kamu ganti ke GitHub Releases / MinIO
VERSION="v4.1.3"
WORKDIR="/tmp/kubesphere-installer"
HELM_TGZ="ks-core-1.1.4.tgz"

mkdir -p $WORKDIR
cd $WORKDIR

echo "[INFO] Downloading KubeSphere images..."
wget -q $BASE_URL/ks-console-$VERSION.tar -O ks-console.tar
wget -q $BASE_URL/ks-apiserver-$VERSION.tar -O ks-apiserver.tar
wget -q $BASE_URL/ks-controller-manager-$VERSION.tar -O ks-controller-manager.tar
wget -q $BASE_URL/extensions-museum-$VERSION.tar -O extensions-museum.tar

echo "[INFO] Importing images into containerd..."
sudo ctr -n k8s.io images import ks-console.tar
sudo ctr -n k8s.io images import ks-apiserver.tar
sudo ctr -n k8s.io images import ks-controller-manager.tar
sudo ctr -n k8s.io images import extensions-museum.tar

echo "[INFO] Downloading Helm chart..."
wget -q $BASE_URL/$HELM_TGZ

echo "[INFO] Installing KubeSphere via Helm..."
helm upgrade --install ks-core $HELM_TGZ \
  -n kubesphere-system --create-namespace

echo "[SUCCESS] KubeSphere $VERSION installation completed!"
