apt-get install -y apt-transport-https wget curl zsh git htop tree numactl
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
wget https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list
mv nvidia-docker.list /etc/apt/sources.list.d/nvidia-docker.list
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
apt-get update -y
apt-get install cpufrequtils -y
apt-get install ocl-icd-opencl-dev ocl-icd-libopencl1 jq libhwloc-dev -y
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
apt-get install -y -q docker-ce docker-ce-cli containerd.io glusterfs-client kubelet kubectl kubeadm nvidia-docker2 clinfo -y
apt-get install clinfo vim ca-certificates tree htop telnet redis-tools zsh wget curl fuse libfuse-dev openjdk-8-jdk vim clinfo kmod -y
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.2.2/local_installers/cuda-repo-ubuntu2004-11-2-local_11.2.2-460.32.03-1_amd64.deb
dpkg -i cuda-repo-ubuntu2004-11-2-local_11.2.2-460.32.03-1_amd64.deb
apt-key add /var/cuda-repo-ubuntu2004-11-2-local/7fa2af80.pub
apt update -y
apt-get -y install cuda net-tools clinfo
apt-get install -y -q apt-transport-https wget curl zsh git htop tree numactl -y
nvidia-smi -pm 1
apt-mark hold nvidia-utils-460 nvidia-compute-utils-460 linux-modules-nvidia-460-generic-hwe-20.04 nvidia-docker2 kubelet kubectl kubeadm
sed -i /GRUB_CMDLINE_LINUX=/s#\"\"#\"default_hugepagesz=1G\ hugepagesz=1G\ hugepages=2\"# /etc/default/grub
update-grub
sed -i "s/ExecStart.*/& --default-ulimit memlock=-1:-1/" /lib/systemd/system/docker.service
swapoff -a
systemctl daemon-reload
systemctl restart docker && systemctl restart kubelet
apt install python3-toml python3-aiohttp python3-pip -y
# sed -i /preserve_hostname:/s#false#true# /etc/cloud/cloud.cfg

uuid=`mdadm --detail --scan | grep -o "UUID=[^ ]*" | cut -d= -f2`
echo "/dev/disk/by-id/md-uuid-$uuid /scratch ext4 defaults 0 0"
echo "/dev/disk/by-id/md-uuid-$uuid /scratch ext4 defaults 0 0" >> /etc/fstab
mkdir /scratch
mount /dev/md0 /scratch
cd /scratch
mkdir calibnet mainnet
