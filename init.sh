CNI_VERSION="v0.8.2"
CRICTL_VERSION="v1.16.0"

sudo mkdir -p /opt/cni/bin
sudo mkdir -p /opt/bin

sudo curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | 
    sudo tar -C /opt/cni/bin -xz

sudo curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | 
    sudo tar -C /opt/bin -xz

sudo kubeadm init --config config.yaml

mkdir -p $HOME/.kube
sudo cp -i -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

#watch -n 1 kubectl get po --all-namespaces
