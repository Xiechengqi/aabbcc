hostnamectl set-hostname ${minerId} && hostnamectl --pretty && hostnamectl --static && hostnamectl --transient
yes | kubeadm reset
kubeadm join 10.19.5.20:6443 --token d6dbql.16w5gros799914to --discovery-token-ca-cert-hash sha256:7391f5afc8d209d685f1142cc43fab93934834ddd71ac37cff12f85097ccc061
