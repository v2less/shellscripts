## install docker
```bash
bash <(wget -q -O - https://get.docker.com) --mirror Aliyun
```

## install docker-compose
```bash
curl -L https://get.daocloud.io/docker/compose/releases/download/v2.12.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## build
```bash
docker-compose build
```

## up
```bash
docker-compose up -d
```

## client
```bash
rsync -avz host.com::share /path/to/folder
#or
rsync -avz --delete rsync://rsync@ip_addr/share/sdk ftp/
```
