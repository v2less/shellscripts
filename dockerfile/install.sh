#!/bin/bash
#curl -fsSL https://get.docker.com | sudo bash -s docker --mirror Aliyun

# Docker Compose
sudo proxychains wget --output-document=/usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/$(proxychains wget --quiet --output-document=- https://api.github.com/repos/docker/compose/releases/latest | grep --perl-regexp --only-matching '"tag_name": "\K.*?(?=")')/run.sh"
sudo chmod +x /usr/local/bin/docker-compose
sudo proxychains wget --output-document=/etc/bash_completion.d/docker-compose "https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose"
printf '\nDocker Compose installed successfully\n\n'

