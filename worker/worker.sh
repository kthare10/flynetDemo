#yum update
yum install -y yum-utils device-mapper-persistent-data lvm2 gcc zlib-devel openssl-devel firewalld gcc-c++
#yum remove python3

#add user
adduser -d /home/worker -m worker
echo 'worker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#install docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker worker
systemctl enable docker
systemctl restart docker

#install cri-o (Docker may be going out of support for Kubernetes in late 2021
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_7/devel:kubic:libcontainers:stable.repo
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:1.17.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:1.17/CentOS_7/devel:kubic:libcontainers:stable:cri-o:1.17.repo
yum install -y cri-o

#install cJSON (prereq for mosquitto)
cd /usr/local
git clone https://github.com/DaveGamble/cJSON.git
cd cJSON
make && make install

#install mosquitto
cd /usr/local
mkdir mosquitto
cd mosquitto
wget https://mosquitto.org/files/source/mosquitto-2.0.9.tar.gz
tar -xzf mosquitto-2.0.9.tar.gz
cd mosquitto-2.0.9
make && make install

#install keadm
/bin/su - worker -c "mkdir bin"
/bin/su - worker -c "/usr/bin/wget https://github.com/kubeedge/kubeedge/releases/download/v1.6.0/keadm-v1.6.0-linux-amd64.tar.gz; tar -xzf keadm-v1.6.0-linux-amd64.tar.gz; ln -s /home/worker/keadm-v1.6.0-linux-amd64/keadm/keadm /home/worker/bin/"
##replace line below with token, generated with this command on core node:
##/bin/su - core -c "sudo /home/core/bin/keadm gettoken --kube-config=/home/core/.kube/config"
/bin/su - worker -c "sudo /home/worker/bin/keadm join --cloudcore-ipport=192.168.125.10:10000 --token=REPLACE_WITH_TOKEN"

#set aliases
echo 192.168.125.10 master.flynetdemo.edu master-node node0 master0 submit0 core0 core >> /etc/hosts
echo 192.168.125.11 worker1.flynetdemo.edu worker-node1 node1 worker1 >> /etc/hosts
echo 192.168.125.12 worker2.flynetdemo.edu worker-node2 node2 worker2 >> /etc/hosts

#open firewall holes for kubernetes and rabbitmq
#systemctl enable firewalld
#systemctl start firewalld
#firewall-cmd --permanent --add-port=2379-2380/tcp
#firewall-cmd --permanent --add-port=4369/tcp
#firewall-cmd --permanent --add-port=5671-5672/tcp
#firewall-cmd --permanent --add-port=6443/tcp
#firewall-cmd --permanent --add-port=8883/tcp
#firewall-cmd --permanent --add-port=10250/tcp
#firewall-cmd --permanent --add-port=10251/tcp
#firewall-cmd --permanent --add-port=10252/tcp
#firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --permanent --add-port=15672/tcp
#firewall-cmd --permanent --add-port=25672/tcp
#firewall-cmd --permanent --add-port=61613-61614/tcp
#firewall-cmd --reload

#disable selinux
setenforce permissive
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config



