#cloud-config

ssh_authorized_keys:
  - ${authorized_key}

apt:
  sources:
    docker:
      source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
      keyid: "9DC858229FC7DD38854AE2D88D81803C0EBFCD88" 

repo_update: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common
  - docker-ce
  - docker-ce-cli
  - containerd.io

package_update: true

runcmd:
  - "iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
  - "docker run --rm -d -p ${app_port}:${app_port} cicdguy/goodrx-api:latest"

final_message: "The system is finally up, after $UPTIME seconds"
