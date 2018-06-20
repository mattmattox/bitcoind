#cloud-config

runcmd:
  - apt-get update
  - apt-get install -y python-setuptools python-pip
  - pip install ansible
  - git clone https://github.com/mazamats/bitcoind.git /etc/ansible
  - ansible-playbook -c local -i "localhost," /etc/ansible/playbook.yml
